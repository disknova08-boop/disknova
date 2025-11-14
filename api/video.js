const https = require('https');

module.exports = async (req, res) => {
  const videoId = req.query.id;

  if (!videoId) {
    return res.status(400).send('Video ID is required');
  }

  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DiskNova - Video Player</title>
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
            if (!VIDEO_ID) {
                throw new Error('No video ID provided');
            }

            const { data: video, error } = await supabase
                .from('videos')
                .select(\`
                    *,
                    publishers:user_id (
                        first_name,
                        last_name,
                        brand_name
                    )
                \`)
                .eq('id', VIDEO_ID)
                .single();

            if (error || !video) {
                throw new Error('Video not found');
            }

            await supabase.rpc('increment_video_views', { video_id: VIDEO_ID });

            loading.style.display = 'none';

            const publisher = video.publishers;
            const publisherName = publisher ?
                \`\${publisher.first_name || ''} \${publisher.last_name || ''}\`.trim() :
                'Unknown';

            app.innerHTML = \`
                <div class="video-container">
                    <video controls autoplay>
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
                            <span>Download</span>
                        </button>
                        <button class="btn btn-secondary" onclick="shareVideo()">
                            <span>🔗</span>
                            <span>Share</span>
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
            console.error('Error loading video:', error);
            loading.style.display = 'none';
            app.innerHTML = \`
                <div class="error-container">
                    <div class="error-icon">❌</div>
                    <h1 class="error-title">Video Not Found</h1>
                    <p class="error-message">
                        The video you're looking for doesn't exist or has been removed.
                    </p>
                    <button class="btn btn-primary" onclick="window.location.href='/'">
                        Go Home
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
            const response = await fetch(url);
            const blob = await response.blob();
            const blobUrl = window.URL.createObjectURL(blob);

            const a = document.createElement('a');
            a.href = blobUrl;
            a.download = filename || 'video.mp4';
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
            alert('Link copied to clipboard! ✅');
        }).catch(() => {
            alert('Failed to copy link');
        });
    }

    window.addEventListener('DOMContentLoaded', loadVideo);
</script>
</body>
</html>
  `;

  res.setHeader('Content-Type', 'text/html');
  res.status(200).send(html);
};