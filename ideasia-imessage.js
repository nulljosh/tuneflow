#!/usr/bin/env node
// iMessage → Ideasia integration
// Text "Idea: Your idea here" and it auto-posts to Ideasia

const axios = require('axios');

const API_URL = 'http://localhost:3030';
const USERNAME = 'joshua';
const PASSWORD = 'TestPass123';

let authToken = null;

async function login() {
  try {
    const response = await axios.post(`${API_URL}/auth/login`, {
      username: USERNAME,
      password: PASSWORD
    });
    authToken = response.data.token;
    console.log('✅ Logged in to Ideasia');
  } catch (error) {
    console.error('❌ Login failed:', error.response?.data || error.message);
  }
}

async function postIdea(title, content) {
  if (!authToken) await login();
  
  try {
    const response = await axios.post(`${API_URL}/posts`, {
      title: title,
      content: content,
      category: 'tech'
    }, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    console.log('✅ Posted idea:', title);
    return response.data.post;
  } catch (error) {
    console.error('❌ Post failed:', error.response?.data || error.message);
  }
}

// Watch stdin for messages
process.stdin.on('data', async (data) => {
  const message = data.toString().trim();
  
  // Format: "Idea: Title | Description"
  // or just: "Idea: Title"
  if (message.startsWith('Idea:')) {
    const ideaText = message.replace('Idea:', '').trim();
    const [title, description] = ideaText.split('|').map(s => s.trim());
    
    await postIdea(
      title,
      description || title
    );
  }
});

console.log('👂 Listening for ideas... (format: Idea: Title | Description)');
