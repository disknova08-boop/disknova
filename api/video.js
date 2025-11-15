export default async (req, res) => {
  const videoId = req.query.id;

  if (!videoId) {
    return res.status(400).send('Video ID is required');
  }

  // ✅ Validate UUID format (basic check)
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!uuidRegex.test(videoId)) {
    return res.status(400).send('Invalid video ID format');
  }

  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DiskNova - Video Player</title>
    <meta property="og:title" content="DiskNova Video">
    <meta property="og:description" content="Watch this video on DiskNova">
    <meta property="og:type" content="video.other">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            max-width: 900px;
            width: 100%;
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }

        .video-container {
            position: relative;
            width: 100%;
            background: #000;
            aspect-ratio: 16 / 9;
            cursor: pointer;
        }

        /* ✅ Thumbnail display */
        .thumbnail-wrapper {
            position: relative;
            width: 100%;
            height: 100%;
            background-size: cover;
            background-position: center;
            background-color: #000;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .thumbnail-wrapper.no-thumbnail {
            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
        }

        .play-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(0, 0, 0, 0.3);
            transition: all 0.3s;
        }

        .video-container:hover .play-overlay {
            background: rgba(0, 0, 0, 0.5);
        }

        .play-button {
            width: 90px;
            height: 90px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.4);
            transition: all 0.3s;
        }

        .video-container:hover .play-button {
            transform: scale(1.1);
            background: white;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.6);
        }

        .play-icon {
            width: 0;
            height: 0;
            border-left: 28px solid #667eea;
            border-top: 16px solid transparent;
            border-bottom: 16px solid transparent;
            margin-left: 8px;
        }

        .no-thumbnail-icon {
            font-size: 80px;
            opacity: 0.3;
        }

        .loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-size: 18px;
            text-align: center;
            z-index: 10;
        }

        .spinner {
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top: 4px solid white;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 10px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .info-section {
            padding: 30px;
        }

        .video-title {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 10px;
        }

        .video-meta {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            color: #64748b;
            font-size: 14px;
            margin-bottom: 20px;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .video-description {
            color: #475569;
            line-height: 1.6;
            margin-bottom: 30px;
        }

        .actions {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            justify-content: center;
            margin-top: 20px;
        }

        .btn {
            padding: 14px 32px;
            border-radius: 12px;
            border: none;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .btn-download {
            background: #4CAF50;
            color: white;
        }

        .btn-download:hover {
            background: #45a049;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(76, 175, 80, 0.4);
        }

        .btn-view {
            background: #2196F3;
            color: white;
        }

        .btn-view:hover {
            background: #1976D2;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(33, 150, 243, 0.4);
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background: #f1f5f9;
            color: #475569;
        }

        .btn-secondary:hover {
            background: #e2e8f0;
        }

        .app-notice {
            text-align: center;
            color: #64748b;
            font-size: 14px;
            margin-top: 15px;
            font-style: italic;
        }

        .error-container {
            text-align: center;
            padding: 60px 30px;
        }

        .error-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }

        .error-title {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 10px;
        }

        .error-message {
            color: #64748b;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        .publisher-info {
            background: #f8fafc;
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
        }

        .publisher-name {
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 5px;
        }

        .publisher-brand {
            color: #64748b;
            font-size: 14px;
        }

        .debug-info {
            background: #fef3c7;
            border: 2px solid #fbbf24;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            font-family: monospace;
            font-size: 12px;
            display: none;
            text-align: left;
            word-break: break-all;
        }

        @media (max-width: 640px) {
            .video-title {
                font-size: 20px;
            }

            .actions {
                flex-direction: column;
            }

            .btn {
                width: 100%;
                justify-content: center;
            }

            .play-button {
                width: 70px;
                height: 70px;
            }

            .play-icon {
                border-left: 22px solid #667eea;
                border-top: 13px solid transparent;
                border-bottom: 13px solid transparent;
                margin-left: 6px;
            }
        }
    </style>
</head>
<body>
<div class="container" id="app">
    <div class="video-container">
        <div class="loading" id="loading">
            <div class="spinner"></div>
            <div>Loading video...</div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
    const SUPABASE_URL = 'https://evajqtqydxmtezgeaief.supabase.co';
    const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8';
    const VIDEO_ID = '${videoId}';

    // ✅ Google Play Store URL
    const GOOGLE_PLAY_URL = 'https://play.google.com/store/apps/details?id=com.disknova.app';

    const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    function redirectToPlayStore() {
        console.log('🔗 Redirecting to Google Play Store:', GOOGLE_PLAY_URL);
        // Uncomment when you have actual Play Store URL:
        // window.location.href = GOOGLE_PLAY_URL;
        alert('📱 Download DiskNova App from Play Store to watch this video!\\n\\n' + GOOGLE_PLAY_URL);
    }

    async function loadVideo() {
        const app = document.getElementById('app');
        const loading = document.getElementById('loading');

        try {
            console.log('🎬 Loading video with ID:', VIDEO_ID);

            if (!VIDEO_ID || VIDEO_ID === 'undefined') {
                throw new Error('No video ID provided');
            }

            // ✅ Get video data
            const { data: video, error: videoError } = await supabase
                .from('videos')
                .select('*')
                .eq('id', VIDEO_ID)
                .single();

            console.log('📊 Video query response:', { video, error: videoError });

            if (videoError) {
                console.error('❌ Supabase error:', videoError);
                throw new Error(\`Database error: \${videoError.message}\`);
            }

            if (!video) {
                throw new Error('Video not found in database');
            }

            // ✅ Get publisher info
            let publisher = null;
            if (video.user_id) {
                const { data: publisherData, error: publisherError } = await supabase
                    .from('publishers')
                    .select('first_name, last_name, brand_name')
                    .eq('id', video.user_id)
                    .single();

                if (!publisherError && publisherData) {
                    publisher = publisherData;
                }
                console.log('👤 Publisher query response:', { publisher, error: publisherError });
            }

            console.log('✅ Video loaded successfully:', video.title);

            // ✅ Get thumbnail URL if available
            let thumbnailUrl = '';
            let thumbnailStyle = '';

            if (video.thumbnail_url && video.thumbnail_url.trim()) {
                const { data } = supabase.storage
                    .from('thumbnails')
                    .getPublicUrl(video.thumbnail_url);
                thumbnailUrl = data.publicUrl;
                thumbnailStyle = \`background-image: url('\${thumbnailUrl}');\`;
                console.log('🖼️ Thumbnail URL:', thumbnailUrl);
            }

            // ✅ Increment view count
            try {
                const { error: viewError } = await supabase.rpc('increment_video_views', {
                    video_id: VIDEO_ID
                });
                if (!viewError) {
                    console.log('👁️ View count incremented');
                } else {
                    console.warn('⚠️ Could not increment views:', viewError);
                }
            } catch (viewError) {
                console.warn('⚠️ View increment failed:', viewError);
            }

            loading.style.display = 'none';

            const publisherName = publisher ?
                \`\${publisher.first_name || ''} \${publisher.last_name || ''}\`.trim() :
                'Unknown Publisher';

            // ✅ Display thumbnail with play button (NO VIDEO PLAYER)
            app.innerHTML = \`
                <div class="video-container" onclick="redirectToPlayStore()">
                    <div class="thumbnail-wrapper \${!thumbnailUrl ? 'no-thumbnail' : ''}" style="\${thumbnailStyle}">
                        \${!thumbnailUrl ? '<div class="no-thumbnail-icon">🎬</div>' : ''}
                        <div class="play-overlay">
                            <div class="play-button">
                                <div class="play-icon"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="info-section">
                    <h1 class="video-title">\${video.title || 'Untitled Video'}</h1>
                    <div class="video-meta">
                        <div class="meta-item">
                            <span>👁️</span>
                            <span>\${(video.views || 0) + 1} views</span>
                        </div>
                        \${video.duration ? \`
                            <div class="meta-item">
                                <span>⏱️</span>
                                <span>\${formatDuration(video.duration)}</span>
                            </div>
                        \` : ''}
                        \${video.file_size ? \`
                            <div class="meta-item">
                                <span>📦</span>
                                <span>\${formatFileSize(video.file_size)}</span>
                            </div>
                        \` : ''}
                        <div class="meta-item">
                            <span>📅</span>
                            <span>\${formatDate(video.created_at)}</span>
                        </div>
                    </div>
                    \${video.description ? \`
                        <p class="video-description">\${video.description}</p>
                    \` : ''}

                    <div class="actions">
                        <button class="btn btn-download" onclick="redirectToPlayStore()">
                            <span>📥</span>
                            <span>Download App</span>
                        </button>
                        <button class="btn btn-view" onclick="redirectToPlayStore()">
                            <span>👁️</span>
                            <span>View in App</span>
                        </button>
                    </div>

                    <p class="app-notice">
                        📱 <strong>Download DiskNova App to watch this video!</strong><br>
                        Web playback is not supported. Click the thumbnail or buttons above.
                    </p>

                    \${publisher ? \`
                        <div class="publisher-info">
                            <div class="publisher-name">
                                Uploaded by \${publisherName}
                            </div>
                            \${publisher.brand_name ? \`
                                <div class="publisher-brand">
                                    \${publisher.brand_name}
                                </div>
                            \` : ''}
                        </div>
                    \` : ''}
                </div>
            \`;

        } catch (error) {
            console.error('💥 Error loading video:', error);
            loading.style.display = 'none';

            app.innerHTML = \`
                <div class="error-container">
                    <div class="error-icon">❌</div>
                    <h1 class="error-title">Video Not Found</h1>
                    <p class="error-message">
                        The video you're looking for doesn't exist or has been removed.
                    </p>
                    <div class="debug-info" id="debugInfo">
                        <strong>Debug Information:</strong><br>
                        Video ID: ${videoId}<br>
                        Error: \${error.message}<br>
                        URL: \${window.location.href}<br>
                        Stack: \${error.stack || 'N/A'}
                    </div>
                    <button class="btn btn-secondary" onclick="document.getElementById('debugInfo').style.display='block'" style="margin: 10px auto;">
                        Show Debug Info
                    </button>
                    <button class="btn btn-primary" onclick="window.location.href='https://disknova-2cna.vercel.app'">
                        Go to Home
                    </button>
                </div>
            \`;
        }
    }

    function formatDuration(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return \`\${mins}:\${secs.toString().padStart(2, '0')}\`;
    }

    function formatFileSize(bytes) {
        if (bytes < 1024) return bytes + ' B';
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
        return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
    }

    function formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    }

    function shareVideo() {
        const url = window.location.href;
        const title = document.querySelector('.video-title')?.textContent || 'Check out this video!';

        if (navigator.share) {
            navigator.share({
                title: title,
                url: url
            }).catch(() => {
                copyLink();
            });
        } else {
            copyLink();
        }
    }

    function copyLink() {
        const url = window.location.href;
        navigator.clipboard.writeText(url).then(() => {
            alert('Link copied to clipboard! ✅\\n' + url);
        }).catch(() => {
            alert('Failed to copy link');
        });
    }

    // ✅ Load video when page loads
    window.addEventListener('DOMContentLoaded', loadVideo);
</script>
</body>
</html>
  `;

  res.setHeader('Content-Type', 'text/html');
  res.status(200).send(html);
};