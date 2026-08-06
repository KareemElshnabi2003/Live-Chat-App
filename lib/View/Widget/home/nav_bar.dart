import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/main.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      selectedItemColor: pref! ? AppColors.whiteColor : AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: currentIndex,
      selectedIconTheme: IconThemeData(
        size: 28,
        color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
      ),
      unselectedIconTheme: const IconThemeData(
        size: 24,
        color: AppColors.black2TextColor,
      ),
      iconSize: 24,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(IconsaxPlusLinear.home_1),
          activeIcon: Icon(IconsaxPlusBold.home_1),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(IconsaxPlusLinear.message),
          activeIcon: Icon(IconsaxPlusBold.message),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(IconsaxPlusLinear.shop),
          activeIcon: Icon(IconsaxPlusBold.shop),
          label: 'Market',
        ),
        BottomNavigationBarItem(
          icon: Icon(IconsaxPlusLinear.setting),
          activeIcon: Icon(IconsaxPlusBold.setting),
          label: 'Profile',
        ),
      ],
      onTap: onTap,
    );
  }
}
