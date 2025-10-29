import 'package:edtech/presentation/widget/custom_shimer.dart';
import 'package:flutter/material.dart';

class ProShimmer extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  const ProShimmer({
    super.key,
    required this.height,
    required this.width,
    this.radius = 0,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CustomShimmer.fromColors(
        highlightColor: Colors.white,
        baseColor: Colors.grey,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
