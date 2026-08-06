import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/start%20page/page_start.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(
      const Duration(milliseconds: 500),
      () {
        if (sharedPreferences!.getString("page") == "Home") {
          Get.offAll(
            () => const HomeView(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
          );
        } else {
          Get.off(() => const PageStart(),
              transition: Transition.leftToRightWithFade);
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SizedBox(
        height: 100.h,
        width: 100.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            textNormal(S.of(context).splashText, AppColors.blackTextColor,
                3.5.w, FontWeight.w400),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}
