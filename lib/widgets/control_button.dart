import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final IconData icon; // Icon hiển thị trên nút
  final VoidCallback? onPressed; // Hàm callback khi nhấn nút
  final String text; // Text bên dưới nút
  final Color backgroundColor; // Màu nền của nút

  const ControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            minimumSize: const Size(50, 50),
            shape: const CircleBorder(),
            elevation: 4,
          ),
          child: Icon(icon, color: Colors.white, size: 25),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}