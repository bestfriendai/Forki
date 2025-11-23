-- Create meal_logs table to store user meal logs
-- This table stores all logged meals with nutrition data

CREATE TABLE IF NOT EXISTS public.meal_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    food_id INTEGER NOT NULL,
    food_name TEXT NOT NULL,
    calories INTEGER NOT NULL DEFAULT 0,
    protein DOUBLE PRECISION NOT NULL DEFAULT 0,
    carbs DOUBLE PRECISION NOT NULL DEFAULT 0,
    fats DOUBLE PRECISION NOT NULL DEFAULT 0,
    category TEXT,
    portion DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    logged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.meal_logs ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to read their own meal logs
CREATE POLICY "Users can read own meal logs"
    ON public.meal_logs
    FOR SELECT
    USING (auth.uid() = user_id);

-- Create policy to allow users to insert their own meal logs
CREATE POLICY "Users can insert own meal logs"
    ON public.meal_logs
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to update their own meal logs
CREATE POLICY "Users can update own meal logs"
    ON public.meal_logs
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Create policy to allow users to delete their own meal logs
CREATE POLICY "Users can delete own meal logs"
    ON public.meal_logs
    FOR DELETE
    USING (auth.uid() = user_id);

-- Create trigger to update updated_at on row update
CREATE TRIGGER set_meal_logs_updated_at
    BEFORE UPDATE ON public.meal_logs
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_meal_logs_user_id ON public.meal_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_meal_logs_logged_at ON public.meal_logs(logged_at DESC);
CREATE INDEX IF NOT EXISTS idx_meal_logs_user_logged_at ON public.meal_logs(user_id, logged_at DESC);

