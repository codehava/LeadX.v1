// Edge Function: admin-delete-user
// Deletes a user by reassigning all business data to a new RM, soft-deleting
// the user record, and banning the auth account.
// Requires service_role key for admin operations.

import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface DeleteUserRequest {
  userId: string
  newRmId: string
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get Authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Extract the token from "Bearer <token>"
    const token = authHeader.replace('Bearer ', '')

    // Create admin client with service_role key
    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    // Verify user from JWT using admin client
    const { data: { user }, error: authError } = await adminClient.auth.getUser(token)

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: `Unauthorized: ${authError?.message || 'Invalid token'}` }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if caller is admin (use adminClient to bypass RLS)
    const { data: callerUser, error: callerError } = await adminClient
      .from('users')
      .select('id, role')
      .eq('id', user.id)
      .single()

    if (callerError || !callerUser || (callerUser.role !== 'ADMIN' && callerUser.role !== 'SUPERADMIN')) {
      return new Response(
        JSON.stringify({ error: 'Insufficient permissions. Admin role required.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Parse request body
    const requestData: DeleteUserRequest = await req.json()
    const { userId, newRmId } = requestData

    // Validate required fields
    if (!userId || !newRmId) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: userId, newRmId' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Self-delete guard
    if (userId === callerUser.id) {
      return new Response(
        JSON.stringify({ error: 'Cannot delete yourself' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate target user exists
    const { data: targetUser, error: targetError } = await adminClient
      .from('users')
      .select('id, parent_id')
      .eq('id', userId)
      .single()

    if (targetError || !targetUser) {
      return new Response(
        JSON.stringify({ error: 'Target user not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate new RM exists and is active
    const { data: newRm, error: newRmError } = await adminClient
      .from('users')
      .select('id, is_active')
      .eq('id', newRmId)
      .single()

    if (newRmError || !newRm) {
      return new Response(
        JSON.stringify({ error: 'New RM user not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!newRm.is_active) {
      return new Response(
        JSON.stringify({ error: 'New RM user is inactive' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Use a consistent timestamp for all updates
    const now = new Date().toISOString()

    // ============================================
    // REASSIGNMENT STEPS (order matters)
    // ============================================

    // Step 1: Get deleted user's parent_id for subordinate reassignment
    const deletedUserParentId = targetUser.parent_id

    // Step 2: Reassign subordinates to deleted user's parent
    const { error: subordinateError } = await adminClient
      .from('users')
      .update({ parent_id: deletedUserParentId, updated_at: now })
      .eq('parent_id', userId)

    if (subordinateError) {
      console.error('Failed to reassign subordinates:', subordinateError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 2: reassign subordinates', details: subordinateError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 3: Transfer customers (assigned_rm_id only, keep created_by)
    const { error: customerError } = await adminClient
      .from('customers')
      .update({ assigned_rm_id: newRmId, updated_at: now })
      .eq('assigned_rm_id', userId)
      .is('deleted_at', null)

    if (customerError) {
      console.error('Failed to transfer customers:', customerError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 3: transfer customers', details: customerError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 4: Transfer pipelines (assigned_rm_id and scored_to_user_id)
    const { error: pipelineAssignedError } = await adminClient
      .from('pipelines')
      .update({ assigned_rm_id: newRmId, scored_to_user_id: newRmId, updated_at: now })
      .eq('assigned_rm_id', userId)
      .is('deleted_at', null)

    if (pipelineAssignedError) {
      console.error('Failed to transfer pipelines (assigned):', pipelineAssignedError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 4a: transfer pipelines (assigned)', details: pipelineAssignedError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Transfer pipelines where only scored_to is the deleted user (not assigned_rm)
    const { error: pipelineScoredError } = await adminClient
      .from('pipelines')
      .update({ scored_to_user_id: newRmId, updated_at: now })
      .eq('scored_to_user_id', userId)
      .is('deleted_at', null)

    if (pipelineScoredError) {
      console.error('Failed to transfer pipelines (scored_to):', pipelineScoredError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 4b: transfer pipelines (scored_to)', details: pipelineScoredError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 5: Transfer activities (user_id only, keep created_by)
    const { error: activityError } = await adminClient
      .from('activities')
      .update({ user_id: newRmId, updated_at: now })
      .eq('user_id', userId)
      .is('deleted_at', null)

    if (activityError) {
      console.error('Failed to transfer activities:', activityError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 5: transfer activities', details: activityError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 6: Transfer HVCs (created_by is ownership field for HVCs)
    const { error: hvcError } = await adminClient
      .from('hvcs')
      .update({ created_by: newRmId, updated_at: now })
      .eq('created_by', userId)
      .is('deleted_at', null)

    if (hvcError) {
      console.error('Failed to transfer HVCs:', hvcError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 6: transfer HVCs', details: hvcError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 7: Transfer brokers (created_by is ownership field for brokers)
    const { error: brokerError } = await adminClient
      .from('brokers')
      .update({ created_by: newRmId, updated_at: now })
      .eq('created_by', userId)
      .is('deleted_at', null)

    if (brokerError) {
      console.error('Failed to transfer brokers:', brokerError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 7: transfer brokers', details: brokerError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 8: Transfer pipeline referrals (both referrer and receiver)
    const { error: referralReferrerError } = await adminClient
      .from('pipeline_referrals')
      .update({ referrer_rm_id: newRmId, updated_at: now })
      .eq('referrer_rm_id', userId)

    if (referralReferrerError) {
      console.error('Failed to transfer pipeline referrals (referrer):', referralReferrerError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 8a: transfer pipeline referrals (referrer)', details: referralReferrerError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { error: referralReceiverError } = await adminClient
      .from('pipeline_referrals')
      .update({ receiver_rm_id: newRmId, updated_at: now })
      .eq('receiver_rm_id', userId)

    if (referralReceiverError) {
      console.error('Failed to transfer pipeline referrals (receiver):', referralReceiverError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 8b: transfer pipeline referrals (receiver)', details: referralReceiverError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 9: Soft-delete user (set is_active=false, deleted_at=now)
    // This is intentionally LAST so partial failures leave the user active (admin can retry)
    const { error: softDeleteError } = await adminClient
      .from('users')
      .update({ is_active: false, deleted_at: now, updated_at: now })
      .eq('id', userId)

    if (softDeleteError) {
      console.error('Failed to soft-delete user:', softDeleteError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 9: soft-delete user', details: softDeleteError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 10: Ban auth account (10 years)
    const { error: banError } = await adminClient.auth.admin.updateUserById(
      userId,
      { ban_duration: '87600h' }
    )

    if (banError) {
      console.error('Failed to ban auth account:', banError)
      return new Response(
        JSON.stringify({ error: 'Failed at step 10: ban auth account', details: banError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Return success response
    return new Response(
      JSON.stringify({
        success: true,
        message: 'User deleted and data reassigned',
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )

  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'An unexpected error occurred' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
