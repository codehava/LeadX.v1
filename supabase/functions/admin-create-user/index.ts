// Edge Function: admin-create-user
// Creates a new user with Supabase Auth and inserts profile data
// Requires service_role key for admin operations

import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface CreateUserRequest {
  email: string
  name: string
  nip: string
  role: string
  phone?: string
  parentId?: string
  branchId?: string
  regionalOfficeId?: string
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
    const requestData: CreateUserRequest = await req.json()
    const { email, name, nip, role, phone, parentId, branchId, regionalOfficeId } = requestData

    // Validate required fields
    if (!email || !name || !nip || !role) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: email, name, nip, role' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Generate temporary password
    const tempPassword = generatePassword()

    // Create user in Supabase Auth (use adminClient for admin API)
    const { data: authData, error: createError } = await adminClient.auth.admin.createUser({
      email,
      password: tempPassword,
      email_confirm: true,
      user_metadata: {
        must_change_password: true,
      },
    })

    if (createError || !authData.user) {
      console.error('Failed to create auth user:', createError)
      return new Response(
        JSON.stringify({ error: `Failed to create auth user: ${createError?.message}` }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const newUserId = authData.user.id

    // Insert user profile into users table (use adminClient to bypass RLS)
    const { error: insertError } = await adminClient
      .from('users')
      .insert({
        id: newUserId,
        email,
        name,
        nip,
        role,
        phone,
        parent_id: parentId,
        branch_id: branchId,
        regional_office_id: regionalOfficeId,
        is_active: true,
      })

    if (insertError) {
      console.error('Failed to insert user profile:', insertError)

      // Rollback: delete the auth user
      await adminClient.auth.admin.deleteUser(newUserId)

      return new Response(
        JSON.stringify({ error: `Failed to create user profile: ${insertError.message}` }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Fetch the created user with all data
    const { data: createdUser, error: fetchError } = await adminClient
      .from('users')
      .select('*')
      .eq('id', newUserId)
      .single()

    if (fetchError) {
      console.error('Failed to fetch created user:', fetchError)
      return new Response(
        JSON.stringify({ error: 'User created but failed to fetch details' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Return success response
    return new Response(
      JSON.stringify({
        user: createdUser,
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
