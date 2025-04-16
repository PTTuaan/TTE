import 'package:flutter/material.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';
import 'package:tte/Page/home_page.dart';
import 'package:tte/Page/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _passwordVisible;
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();

  void register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Future<void> login() async {
    try {
      // Xử lý đăng nhập tại đây (ví dụ: gọi API hoặc kiểm tra thông tin đăng nhập)
      print("Logging in with email: ${_userEmailController.text.trim()} and password: ${_userPasswordController.text.trim()}");
      // Giả lập đăng nhập thành công
      print("Login successful with email: ${_userEmailController.text.trim()}");
    } catch (e) {
      // Xử lý lỗi chung
      String message = 'Đăng nhập thất bại: $e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 100),
              const SizedBox(height: 20),
              const Text("Xin Chào", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Chào mừng đến với chúng tôi!', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _userEmailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(16.0),
                  labelText: 'Email',
                  hintText: 'Nhập email của bạn',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _userPasswordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(16.0),
                  labelText: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu của bạn',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                },
                child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              const SizedBox(height: 10),
              SignInButton(
                buttonSize: ButtonSize.medium,
                buttonType: ButtonType.google,
                onPressed: () {
                  print('click');
                },
              ),
              const SizedBox(height: 10),
              SignInButton(
                buttonSize: ButtonSize.medium,
                buttonType: ButtonType.apple,
                onPressed: () {
                  print('click');
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SignInButton.mini(buttonType: ButtonType.facebook, onPressed: () {}),
                  SignInButton.mini(buttonType: ButtonType.microsoft, onPressed: () {}),
                  SignInButton.mini(buttonType: ButtonType.github, onPressed: () {}),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Not a member? "),
                  GestureDetector(
                    onTap: register,
                    child: const Text("Register Now", style: TextStyle(fontSize: 16, color: Colors.blue)),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}