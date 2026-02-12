-- Ideasia → Supabase Migration Schema
-- Run this in Supabase SQL Editor after creating your project

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(30) UNIQUE NOT NULL CHECK (username ~ '^[a-zA-Z0-9_-]+$'),
    email VARCHAR(255) UNIQUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Posts table
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL CHECK (length(content) >= 10 AND length(content) <= 5000),
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(50) DEFAULT 'other' CHECK (category IN ('tech', 'business', 'social', 'entertainment', 'other')),
    upvotes INTEGER DEFAULT 0 CHECK (upvotes >= 0),
    downvotes INTEGER DEFAULT 0 CHECK (downvotes >= 0),
    score INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'milestone_10', 'milestone_100', 'milestone_1000', 'incorporated')),
    views INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Votes table
CREATE TABLE IF NOT EXISTS votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    vote VARCHAR(10) NOT NULL CHECK (vote IN ('up', 'down')),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, post_id)
);

-- Milestones table
CREATE TABLE IF NOT EXISTS milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    threshold INTEGER NOT NULL,
    reached BOOLEAN DEFAULT FALSE,
    reached_at TIMESTAMP,
    action_triggered BOOLEAN DEFAULT FALSE,
    UNIQUE(post_id, threshold)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_posts_author ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_category ON posts(category);
CREATE INDEX IF NOT EXISTS idx_posts_score ON posts(score DESC);
CREATE INDEX IF NOT EXISTS idx_posts_upvotes ON posts(upvotes DESC);
CREATE INDEX IF NOT EXISTS idx_posts_created ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_votes_user ON votes(user_id);
CREATE INDEX IF NOT EXISTS idx_votes_post ON votes(post_id);
CREATE INDEX IF NOT EXISTS idx_milestones_post ON milestones(post_id);

-- Functions
CREATE OR REPLACE FUNCTION update_post_score()
RETURNS TRIGGER AS $$
BEGIN
    NEW.score := NEW.upvotes - NEW.downvotes;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_post_score
    BEFORE INSERT OR UPDATE OF upvotes, downvotes ON posts
    FOR EACH ROW
    EXECUTE FUNCTION update_post_score();

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_posts_updated_at
    BEFORE UPDATE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- RPC functions for voting logic
CREATE OR REPLACE FUNCTION upvote_post(p_post_id UUID, p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    existing_vote VARCHAR(10);
    new_upvotes INTEGER;
    new_downvotes INTEGER;
BEGIN
    -- Check existing vote
    SELECT vote INTO existing_vote
    FROM votes
    WHERE user_id = p_user_id AND post_id = p_post_id;

    IF existing_vote = 'up' THEN
        -- Remove upvote
        DELETE FROM votes WHERE user_id = p_user_id AND post_id = p_post_id;
        UPDATE posts SET upvotes = upvotes - 1 WHERE id = p_post_id;
    ELSIF existing_vote = 'down' THEN
        -- Change downvote to upvote
        UPDATE votes SET vote = 'up' WHERE user_id = p_user_id AND post_id = p_post_id;
        UPDATE posts SET upvotes = upvotes + 1, downvotes = downvotes - 1 WHERE id = p_post_id;
    ELSE
        -- New upvote
        INSERT INTO votes (user_id, post_id, vote) VALUES (p_user_id, p_post_id, 'up');
        UPDATE posts SET upvotes = upvotes + 1 WHERE id = p_post_id;
    END IF;

    -- Return updated counts
    SELECT upvotes, downvotes INTO new_upvotes, new_downvotes
    FROM posts WHERE id = p_post_id;

    RETURN json_build_object('upvotes', new_upvotes, 'downvotes', new_downvotes, 'score', new_upvotes - new_downvotes);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION downvote_post(p_post_id UUID, p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    existing_vote VARCHAR(10);
    new_upvotes INTEGER;
    new_downvotes INTEGER;
BEGIN
    SELECT vote INTO existing_vote
    FROM votes
    WHERE user_id = p_user_id AND post_id = p_post_id;

    IF existing_vote = 'down' THEN
        DELETE FROM votes WHERE user_id = p_user_id AND post_id = p_post_id;
        UPDATE posts SET downvotes = downvotes - 1 WHERE id = p_post_id;
    ELSIF existing_vote = 'up' THEN
        UPDATE votes SET vote = 'down' WHERE user_id = p_user_id AND post_id = p_post_id;
        UPDATE posts SET downvotes = downvotes + 1, upvotes = upvotes - 1 WHERE id = p_post_id;
    ELSE
        INSERT INTO votes (user_id, post_id, vote) VALUES (p_user_id, p_post_id, 'down');
        UPDATE posts SET downvotes = downvotes + 1 WHERE id = p_post_id;
    END IF;

    SELECT upvotes, downvotes INTO new_upvotes, new_downvotes
    FROM posts WHERE id = p_post_id;

    RETURN json_build_object('upvotes', new_upvotes, 'downvotes', new_downvotes, 'score', new_upvotes - new_downvotes);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Row Level Security (RLS) Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view all profiles" ON users
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Posts policies
CREATE POLICY "Anyone can view posts" ON posts
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create posts" ON posts
    FOR INSERT WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can update own posts" ON posts
    FOR UPDATE USING (auth.uid() = author_id);

CREATE POLICY "Users can delete own posts" ON posts
    FOR DELETE USING (auth.uid() = author_id);

-- Votes policies
CREATE POLICY "Anyone can view votes" ON votes
    FOR SELECT USING (true);

CREATE POLICY "Users can insert own votes" ON votes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own votes" ON votes
    FOR DELETE USING (auth.uid() = user_id);

-- Milestones policies
CREATE POLICY "Anyone can view milestones" ON milestones
    FOR SELECT USING (true);

-- Demo data (optional - remove if you don't want it)
INSERT INTO users (username, email) VALUES
    ('demo_user', 'demo@example.com'),
    ('alice', 'alice@example.com'),
    ('bob', 'bob@example.com')
ON CONFLICT (username) DO NOTHING;
