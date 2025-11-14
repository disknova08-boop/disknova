// api/reset-password.js
// Create this file in your Vercel project at: /api/reset-password.js

export default async (req, res) => {
  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - DiskNova</title>
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
            background: rgba(37, 99, 235, 0.1);
        }

        h1 {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 12px;
            text-align: center;
        }

        .message {
            font-size: 16px;
            color: #64748b;
            line-height: 1.6;
            margin-bottom: 32px;
            text-align: center;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 8px;
        }

        input {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            font-size: 16px;
            transition: all 0.3s;
            background: #f8fafc;
        }

        input:focus {
            outline: none;
            border-color: #2563eb;
            background: white;
        }

        .password-toggle {
            position: relative;
        }

        .toggle-btn {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            font-size: 20px;
            color: #64748b;
            padding: 4px;
        }

        .btn {
            width: 100%;
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
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }

        .btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        .error-message {
            background: #fef2f2;
            border: 2px solid #fca5a5;
            border-radius: 12px;
            padding: 12px 16px;
            margin-bottom: 20px;
            font-size: 14px;
            color: #991b1b;
            display: none;
        }

        .success-message {
            background: #f0fdf4;
            border: 2px solid #86efac;
            border-radius: 12px;
            padding: 12px 16px;
            margin-bottom: 20px;
            font-size: 14px;
            color: #166534;
            display: none;
        }

        .password-requirements {
            font-size: 13px;
            color: #64748b;
            margin-top: 8px;
            padding-left: 4px;
        }

        .requirement {
            margin: 4px 0;
        }

        .requirement.valid {
            color: #16a34a;
        }

        .requirement.invalid {
            color: #dc2626;
        }

        .footer {
            margin-top: 32px;
            padding-top: 24px;
            border-top: 1px solid #e2e8f0;
            color: #94a3b8;
            font-size: 14px;
            text-align: center;
        }

        .spinner {
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top: 3px solid white;
            width: 20px;
            height: 20px;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        #successView {
            display: none;
            text-align: center;
        }

        .success-icon {
            width: 100px;
            height: 100px;
            margin: 0 auto 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 56px;
            background: rgba(34, 197, 94, 0.1);
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
<div class="container">
    <div class="logo">
        <div class="logo-icon">💾</div>
        <div class="logo-text">DiskNova</div>
    </div>

    <div id="formView">
        <div class="status-icon">🔐</div>
        <h1>Reset Your Password</h1>
        <p class="message">Enter your new password below</p>

        <div class="error-message" id="errorMessage"></div>
        <div class="success-message" id="successMessage"></div>

        <form id="resetForm">
            <div class="form-group">
                <label for="newPassword">New Password</label>
                <div class="password-toggle">
                    <input
                        type="password"
                        id="newPassword"
                        placeholder="Enter new password"
                        required
                    >
                    <button type="button" class="toggle-btn" onclick="togglePassword('newPassword')">
                        👁️
                    </button>
                </div>
                <div class="password-requirements">
                    <div class="requirement" id="req-length">• At least 6 characters</div>
                </div>
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <div class="password-toggle">
                    <input
                        type="password"
                        id="confirmPassword"
                        placeholder="Confirm new password"
                        required
                    >
                    <button type="button" class="toggle-btn" onclick="togglePassword('confirmPassword')">
                        👁️
                    </button>
                </div>
            </div>

            <button type="submit" class="btn" id="submitBtn">
                <span id="btnText">Reset Password</span>
                <div class="spinner" id="btnSpinner" style="display: none;"></div>
            </button>
        </form>
    </div>

    <div id="successView">
        <div class="success-icon">✅</div>
        <h1>Password Reset Successful!</h1>
        <p class="message">
            Your password has been updated successfully. You can now login with your new password.
        </p>
        <button class="btn" onclick="goToDashboard()">
            Back to Dashboard
        </button>
    </div>

    <div class="footer">
        © 2025 DiskNova. All rights reserved.
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
    const SUPABASE_URL = 'https://evajqtqydxmtezgeaief.supabase.co';
    const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8';
    const DASHBOARD_URL = 'https://disknova-2cna.vercel.app';

    const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    const newPasswordInput = document.getElementById('newPassword');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const reqLength = document.getElementById('req-length');
    const errorMessage = document.getElementById('errorMessage');
    const successMessage = document.getElementById('successMessage');
    const submitBtn = document.getElementById('submitBtn');
    const btnText = document.getElementById('btnText');
    const btnSpinner = document.getElementById('btnSpinner');
    const formView = document.getElementById('formView');
    const successView = document.getElementById('successView');

    // Validate password requirements
    newPasswordInput.addEventListener('input', function() {
        const password = this.value;

        if (password.length >= 6) {
            reqLength.classList.add('valid');
            reqLength.classList.remove('invalid');
            reqLength.textContent = '✓ At least 6 characters';
        } else {
            reqLength.classList.add('invalid');
            reqLength.classList.remove('valid');
            reqLength.textContent = '• At least 6 characters';
        }
    });

    function togglePassword(inputId) {
        const input = document.getElementById(inputId);
        input.type = input.type === 'password' ? 'text' : 'password';
    }

    function showError(message) {
        errorMessage.textContent = message;
        errorMessage.style.display = 'block';
        successMessage.style.display = 'none';
    }

    function showSuccess(message) {
        successMessage.textContent = message;
        successMessage.style.display = 'block';
        errorMessage.style.display = 'none';
    }

    function hideMessages() {
        errorMessage.style.display = 'none';
        successMessage.style.display = 'none';
    }

    function setLoading(isLoading) {
        submitBtn.disabled = isLoading;
        btnText.style.display = isLoading ? 'none' : 'inline';
        btnSpinner.style.display = isLoading ? 'block' : 'none';
    }

    function goToDashboard() {
        window.location.href = DASHBOARD_URL;
    }

    document.getElementById('resetForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideMessages();

        const newPassword = newPasswordInput.value;
        const confirmPassword = confirmPasswordInput.value;

        // Validation
        if (newPassword.length < 6) {
            showError('Password must be at least 6 characters long');
            return;
        }

        if (newPassword !== confirmPassword) {
            showError('Passwords do not match');
            return;
        }

        setLoading(true);

        try {
            console.log('🔐 Updating password...');

            const { data, error } = await supabase.auth.updateUser({
                password: newPassword
            });

            if (error) {
                throw error;
            }

            console.log('✅ Password updated successfully');

            // Show success view
            formView.style.display = 'none';
            successView.style.display = 'block';

        } catch (error) {
            console.error('❌ Password reset failed:', error);
            showError(error.message || 'Failed to reset password. Please try again.');
        } finally {
            setLoading(false);
        }
    });

    // Verify reset token on page load
    window.addEventListener('DOMContentLoaded', async function() {
        try {
            console.log('🔐 Verifying reset token...');

            // Get URL parameters
            const urlParams = new URLSearchParams(window.location.search);
            const token_hash = urlParams.get('token_hash');
            const type = urlParams.get('type');

            console.log('Token hash:', token_hash ? 'Present' : 'Missing');
            console.log('Type:', type);

            if (!token_hash || !type) {
                showError('Invalid reset link. Missing required parameters.');
                submitBtn.disabled = true;
                return;
            }

            // Verify the token
            const { data, error } = await supabase.auth.verifyOtp({
                token_hash: token_hash,
                type: type
            });

            if (error) {
                console.error('❌ Token verification failed:', error);
                showError('Invalid or expired reset link. Please request a new password reset.');
                submitBtn.disabled = true;
                return;
            }

            console.log('✅ Valid reset token - User can now set new password');

        } catch (error) {
            console.error('Verification error:', error);
            showError('Error validating reset link. Please try again.');
            submitBtn.disabled = true;
        }
    });
</script>
</body>
</html>
  `;

  res.setHeader('Content-Type', 'text/html');
  res.status(200).send(html);
};