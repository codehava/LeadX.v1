-- ============================================
-- Allow users to see all activities for customers they can access
-- ============================================
-- Problem: A manager (ROH/BM/BH) can see a customer via hierarchy,
-- but cannot see activities for that customer made by users outside
-- their direct hierarchy. This policy bridges that gap:
-- if you can access the customer, you can see its activities.
--
-- The calendar/activities page is unaffected because it filters
-- by user_id on the client side (watchUserActivities).
-- ============================================

CREATE POLICY "activities_select_via_customer" ON "public"."activities"
FOR SELECT USING (
  customer_id IS NOT NULL
  AND "public"."can_access_customer"(customer_id)
);
