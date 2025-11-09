import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const SUPABASE_URL = "https://evajqtqydxmtezgeaief.supabase.co"
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!  // ये secret env में रखना
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

serve(async (req) => {
  const body = await req.json()

  // Telegram message extract करना
  const message = body.message
  if (!message?.video) {
    return new Response("No video found", { status: 200 })
  }

  const file_id = message.video.file_id
  const user_id = message.from.id
  const username = message.from.username || "unknown"

  // Telegram से file download link लो
  const TELEGRAM_BOT_TOKEN = Deno.env.get("TELEGRAM_TOKEN")!
  const fileInfo = await fetch(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getFile?file_id=${file_id}`)
  const fileData = await fileInfo.json()
  const file_path = fileData.result.file_path

  const fileUrl = `https://api.telegram.org/file/bot${TELEGRAM_BOT_TOKEN}/${file_path}`

  // file को Supabase storage में upload करो
  const res = await fetch(fileUrl)
  const arrayBuffer = await res.arrayBuffer()
  const fileName = `${user_id}_${Date.now()}.mp4`

  const { error } = await supabase.storage
    .from("telegram_uploads")
    .upload(fileName, arrayBuffer, { contentType: "video/mp4" })

  if (error) {
    console.error(error)
    return new Response("Upload failed", { status: 500 })
  }

  // Optional: Database में record भी डाल दो
  await supabase.from("telegram_videos").insert({
    user_id,
    username,
    file_name: fileName,
  })

  // Telegram को reply
  await fetch(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      chat_id: user_id,
      text: `✅ Video uploaded successfully!\nFilename: ${fileName}`,
    }),
  })

  return new Response("ok", { status: 200 })
})
