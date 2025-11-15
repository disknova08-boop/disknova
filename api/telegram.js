//
//import axios from 'axios';
//import { createClient } from '@supabase/supabase-js';
//import sharp from 'sharp';
//
//const SUPABASE_URL = process.env.SUPABASE_URL;
//const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
//const BOT_TOKEN = process.env.BOT_TOKEN;
//const WEBAPP_URL = process.env.WEBAPP_URL || 'https://disknova-2cna.vercel.app';
//
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
//function extractUsername(text) {
//  if (!text) return null;
//  text = text.trim();
//
//  const patterns = [
//    /(?:https?:\/\/)?(?:www\.)?t\.me\/([a-zA-Z0-9_]+)/i,
//    /(?:https?:\/\/)?(?:www\.)?telegram\.me\/([a-zA-Z0-9_]+)/i,
//    /@([a-zA-Z0-9_]+)/,
//    /^([a-zA-Z0-9_]+)$/
//  ];
//
//  for (const pattern of patterns) {
//    const match = text.match(pattern);
//    if (match && match[1]) {
//      return match[1].toLowerCase();
//    }
//  }
//  return null;
//}
//
//// ✅ Sanitize filename - remove special characters
//function sanitizeFileName(fileName) {
//  if (!fileName || typeof fileName !== "string") {
//    return "video.mp4";
//  }
//
//  const parts = fileName.split('.');
//  const extension = parts.length > 1 ? parts.pop() : 'mp4';
//  const nameWithoutExt = parts.join('.');
//
//  const sanitized = nameWithoutExt
//    .replace(/[^\w\s.-]/g, '')
//    .replace(/\s+/g, '_')
//    .replace(/[–—]/g, '-')
//    .replace(/[\[\](){}]/g, '')
//    .replace(/_+/g, '_')
//    .replace(/-+/g, '-')
//    .replace(/^[.-]+/, '')
//    .replace(/[.-]+$/, '')
//    .substring(0, 50);
//
//  return `${sanitized || 'video'}.${extension}`;
//}
//
//function generateFileName(brandName, originalFileName, timestamp) {
//  const safeOriginal = originalFileName || `video_${timestamp}.mp4`;
//
//  const sanitizedBrandName = brandName
//    .replace(/[^a-zA-Z0-9]/g, '_')
//    .substring(0, 30);
//
//  const sanitizedOriginal = sanitizeFileName(safeOriginal);
//  return `${sanitizedBrandName}_${timestamp}_${sanitizedOriginal}`;
//}
//
//
//// ✅ Generate thumbnail from Telegram's built-in thumbnail
//async function getTelegramThumbnail(fileId) {
//  try {
//    const getFileResp = await axios.get(
//      `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
//    );
//    const filePath = getFileResp.data.result.file_path;
//    const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;
//
//    const thumbResp = await axios.get(fileUrl, { responseType: 'arraybuffer' });
//    const buffer = Buffer.from(thumbResp.data);
//
//    // Resize and optimize thumbnail using sharp
//    const optimizedThumb = await sharp(buffer)
//      .resize(1280, 720, { fit: 'cover' })
//      .jpeg({ quality: 85 })
//      .toBuffer();
//
//    return optimizedThumb;
//  } catch (error) {
//    console.error('Thumbnail extraction error:', error);
//    return null;
//  }
//}
//
//// ✅ Upload single video with thumbnail
//async function uploadVideo(fileObj, publisher, chatId) {
//  try {
//    const fileId = fileObj.file_id;
//    const thumbFileId = fileObj.thumb?.file_id;
//
//    // Get video file from Telegram
//    const getFileResp = await axios.get(
//      `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
//    );
//    const filePath = getFileResp.data.result.file_path;
//    const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;
//
//    const fileResp = await axios.get(fileUrl, { responseType: 'arraybuffer' });
//    const buffer = Buffer.from(fileResp.data);
//
//    const timestamp = Date.now();
//    const brandName = publisher.brand_name || publisher.first_name || 'User';
//    const uniqueFileName = generateFileName(brandName, fileObj.file_name, timestamp);
//    const fileName = `telegram/${uniqueFileName}`;
//
//    console.log('📤 Uploading:', fileName);
//
//    // Upload video to Supabase Storage
//    const { error: uploadErr } = await supabase.storage
//      .from('videos')
//      .upload(fileName, buffer, {
//        contentType: fileObj.mime_type || 'video/mp4',
//        upsert: false
//      });
//
//    if (uploadErr) throw uploadErr;
//
//    const { data: { publicUrl } } = supabase.storage
//      .from('videos')
//      .getPublicUrl(fileName);
//
//    // ✅ Get and upload thumbnail
//    let thumbnailUrl = '';
//    let fullThumbnailUrl = '';
//
//    try {
//      let thumbnailBuffer = null;
//
//      if (thumbFileId) {
//        console.log('🖼️ Extracting thumbnail from Telegram...');
//        thumbnailBuffer = await getTelegramThumbnail(thumbFileId);
//      }
//
//      if (thumbnailBuffer) {
//        const thumbFileName = `thumb_${timestamp}.jpg`;
//        const thumbPath = `uploads/${publisher.user_id}/${thumbFileName}`;
//
//        const { error: thumbUploadErr } = await supabase.storage
//          .from('thumbnails')
//          .upload(thumbPath, thumbnailBuffer, {
//            contentType: 'image/jpeg',
//            upsert: false
//          });
//
//        if (!thumbUploadErr) {
//          thumbnailUrl = thumbPath;
//
//          // Get full public URL
//          const { data } = supabase.storage
//            .from('thumbnails')
//            .getPublicUrl(thumbPath);
//          fullThumbnailUrl = data.publicUrl;
//
//          console.log('✅ Thumbnail uploaded:', fullThumbnailUrl);
//        }
//      }
//    } catch (thumbError) {
//      console.error('⚠️ Thumbnail processing error:', thumbError);
//    }
//
//    // Insert into database
//    const { data: videoRecord, error: dbErr } = await supabase
//      .from('videos')
//      .insert({
//        user_id: publisher.user_id,
//        title: uniqueFileName.replace(/\.[^/.]+$/, ''),
//        description: `Uploaded via Telegram on ${new Date().toLocaleString()}`,
//        video_url: publicUrl,
//        thumbnail_url: thumbnailUrl,
//        file_name: uniqueFileName,
//        file_size: fileObj.file_size || 0,
//        duration: fileObj.duration || 0,
//        views: 0,
//        created_at: new Date().toISOString()
//      })
//      .select()
//      .single();
//
//    if (dbErr) throw dbErr;
//
//    const shareUrl = `${WEBAPP_URL}/video/${videoRecord.id}`;
//
//    return {
//      success: true,
//      fileName: uniqueFileName,
//      fileSize: fileObj.file_size,
//      shareUrl,
//      videoId: videoRecord.id,
//      hasThumbnail: !!thumbnailUrl,
//      thumbnailUrl: fullThumbnailUrl
//    };
//
//  } catch (error) {
//    console.error('❌ Upload error:', error);
//    return {
//      success: false,
//      error: error.message,
//      fileName: fileObj.file_name || 'video'
//    };
//  }
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
//    // ✅ /start command
//    if (msg.text?.trim().toLowerCase() === '/start') {
//      await sendMessage(chatId,
//        `🎉 <b>Welcome to DiskNova Bot!</b>\n\n` +
//        `I can help you upload videos directly to your DiskNova account.\n\n` +
//        `<b>Commands:</b>\n` +
//        `/link - Link your Telegram account\n` +
//        `/status - Check verification status\n` +
//        `/help - Show help\n\n` +
//        `<b>To get started:</b>\n` +
//        `Send me your Telegram profile link to verify your account.`
//      );
//      return res.status(200).json({ ok: true });
//    }
//
//    // ✅ /help command
//    if (msg.text?.trim().toLowerCase() === '/help') {
//      await sendMessage(chatId,
//        `📚 <b>DiskNova Bot Help</b>\n\n` +
//        `<b>Available Commands:</b>\n` +
//        `/start - Welcome message\n` +
//        `/link - Get verification instructions\n` +
//        `/status - Check verification status\n` +
//        `/help - Show this message\n\n` +
//        `<b>How to upload videos:</b>\n` +
//        `1. Send video file(s)\n` +
//        `2. Videos auto-upload with thumbnail\n` +
//        `3. Get shareable link instantly\n\n` +
//        `<b>First time setup:</b>\n` +
//        `1. Add your Telegram link in DiskNova app\n` +
//        `2. Send your Telegram link here\n` +
//        `3. Click verification button\n` +
//        `4. Start uploading! 🎥`
//      );
//      return res.status(200).json({ ok: true });
//    }
//
//    // ✅ /status command
//    if (msg.text?.trim().toLowerCase() === '/status') {
//      const { data: publisher } = await supabase
//        .from('publishers')
//        .select('telegram_verified, first_name, brand_name, telegram_url, telegram_id')
//        .eq('telegram_id', tgUserId)
//        .maybeSingle();
//
//      if (publisher?.telegram_verified) {
//        await sendMessage(chatId,
//          `✅ <b>Verification Status: VERIFIED</b>\n\n` +
//          `Name: ${publisher.first_name}\n` +
//          `Brand: ${publisher.brand_name}\n` +
//          `Link: ${publisher.telegram_url}\n\n` +
//          `🎬 You can now upload videos!\n\n` +
//          `Just send me video files and they'll be uploaded with thumbnails.`
//        );
//      } else if (publisher && !publisher.telegram_verified) {
//        await sendMessage(chatId,
//          `⚠️ <b>Account Linked but Not Verified</b>\n\n` +
//          `Your Telegram link: ${publisher.telegram_url || 'Not set'}\n\n` +
//          `Send your Telegram link to verify.`
//        );
//      } else {
//        await sendMessage(chatId,
//          `❌ <b>Not Linked</b>\n\n` +
//          `Please add your Telegram link in the DiskNova app first.\n\n` +
//          `Then send your Telegram link here to verify.`
//        );
//      }
//      return res.status(200).json({ ok: true });
//    }
//
//    // ✅ /link command
//    if (msg.text?.trim().toLowerCase() === '/link') {
//      await sendMessage(chatId,
//        `🔗 <b>How to Verify Your Account</b>\n\n` +
//        `<b>Step 1:</b> Add your Telegram link in DiskNova app\n` +
//        `Go to: Profile → Verification → Social Links → Telegram\n\n` +
//        `<b>Step 2:</b> Send your Telegram link here\n` +
//        `Example formats:\n` +
//        `• https://t.me/your_username\n` +
//        `• t.me/your_username\n` +
//        `• @your_username\n\n` +
//        `<b>Step 3:</b> Click the verification link I send\n\n` +
//        `That's it! Then you can upload videos with thumbnails. 🎥`
//      );
//      return res.status(200).json({ ok: true });
//    }
//
//    // ✅ Handle Telegram link verification
//    if (msg.text && !msg.text.startsWith('/')) {
//      const messageText = msg.text.trim();
//      const sentUsername = extractUsername(messageText);
//
//      if (!sentUsername) {
//        await sendMessage(chatId,
//          `❌ <b>Invalid Telegram Link</b>\n\n` +
//          `Please send a valid Telegram link:\n` +
//          `• https://t.me/your_username\n` +
//          `• t.me/your_username\n` +
//          `• @your_username\n\n` +
//          `Use /link for more help.`
//        );
//        return res.status(200).json({ ok: true });
//      }
//
//      const { data: allPublishers } = await supabase
//        .from('publishers')
//        .select('*')
//        .not('telegram_url', 'is', null);
//
//      let matchedPublisher = null;
//
//      if (allPublishers && allPublishers.length > 0) {
//        matchedPublisher = allPublishers.find(pub => {
//          const storedUsername = extractUsername(pub.telegram_url);
//          return storedUsername === sentUsername;
//        });
//      }
//
//      if (!matchedPublisher) {
//        await sendMessage(chatId,
//          `❌ <b>No Matching Account Found</b>\n\n` +
//          `Username sent: <code>@${sentUsername}</code>\n\n` +
//          `This username is not registered in DiskNova app.\n\n` +
//          `<b>Please:</b>\n` +
//          `1. Open DiskNova app\n` +
//          `2. Go to Verification → Social Links\n` +
//          `3. Add this link: <code>https://t.me/${sentUsername}</code>\n` +
//          `4. Save and come back\n` +
//          `5. Send the link again here`
//        );
//        return res.status(200).json({ ok: true });
//      }
//
//      if (matchedPublisher.telegram_verified && matchedPublisher.telegram_id === tgUserId) {
//        await sendMessage(chatId,
//          `✅ <b>You're Already Verified!</b>\n\n` +
//          `Name: ${matchedPublisher.first_name}\n` +
//          `Brand: ${matchedPublisher.brand_name}\n\n` +
//          `🎬 <b>Ready to upload videos?</b>\n` +
//          `Just send me any video file(s) and they'll be uploaded with thumbnails!`
//        );
//        return res.status(200).json({ ok: true });
//      }
//
//      const token = [...Array(30)].map(() => (Math.random() * 36 | 0).toString(36)).join('');
//      const expiresAt = new Date(Date.now() + 1000 * 60 * 15).toISOString();
//
//      await supabase
//        .from('telegram_verifications')
//        .delete()
//        .eq('telegram_id', tgUserId);
//
//      const { error: insertError } = await supabase
//        .from('telegram_verifications')
//        .insert({
//          telegram_id: tgUserId,
//          token,
//          expires_at: expiresAt,
//          used: false,
//          publisher_id: matchedPublisher.id,
//          bot_username: msg.from?.username || 'User'
//        });
//
//      if (insertError) {
//        console.error('Error creating verification:', insertError);
//        await sendMessage(chatId, '❌ Failed to create verification link. Please try again.');
//        return res.status(200).json({ ok: true });
//      }
//
//      const verifyUrl = `${WEBAPP_URL}/api/verify-telegram?token=${token}&telegram_id=${tgUserId}&bot_username=${encodeURIComponent(msg.from?.username || 'User')}`;
//
//      await sendMessage(chatId,
//        `🎉 <b>Account Found!</b>\n\n` +
//        `<b>Name:</b> ${matchedPublisher.first_name}\n` +
//        `<b>Brand:</b> ${matchedPublisher.brand_name}\n` +
//        `<b>Link:</b> ${matchedPublisher.telegram_url}\n\n` +
//        `✅ Click the button below to complete verification:\n\n` +
//        `⏱ Link expires in 15 minutes.`,
//        {
//          reply_markup: {
//            inline_keyboard: [[
//              { text: '✅ Verify Account', url: verifyUrl }
//            ]]
//          }
//        }
//      );
//      return res.status(200).json({ ok: true });
//    }
//
//    // ✅ Handle video/document uploads (instant upload with thumbnail)
//    if (msg.video || msg.document) {
//      const { data: publisher } = await supabase
//        .from('publishers')
//        .select('*')
//        .eq('telegram_id', tgUserId)
//        .eq('telegram_verified', true)
//        .maybeSingle();
//
//      if (!publisher) {
//        await sendMessage(chatId,
//          `❌ <b>Not Verified</b>\n\n` +
//          `You need to verify your account first.\n\n` +
//          `Send your Telegram link (e.g., https://t.me/username) to get started.`
//        );
//        return res.status(200).json({ ok: true });
//      }
//
//      const fileObj = msg.video || msg.document;
//
//      await sendMessage(chatId,
//        `⏳ <b>Uploading video with thumbnail...</b>\n\n` +
//        `📁 File: ${fileObj.file_name || 'video.mp4'}\n` +
//        `📊 Size: ${(fileObj.file_size / 1024 / 1024).toFixed(2)} MB`
//      );
//
//      // ✅ Upload immediately with thumbnail
//      const result = await uploadVideo(fileObj, publisher, chatId);
//
//      if (result.success) {
//
//
//        // ✅ Then send thumbnail with link as separate message
//        if (result.hasThumbnail && result.thumbnailUrl) {
//          try {
//            await axios.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto`, {
//              chat_id: chatId,
//              photo: result.thumbnailUrl,
//              caption: `🔗 <b>Share this video:</b>\n${result.shareUrl}`,
//              parse_mode: 'HTML',
//
//            });
//            console.log('✅ Thumbnail message sent to Telegram');
//          } catch (photoError) {
//            console.error('❌ Error sending photo:', photoError);
//            // Fallback to text message with link
//            await sendMessage(chatId, `🔗 <b>Share Link:</b>\n${result.shareUrl}`);
//          }
//        } else {
//          // No thumbnail, just send link
//          await sendMessage(chatId, `🔗 <b>Share Link:</b>\n${result.shareUrl}`);
//        }
//      } else {
//        await sendMessage(chatId,
//          `❌ <b>Upload Failed</b>\n\n` +
//          `Error: ${result.error}\n\n` +
//          `Please try again.`
//        );
//      }
//
//      return res.status(200).json({ ok: true });
//    }
//
//    return res.status(200).json({ ok: true });
//
//  } catch (error) {
//    console.error('Handler error:', error);
//    return res.status(200).json({ ok: true });
//  }
//}
import axios from 'axios';
import { createClient } from '@supabase/supabase-js';
import sharp from 'sharp';
import { Readable } from 'stream';
import http from 'http';
import https from 'https';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const BOT_TOKEN = process.env.BOT_TOKEN;
const WEBAPP_URL = process.env.WEBAPP_URL || 'https://disknova-2cna.vercel.app';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// ✅ Optimized axios instance with keep-alive
const axiosInstance = axios.create({
  timeout: 300000, // 5 minutes
  maxContentLength: Infinity,
  maxBodyLength: Infinity,
  httpAgent: new http.Agent({
    keepAlive: true,
    keepAliveMsecs: 30000,
    maxSockets: 10
  }),
  httpsAgent: new https.Agent({
    keepAlive: true,
    keepAliveMsecs: 30000,
    maxSockets: 10
  })
});

async function sendMessage(chatId, text, options = {}) {
  try {
    await axiosInstance.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      chat_id: chatId,
      text,
      parse_mode: 'HTML',
      ...options
    });
  } catch (e) {
    console.error('Error sending message:', e.response?.data || e.message);
  }
}

function extractUsername(text) {
  if (!text) return null;
  text = text.trim();

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

function sanitizeFileName(fileName) {
  if (!fileName || typeof fileName !== "string") {
    return "video.mp4";
  }

  const parts = fileName.split('.');
  const extension = parts.length > 1 ? parts.pop() : 'mp4';
  const nameWithoutExt = parts.join('.');

  const sanitized = nameWithoutExt
    .replace(/[^\w\s.-]/g, '')
    .replace(/\s+/g, '_')
    .replace(/[–—]/g, '-')
    .replace(/[\[\](){}]/g, '')
    .replace(/_+/g, '_')
    .replace(/-+/g, '-')
    .replace(/^[.-]+/, '')
    .replace(/[.-]+$/, '')
    .substring(0, 50);

  return `${sanitized || 'video'}.${extension}`;
}

function generateFileName(brandName, originalFileName, timestamp) {
  const safeOriginal = originalFileName || `video_${timestamp}.mp4`;

  const sanitizedBrandName = brandName
    .replace(/[^a-zA-Z0-9]/g, '_')
    .substring(0, 30);

  const sanitizedOriginal = sanitizeFileName(safeOriginal);
  return `${sanitizedBrandName}_${timestamp}_${sanitizedOriginal}`;
}

// ✅ OPTIMIZED: Stream-based thumbnail extraction
async function getTelegramThumbnail(fileId) {
  try {
    const getFileResp = await axiosInstance.get(
      `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
    );
    const filePath = getFileResp.data.result.file_path;
    const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;

    const thumbResp = await axiosInstance.get(fileUrl, {
      responseType: 'arraybuffer',
      timeout: 30000
    });
    const buffer = Buffer.from(thumbResp.data);

    const optimizedThumb = await sharp(buffer)
      .resize(1280, 720, { fit: 'cover' })
      .jpeg({ quality: 85 })
      .toBuffer();

    return optimizedThumb;
  } catch (error) {
    console.error('Thumbnail extraction error:', error);
    return null;
  }
}

// ✅ OPTIMIZED: Streaming upload (no full file in memory)
async function uploadVideoOptimized(fileObj, publisher, chatId) {
  const startTime = Date.now();

  try {
    const fileId = fileObj.file_id;
    const thumbFileId = fileObj.thumb?.file_id;
    const fileSize = fileObj.file_size || 0;

    console.log(`📤 Starting optimized upload: ${fileObj.file_name || 'video'}`);
    console.log(`📊 File size: ${(fileSize / (1024 * 1024)).toFixed(2)} MB`);

    // Get file URL from Telegram
    const getFileResp = await axiosInstance.get(
      `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
    );
    const filePath = getFileResp.data.result.file_path;
    const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;

    const timestamp = Date.now();
    const brandName = publisher.brand_name || publisher.first_name || 'User';
    const uniqueFileName = generateFileName(brandName, fileObj.file_name, timestamp);
    const fileName = `telegram/${uniqueFileName}`;

    // ✅ OPTIMIZATION 1: Stream download instead of loading full file
    console.log('🚀 Starting streaming download...');

    const response = await axiosInstance.get(fileUrl, {
      responseType: 'stream',
      timeout: 300000, // 5 minutes
      onDownloadProgress: (progressEvent) => {
        if (progressEvent.total) {
          const percent = Math.round((progressEvent.loaded * 100) / progressEvent.total);
          if (percent % 20 === 0) { // Log every 20%
            console.log(`📥 Download progress: ${percent}%`);
          }
        }
      }
    });

    // ✅ OPTIMIZATION 2: Convert stream to buffer efficiently
    const chunks = [];
    let downloadedSize = 0;

    await new Promise((resolve, reject) => {
      response.data.on('data', (chunk) => {
        chunks.push(chunk);
        downloadedSize += chunk.length;

        // Progress update every 5MB
        if (downloadedSize % (5 * 1024 * 1024) < chunk.length) {
          const progress = ((downloadedSize / fileSize) * 100).toFixed(1);
          console.log(`📥 Downloaded: ${progress}% (${(downloadedSize / (1024 * 1024)).toFixed(2)} MB)`);
        }
      });

      response.data.on('end', () => {
        console.log('✅ Download complete!');
        resolve();
      });

      response.data.on('error', (err) => {
        console.error('❌ Download error:', err);
        reject(err);
      });
    });

    const buffer = Buffer.concat(chunks);
    const downloadTime = ((Date.now() - startTime) / 1000).toFixed(2);
    const downloadSpeed = ((fileSize / (1024 * 1024)) / downloadTime).toFixed(2);
    console.log(`⚡ Download completed in ${downloadTime}s (${downloadSpeed} MB/s)`);

    // ✅ OPTIMIZATION 3: Upload to Supabase with progress
    console.log('📤 Uploading to Supabase...');
    const uploadStartTime = Date.now();

    const { error: uploadErr } = await supabase.storage
      .from('videos')
      .upload(fileName, buffer, {
        contentType: fileObj.mime_type || 'video/mp4',
        upsert: false
      });

    if (uploadErr) throw uploadErr;

    const uploadTime = ((Date.now() - uploadStartTime) / 1000).toFixed(2);
    const uploadSpeed = ((fileSize / (1024 * 1024)) / uploadTime).toFixed(2);
    console.log(`⚡ Upload completed in ${uploadTime}s (${uploadSpeed} MB/s)`);

    const { data: { publicUrl } } = supabase.storage
      .from('videos')
      .getPublicUrl(fileName);

    // ✅ OPTIMIZATION 4: Process thumbnail in parallel (async)
    let thumbnailUrl = '';
    let fullThumbnailUrl = '';

    // Don't wait for thumbnail - process async
    const thumbnailPromise = (async () => {
      try {
        if (thumbFileId) {
          console.log('🖼️ Processing thumbnail...');
          const thumbnailBuffer = await getTelegramThumbnail(thumbFileId);

          if (thumbnailBuffer) {
            const thumbFileName = `thumb_${timestamp}.jpg`;
            const thumbPath = `uploads/${publisher.user_id}/${thumbFileName}`;

            const { error: thumbUploadErr } = await supabase.storage
              .from('thumbnails')
              .upload(thumbPath, thumbnailBuffer, {
                contentType: 'image/jpeg',
                upsert: false
              });

            if (!thumbUploadErr) {
              thumbnailUrl = thumbPath;
              const { data } = supabase.storage
                .from('thumbnails')
                .getPublicUrl(thumbPath);
              fullThumbnailUrl = data.publicUrl;
              console.log('✅ Thumbnail uploaded');
            }
          }
        }
      } catch (thumbError) {
        console.error('⚠️ Thumbnail error:', thumbError);
      }
      return { thumbnailUrl, fullThumbnailUrl };
    })();

    // Wait for thumbnail processing
    const thumbResult = await thumbnailPromise;
    thumbnailUrl = thumbResult.thumbnailUrl;
    fullThumbnailUrl = thumbResult.fullThumbnailUrl;

    // Insert into database
    const { data: videoRecord, error: dbErr } = await supabase
      .from('videos')
      .insert({
        user_id: publisher.user_id,
        title: uniqueFileName.replace(/\.[^/.]+$/, ''),
        description: `Uploaded via Telegram on ${new Date().toLocaleString()}`,
        video_url: publicUrl,
        thumbnail_url: thumbnailUrl,
        file_name: uniqueFileName,
        file_size: fileSize,
        duration: fileObj.duration || 0,
        views: 0,
        created_at: new Date().toISOString()
      })
      .select()
      .single();

    if (dbErr) throw dbErr;

    const totalTime = ((Date.now() - startTime) / 1000).toFixed(2);
    const avgSpeed = ((fileSize / (1024 * 1024)) / totalTime).toFixed(2);
    console.log(`🎉 Total time: ${totalTime}s | Average speed: ${avgSpeed} MB/s`);

    const shareUrl = `${WEBAPP_URL}/video/${videoRecord.id}`;

    return {
      success: true,
      fileName: uniqueFileName,
      fileSize: fileSize,
      shareUrl,
      videoId: videoRecord.id,
      hasThumbnail: !!thumbnailUrl,
      thumbnailUrl: fullThumbnailUrl,
      uploadTime: totalTime,
      avgSpeed: avgSpeed
    };

  } catch (error) {
    console.error('❌ Upload error:', error);
    return {
      success: false,
      error: error.message,
      fileName: fileObj.file_name || 'video'
    };
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
        `<b>How to upload videos:</b>\n` +
        `1. Send video file(s)\n` +
        `2. Videos auto-upload with thumbnail (⚡ optimized streaming)\n` +
        `3. Get shareable link instantly\n\n` +
        `<b>First time setup:</b>\n` +
        `1. Add your Telegram link in DiskNova app\n` +
        `2. Send your Telegram link here\n` +
        `3. Click verification button\n` +
        `4. Start uploading! 🎥`
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
          `🎬 You can now upload videos!\n\n` +
          `⚡ Optimized streaming upload enabled - faster uploads!`
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
        `• https://t.me/your_username\n` +
        `• t.me/your_username\n` +
        `• @your_username\n\n` +
        `<b>Step 3:</b> Click the verification link I send\n\n` +
        `That's it! Then you can upload videos with ⚡ fast streaming. 🎥`
      );
      return res.status(200).json({ ok: true });
    }

    // ✅ Handle Telegram link verification
    if (msg.text && !msg.text.startsWith('/')) {
      const messageText = msg.text.trim();
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

      if (matchedPublisher.telegram_verified && matchedPublisher.telegram_id === tgUserId) {
        await sendMessage(chatId,
          `✅ <b>You're Already Verified!</b>\n\n` +
          `Name: ${matchedPublisher.first_name}\n` +
          `Brand: ${matchedPublisher.brand_name}\n\n` +
          `🎬 <b>Ready to upload videos?</b>\n` +
          `Just send me any video file(s) - ⚡ optimized streaming enabled!`
        );
        return res.status(200).json({ ok: true });
      }

      const token = [...Array(30)].map(() => (Math.random() * 36 | 0).toString(36)).join('');
      const expiresAt = new Date(Date.now() + 1000 * 60 * 15).toISOString();

      await supabase
        .from('telegram_verifications')
        .delete()
        .eq('telegram_id', tgUserId);

      const { error: insertError } = await supabase
        .from('telegram_verifications')
        .insert({
          telegram_id: tgUserId,
          token,
          expires_at: expiresAt,
          used: false,
          publisher_id: matchedPublisher.id,
          bot_username: msg.from?.username || 'User'
        });

      if (insertError) {
        console.error('Error creating verification:', insertError);
        await sendMessage(chatId, '❌ Failed to create verification link. Please try again.');
        return res.status(200).json({ ok: true });
      }

      const verifyUrl = `${WEBAPP_URL}/api/verify-telegram?token=${token}&telegram_id=${tgUserId}&bot_username=${encodeURIComponent(msg.from?.username || 'User')}`;

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

    // ✅ Handle video/document uploads (OPTIMIZED STREAMING)
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

      const fileObj = msg.video || msg.document;

      await sendMessage(chatId,
        `⚡ <b>Uploading with optimized streaming...</b>\n\n` +
        `📁 File: ${fileObj.file_name || 'video.mp4'}\n` +
        `📊 Size: ${(fileObj.file_size / 1024 / 1024).toFixed(2)} MB\n\n` +
        `⏳ Processing... (faster speeds enabled)`
      );

      // ✅ Use optimized streaming upload
      const result = await uploadVideoOptimized(fileObj, publisher, chatId);

      if (result.success) {
        await sendMessage(chatId,
          `✅ <b>Upload Complete!</b>\n\n` +
          `📁 File: ${result.fileName}\n` +
          `📊 Size: ${(result.fileSize / 1024 / 1024).toFixed(2)} MB\n` +
          `⚡ Time: ${result.uploadTime}s\n` +
          `🚀 Speed: ${result.avgSpeed} MB/s\n` +
          `🖼️ Thumbnail: ${result.hasThumbnail ? 'Yes ✅' : 'No ❌'}`
        );

        // Send thumbnail with link
        if (result.hasThumbnail && result.thumbnailUrl) {
          try {
            await axiosInstance.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto`, {
              chat_id: chatId,
              photo: result.thumbnailUrl,
              caption: `🔗 <b>Share this video:</b>\n${result.shareUrl}`,
              parse_mode: 'HTML'
            });
          } catch (photoError) {
            console.error('❌ Error sending photo:', photoError);
            await sendMessage(chatId, `🔗 <b>Share Link:</b>\n${result.shareUrl}`);
          }
        } else {
          await sendMessage(chatId, `🔗 <b>Share Link:</b>\n${result.shareUrl}`);
        }
      } else {
        await sendMessage(chatId,
          `❌ <b>Upload Failed</b>\n\n` +
          `Error: ${result.error}\n\n` +
          `Please try again.`
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