import 'package:flutter/material.dart';

import 'button_custom.dart';
import 'colors.dart';

void informationDialog(BuildContext context, String label, String content) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width > 600
          ? 400
          : MediaQuery.of(context).size.width,
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(color: Colors.transparent),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: label == "warning"
                            ? Colors.red[800]
                            : colorPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        label == "warning" ? Icons.close : Icons.check,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(content, textAlign: TextAlign.center),
                SizedBox(height: 16),
                label == "warning"
                    ? ButtonSecondary(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        name: "Ok",
                      )
                    : ButtonPrimary(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        name: "Ok",
                      ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      );
    },
  );
}

void confirmationDialog(
  BuildContext context,
  String label,
  String content, {
  Function? no,
  Function? yes,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width > 600
          ? 400
          : MediaQuery.of(context).size.width,
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(color: Colors.transparent),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: label == "warning"
                            ? Colors.red[800]
                            : colorPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        label == "warning" ? Icons.close : Icons.check,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(content, textAlign: TextAlign.center),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ButtonSecondary(
                        onTap: () {
                          no!();
                        },
                        name: "No",
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ButtonPrimary(
                        onTap: () {
                          yes!();
                        },
                        name: "Yes",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      );
    },
  );
}
