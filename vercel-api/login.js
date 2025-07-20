import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://bvjqywbyehvqlzqoyspl.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ2anF5d2J5ZWh2cWx6cW95c3BsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1OTEyMzcsImV4cCI6MjA2NTE2NzIzN30.4HbyTYGBmrHfmUP2VPP1xoc5H_14DMN-LkZkvlX-arM';
const supabase = createClient(supabaseUrl, supabaseKey);

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, message: 'Method not allowed' });
  }

  try {
    const { username, password } = req.body;

    // Validate input
    if (!username || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Username and password are required' 
      });
    }

    // Find user by username or email
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('*')
      .or(`username.eq.${username},email.eq.${username}`)
      .single();

    if (userError || !userData) {
      return res.status(400).json({ 
        success: false, 
        message: 'User not found' 
      });
    }

    // Sign in with email and password
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: userData.email,
      password: password
    });

    if (authError) {
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid credentials' 
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        id: userData.id,
        username: userData.username,
        email: userData.email,
        wallet_address: userData.wallet_address,
        balance: userData.balance,
        token: authData.session.access_token
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({ 
      success: false, 
      message: 'Internal server error' 
    });
  }
} 