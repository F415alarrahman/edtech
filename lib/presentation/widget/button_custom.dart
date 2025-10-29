import 'package:flutter/material.dart';

import 'colors.dart';

class ButtonIcon extends StatelessWidget {
  final IconData icon;

  const ButtonIcon({super.key, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorPrimary, colorSecondary],
        ),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class ButtonPrimary extends StatelessWidget {
  final String? name;
  final Function onTap;
  const ButtonPrimary({super.key, this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colorPrimary,
          border: Border.all(width: 2, color: colorPrimary),
        ),
        child: Text(
          "$name",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ButtonPrimaryNoRounded extends StatelessWidget {
  final String? name;
  final Function onTap;
  const ButtonPrimaryNoRounded({super.key, this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red[900] ?? Colors.transparent, Colors.red],
          ),
        ),
        child: Text(
          "$name",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ButtonSecondary extends StatelessWidget {
  final String? name;
  final Function onTap;
  const ButtonSecondary({super.key, this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(width: 2, color: colorPrimary),
        ),
        child: Text(
          "$name",
          textAlign: TextAlign.center,
          style: const TextStyle(color: colorPrimary),
        ),
      ),
    );
  }
}
