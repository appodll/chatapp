import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioItem extends StatelessWidget {
  final button;
  final sound;
  const AudioItem({super.key, required this.sound, required this.button});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: Get.width - 160,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          sound,
          button
        ],
      ),
    );
  }
}