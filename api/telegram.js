//
//import axios from 'axios';
//import { createClient } from '@supabase/supabase-js';
//
//const SUPABASE_URL = process.env.SUPABASE_URL;
//const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
//const BOT_TOKEN = process.env.BOT_TOKEN;
//const WEBAPP_URL = process.env.WEBAPP_URL || 'https://disknova-2cna.vercel.app';
//
//const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
//
//// Store pending uploads temporarily (in production, use Redis or database)
//const pendingUploads = new Map();
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
//  const username = msg.from?.username || msg.from?.first_name || 'User';
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
//        `/help - Show help\n` +
//        `/cancel - Cancel current upload\n\n` +
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
//        `/cancel - Cancel current upload\n` +
//        `/help - Show this message\n\n` +
//        `<b>How to upload videos:</b>\n` +
//        `1. Send video file\n` +
//        `2. Enter video title\n` +
//        `3. Enter description\n` +
//        `4. Video will be uploaded!\n\n` +
//        `<b>First time setup:</b>\n` +
//        `1. Add your Telegram link in DiskNova app\n` +
//        `2. Send your Telegram link here\n` +
//        `3. Click verification button\n` +
//        `4. Start uploading! 🎥`
//      );
//      return res.status(200).json({ ok: true });
//    }
//
//    // ✅ /cancel command
//    if (msg.text?.trim().toLowerCase() === '/cancel') {
//      if (pendingUploads.has(tgUserId)) {
//        pendingUploads.delete(tgUserId);
//        await sendMessage(chatId, '❌ Upload cancelled. Send a new video to start again.');
//      } else {
//        await sendMessage(chatId, 'No active upload to cancel.');
//      }
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
//          `Just send me a video file and I'll guide you through the process.`
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
//        `• https://t.me/Hkgaming07\n` +
//        `• t.me/Hkgaming07\n` +
//        `• @Hkgaming07\n\n` +
//        `<b>Step 3:</b> Click the verification link I send\n\n` +
//        `That's it! Then you can upload videos. 🎥`
//      );
//      return res.status(200).json({ ok: true });
//    }
//
//    // ✅ Handle Telegram link messages
//    if (msg.text && !msg.text.startsWith('/')) {
//      const messageText = msg.text.trim();
//      const sentUsername = extractUsername(messageText);
//
//      // Check if user is in middle of video upload
//      const pendingUpload = pendingUploads.get(tgUserId);
//
//      if (pendingUpload) {
//        // User is providing title or description
//        if (pendingUpload.step === 'waiting_title') {
//          pendingUpload.title = messageText;
//          pendingUpload.step = 'waiting_description';
//          pendingUploads.set(tgUserId, pendingUpload);
//
//          await sendMessage(chatId,
//            `✅ <b>Title saved:</b> ${messageText}\n\n` +
//            `📝 Now send the video description:\n` +
//            `(This will help viewers understand what the video is about)`
//          );
//          return res.status(200).json({ ok: true });
//        }
//
//        if (pendingUpload.step === 'waiting_description') {
//          pendingUpload.description = messageText;
//          pendingUpload.step = 'processing';
//          pendingUploads.set(tgUserId, pendingUpload);
//
//          // Now process the upload
//          await sendMessage(chatId, '⏳ <b>Processing your video...</b>\n\nPlease wait while we upload it to DiskNova.');
//
//          try {
//            const { fileObj, publisher } = pendingUpload;
//            const fileId = fileObj.file_id;
//
//            const getFileResp = await axios.get(
//              `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
//            );
//            const filePath = getFileResp.data.result.file_path;
//            const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;
//
//            const fileResp = await axios.get(fileUrl, { responseType: 'arraybuffer' });
//            const buffer = Buffer.from(fileResp.data);
//
//            const timestamp = Date.now();
//            const originalName = fileObj.file_name || `video_${timestamp}.mp4`;
//            const uniqueFileName = `${publisher.user_id}_${timestamp}_${originalName}`;
//            const fileName = `telegram/${uniqueFileName}`;
//
//            const { error: uploadErr } = await supabase.storage
//              .from('videos')
//              .upload(fileName, buffer, {
//                contentType: fileObj.mime_type || 'video/mp4',
//                upsert: false
//              });
//
//            if (uploadErr) throw uploadErr;
//
//            const { data: { publicUrl } } = supabase.storage
//              .from('videos')
//              .getPublicUrl(fileName);
//
//            const { data: videoRecord, error: dbErr } = await supabase
//              .from('videos')
//              .insert({
//                user_id: publisher.user_id,
//                title: pendingUpload.title,
//                description: pendingUpload.description,
//                video_url: publicUrl,
//                file_name: uniqueFileName,
//                file_size: fileObj.file_size || 0,
//                duration: fileObj.duration || 0,
//                views: 0,
//                created_at: new Date().toISOString()
//              })
//              .select()
//              .single();
//
//            if (dbErr) throw dbErr;
//
//            const shareUrl = `${WEBAPP_URL}/video/${videoRecord.id}`;
//
//            await sendMessage(chatId,
//              `✅ <b>Video Uploaded Successfully!</b>\n\n` +
//              `📁 <b>File:</b> ${originalName}\n` +
//              `📊 <b>Size:</b> ${(fileObj.file_size / 1024 / 1024).toFixed(2)} MB\n` +
//              `🎬 <b>Title:</b> ${pendingUpload.title}\n` +
//              `📝 <b>Description:</b> ${pendingUpload.description.substring(0, 50)}...\n\n` +
//              `🔗 <b>Share Link:</b>\n${shareUrl}`,
//              {
//                reply_markup: {
//                  inline_keyboard: [[
//                    { text: '🔗 View Video', url: shareUrl },
//                    { text: '📊 Dashboard', url: WEBAPP_URL }
//                  ]]
//                }
//              }
//            );
//
//            // Clear pending upload
//            pendingUploads.delete(tgUserId);
//
//          } catch (uploadError) {
//            console.error('Upload error:', uploadError);
//            await sendMessage(chatId,
//              `❌ <b>Upload Failed</b>\n\n` +
//              `Error: ${uploadError.message}\n\n` +
//              `Please try again by sending your video.`
//            );
//            pendingUploads.delete(tgUserId);
//          }
//
//          return res.status(200).json({ ok: true });
//        }
//      }
//
//      // If not in upload process, treat as Telegram link verification
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
//      // Search for matching publisher
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
//          `Just send me any video file and I'll help you upload it to DiskNova!`
//        );
//        return res.status(200).json({ ok: true });
//      }
//
//      // Generate verification token
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
//          publisher_id: matchedPublisher.id
//        });
//
//      if (insertError) {
//        console.error('Error creating verification:', insertError);
//        await sendMessage(chatId, '❌ Failed to create verification link. Please try again.');
//        return res.status(200).json({ ok: true });
//      }
//
//      const verifyUrl = `${WEBAPP_URL}/api/verify-telegram?token=${token}&telegram_id=${tgUserId}`;
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
//    // ✅ Handle video/document uploads
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
//      // Store upload info and ask for title
//      pendingUploads.set(tgUserId, {
//        fileObj,
//        publisher,
//        step: 'waiting_title',
//        timestamp: Date.now()
//      });
//
//      await sendMessage(chatId,
//        `🎬 <b>Video Received!</b>\n\n` +
//        `📁 File: ${fileObj.file_name || 'video.mp4'}\n` +
//        `📊 Size: ${(fileObj.file_size / 1024 / 1024).toFixed(2)} MB\n\n` +
//        `✍️ <b>Step 1/2:</b> Please send the video title:\n` +
//        `(Example: "How to cook pasta" or "Gaming highlights")\n\n` +
//        `Type /cancel to cancel this upload.`
//      );
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
// api/telegram.js
// api/telegram.js
import axios from 'axios';
import { createClient } from '@supabase/supabase-js';
import sharp from 'sharp';

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

// ✅ Sanitize filename - remove special characters
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


// ✅ Generate thumbnail from Telegram's built-in thumbnail
async function getTelegramThumbnail(fileId) {
  try {
    const getFileResp = await axios.get(
      `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
    );
    const filePath = getFileResp.data.result.file_path;
    const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;

    const thumbResp = await axios.get(fileUrl, { responseType: 'arraybuffer' });
    const buffer = Buffer.from(thumbResp.data);

    // Resize and optimize thumbnail using sharp
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

// ✅ Upload single video with thumbnail
async function uploadVideo(fileObj, publisher, chatId) {
  try {
    const fileId = fileObj.file_id;
    const thumbFileId = fileObj.thumb?.file_id;

    // Get video file from Telegram
    const getFileResp = await axios.get(
      `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
    );
    const filePath = getFileResp.data.result.file_path;
    const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;

    const fileResp = await axios.get(fileUrl, { responseType: 'arraybuffer' });
    const buffer = Buffer.from(fileResp.data);

    const timestamp = Date.now();
    const brandName = publisher.brand_name || publisher.first_name || 'User';
    const uniqueFileName = generateFileName(brandName, fileObj.file_name, timestamp);
    const fileName = `telegram/${uniqueFileName}`;

    console.log('📤 Uploading:', fileName);

    // Upload video to Supabase Storage
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

    // ✅ Get and upload thumbnail
    let thumbnailUrl = '';
    let fullThumbnailUrl = '';

    try {
      let thumbnailBuffer = null;

      if (thumbFileId) {
        console.log('🖼️ Extracting thumbnail from Telegram...');
        thumbnailBuffer = await getTelegramThumbnail(thumbFileId);
      }

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

          // Get full public URL
          const { data } = supabase.storage
            .from('thumbnails')
            .getPublicUrl(thumbPath);
          fullThumbnailUrl = data.publicUrl;

          console.log('✅ Thumbnail uploaded:', fullThumbnailUrl);
        }
      }
    } catch (thumbError) {
      console.error('⚠️ Thumbnail processing error:', thumbError);
    }

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
        file_size: fileObj.file_size || 0,
        duration: fileObj.duration || 0,
        views: 0,
        created_at: new Date().toISOString()
      })
      .select()
      .single();

    if (dbErr) throw dbErr;

    const shareUrl = `${WEBAPP_URL}/video/${videoRecord.id}`;

    return {
      success: true,
      fileName: uniqueFileName,
      fileSize: fileObj.file_size,
      shareUrl,
      videoId: videoRecord.id,
      hasThumbnail: !!thumbnailUrl,
      thumbnailUrl: fullThumbnailUrl
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
        `2. Videos auto-upload with thumbnail\n` +
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
          `Just send me video files and they'll be uploaded with thumbnails.`
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
        `That's it! Then you can upload videos with thumbnails. 🎥`
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
          `Just send me any video file(s) and they'll be uploaded with thumbnails!`
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

    // ✅ Handle video/document uploads (instant upload with thumbnail)
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
        `⏳ <b>Uploading video with thumbnail...</b>\n\n` +
        `📁 File: ${fileObj.file_name || 'video.mp4'}\n` +
        `📊 Size: ${(fileObj.file_size / 1024 / 1024).toFixed(2)} MB`
      );

      // ✅ Upload immediately with thumbnail
      const result = await uploadVideo(fileObj, publisher, chatId);

      if (result.success) {
        // ✅ First send success message
        await sendMessage(chatId,
          `✅ <b>Video Uploaded Successfully!</b>\n\n` +
          `📁 <b>File:</b> ${result.fileName}\n` +
          `📊 <b>Size:</b> ${(result.fileSize / 1024 / 1024).toFixed(2)} MB\n` +
          `${result.hasThumbnail ? '🖼️ <b>Thumbnail:</b> Generated\n' : ''}`
        );

        // ✅ Then send thumbnail with link as separate message
        if (result.hasThumbnail && result.thumbnailUrl) {
          try {
            await axios.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto`, {
              chat_id: chatId,
              photo: result.thumbnailUrl,
              caption: `🔗 <b>Share this video:</b>\n${result.shareUrl}`,
              parse_mode: 'HTML',
              reply_markup: {
                inline_keyboard: [[
                  { text: '🔗 Open Video', url: result.shareUrl },
                  { text: '📊 Dashboard', url: WEBAPP_URL }
                ]]
              }
            });
            console.log('✅ Thumbnail message sent to Telegram');
          } catch (photoError) {
            console.error('❌ Error sending photo:', photoError);
            // Fallback to text message with link
            await sendMessage(chatId, `🔗 <b>Share Link:</b>\n${result.shareUrl}`);
          }
        } else {
          // No thumbnail, just send link
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