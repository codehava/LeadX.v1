// Edge Function: admin-reset-password
// Resets a user's password and generates a temporary password
// Requires service_role key for admin operations

import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ResetPasswordRequest {
  userId: string
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
    // Service role can verify any user's JWT
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

    // Check if user is admin (use adminClient to bypass RLS)
    const { data: callerUser, error: callerError } = await adminClient
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single()

    if (callerError || !callerUser || (callerUser.role !== 'ADMIN' && callerUser.role !== 'SUPERADMIN')) {
      return new Response(
        JSON.stringify({ error: 'Insufficient permissions. Admin role required.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Parse request body
    const requestData: ResetPasswordRequest = await req.json()
    const { userId: targetUserId } = requestData

    if (!targetUserId) {
      return new Response(
        JSON.stringify({ error: 'Missing required field: userId' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Generate new temporary password
    const tempPassword = generatePassword()

    // Update user password using Admin API (use adminClient)
    const { error: updateError } = await adminClient.auth.admin.updateUserById(
      targetUserId,
      {
        password: tempPassword,
        user_metadata: {
          must_change_password: true,
        },
      }
    )

    if (updateError) {
      console.error('Failed to reset password:', updateError)
      return new Response(
        JSON.stringify({ error: `Failed to reset password: ${updateError.message}` }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Return success response with temporary password
    return new Response(
      JSON.stringify({
        temporaryPassword: tempPassword,
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

// Generate a random 12-character password
function generatePassword(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%'
  const length = 12
  let password = ''

  for (let i = 0; i < length; i++) {
    const randomIndex = Math.floor(Math.random() * chars.length)
    password += chars[randomIndex]
  }

  return password
}
