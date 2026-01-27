# Supabase Edge Functions

This directory contains Edge Functions for admin operations that require the service_role key.

## Functions

### 1. admin-create-user

Creates a new user with Supabase Auth and inserts profile data into the users table.

**Endpoint:** `<SUPABASE_URL>/functions/v1/admin-create-user`

**Method:** POST

**Authentication:** Requires Bearer token (user must be ADMIN or SUPERADMIN)

**Request Body:**
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "nip": "123456",
  "role": "RM",
  "phone": "081234567890",
  "parentId": "optional-uuid",
  "branchId": "optional-uuid",
  "regionalOfficeId": "optional-uuid"
}
```

**Response (Success - 200):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "nip": "123456",
    "role": "RM",
    ...
  },
  "temporaryPassword": "Generated12!"
}
```

**Error Responses:**
- 401: Missing or invalid authorization
- 403: Insufficient permissions (not admin)
- 400: Validation error or user creation failed

---

### 2. admin-reset-password

Resets a user's password and generates a temporary password.

**Endpoint:** `<SUPABASE_URL>/functions/v1/admin-reset-password`

**Method:** POST

**Authentication:** Requires Bearer token (user must be ADMIN or SUPERADMIN)

**Request Body:**
```json
{
  "userId": "user-uuid"
}
```

**Response (Success - 200):**
```json
{
  "temporaryPassword": "NewPass123!"
}
```

**Error Responses:**
- 401: Missing or invalid authorization
- 403: Insufficient permissions (not admin)
- 400: Invalid userId or password reset failed

---

## Deployment

### Prerequisites

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link to your project:
   ```bash
   supabase link --project-ref <your-project-ref>
   ```

### Deploy Functions

Deploy all functions:
```bash
supabase functions deploy
```

Deploy a specific function:
```bash
supabase functions deploy admin-create-user
supabase functions deploy admin-reset-password
```

### Set Environment Variables

The functions require the following environment variables to be set in your Supabase project:

- `SUPABASE_URL` - Automatically provided by Supabase
- `SUPABASE_SERVICE_ROLE_KEY` - Automatically provided by Supabase

These are set automatically when deploying to Supabase Cloud or self-hosted instances.

### Testing Locally

1. Start the local Supabase environment:
   ```bash
   supabase start
   ```

2. Serve functions locally:
   ```bash
   supabase functions serve
   ```

3. Test with curl:
   ```bash
   curl -i --location --request POST 'http://localhost:54321/functions/v1/admin-create-user' \
     --header 'Authorization: Bearer YOUR_JWT_TOKEN' \
     --header 'Content-Type: application/json' \
     --data '{"email":"test@example.com","name":"Test User","nip":"123","role":"RM"}'
   ```

## Security Notes

- These functions use the `service_role` key which bypasses Row Level Security (RLS)
- Authentication is handled by verifying the JWT token and checking user role
- Only users with ADMIN or SUPERADMIN role can execute these functions
- The service_role key never leaves the server (Edge Function runtime)
- All operations are logged to Supabase logs for audit purposes

## Self-Hosted Supabase

For self-hosted Supabase instances:

1. Ensure Deno is installed and Edge Functions are enabled
2. Deploy functions using the Supabase CLI as described above
3. Configure your `.env` file with the correct Supabase URL
4. The Flutter app will automatically use the configured URL to call functions

## Troubleshooting

### Function Returns 401 Unauthorized

- Verify the JWT token is valid and not expired
- Check that the Authorization header is formatted as: `Bearer <token>`
- Ensure the user exists in the users table

### Function Returns 403 Forbidden

- Verify the calling user has role 'ADMIN' or 'SUPERADMIN' in the users table
- Check Supabase logs for details: `supabase functions logs <function-name>`

### Function Returns 400 Bad Request

- Check the request body format matches the expected schema
- Review function logs for specific error messages
- Verify email format and uniqueness constraints

### Deployment Fails

- Ensure you're logged in: `supabase login`
- Verify project link: `supabase projects list`
- Check function syntax: TypeScript files must be valid
- Review deployment logs for detailed error messages
