// api/confirm.js
// Create this file in your Vercel project at: /api/confirm.js

export default async (req, res) => {
  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Verification - DiskNova</title>
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
            max-width: 500px;
            width: 100%;
            background: white;
            border-radius: 24px;
            padding: 48px 32px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            text-align: center;
        }

        .logo {
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 32px;
        }

        .logo-icon {
            width: 60px;
            height: 60px;
            background: rgba(37, 99, 235, 0.1);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            margin-right: 12px;
        }

        .logo-text {
            font-size: 32px;
            font-weight: 700;
            color: #1e293b;
        }

        .status-icon {
            width: 100px;
            height: 100px;
            margin: 0 auto 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 56px;
        }

        .status-icon.success {
            background: rgba(34, 197, 94, 0.1);
        }

        .status-icon.loading {
            background: rgba(59, 130, 246, 0.1);
            animation: pulse 2s ease-in-out infinite;
        }

        .status-icon.error {
            background: rgba(239, 68, 68, 0.1);
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.05); opacity: 0.8; }
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .spinner {
            border: 4px solid rgba(37, 99, 235, 0.2);
            border-radius: 50%;
            border-top: 4px solid #2563eb;
            width: 56px;
            height: 56px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }

        h1 {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 12px;
        }

        .message {
            font-size: 16px;
            color: #64748b;
            line-height: 1.6;
            margin-bottom: 32px;
        }

        .btn {
            display: inline-block;
            padding: 16px 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }

        .error-details {
            background: #fef2f2;
            border: 2px solid #fca5a5;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 24px;
            font-size: 14px;
            color: #991b1b;
            text-align: left;
            word-break: break-word;
        }

        .footer {
            margin-top: 32px;
            padding-top: 24px;
            border-top: 1px solid #e2e8f0;
            color: #94a3b8;
            font-size: 14px;
        }

        @media (max-width: 640px) {
            .container {
                padding: 32px 24px;
            }

            h1 {
                font-size: 24px;
            }

            .logo-text {
                font-size: 28px;
            }
        }
    </style>
</head>
<body>
<div class="container" id="app">
    <div class="logo">
        <div class="logo-icon">💾</div>
        <div class="logo-text">DiskNova</div>
    </div>

    <div class="status-icon loading">
        <div class="spinner"></div>
    </div>

    <h1>Verifying Your Email</h1>
    <p class="message">Please wait while we verify your email address...</p>
</div>

<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
    const SUPABASE_URL = 'https://evajqtqydxmtezgeaief.supabase.co';
    const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8';
    const DASHBOARD_URL = 'https://disknova-2cna.vercel.app';

    const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    async function verifyEmail() {
        const app = document.getElementById('app');

        try {
            console.log('🔐 Starting email verification...');
            console.log('Current URL:', window.location.href);

            // Get the hash fragment (everything after #)
            const hashParams = new URLSearchParams(window.location.hash.substring(1));

            // Also check query parameters as fallback
            const queryParams = new URLSearchParams(window.location.search);

            // Try to get token from hash first, then from query
            const access_token = hashParams.get('access_token') || queryParams.get('access_token');
            const refresh_token = hashParams.get('refresh_token') || queryParams.get('refresh_token');
            const token_hash = queryParams.get('token_hash');
            const type = queryParams.get('type') || hashParams.get('type');

            console.log('Access Token:', access_token ? 'Present' : 'Missing');
            console.log('Refresh Token:', refresh_token ? 'Present' : 'Missing');
            console.log('Token Hash:', token_hash ? 'Present' : 'Missing');
            console.log('Type:', type);

            // Method 1: If we have access_token and refresh_token (from email link)
            if (access_token && refresh_token) {
                console.log('✅ Using access/refresh tokens from email link');

                const { data, error } = await supabase.auth.setSession({
                    access_token: access_token,
                    refresh_token: refresh_token
                });

                if (error) throw error;

                console.log('✅ Email verified successfully via session!');
                showSuccess();
                return;
            }

            // Method 2: If we have token_hash (OTP verification)
            if (token_hash && type) {
                console.log('✅ Using OTP verification with token_hash');

                const { data, error } = await supabase.auth.verifyOtp({
                    token_hash: token_hash,
                    type: type
                });

                if (error) throw error;

                console.log('✅ Email verified successfully via OTP!');
                showSuccess();
                return;
            }

            // If no valid params found
            throw new Error('Invalid verification link. Missing required authentication parameters.');

        } catch (error) {
            console.error('❌ Verification failed:', error);
            showError(error.message || 'Verification failed');
        }
    }

    function showSuccess() {
        const app = document.getElementById('app');
        app.innerHTML = \`
            <div class="logo">
                <div class="logo-icon">💾</div>
                <div class="logo-text">DiskNova</div>
            </div>

            <div class="status-icon success">
                ✅
            </div>

            <h1>Email Verified Successfully!</h1>
            <p class="message">
                Your email has been verified. You can now access your dashboard and start uploading videos.
            </p>

            <button class="btn" onclick="goToDashboard()">
                Go to Dashboard
            </button>

            <div class="footer">
                © 2025 DiskNova. All rights reserved.
            </div>
        \`;
    }

    function showError(errorMessage) {
        const app = document.getElementById('app');
        app.innerHTML = \`
            <div class="logo">
                <div class="logo-icon">💾</div>
                <div class="logo-text">DiskNova</div>
            </div>

            <div class="status-icon error">
                ❌
            </div>

            <h1>Verification Failed</h1>
            <p class="message">
                We couldn't verify your email address. The link may have expired or been used already.
            </p>

            <div class="error-details">
                <strong>Error:</strong> \${errorMessage}
            </div>

            <button class="btn" onclick="goToDashboard()">
                Back to Dashboard
            </button>

            <div class="footer">
                Need help? Contact support at support@disknova.com
            </div>
        \`;
    }

    function goToDashboard() {
        window.location.href = DASHBOARD_URL;
    }

    // Start verification when page loads
    window.addEventListener('DOMContentLoaded', verifyEmail);
</script>
</body>
</html>
  `;

  res.setHeader('Content-Type', 'text/html');
  res.status(200).send(html);
};