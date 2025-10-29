import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'images_path.dart';

class DialogCustom {
  void showLoading(BuildContext context) {
    Future.delayed(Duration.zero).then((value) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 32),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(ImagesAssets.logo, height: 80),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Silahkan Tunggu..",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 4),
                  const CupertinoActivityIndicator(radius: 20),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void showMessage(BuildContext context, String error) {
    Future.delayed(Duration.zero).then((value) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 32),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(ImagesAssets.logo, height: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "$error ",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
