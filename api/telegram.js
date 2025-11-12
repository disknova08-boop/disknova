import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const BOT_TOKEN = process.env.BOT_TOKEN;
const WEBAPP_URL = process.env.WEBAPP_URL || 'https://disknova-2cna-6s1ooz0i1-disknovas-projects.vercel.app';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// Helper to send Telegram messages
async function sendMessage(chatId, text, options = {}) {
  try {
    await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: chatId,
        text,
        parse_mode: 'HTML',
        ...options
      }),
    });
  } catch (e) {
    console.error('Error sending message:', e.message);
  }
}

export default async function handler(req, res) {
  if (req.method === 'GET') {
    return res.status(200).json({ status: 'Webhook is running' });
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const update = req.body;
    const msg = update.message || update.channel_post || update.edited_message;
    if (!msg) return res.status(200).json({ ok: true });

    const chatId = msg.chat?.id;
    const tgUserId = msg.from?.id;
    const username = msg.from?.username || msg.from?.first_name || 'User';

    const text = msg.text?.trim().toLowerCase();

    // --- /start ---
    if (text === '/start') {
      await sendMessage(chatId,
        `🎉 <b>Welcome to DiskNova Bot!</b>\n\n` +
        `I can help you upload videos directly to your DiskNova account.\n\n` +
        `<b>Commands:</b>\n` +
        `/link - Link your Telegram account with DiskNova\n` +
        `/status - Check verification status\n` +
        `/help - Show this help message\n\n` +
        `To get started, use /link command to verify your account.`
      );
      return res.status(200).json({ ok: true });
    }

    // --- /help ---
    if (text === '/help') {
      await sendMessage(chatId,
        `📚 <b>DiskNova Bot Help</b>\n\n` +
        `<b>Available Commands:</b>\n` +
        `/start - Welcome message\n` +
        `/link - Get verification link\n` +
        `/status - Check if you're verified\n` +
        `/help - Show this message\n\n` +
        `<b>How to use:</b>\n` +
        `1. Use /link to get verification URL\n` +
        `2. Open the link in your browser\n` +
        `3. Login to your DiskNova account\n` +
        `4. Once verified, send any video file to upload!`
      );
      return res.status(200).json({ ok: true });
    }

    // --- /status ---
    if (text === '/status') {
      const { data: publisher } = await supabase
        .from('publishers')
        .select('telegram_verified, first_name, brand_name')
        .eq('telegram_id', tgUserId)
        .single();

      if (publisher?.telegram_verified) {
        await sendMessage(chatId,
          `✅ <b>Verification Status: VERIFIED</b>\n\n` +
          `Name: ${publisher.first_name}\n` +
          `Brand: ${publisher.brand_name}\n\n` +
          `You can now upload videos by sending them as files!`
        );
      } else {
        await sendMessage(chatId,
          `❌ <b>Not Verified</b>\n\nUse /link command to verify your account.`
        );
      }
      return res.status(200).json({ ok: true });
    }

    // --- /link ---
    if (text === '/link') {
      const { data: existingPub } = await supabase
        .from('publishers')
        .select('telegram_verified, first_name')
        .eq('telegram_id', tgUserId)
        .single();

      if (existingPub?.telegram_verified) {
        await sendMessage(chatId,
          `✅ You're already verified, ${existingPub.first_name}!\n\nYou can upload videos by sending them as files.`
        );
        return res.status(200).json({ ok: true });
      }

      const token = [...Array(30)].map(() => (Math.random() * 36 | 0).toString(36)).join('');
      const expiresAt = new Date(Date.now() + 1000 * 60 * 15).toISOString();

      await supabase.from('telegram_verifications').delete().eq('telegram_id', tgUserId);
      const { error: insertErr } = await supabase
        .from('telegram_verifications')
        .insert({ telegram_id: tgUserId, token, expires_at: expiresAt, used: false });

      if (insertErr) {
        await sendMessage(chatId, '❌ Error creating verification link. Please try again.');
        return res.status(200).json({ ok: true });
      }

      const verifyUrl = `${WEBAPP_URL}/verify-telegram?token=${token}`;

      await sendMessage(chatId,
        `🔗 <b>Verification Link Created!</b>\n\nClick below to verify:\n${verifyUrl}\n\n⏱ Link expires in 15 minutes.`,
        {
          reply_markup: {
            inline_keyboard: [[
              { text: '🔗 Verify Account', url: verifyUrl }
            ]]
          }
        }
      );
      return res.status(200).json({ ok: true });
    }

    // --- Handle file uploads ---
    if (msg.video || msg.document) {
      const { data: publisher } = await supabase
        .from('publishers')
        .select('*')
        .eq('telegram_id', tgUserId)
        .eq('telegram_verified', true)
        .single();

      if (!publisher) {
        await sendMessage(chatId,
          `❌ <b>Not Verified</b>\nUse /link to verify your account first.`
        );
        return res.status(200).json({ ok: true });
      }

      await sendMessage(chatId, '⏳ Uploading your video... Please wait.');

      try {
        const fileObj = msg.video || msg.document;
        const fileId = fileObj.file_id;

        // Get file info
        const getFileResp = await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`);
        const fileData = await getFileResp.json();
        const filePath = fileData.result.file_path;
        const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;

        const fileResp = await fetch(fileUrl);
        const buffer = Buffer.from(await fileResp.arrayBuffer());

        const timestamp = Date.now();
        const originalName = fileObj.file_name || `video_${timestamp}.mp4`;
        const fileName = `${publisher.user_id}_${timestamp}_${originalName}`;

        const { error: uploadErr } = await supabase.storage
          .from('videos')
          .upload(fileName, buffer, {
            contentType: fileObj.mime_type || 'video/mp4',
            upsert: false
          });

        if (uploadErr) throw uploadErr;

        const { data: { publicUrl } } = supabase.storage
          .from('videos')
          .getPublicUrl(fileName);

        const { data: videoRecord, error: dbErr } = await supabase
          .from('videos')
          .insert({
            user_id: publisher.user_id,
            title: msg.caption || originalName,
            description: `Uploaded via Telegram by ${username}`,
            video_url: publicUrl,
            file_size: fileObj.file_size || 0,
            duration: fileObj.duration || 0,
            views: 0,
            created_at: new Date().toISOString()
          })
          .select()
          .single();

        if (dbErr) throw dbErr;

        const shareUrl = `${WEBAPP_URL}/video/${videoRecord.id}`;

        await sendMessage(chatId,
          `✅ <b>Video Uploaded Successfully!</b>\n\n📁 File: ${originalName}\n📊 Size: ${(fileObj.file_size / 1024 / 1024).toFixed(2)} MB\n\n🔗 ${shareUrl}`,
          {
            reply_markup: {
              inline_keyboard: [[
                { text: '🔗 View Video', url: shareUrl },
                { text: '📊 Dashboard', url: WEBAPP_URL }
              ]]
            }
          }
        );

      } catch (uploadError) {
        console.error('Upload error:', uploadError);
        await sendMessage(chatId,
          `❌ <b>Upload Failed</b>\nError: ${uploadError.message}`
        );
      }

      return res.status(200).json({ ok: true });
    }

    // --- Unknown command ---
    await sendMessage(chatId, `❓ Unknown command. Use /help to see available commands.`);
    return res.status(200).json({ ok: true });

  } catch (error) {
    console.error('Handler error:', error);
    return res.status(200).json({ ok: true }); // Always 200 for Telegram
  }
}
