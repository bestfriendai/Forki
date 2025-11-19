-- Create a function to automatically create a user profile in public.users
-- when a new user is created in auth.users
-- This ensures the row is always created, regardless of RLS policies

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a new row into public.users with the user's ID and email
    -- Extract name from user_metadata if available
    -- Only specify fields we have values for - let defaults handle the rest
    INSERT INTO public.users (id, email, name)
    VALUES (
        NEW.id,
        NEW.email,
        NEW.raw_user_meta_data->>'name'
    )
    ON CONFLICT (id) DO NOTHING; -- Don't error if row already exists
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if it exists (to allow re-running this migration)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger on auth.users to automatically create profile
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

