// Score Aggregation Cron Job
// Runs every 10 minutes to process dirty_users table
// Recalculates aggregate scores for users and their managers (hierarchical rollup)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

interface DirtyUser {
  user_id: string;
  dirtied_at: string;
}

serve(async (req) => {
  try {
    // Initialize Supabase client with service role (bypasses RLS)
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    console.log("Starting score aggregation cron job");

    // Get all current periods (one per period_type)
    const { data: currentPeriods, error: periodError } = await supabase
      .from("scoring_periods")
      .select("id, period_type")
      .eq("is_current", true);

    if (periodError || !currentPeriods || currentPeriods.length === 0) {
      console.error("No current scoring periods found:", periodError);
      return new Response(
        JSON.stringify({ error: "No current scoring period" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    // Find display period: shortest granularity (WEEKLY < MONTHLY < QUARTERLY < YEARLY)
    const priorityOrder: Record<string, number> = {
      WEEKLY: 1,
      MONTHLY: 2,
      QUARTERLY: 3,
      YEARLY: 4,
    };
    currentPeriods.sort(
      (a, b) =>
        (priorityOrder[a.period_type] ?? 5) -
        (priorityOrder[b.period_type] ?? 5)
    );
    const periodId = currentPeriods[0].id;
    console.log(
      `Found ${currentPeriods.length} current period(s). Display period: ${periodId} (${currentPeriods[0].period_type})`
    );

    // Get all dirty users (no limit - process all)
    const { data: dirtyUsers, error: dirtyError } = await supabase
      .from("dirty_users")
      .select("user_id, dirtied_at")
      .order("dirtied_at", { ascending: true }); // Oldest first (FIFO)

    if (dirtyError) {
      console.error("Error fetching dirty users:", dirtyError);
      return new Response(
        JSON.stringify({ error: "Failed to fetch dirty users" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    if (!dirtyUsers || dirtyUsers.length === 0) {
      console.log("No dirty users to process");
      return new Response(
        JSON.stringify({ message: "No dirty users", processed: 0 }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    console.log(`Processing ${dirtyUsers.length} dirty users`);

    let successCount = 0;
    let errorCount = 0;

    // Process each dirty user
    for (const dirtyUser of dirtyUsers) {
      try {
        // Call recalculate_aggregate function
        const { error: recalcError } = await supabase.rpc(
          "recalculate_aggregate",
          {
            p_user_id: dirtyUser.user_id,
            p_period_id: periodId,
          }
        );

        if (recalcError) {
          console.error(
            `Failed to recalculate for user ${dirtyUser.user_id}:`,
            recalcError
          );

          // Log error to system_errors table
          await supabase.from("system_errors").insert({
            error_type: "CRON_USER_FAILED",
            entity_id: dirtyUser.user_id,
            error_message: `Aggregate recalculation failed: ${recalcError.message}`,
            created_at: new Date().toISOString(),
          });

          errorCount++;
          // Continue with next user (don't fail entire batch)
          continue;
        }

        // Remove from dirty_users after successful processing
        const { error: deleteError } = await supabase
          .from("dirty_users")
          .delete()
          .eq("user_id", dirtyUser.user_id);

        if (deleteError) {
          console.error(
            `Failed to remove dirty user ${dirtyUser.user_id}:`,
            deleteError
          );
          // Not critical - will be reprocessed next run
        }

        successCount++;
        console.log(`✓ Processed user ${dirtyUser.user_id}`);
      } catch (error) {
        console.error(
          `Exception processing user ${dirtyUser.user_id}:`,
          error
        );
        errorCount++;

        // Log to system_errors
        try {
          await supabase.from("system_errors").insert({
            error_type: "CRON_EXCEPTION",
            entity_id: dirtyUser.user_id,
            error_message: `Unexpected exception: ${
              error instanceof Error ? error.message : String(error)
            }`,
            created_at: new Date().toISOString(),
          });
        } catch (logError) {
          console.error("Failed to log error:", logError);
        }
      }
    }

    // Step 1: Deactivate expired measures (BEFORE ranking, per pitfall #6 in research)
    // This ensures consistent scores before ranking computation
    let measuresDeactivated = 0;
    console.log("Checking for expired measures...");
    const { data: deactivated, error: deactivateError } = await supabase.rpc(
      "deactivate_expired_measures"
    );
    if (deactivateError) {
      console.error("Measure deactivation failed:", deactivateError);
      // Non-fatal -- continue with ranking
    } else if (deactivated > 0) {
      measuresDeactivated = deactivated;
      console.log(`Deactivated ${deactivated} expired measures`);
    }

    // Step 2: Calculate rankings (AFTER all dirty users processed, per pitfall #1)
    // Only if at least one user was successfully recalculated
    let rankingUpdated = false;
    if (successCount > 0) {
      console.log("Calculating rankings...");
      const { error: rankError } = await supabase.rpc(
        "calculate_rankings",
        { p_period_id: periodId }
      );
      if (rankError) {
        console.error("Ranking calculation failed:", rankError);
        // Log to system_errors but don't fail the entire response
        try {
          await supabase.from("system_errors").insert({
            error_type: "CRON_RANKING_FAILED",
            error_message: `Ranking calculation failed: ${rankError.message}`,
            created_at: new Date().toISOString(),
          });
        } catch (logError) {
          console.error("Failed to log ranking error:", logError);
        }
      } else {
        rankingUpdated = true;
        console.log("Rankings updated for period:", periodId);
      }
    }

    const summary = {
      message: "Score aggregation complete",
      total: dirtyUsers.length,
      success: successCount,
      errors: errorCount,
      periodId,
      rankingUpdated,
      measuresDeactivated,
    };

    console.log("Cron job summary:", summary);

    return new Response(JSON.stringify(summary), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Cron job failed:", error);
    return new Response(
      JSON.stringify({
        error: "Cron job failed",
        message: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
