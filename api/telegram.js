//// api/telegram.js
//import axios from 'axios';
//import { createClient } from '@supabase/supabase-js';
//import fs from 'fs';
//import https from 'https';
//
//const SUPABASE_URL = process.env.SUPABASE_URL;
//const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
//const BOT_TOKEN = process.env.BOT_TOKEN;
//const WEBAPP_URL = process.env.WEBAPP_URL || 'https://disknova-2cna.vercel.app';
//const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
//
//async function sendMessage(chatId, text, options = {}) {
//  try {
//    await axios.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
//      chat_id: chatId,
//      text,
//      parse_mode: 'HTML',
//      ...options
//    });
//  } catch (e) {
//    console.error('Error sending message:', e.response?.data || e.message);
//  }
//}
//
//// Download Telegram File
//async function downloadTelegramFile(fileId) {
//  const fileRes = await axios.get(
//    `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
//  );
//  const filePath = fileRes.data.result.file_path;
//  const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;
//
//  const tempPath = `/tmp/${Date.now()}_${filePath.split('/').pop()}`;
//  const file = fs.createWriteStream(tempPath);
//
//  return new Promise((resolve, reject) => {
//    https.get(fileUrl, (response) => {
//      response.pipe(file);
//      file.on('finish', () => file.close(() => resolve(tempPath)));
//    }).on('error', reject);
//  });
//}
//
//export default async function handler(req, res) {
//  if (req.method === 'GET') return res.status(200).json({ status: 'Bot active' });
//  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });
//
//  const update = req.body;
//  const msg = update.message || update.channel_post || update.edited_message;
//  if (!msg) return res.status(200).json({ ok: true });
//
//  const chatId = msg.chat?.id;
//  const tgUserId = msg.from?.id;
//
//  try {
//    // ✅ Step 1: Commands
//    if (msg.text?.trim().toLowerCase() === '/start') {
//      await sendMessage(chatId, '👋 Welcome to DiskNova Bot!\nUse /link to verify your account.');
//      return res.status(200).json({ ok: true });
//    }
//
//    if (msg.text?.trim().toLowerCase() === '/help') {
//      await sendMessage(chatId, 'Commands:\n/link - verify\n/status - check verification');
//      return res.status(200).json({ ok: true });
//    }
//
//    if (msg.text?.trim().toLowerCase() === '/status') {
//      const { data: publisher } = await supabase
//        .from('publishers')
//        .select('telegram_verified, brand_name')
//        .eq('telegram_id', tgUserId)
//        .single();
//
//      if (publisher?.telegram_verified)
//        await sendMessage(chatId, `✅ Verified for brand: ${publisher.brand_name}`);
//      else await sendMessage(chatId, '❌ Not verified.\nUse /link to verify.');
//      return res.status(200).json({ ok: true });
//    }
//
//    if (msg.text?.trim().toLowerCase() === '/link') {
//      const token = Math.random().toString(36).substring(2, 15);
//      const expiresAt = new Date(Date.now() + 15 * 60 * 1000).toISOString();
//
//      await supabase.from('telegram_verifications').delete().eq('telegram_id', tgUserId);
//      await supabase.from('telegram_verifications').insert({
//        telegram_id: tgUserId,
//        token,
//        expires_at: expiresAt,
//        used: false
//      });
//
//      const verifyUrl = `${WEBAPP_URL}/api/verify-telegram?token=${token}&telegram_id=${tgUserId}`;
//      await sendMessage(chatId, '🔗 Click below to verify your DiskNova account', {
//        reply_markup: { inline_keyboard: [[{ text: 'Verify ✅', url: verifyUrl }]] }
//      });
//      return res.status(200).json({ ok: true });
//    }
//
//    // ✅ Step 2: Handle video uploads
//    if (msg.video || msg.document || msg.video_note) {
//      const { data: publisher } = await supabase
//        .from('publishers')
//        .select('id, telegram_verified, brand_name')
//        .eq('telegram_id', tgUserId)
//        .single();
//
//      if (!publisher?.telegram_verified) {
//        await sendMessage(chatId, '⚠️ Please verify first using /link');
//        return res.status(200).json({ ok: true });
//      }
//
//      const video = msg.video || msg.document || msg.video_note;
//      const filePath = await downloadTelegramFile(video.file_id);
//
//      const fileData = fs.readFileSync(filePath);
//      const fileName = `${publisher.brand_name}_${Date.now()}.mp4`;
//
//      const { data, error } = await supabase.storage
//        .from('videos')
//        .upload(`telegram/${fileName}`, fileData, {
//          contentType: 'video/mp4',
//          upsert: false,
//        });
//
//      fs.unlinkSync(filePath);
//
//      if (error) {
//        console.error('Upload error:', error);
//        await sendMessage(chatId, '❌ Upload failed.');
//      } else {
//        const publicUrl = `${SUPABASE_URL.replace('.co', '.co/storage/v1/object/public/videos/telegram/')}${fileName}`;
//        await sendMessage(chatId, `✅ Video uploaded successfully!\n\n🔗 ${publicUrl}`);
//      }
//    }
//
//    res.status(200).json({ ok: true });
//  } catch (error) {
//    console.error('Error in handler:', error);
//    res.status(200).json({ ok: true });
//  }
//}
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

// Extract username from Telegram URL or @username
function extractUsername(text) {
  if (!text) return null;

  text = text.trim().toLowerCase();

  const patterns = [
    /(?:https?:\/\/)?(?:www\.)?t\.me\/([a-zA-Z0-9_]+)/i,
    /(?:https?:\/\/)?(?:www\.)?telegram\.me\/([a-zA-Z0-9_]+)/i,
    /@([a-zA-Z0-9_]+)/,
    /^([a-zA-Z0-9_]+)$/
  ];

  for (const pattern of patterns) {
    const match = text.match(pattern);
    if (match && match[1]) {
      return match[1].toLowerCase();
    }
  }

  return null;
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
        `<b>To get started:</b>\n` +
        `Send me your Telegram profile link to verify your account.`
      );
      return res.status(200).json({ ok: true });
    }

    // ✅ /help command
    if (msg.text?.trim().toLowerCase() === '/help') {
      await sendMessage(chatId,
        `📚 <b>DiskNova Bot Help</b>\n\n` +
        `<b>Available Commands:</b>\n` +
        `/start - Welcome message\n` +
        `/link - Get verification instructions\n` +
        `/status - Check verification status\n` +
        `/help - Show this message\n\n` +
        `<b>How to use:</b>\n` +
        `1. Add your Telegram link in DiskNova app\n` +
        `2. Send your Telegram link here (e.g., https://t.me/Hkgaming07)\n` +
        `3. Click the verification link I send\n` +
        `4. Start uploading videos!`
      );
      return res.status(200).json({ ok: true });
    }

    // ✅ /status command
    if (msg.text?.trim().toLowerCase() === '/status') {
      const { data: publisher } = await supabase
        .from('publishers')
        .select('telegram_verified, first_name, brand_name, telegram_url, telegram_id')
        .eq('telegram_id', tgUserId)
        .maybeSingle();

      if (publisher?.telegram_verified) {
        await sendMessage(chatId,
          `✅ <b>Verification Status: VERIFIED</b>\n\n` +
          `Name: ${publisher.first_name}\n` +
          `Brand: ${publisher.brand_name}\n` +
          `Link: ${publisher.telegram_url}\n\n` +
          `You can now upload videos by sending them as files!`
        );
      } else if (publisher && !publisher.telegram_verified) {
        await sendMessage(chatId,
          `⚠️ <b>Account Linked but Not Verified</b>\n\n` +
          `Your Telegram link: ${publisher.telegram_url || 'Not set'}\n\n` +
          `Send your Telegram link to verify.`
        );
      } else {
        await sendMessage(chatId,
          `❌ <b>Not Linked</b>\n\n` +
          `Please add your Telegram link in the DiskNova app first.\n\n` +
          `Then send your Telegram link here to verify.`
        );
      }
      return res.status(200).json({ ok: true });
    }

    // ✅ /link command
    if (msg.text?.trim().toLowerCase() === '/link') {
      await sendMessage(chatId,
        `🔗 <b>How to Verify Your Account</b>\n\n` +
        `<b>Step 1:</b> Add your Telegram link in DiskNova app\n` +
        `Go to: Profile → Verification → Social Links → Telegram\n\n` +
        `<b>Step 2:</b> Send your Telegram link here\n` +
        `Example formats:\n` +
        `• https://t.me/Hkgaming07\n` +
        `• t.me/Hkgaming07\n` +
        `• @Hkgaming07\n\n` +
        `<b>Step 3:</b> Click the verification link I send\n\n` +
        `That's it! Then you can upload videos. 🎥`
      );
      return res.status(200).json({ ok: true });
    }

    // ✅ Handle Telegram link messages (any text that looks like a Telegram link)
    if (msg.text && !msg.text.startsWith('/')) {
      const messageText = msg.text.trim();

      // Extract username from the message
      const sentUsername = extractUsername(messageText);

      if (!sentUsername) {
        await sendMessage(chatId,
          `❌ <b>Invalid Telegram Link</b>\n\n` +
          `Please send a valid Telegram link:\n` +
          `• https://t.me/your_username\n` +
          `• t.me/your_username\n` +
          `• @your_username\n\n` +
          `Use /link for more help.`
        );
        return res.status(200).json({ ok: true });
      }

      // 🔥 FIXED: Search by matching username in telegram_url, not telegram_id
      const { data: allPublishers } = await supabase
        .from('publishers')
        .select('*')
        .not('telegram_url', 'is', null);

      let matchedPublisher = null;

      if (allPublishers && allPublishers.length > 0) {
        matchedPublisher = allPublishers.find(pub => {
          const storedUsername = extractUsername(pub.telegram_url);
          return storedUsername === sentUsername;
        });
      }

      if (!matchedPublisher) {
        await sendMessage(chatId,
          `❌ <b>No Matching Account Found</b>\n\n` +
          `Username sent: <code>@${sentUsername}</code>\n\n` +
          `This username is not registered in DiskNova app.\n\n` +
          `<b>Please:</b>\n` +
          `1. Open DiskNova app\n` +
          `2. Go to Verification → Social Links\n` +
          `3. Add this link: <code>https://t.me/${sentUsername}</code>\n` +
          `4. Save and come back\n` +
          `5. Send the link again here`
        );
        return res.status(200).json({ ok: true });
      }

      // 🔥 FIXED: Check if already verified for THIS publisher
      if (matchedPublisher.telegram_verified && matchedPublisher.telegram_id === tgUserId) {
        await sendMessage(chatId,
          `✅ You're already verified, ${matchedPublisher.first_name}!\n\n` +
          `You can upload videos by sending them as files.`
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

      // Insert new token with publisher_id
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
        `🎉 <b>Account Found!</b>\n\n` +
        `<b>Name:</b> ${matchedPublisher.first_name}\n` +
        `<b>Brand:</b> ${matchedPublisher.brand_name}\n` +
        `<b>Link:</b> ${matchedPublisher.telegram_url}\n\n` +
        `✅ Click the button below to complete verification:\n\n` +
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
      const { data: publisher } = await supabase
        .from('publishers')
        .select('*')
        .eq('telegram_id', tgUserId)
        .eq('telegram_verified', true)
        .maybeSingle();

      if (!publisher) {
        await sendMessage(chatId,
          `❌ <b>Not Verified</b>\n\n` +
          `You need to verify your account first.\n\n` +
          `Send your Telegram link (e.g., https://t.me/username) to get started.`
        );
        return res.status(200).json({ ok: true });
      }

      await sendMessage(chatId, '⏳ Uploading your video... Please wait.');

      try {
        const fileObj = msg.video || msg.document;
        const fileId = fileObj.file_id;

        const getFileResp = await axios.get(
          `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
        );
        const filePath = getFileResp.data.result.file_path;
        const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;

        const fileResp = await axios.get(fileUrl, { responseType: 'arraybuffer' });
        const buffer = Buffer.from(fileResp.data);

        const timestamp = Date.now();
        const originalName = fileObj.file_name || `video_${timestamp}.mp4`;
        const fileName = `telegram/${publisher.user_id}_${timestamp}_${originalName}`;

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
          `✅ <b>Video Uploaded Successfully!</b>\n\n` +
          `📁 File: ${originalName}\n` +
          `📊 Size: ${(fileObj.file_size / 1024 / 1024).toFixed(2)} MB\n\n` +
          `🔗 Share Link:\n${shareUrl}`,
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
          `Error: ${uploadError.message}`
        );
      }

      return res.status(200).json({ ok: true });
    }

    return res.status(200).json({ ok: true });

  } catch (error) {
    console.error('Handler error:', error);
    return res.status(200).json({ ok: true });
  }
}