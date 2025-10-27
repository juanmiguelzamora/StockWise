import 'package:flutter/material.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';

class InputSection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const InputSection({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: AppColors.textPrimary, // 👈 color of the inputted text
                fontSize: 16, // optional: adjust text size
              ),
              decoration: InputDecoration(
                hintText: 'Ask about stock, trends, or predictions...',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary, // 👈 optional: hint text color
                ),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (value) => onSend(value),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () => onSend(controller.text),
            mini: true,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
