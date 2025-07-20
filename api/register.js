import { createClient } from '@supabase/supabase-js';
import nodemailer from 'nodemailer';

const supabaseUrl = 'https://bvjqywbyehvqlzqoyspl.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ2anF5d2J5ZWh2cWx6cW95c3BsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1OTEyMzcsImV4cCI6MjA2NTE2NzIzN30.4HbyTYGBmrHfmUP2VPP1xoc5H_14DMN-LkZkvlX-arM';
const supabase = createClient(supabaseUrl, supabaseKey);

export default async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, message: 'Method not allowed' });
  }

  try {
    const { username, email, password } = req.body;

    // Validate input
    if (!username || !email || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Username, email and password are required' 
      });
    }

    // Create user in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: email,
      password: password,
      options: {
        data: {
          username: username
        }
      }
    });

    if (authError) {
      return res.status(400).json({ 
        success: false, 
        message: authError.message 
      });
    }

    // Generate wallet address
    const walletAddress = `PRDT_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // Insert user data into users table
    const { data: userData, error: userError } = await supabase
      .from('users')
      .insert([
        {
          id: authData.user.id,
          username: username,
          email: email,
          wallet_address: walletAddress,
          balance: 1000.0,
          verified: false,
          created_at: new Date().toISOString()
        }
      ])
      .select()
      .single();

    if (userError) {
      return res.status(400).json({ 
        success: false, 
        message: userError.message 
      });
    }

    // Generate and send verification code
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Create transporter with real SMTP settings
    const transporter = nodemailer.createTransporter({
      host: 'mail.prdttoken.com',
      port: 465,
      secure: true,
      auth: {
        user: 'support@prdttoken.com',
        pass: process.env.EMAIL_PASSWORD
      },
      tls: {
        rejectUnauthorized: false
      }
    });

    // Get user's IP address
    const ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;

    // Send verification email
    await transporter.sendMail({
      from: 'support@prdttoken.com',
      to: email,
      subject: 'PRDT Token - Account Verification Required',
      text: `
Dear ${username},

Welcome to the PRDT Token family!

To activate your account, please use the verification code below:

VERIFICATION CODE: ${verificationCode}

Code validity: 10 minutes

Login Information:
Username: ${username}
Email: ${email}
IP Address: ${ip}
Date: ${new Date().toLocaleString()}

Security Warning:
- Never share this code with anyone
- PRDT Token team will never ask for your code
- Report suspicious activity immediately

Support: support@prdttoken.com
Website: https://prdttoken.com

Thank you,
PRDT Token Security Team
      `,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>PRDT Token - Account Verification</title>
          <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }
            .container { max-width: 600px; margin: 0 auto; background-color: white; }
            .header { background: linear-gradient(45deg, #667eea, #764ba2); color: white; padding: 20px; text-align: center; }
            .content { padding: 30px; }
            .code { background: #f8f9fa; border: 2px solid #dee2e6; padding: 20px; text-align: center; font-size: 48px; font-weight: bold; margin: 20px 0; border-radius: 8px; }
            .info-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
            .info-table td { padding: 12px; border: 1px solid #dee2e6; }
            .info-table tr:nth-child(even) { background-color: #f8f9fa; }
            .warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }
            .footer { background-color: #f8f9fa; padding: 20px; text-align: center; color: #6c757d; font-size: 14px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>PRDT Token</h1>
              <p>Account Verification</p>
            </div>
            
            <div class="content">
              <h2>Hello ${username},</h2>
              <p>Please use the following code to verify your account:</p>
              
              <div class="code">${verificationCode}</div>
              
              <table class="info-table">
                <tr><td><strong>Username</strong></td><td>${username}</td></tr>
                <tr><td><strong>Email</strong></td><td>${email}</td></tr>
                <tr><td><strong>IP Address</strong></td><td>${ip}</td></tr>
                <tr><td><strong>Date</strong></td><td>${new Date().toLocaleString()}</td></tr>
              </table>
              
              <div class="warning">
                <strong>WARNING:</strong> Never share this code with anyone!
              </div>
            </div>
            
            <div class="footer">
              <p>Support: support@prdttoken.com | Website: https://prdttoken.com</p>
              <p>&copy; 2024 PRDT Token. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `
    });

    // Store verification code in database
    await supabase
      .from('users')
      .update({ 
        verification_code: verificationCode,
        verification_sent_at: new Date().toISOString()
      })
      .eq('username', username);

    return res.status(200).json({
      success: true,
      message: 'Registration successful. Please check your email for verification code.',
      user: {
        id: userData.id,
        username: userData.username,
        email: userData.email,
        wallet_address: userData.wallet_address,
        balance: userData.balance,
        verified: false
      }
    });

  } catch (error) {
    console.error('Registration error:', error);
    return res.status(500).json({ 
      success: false, 
      message: 'Internal server error' 
    });
  }
} 