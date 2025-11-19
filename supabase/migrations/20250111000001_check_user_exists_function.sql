-- Create a function to check if a user exists in auth.users
-- This function can be called via REST API to check for duplicate emails

CREATE OR REPLACE FUNCTION public.check_user_exists_in_auth(check_email TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Check if email exists in auth.users
    RETURN EXISTS (
        SELECT 1 
        FROM auth.users 
        WHERE email = check_email
    );
END;
$$;

-- Grant execute permission to anon role
GRANT EXECUTE ON FUNCTION public.check_user_exists_in_auth(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.check_user_exists_in_auth(TEXT) TO authenticated;

