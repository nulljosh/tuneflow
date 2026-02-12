// Ideasia Client-Side Implementation with Supabase
// Drop this into a Vite React app

import { createClient } from '@supabase/supabase-js'

// Initialize Supabase client
const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)

// ============================================
// AUTH
// ============================================

export async function signUp(username, email, password) {
  // 1. Create auth user
  const { data: authData, error: authError } = await supabase.auth.signUp({
    email,
    password,
  })
  
  if (authError) throw authError
  
  // 2. Create user profile
  const { error: profileError } = await supabase
    .from('users')
    .insert({
      id: authData.user.id,
      username,
      email,
    })
  
  if (profileError) throw profileError
  
  return authData.user
}

export async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })
  
  if (error) throw error
  
  // Update last_login
  await supabase
    .from('users')
    .update({ last_login: new Date().toISOString() })
    .eq('id', data.user.id)
  
  return data.user
}

export async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}

export function getCurrentUser() {
  return supabase.auth.getUser()
}

export function onAuthStateChange(callback) {
  return supabase.auth.onAuthStateChange(callback)
}

// ============================================
// POSTS
// ============================================

export async function createPost({ title, content, category = 'other' }) {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('Not authenticated')
  
  const { data, error } = await supabase
    .from('posts')
    .insert({
      title,
      content,
      category,
      author_id: user.id,
    })
    .select(`
      *,
      author:users(username)
    `)
    .single()
  
  if (error) throw error
  return data
}

export async function getPosts({ category, sortBy = 'created_at', limit = 20 } = {}) {
  let query = supabase
    .from('posts')
    .select(`
      *,
      author:users(username, id)
    `)
    .order(sortBy, { ascending: false })
    .limit(limit)
  
  if (category && category !== 'all') {
    query = query.eq('category', category)
  }
  
  const { data, error } = await query
  if (error) throw error
  return data
}

export async function getPost(id) {
  const { data, error } = await supabase
    .from('posts')
    .select(`
      *,
      author:users(username, id)
    `)
    .eq('id', id)
    .single()
  
  if (error) throw error
  return data
}

export async function deletePost(id) {
  const { error } = await supabase
    .from('posts')
    .delete()
    .eq('id', id)
  
  if (error) throw error
}

// ============================================
// VOTING
// ============================================

export async function upvotePost(postId) {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('Not authenticated')
  
  const { data, error } = await supabase
    .rpc('upvote_post', {
      p_post_id: postId,
      p_user_id: user.id
    })
  
  if (error) throw error
  return data
}

export async function downvotePost(postId) {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('Not authenticated')
  
  const { data, error } = await supabase
    .rpc('downvote_post', {
      p_post_id: postId,
      p_user_id: user.id
    })
  
  if (error) throw error
  return data
}

export async function getUserVote(postId) {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return null
  
  const { data, error } = await supabase
    .from('votes')
    .select('vote')
    .eq('post_id', postId)
    .eq('user_id', user.id)
    .maybeSingle()
  
  if (error) throw error
  return data?.vote || null
}

// ============================================
// USAGE EXAMPLES
// ============================================

/*
// In your React component:

import { signIn, signUp, signOut, getCurrentUser } from './client-example'

// Sign up
try {
  const user = await signUp('josh', 'josh@example.com', 'password123')
  console.log('Signed up:', user)
} catch (error) {
  console.error('Sign up error:', error.message)
}

// Sign in
try {
  const user = await signIn('josh@example.com', 'password123')
  console.log('Signed in:', user)
} catch (error) {
  console.error('Sign in error:', error.message)
}

// Create post
try {
  const post = await createPost({
    title: 'My first idea',
    content: 'This is a great idea for a new app...',
    category: 'tech'
  })
  console.log('Created post:', post)
} catch (error) {
  console.error('Create post error:', error.message)
}

// Get posts
const posts = await getPosts({ category: 'tech', sortBy: 'upvotes' })
console.log('Posts:', posts)

// Upvote
const result = await upvotePost(postId)
console.log('Vote result:', result) // { upvotes: 5, downvotes: 1, score: 4 }

// Listen to auth state
onAuthStateChange((event, session) => {
  if (event === 'SIGNED_IN') {
    console.log('User signed in:', session.user)
  } else if (event === 'SIGNED_OUT') {
    console.log('User signed out')
  }
})
*/

// ============================================
// REAL-TIME SUBSCRIPTIONS (BONUS)
// ============================================

export function subscribeToPostUpdates(postId, callback) {
  return supabase
    .channel(`post:${postId}`)
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'posts',
        filter: `id=eq.${postId}`
      },
      callback
    )
    .subscribe()
}

/*
// Usage:
const subscription = subscribeToPostUpdates(postId, (payload) => {
  console.log('Post updated:', payload.new)
  // Update UI with new vote counts
})

// Cleanup:
subscription.unsubscribe()
*/
