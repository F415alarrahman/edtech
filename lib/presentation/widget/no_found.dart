import 'package:edtech/presentation/widget/images_path.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoFound extends StatelessWidget {
  final String message; 
  final String subMessage;

  const NoFound({
    super.key,
    this.message = "No Result Found", 
    this.subMessage =
        "We can’t find any item matching your search", 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              ImagesAssets.noFound,
              width: 128,
              height: 128,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            // Pesan Utama
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
                height: 1.2,
                fontWeight: FontWeight.bold,
                fontFamily: "Google Sans",
              ),
            ),
            const SizedBox(height: 8),
            // Sub Pesan
            Text(
              subMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A4A),
                height: 1.5,
                fontFamily: "Roboto",
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
