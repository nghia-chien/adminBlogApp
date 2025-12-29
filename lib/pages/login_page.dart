import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../models/user.dart' as models;
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailPasswordAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Sign in
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // Get current user after sign in
        final user = userCredential.user;
        if (user == null) {
          throw Exception('Không thể lấy thông tin người dùng');
        }

        // 🔒 CHECK ROLE - chỉ cho phép admin
        models.User? userData;
        try {
          userData = await ApiService.getUser(user.uid);
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching user data: $e');
          }
          // Nếu không lấy được userData, đăng xuất và báo lỗi
          await _auth.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể kiểm tra quyền truy cập. Vui lòng thử lại.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Kiểm tra role admin
        if (userData == null || userData.role != 'admin') {
          await _auth.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(userData == null
                    ? 'Tài khoản không tồn tại trong hệ thống'
                    : 'Tài khoản này không có quyền truy cập. Chỉ dành cho quản trị viên.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        // Nếu là admin, chuyển đến dashboard
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đăng nhập admin thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        }
      } else {
        // Sign up - wrap in additional try-catch to catch type cast errors
        try {
          await _auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đăng ký thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            });
          }
        } catch (signUpError) {
          // Catch any type cast or other errors during sign up
          if (kDebugMode) {
            print('Sign up error details: $signUpError');
          }
          if (kDebugMode) {
            print('Error type: ${signUpError.runtimeType}');
          }
          if (signUpError.toString().contains('PigeonUserDetails')) {
            // If it's a type cast error, user might still be created
            // Check if user was actually created
            final currentUser = _auth.currentUser;
            if (currentUser != null && mounted) {
              // User was created despite the error
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đăng ký thành công! (Có cảnh báo kỹ thuật)'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              });
            } else {
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      switch (e.code) {
        case 'weak-password':
          message = 'Mật khẩu quá yếu';
          break;
        case 'email-already-in-use':
          message = 'Email đã được sử dụng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'user-not-found':
          message = 'Không tìm thấy người dùng';
          break;
        case 'wrong-password':
          message = 'Sai mật khẩu';
          break;
        case 'permission-denied':
          message = e.message ?? 'Không có quyền truy cập';
          break;
        default:
          message = e.message ?? 'Đã xảy ra lỗi';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        
        if (mounted && userCredential.user != null) {
          // Kiểm tra role admin
          final user = userCredential.user!;
          models.User? userData;
          try {
            userData = await ApiService.getUser(user.uid);
          } catch (e) {
            if (kDebugMode) {
              print('Error fetching user data: $e');
            }
            // Nếu không lấy được userData, đăng xuất và báo lỗi
            await _auth.signOut();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không thể kiểm tra quyền truy cập. Vui lòng thử lại.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
            }
            return;
          }
          
          // Kiểm tra role admin
          if (userData == null || userData.role != 'admin') {
            await _auth.signOut();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(userData == null
                      ? 'Tài khoản không tồn tại trong hệ thống'
                      : 'Tài khoản này không có quyền truy cập. Chỉ dành cho quản trị viên.'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
            return;
          }
          
          // Nếu là admin, chuyển đến dashboard
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đăng nhập admin bằng Google thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập bị hủy'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on PlatformException catch (e) {
      String message = 'Lỗi đăng nhập Google';
      if (e.code == 'sign_in_failed') {
        if (e.message?.contains('10') == true) {
          message = 'Google Sign In chưa được cấu hình đúng. '
              'Vui lòng kiểm tra SHA-1 fingerprint trong Firebase Console.';
        } else {
          message = 'Đăng nhập Google thất bại: ${e.message ?? e.code}';
        }
      } else {
        message = 'Lỗi: ${e.message ?? e.code}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng nhập Google: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Logo or Icon
              Icon(
                Icons.account_circle,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              // Name field (only for sign up)
              if (!_isLogin) ...[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (!_isLogin && value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleEmailPasswordAuth,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
              ),
              const SizedBox(height: 16),
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Hoặc',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              // Google Sign In button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.g_mobiledata, size: 24);
                  },
                ),
                label: const Text('Đăng nhập bằng Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              // Toggle between login and sign up
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _formKey.currentState?.reset();
                        });
                      },
                child: Text(
                  _isLogin
                      ? 'Chưa có tài khoản? Đăng ký'
                      : 'Đã có tài khoản? Đăng nhập',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

