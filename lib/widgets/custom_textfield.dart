import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final bool obscureText;
  
  const CustomTextfield({super.key, required this.controller, required this.label,  this.keyboardType= TextInputType.text, this.obscureText=false});

  @override
  Widget build(BuildContext context) {
    return   Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    
  }
}