import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class CarbsenseTextbox extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType keyBoardType;
  final bool isPassword;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const CarbsenseTextbox({
    super.key,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.controller,
    this.isPassword = false,
    this.keyBoardType = TextInputType.text,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // return SizedBox(
    //  width: 320,
    //child: TextFormField(
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: isPassword,
      keyboardType: keyBoardType,
      validator: validator,
      style: AppTextStyles.body(context), // ← typed text style
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption(context), // ← label above field
        hintText: hint,
        hintStyle: AppTextStyles.caption(context).copyWith(
          color: Colors.grey[400], // ← hint text, greyed out
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 15) : null,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xff764abc), width: 2),
        ),
      ),
    );
  }
}
