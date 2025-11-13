// api/telegram.js
import axios from 'axios';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const BOT_TOKEN = process.env.BOT_TOKEN;
const WEBAPP_URL = process.env.WEBAPP_URL || 'https://disknova-2cna.vercel.app';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

async function sendMessage(chatId, text, options = {}) {
  try {
    await axios.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      chat_id: chatId,
      text,
      parse_mode: 'HTML',
      ...options
    });
  } catch (e) {
    console.error('Error sending message:', e.response?.data || e.message);
  }
}

export default async function handler(req, res) {
  if (req.method === 'GET') return res.status(200).json({ status: 'Bot active' });
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const update = req.body;
  const msg = update.message || update.channel_post || update.edited_message;
  if (!msg) return res.status(200).json({ ok: true });

  const chatId = msg.chat?.id;
  const tgUserId = msg.from?.id;
  const username = msg.from?.username || msg.from?.first_name || 'User';

  try {
    // ✅ /start command
    if (msg.text?.trim().toLowerCase() === '/start') {
      await sendMessage(chatId,
        `🎉 <b>Welcome to DiskNova Bot!</b>\n\n` +
        `I can help you upload videos directly to your DiskNova account.\n\n` +
        `<b>Commands:</b>\n` +
        `/link - Link your Telegram account\n` +
        `/status - Check verification status\n` +
        `/help - Show help\n\n` +
        `To get started, use /link command.`
      );
      return res.status(200).json({ ok: true });
    }

    // ✅ /help command
    if (msg.text?.trim().toLowerCase() === '/help') {
      await sendMessage(chatId,
        `📚 <b>DiskNova Bot Help</b>\n\n` +
        `<b>Available Commands:</b>\n` +
        `/start - Welcome message\n` +
        `/link - Get verification link\n` +
        `/status - Check verification status\n` +
        `/help - Show this message\n\n` +
        `<b>How to use:</b>\n` +
        `1. Add your Telegram link in DiskNova app\n` +
        `2. Use /link to get verification URL\n` +
        `3. Click the link to verify\n` +
        `4. Send video files to upload!`
      );
      return res.status(200).json({ ok: true });
    }

    // ✅ /status command
    if (msg.text?.trim().toLowerCase() === '/status') {
      const { data: publisher } = await supabase
        .from('publishers')
        .select('telegram_verified, first_name, brand_name, telegram_url, telegram_id')
        .eq('telegram_id', tgUserId)
        .single();

      if (publisher?.telegram_verified) {
        await sendMessage(chatId,
          `✅ <b>Verification Status: VERIFIED</b>\n\n` +
          `Name: ${publisher.first_name}\n` +
          `Brand: ${publisher.brand_name}\n\n` +
          `You can now upload videos by sending them as files!`
        );
      } else if (publisher && !publisher.telegram_verified) {
        await sendMessage(chatId,
          `⚠️ <b>Account Linked but Not Verified</b>\n\n` +
          `Your Telegram link: ${publisher.telegram_url || 'Not set'}\n\n` +
          `Use /link command to complete verification.`
        );
      } else {
        await sendMessage(chatId,
          `❌ <b>Not Linked</b>\n\n` +
          `Please add your Telegram link in the DiskNova app first, then use /link to verify.`
        );
      }
      return res.status(200).json({ ok: true });
    }

    // ✅ /link command (verification flow) - FIXED VERSION
    if (msg.text?.trim().toLowerCase() === '/link') {
      // Check if user already has telegram_id set (previously linked)
      const { data: existingPublisher } = await supabase
        .from('publishers')
        .select('*')
        .eq('telegram_id', tgUserId)
        .maybeSingle();

      if (existingPublisher?.telegram_verified) {
        await sendMessage(chatId,
          `✅ You're already verified, ${existingPublisher.first_name}!\n\n` +
          `You can upload videos by sending them as files.`
        );
        return res.status(200).json({ ok: true });
      }

      // Build possible Telegram URL variations
      const possibleUrls = [
        `https://t.me/${username}`,
        `https://telegram.me/${username}`,
        `t.me/${username}`,
        `telegram.me/${username}`,
        `@${username}`
      ];

      // Search for publisher with matching telegram_url OR already has this telegram_id
      const { data: publishers } = await supabase
        .from('publishers')
        .select('*')
        .not('telegram_url', 'is', null);

      // Find matching publisher
      const matchedPublisher = publishers?.find(pub => {
        const url = pub.telegram_url?.toLowerCase().trim();
        if (!url) return false;

        // Check if any possible URL format matches
        return possibleUrls.some(possibleUrl =>
          url.includes(possibleUrl.toLowerCase()) ||
          url.includes(username.toLowerCase())
        );
      }) || existingPublisher;

      if (!matchedPublisher) {
        // Get username-specific URL for clearer instructions
        const yourTelegramUrl = msg.from?.username
          ? `https://t.me/${msg.from.username}`
          : 'your Telegram profile URL';

        await sendMessage(chatId,
          `❌ <b>Telegram Link Not Found</b>\n\n` +
          `Please add your Telegram link in the DiskNova app first:\n\n` +
          `1. Open DiskNova app\n` +
          `2. Go to Profile → Social Links\n` +
          `3. Add Telegram URL: <code>${yourTelegramUrl}</code>\n` +
          `4. Save changes\n` +
          `5. Come back and use /link again\n\n` +
          `<i>Make sure the URL matches your Telegram username!</i>`
        );
        return res.status(200).json({ ok: true });
      }

      // Generate verification token
      const token = [...Array(30)].map(() => (Math.random() * 36 | 0).toString(36)).join('');
      const expiresAt = new Date(Date.now() + 1000 * 60 * 15).toISOString();

      // Delete old tokens for this telegram_id
      await supabase
        .from('telegram_verifications')
        .delete()
        .eq('telegram_id', tgUserId);

      // Insert new token
      const { error: insertError } = await supabase
        .from('telegram_verifications')
        .insert({
          telegram_id: tgUserId,
          token,
          expires_at: expiresAt,
          used: false,
          publisher_id: matchedPublisher.id
        });

      if (insertError) {
        console.error('Error creating verification:', insertError);
        await sendMessage(chatId, '❌ Failed to create verification link. Please try again.');
        return res.status(200).json({ ok: true });
      }

      const verifyUrl = `${WEBAPP_URL}/api/verify-telegram?token=${token}&telegram_id=${tgUserId}`;

      await sendMessage(chatId,
        `🔗 <b>Verification Link Created!</b>\n\n` +
        `Account: ${matchedPublisher.first_name} (${matchedPublisher.brand_name})\n\n` +
        `Click the button below to verify your account:\n\n` +
        `⏱ Link expires in 15 minutes.`,
        {
          reply_markup: {
            inline_keyboard: [[
              { text: '✅ Verify Account', url: verifyUrl }
            ]]
          }
        }
      );
      return res.status(200).json({ ok: true });
    }

    // ✅ Handle video/document uploads
    if (msg.video || msg.document) {
      // Check if user is verified
      const { data: publisher } = await supabase
        .from('publishers')
        .select('*')
        .eq('telegram_id', tgUserId)
        .eq('telegram_verified', true)
        .single();

      if (!publisher) {
        await sendMessage(chatId,
          `❌ <b>Not Verified</b>\n\n` +
          `You need to verify your account first.\n` +
          `Use /link command to get started.`
        );
        return res.status(200).json({ ok: true });
      }

      await sendMessage(chatId, '⏳ Uploading your video... Please wait.');

      try {
        const fileObj = msg.video || msg.document;
        const fileId = fileObj.file_id;

        // Get file info
        const getFileResp = await axios.get(
          `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
        );
        const filePath = getFileResp.data.result.file_path;
        const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;

        // Download file
        const fileResp = await axios.get(fileUrl, { responseType: 'arraybuffer' });
        const buffer = Buffer.from(fileResp.data);

        // Generate unique filename
        const timestamp = Date.now();
        const originalName = fileObj.file_name || `video_${timestamp}.mp4`;
        const fileName = `telegram/${publisher.user_id}_${timestamp}_${originalName}`;

        // Upload to Supabase Storage
        const { error: uploadErr } = await supabase.storage
          .from('videos')
          .upload(fileName, buffer, {
            contentType: fileObj.mime_type || 'video/mp4',
            upsert: false
          });

        if (uploadErr) throw uploadErr;

        // Get public URL
        const { data: { publicUrl } } = supabase.storage
          .from('videos')
          .getPublicUrl(fileName);

        // Insert into videos table
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
          `✅ <b>Video Uploaded Successfully!</b>\n\n` +
          `📁 File: ${originalName}\n` +
          `📊 Size: ${(fileObj.file_size / 1024 / 1024).toFixed(2)} MB\n\n` +
          `🔗 Share Link:\n${shareUrl}\n\n` +
          `View and manage your videos in the DiskNova dashboard.`,
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
          `❌ <b>Upload Failed</b>\n\n` +
          `Error: ${uploadError.message}\n\n` +
          `Please try again or contact support.`
        );
      }

      return res.status(200).json({ ok: true });
    }

    // Unknown command
    await sendMessage(chatId,
      `❓ Unknown command. Use /help to see available commands.`
    );

    return res.status(200).json({ ok: true });

  } catch (error) {
    console.error('Handler error:', error);
    return res.status(200).json({ ok: true });
  }
}