import 'package:flutter/material.dart';
import 'package:tte/Page/login_page.dart'; // Giả sử bạn đã định nghĩa LoginPage

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late bool _passwordVisible;
  late bool _confPasswordVisible;
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userConfPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _confPasswordVisible = false;
  }

  Future<void> register() async {
    if (_userPasswordController.text != _userConfPasswordController.text) {
      // Nếu mật khẩu và xác nhận mật khẩu không khớp
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp.')),
      );
      return;
    }

    try {
      // Xử lý đăng ký tại đây (ví dụ: gọi API hoặc lưu thông tin)
      print("Đăng ký với email: ${_userEmailController.text.trim()} và mật khẩu: ${_userPasswordController.text.trim()}");
      // Giả lập đăng ký thành công
      print("Đăng ký thành công: ${_userEmailController.text.trim()}");
      // Chuyển hướng về trang đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      // Xử lý lỗi chung
      String message = 'Đăng ký thất bại: $e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
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
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _userConfPasswordController,
                obscureText: !_confPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(16.0),
                  labelText: 'Nhập lại mật khẩu',
                  hintText: 'Nhập mật khẩu của bạn',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _confPasswordVisible = !_confPasswordVisible;
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
                onPressed: register,
                child: const Text('Register', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already a member? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Login Now",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}