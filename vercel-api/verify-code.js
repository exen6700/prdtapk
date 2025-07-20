const { createClient } = require('@supabase/supabase-js');

// Supabase configuration
const supabaseUrl = 'https://bvjqywbyehvqlzqoyspl.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ2anF5d2J5ZWh2cWx6cW95c3BsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1OTEyMzcsImV4cCI6MjA2NTE2NzIzN30.4HbyTYGBmrHfmUP2VPP1xoc5H_14DMN-LkZkvlX-arM';
const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { username, email, code } = req.body;

    if (!username || !email || !code) {
      return res.status(400).json({ error: 'Username, email and code are required' });
    }

    // Check if user exists and get verification code
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('username', username)
      .eq('email', email)
      .single();

    if (error || !user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if verification code matches
    if (user.verification_code !== code) {
      return res.status(400).json({ error: 'Invalid verification code' });
    }

    // Check if code is expired (10 minutes)
    const verificationSentAt = new Date(user.verification_sent_at);
    const now = new Date();
    const timeDiff = now - verificationSentAt;
    const tenMinutes = 10 * 60 * 1000; // 10 minutes in milliseconds

    if (timeDiff > tenMinutes) {
      return res.status(400).json({ error: 'Verification code has expired' });
    }

    // Mark user as verified
    const { error: updateError } = await supabase
      .from('users')
      .update({ 
        verified: true,
        verification_code: null,
        verification_sent_at: null,
        verified_at: new Date().toISOString()
      })
      .eq('username', username);

    if (updateError) {
      console.error('Update error:', updateError);
      return res.status(500).json({ error: 'Failed to verify user' });
    }

    res.status(200).json({ 
      success: true, 
      message: 'Email verified successfully',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        verified: true
      }
    });

  } catch (error) {
    console.error('Verification error:', error);
    res.status(500).json({ error: 'Failed to verify code' });
  }
}; 