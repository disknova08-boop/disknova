
// Supabase Database Schema Setup Instructions:
/*
1. Create 'publishers' table:
   CREATE TABLE publishers (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
     first_name TEXT NOT NULL,
     last_name TEXT NOT NULL,
     brand_name TEXT NOT NULL,
     email TEXT NOT NULL,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

2. Create 'videos' table:
   CREATE TABLE videos (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
     title TEXT NOT NULL,
     description TEXT,
     video_url TEXT NOT NULL,
     file_name TEXT NOT NULL,
     file_size BIGINT DEFAULT 0,
     views INTEGER DEFAULT 0,
     earnings DECIMAL(10, 6) DEFAULT 0,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

3. Create Storage Bucket:
   - Go to Storage in Supabase Dashboard
   - Create bucket named 'videos'
   - Set it to public
   - Add policy:
     * Authenticated users can upload
     * Everyone can read

4. Enable Row Level Security (RLS):

   For publishers table:
   CREATE POLICY "Users can view own data" ON publishers
     FOR SELECT USING (auth.uid() = user_id);

   CREATE POLICY "Users can insert own data" ON publishers
     FOR INSERT WITH CHECK (auth.uid() = user_id);

   For videos table:
   CREATE POLICY "Users can view own videos" ON videos
     FOR SELECT USING (auth.uid() = user_id);

   CREATE POLICY "Users can insert own videos" ON videos
     FOR INSERT WITH CHECK (auth.uid() = user_id);

   CREATE POLICY "Users can delete own videos" ON videos
     FOR DELETE USING (auth.uid() = user_id);

   CREATE POLICY "Users can update own videos" ON videos
     FOR UPDATE USING (auth.uid() = user_id);
*/