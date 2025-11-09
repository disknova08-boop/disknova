import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  final _newEmailController = TextEditingController();
  final _currentPasswordForEmailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoadingEmail = false;
  bool _isLoadingPassword = false;

  final supabase = Supabase.instance.client;

  // @override
  // void dispose() {
  //   _newEmailController.dispose();
  //   _currentPasswordForEmailController.dispose();
  //   _oldPasswordController.dispose();
  //   _newPasswordController.dispose();
  //   _confirmPasswordController.dispose();
  //   super.dispose();
  // }

  Future<bool> _isEmailRegistered(String email) async {
    try {
      final res = await supabase.functions.invoke(
        'auth-check-email',
        body: {'email': email.trim()},
      );
      final data = res.data;
      print(data);
      if (data is Map && data['exists'] == true) return true;
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> _updateEmail() async {
    if (!_formKeyEmail.currentState!.validate()) return;

    setState(() => _isLoadingEmail = true);

    try {
      final newEmail = _newEmailController.text.trim();

      // Check if email is already registered
      final isRegistered = await _isEmailRegistered(newEmail);

      if (isRegistered) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This email is already registered. Please enter a different email.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() => _isLoadingEmail = false);
        return;
      }

      await supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email updated successfully! Please check your new email for confirmation.'),
            backgroundColor: Colors.green,
          ),
        );

        _newEmailController.clear();
        _currentPasswordForEmailController.clear();
      }
    } on AuthException catch (e) {
      if (mounted) {
        print('Error: ${e.message}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        print('Error: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingEmail = false);
    }
  }

  Future<void> _updatePassword() async {
    if (!_formKeyPassword.currentState!.validate()) return;

    setState(() => _isLoadingPassword = true);

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
        emailRedirectTo: 'https://disknova-lv7x6dvuy-disknovas-projects.vercel.app/confirm'
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingPassword = false);
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                side:  BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWideScreen ? 80 : 20,
          vertical: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Change Email Section
            const Text(
              'Change Email',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Security First :)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKeyEmail,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Old Email',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: currentUser?.email ?? '',
                      enabled: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'New Email',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter new email',
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter new email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Current Password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentPasswordForEmailController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter current password',
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoadingEmail ? null : _updateEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoadingEmail
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Update Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),

            // Change Password Section
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Security First :)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKeyPassword,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Old Password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter old password',
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter old password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm new password',
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoadingPassword ? null : _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoadingPassword
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Update Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}