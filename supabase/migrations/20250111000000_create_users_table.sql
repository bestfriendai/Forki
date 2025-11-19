-- Create users table to store user profile data
-- This table extends Supabase Auth users with additional profile information

CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    email TEXT,
    age TEXT,
    gender TEXT,
    height TEXT,
    weight TEXT,
    goal TEXT,
    goal_duration INTEGER DEFAULT 0,
    food_preferences TEXT[] DEFAULT '{}',
    notifications BOOLEAN DEFAULT false,
    selected_character TEXT DEFAULT 'Forki',
    persona_id INTEGER DEFAULT 13,
    recommended_calories INTEGER DEFAULT 2000,
    eating_pattern TEXT,
    bmi DOUBLE PRECISION DEFAULT 0,
    body_type TEXT,
    metabolism TEXT,
    macro_protein INTEGER,
    macro_carbs INTEGER,
    macro_fats INTEGER,
    macro_fiber INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to read their own data
CREATE POLICY "Users can read own data"
    ON public.users
    FOR SELECT
    USING (auth.uid() = id);

-- Create policy to allow users to insert their own data
CREATE POLICY "Users can insert own data"
    ON public.users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Create policy to allow users to update their own data
CREATE POLICY "Users can update own data"
    ON public.users
    FOR UPDATE
    USING (auth.uid() = id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update updated_at on row update
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

