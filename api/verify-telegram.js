// api/verify-telegram.js
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end();
  const { token, publisher_id } = req.body; // publisher_id from signed-in user (frontend)
  // 1) fetch verification token row
  const { data: row, error } = await supabase
    .from('telegram_verifications')
    .select('*')
    .eq('token', token)
    .eq('used', false)
    .single();

  if (error || !row) return res.status(400).json({ error: 'Invalid or expired token' });

  // check expiry
  if (new Date(row.expires_at) < new Date()) return res.status(400).json({ error: 'Expired' });

  // mark used and update publishers table with telegram_id
  await supabase.from('telegram_verifications').update({ used: true }).eq('id', row.id);

  await supabase.from('publishers').update({
    telegram_id: row.telegram_id,
    telegram_verified: true
  }).eq('id', publisher_id);

  return res.json({ success: true });
}
