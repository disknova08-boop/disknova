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
        }

        video {
            width: 100%;
            height: auto;
            display: block;
            max-height: 70vh;
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
        }

        .btn {
            padding: 12px 24px;
            border-radius: 10px;
            border: none;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 8px;
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

    const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    async function loadVideo() {
        const app = document.getElementById('app');
        const loading = document.getElementById('loading');

        try {
            console.log('🎬 Loading video with ID:', VIDEO_ID);

            if (!VIDEO_ID || VIDEO_ID === 'undefined') {
                throw new Error('No video ID provided');
            }

            // ✅ First, get the video data
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

            // ✅ Then, separately get publisher info
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

            // ✅ Display video player
            app.innerHTML = \`
                <div class="video-container">
                    <video controls autoplay controlsList="nodownload">
                        <source src="\${video.video_url}" type="video/mp4">
                        Your browser does not support the video tag.
                    </video>
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
                        <button class="btn btn-primary" onclick="downloadVideo('\${video.video_url}', '\${video.title}')">
                            <span>⬇️</span>
                            <span>Download Video</span>
                        </button>
                        <button class="btn btn-secondary" onclick="shareVideo()">
                            <span>🔗</span>
                            <span>Share Link</span>
                        </button>
                        <button class="btn btn-secondary" onclick="copyLink()">
                            <span>📋</span>
                            <span>Copy Link</span>
                        </button>
                    </div>
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

    async function downloadVideo(url, filename) {
        try {
            console.log('📥 Starting download...');
            const response = await fetch(url);
            const blob = await response.blob();
            const blobUrl = window.URL.createObjectURL(blob);

            const a = document.createElement('a');
            a.href = blobUrl;
            a.download = (filename || 'video') + '.mp4';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(blobUrl);

            alert('Download started! ✅');
        } catch (error) {
            console.error('Download error:', error);
            alert('Download failed. Please try again.');
        }
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