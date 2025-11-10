// api/verify-telegram.js
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  // Handle OPTIONS request
  if (req.method === 'OPTIONS') {
    return res.status(200).json({ ok: true });
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { token, user_id } = req.body;

    // Validate input
    if (!token || !user_id) {
      return res.status(400).json({
        success: false,
        error: 'Missing token or user_id'
      });
    }

    // Check if token exists and is valid
    const { data: verification, error: tokenError } = await supabase
      .from('telegram_verifications')
      .select('*')
      .eq('token', token)
      .eq('used', false)
      .single();

    if (tokenError || !verification) {
      return res.status(400).json({
        success: false,
        error: 'Invalid or expired verification token'
      });
    }

    // Check if token is expired
    const expiresAt = new Date(verification.expires_at);
    const now = new Date();

    if (expiresAt < now) {
      return res.status(400).json({
        success: false,
        error: 'Verification link has expired. Please request a new one.'
      });
    }

    // Check if this telegram_id is already linked to another user
    const { data: existingLink } = await supabase
      .from('publishers')
      .select('user_id, first_name')
      .eq('telegram_id', verification.telegram_id)
      .single();

    if (existingLink && existingLink.user_id !== user_id) {
      return res.status(400).json({
        success: false,
        error: 'This Telegram account is already linked to another user.'
      });
    }

    // Update publisher with telegram_id and mark as verified
    const { error: updateError } = await supabase
      .from('publishers')
      .update({
        telegram_id: verification.telegram_id,
        telegram_verified: true,
        updated_at: new Date().toISOString()
      })
      .eq('user_id', user_id);

    if (updateError) {
      console.error('Error updating publisher:', updateError);
      return res.status(500).json({
        success: false,
        error: 'Failed to link Telegram account'
      });
    }

    // Mark token as used
    await supabase
      .from('telegram_verifications')
      .update({ used: true })
      .eq('token', token);

    // Get publisher info
    const { data: publisher } = await supabase
      .from('publishers')
      .select('first_name, brand_name')
      .eq('user_id', user_id)
      .single();

    return res.status(200).json({
      success: true,
      message: 'Telegram account linked successfully!',
      publisher: {
        name: publisher?.first_name,
        brand: publisher?.brand_name
      }
    });

  } catch (error) {
    console.error('Verification error:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
}