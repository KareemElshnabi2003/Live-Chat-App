// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String groubName;
  final String callerImage;
  final bool isVideoCall;
  final bool isGroub;
  final String groubImg;

  final VoidCallback onPressAnswer;

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.groubImg,
    required this.callerImage,
    required this.isVideoCall,
    required this.onPressAnswer,
    required this.groubName,
    required this.isGroub,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  )..repeat(reverse: true);

  late final AnimationController _slideController = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  )..forward();

  late final AnimationController _floatController = AnimationController(
    duration: const Duration(milliseconds: 3000),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _pulseAnimation =
      Tween<double>(begin: 1.0, end: 1.05).animate(
    CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
  );

  late final Animation<double> _floatAnimation =
      Tween<double>(begin: -10, end: 10).animate(
    CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
  );

  // Audio player for ringtone
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingSound = false;

  @override
  void initState() {
    super.initState();
    _startRingtone();
  }

  @override
  void dispose() {
    _stopRingtone();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    super.dispose();
  }




// 3. عدل دالة التشغيل
  Future<void> _startRingtone() async {
    try {
      _isPlayingSound = true;

      // تحديد مسار الرنة من الـ Assets
      // اتأكد إن مسار الفايل مكتوب كامل زي ما هو في pubspec.yaml
      await _audioPlayer.setAsset('assets/sounds/past_live.mp3');

      // تفعيل التكرار (عشان الرنة تفضل شغالة لحد ما اليوزر يرد)
      await _audioPlayer.setLoopMode(LoopMode.one);

      // ضبط الصوت
      await _audioPlayer.setVolume(0.8);

      // تشغيل
      _audioPlayer.play();

    } catch (e) {
      debugPrint('Error playing ringtone: $e');
    }
  }

// 4. دالة الإيقاف
  Future<void> _stopRingtone() async {
    try {
      if (_isPlayingSound) {
        await _audioPlayer.stop();
        _isPlayingSound = false;
      }
    } catch (e) {
      debugPrint('Error stopping ringtone: $e');
    }
  }
  // // Start playing ringtone
  // Future<void> _startRingtone() async {
  //   try {
  //     _isPlayingSound = true;
  //
  //     // Option 1: Play from assets (preferred)
  //     // Make sure you have a ringtone file in assets/sounds/ringtone.mp3
  //     await _audioPlayer.play(AssetSource('past_live.mp3'));
  //
  //     // Set to loop
  //     await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  //
  //     // Set volume (0.0 to 1.0)
  //     await _audioPlayer.setVolume(0.8);
  //
  //     // Option 2: Play from URL (if you want to use online sound)
  //     // await _audioPlayer.play(UrlSource('YOUR_RINGTONE_URL'));
  //   } catch (e) {
  //     debugPrint('Error playing ringtone: $e');
  //   }
  // }
  //
  // // Stop playing ringtone
  // Future<void> _stopRingtone() async {
  //   try {
  //     if (_isPlayingSound) {
  //       await _audioPlayer.stop();
  //       _isPlayingSound = false;
  //     }
  //   } catch (e) {
  //     debugPrint('Error stopping ringtone: $e');
  //   }
  // }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onReject() async {
    await _stopRingtone();
    Get.back();
    _showSnackBar('تم رفض المكالمة', const Color(0xffE74C3C));
  }

  void _onAccept() async {
    await _stopRingtone();
    widget.onPressAnswer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _stopRingtone();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF4F2E9),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -80,
                child: AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, _) => Transform.translate(
                    offset:
                        Offset(_floatAnimation.value, _floatAnimation.value),
                    child: Container(
                      width: 62.5.w,
                      height: 62.5.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.isVideoCall
                                ? const Color(0xff9B59B6).withOpacity(0.1)
                                : const Color(0xff3498DB).withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -120,
                left: -120,
                child: AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, _) => Transform.translate(
                    offset:
                        Offset(-_floatAnimation.value, -_floatAnimation.value),
                    child: Container(
                      width: 75.w,
                      height: 75.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.isVideoCall
                                ? const Color(0xff8E44AD).withOpacity(0.08)
                                : const Color(0xff2980B9).withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 60),
                  const Spacer(),
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (var i = 0; i < 3; i++)
                          ModernRipple(
                            delay: i * 0.6,
                            size: 220.0 + (i * 50),
                            color: widget.isVideoCall
                                ? const Color(0xff9B59B6)
                                : const Color(0xff3498DB),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.isVideoCall
                                    ? const Color(0xff9B59B6).withOpacity(0.25)
                                    : const Color(0xff3498DB).withOpacity(0.25),
                                blurRadius: 50,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: widget.isGroub
                                ? CircleAvatar(
                                    radius: 95,
                                    backgroundImage: widget.groubImg
                                                    .toString() ==
                                                "" ||
                                            widget.groubImg.toString() == "null"
                                        ? null
                                        : NetworkImage(
                                            widget.groubImg),
                                    child: widget.groubImg.toString() == "" ||
                                            widget.groubImg.toString() == "null"
                                        ? textNormal(
                                            widget.groubName[0],
                                            AppColors.blackColor,
                                            10.w,
                                            FontWeight.bold)
                                        : null,
                                  )
                                : CircleAvatar(
                                    radius: 95,
                                    backgroundImage: widget.callerImage
                                                    .toString() ==
                                                "" ||
                                            widget.callerImage.toString() ==
                                                "null"
                                        ? null
                                        : NetworkImage(
                                            widget.callerImage),
                                    child:
                                        widget.callerImage.toString() == "" ||
                                                widget.callerImage.toString() ==
                                                    "null"
                                            ? textNormal(
                                                widget.callerName[0],
                                                AppColors.blackColor,
                                                10.w,
                                                FontWeight.bold)
                                            : null,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.5.w),
                  FadeTransition(
                    opacity: _slideController,
                    child: Text(
                      widget.isGroub
                          ? "${widget.callerName} من المحادثة  ${widget.groubName}"
                          : widget.callerName,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 8.w,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _slideController,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'يتصل بك الآن',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 3.5.w,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff7F8C8D),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const AnimatedDots(),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ModernCallButton(
                          icon: widget.isVideoCall
                              ? Icons.videocam_rounded
                              : Icons.call_rounded,
                          color: const Color(0xff2ECC71),
                          label: 'قبول',
                          onPressed: _onAccept,
                          isPrimary: true,
                        ),
                        ModernCallButton(
                          icon: Icons.close_rounded,
                          color: const Color(0xffE74C3C),
                          label: 'رفض',
                          onPressed: _onReject,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernCallButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const ModernCallButton({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<ModernCallButton> createState() => _ModernCallButtonState();
}

class _ModernCallButtonState extends State<ModernCallButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: 1.0, end: 0.9).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  bool _isPressed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Container(
              width: 17.5.w,
              height: 17.5.w,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_isPressed ? 0.3 : 0.45),
                    blurRadius: _isPressed ? 15 : 30,
                    spreadRadius: _isPressed ? 0 : 4,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 35,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              widget.label,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 4.w,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernRipple extends StatefulWidget {
  final double delay;
  final double size;
  final Color color;

  const ModernRipple({
    super.key,
    required this.delay,
    required this.size,
    required this.color,
  });

  @override
  State<ModernRipple> createState() => _ModernRippleState();
}

class _ModernRippleState extends State<ModernRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 2500),
    vsync: this,
  );

  late final Animation<double> _animation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        width: widget.size * _animation.value,
        height: widget.size * _animation.value,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withOpacity(0.25 * (1 - _animation.value)),
            width: 2.5,
          ),
        ),
      ),
    );
  }
}

class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        children: List.generate(3, (index) {
          final opacity =
              ((_controller.value - index * 0.2) % 1.0).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff7F8C8D).withOpacity(opacity * 0.8),
              ),
            ),
          );
        }),
      ),
    );
  }
}
