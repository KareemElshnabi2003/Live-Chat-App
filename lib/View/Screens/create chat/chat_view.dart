//======================== new code ======================================================

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Data/Model/message_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/create%20chat/settings.dart';
import 'package:live_chat/View/Screens/Chat%20Botton%20Sheet/show_bottom_change_music.dart';
import 'package:live_chat/View/Screens/Chat%20Botton%20Sheet/show_bottom_sheet_persons_chat.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
// Import url_launcher if you want to open links
// import 'package:url_launcher/url_launcher.dart';

//region Voice Recording Wave Widget
class VoiceRecordingWave extends StatefulWidget {
  final bool isRecording;
  final Color? waveColor;
  final double? height;
  final double? width;
  final int barCount;

  const VoiceRecordingWave({
    super.key,
    required this.isRecording,
    this.waveColor,
    this.height = 30,
    this.width = 100,
    this.barCount = 5,
  });

  @override
  State<VoiceRecordingWave> createState() => _VoiceRecordingWaveState();
}

class _VoiceRecordingWaveState extends State<VoiceRecordingWave>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + _random.nextInt(400)),
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.1, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && widget.isRecording) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(VoiceRecordingWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    for (var controller in _controllers) {
      controller.repeat(reverse: true);
    }
  }

  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(widget.barCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: 3,
                height: widget.isRecording
                    ? (widget.height! * _animations[index].value)
                    : 8,
                decoration: BoxDecoration(
                  color: widget.waveColor ?? Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
//endregion

//region Enhanced Voice Recording Widget
class EnhancedVoiceRecording extends StatefulWidget {
  final bool isRecording;
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final VoidCallback? onCancelRecording;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? waveColor;
  final Color? timerColor;

  const EnhancedVoiceRecording({
    super.key,
    required this.isRecording,
    this.onStartRecording,
    this.onStopRecording,
    this.onCancelRecording,
    this.backgroundColor,
    this.iconColor,
    this.waveColor,
    this.timerColor,
  });

  @override
  State<EnhancedVoiceRecording> createState() => _EnhancedVoiceRecordingState();
}

class _EnhancedVoiceRecordingState extends State<EnhancedVoiceRecording>
    with SingleTickerProviderStateMixin {
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(EnhancedVoiceRecording oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      debugPrint('Starting recording timer');
      _startTimer();
      _animationController.forward();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      debugPrint('Stopping recording timer');
      _stopTimer();
      _animationController.reset();
    }
  }

  void _startTimer() {
    _recordingDuration = Duration.zero;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (widget.isRecording) {
        setState(() {
          _recordingDuration += const Duration(milliseconds: 100);
          debugPrint('Timer tick: ${_recordingDuration.inSeconds} seconds');
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _recordingDuration = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (widget.isRecording) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            FadeTransition(
              opacity: _animationController,
              child: const Icon(
                Icons.fiber_manual_record,
                color: Colors.red,
                size: 12,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(_recordingDuration),
              style: TextStyle(
                color: widget.timerColor ?? Colors.teal,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VoiceRecordingWave(
                isRecording: widget.isRecording,
                waveColor: widget.waveColor ?? Colors.teal,
                width: 15.w,
                height: 25,
                barCount: 10,
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    debugPrint('Stop/Send recording');
                    widget.onStopRecording?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    debugPrint('Cancel recording');
                    widget.onCancelRecording?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onLongPressStart: (_) {
          debugPrint('Start recording');
          widget.onStartRecording?.call();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.teal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mic,
            color: widget.iconColor ?? Colors.teal,
            size: 24,
          ),
        ),
      );
    }
  }
}
//endregion

//region PinnedAdWidget - New Widget for displaying pinned ads
class PinnedAdWidget extends StatelessWidget {
  final String? adTitle;
  final String? adLink;
  final String? adImage;
  final VoidCallback? onTap;

  const PinnedAdWidget({
    super.key,
    this.adTitle,
    this.adLink,
    this.adImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: () {
        if (adLink?.isNotEmpty == true && adLink != "null") {
          print("Opening ad link: $adLink");
          try {
            final uri = Uri.parse(adLink!);
            launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            print("Error opening link: $e");
          }
        }
        onTap?.call();
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: pref!
              ? AppColors.darkcolor.withOpacity(0.8)
              : AppColors.whiteColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ad Image Section
            if (adImage?.isNotEmpty == true && adImage != "null")
              Container(
                height: 15.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      "$adImage",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    // Pinned Icon
                    Positioned(
                      top: 10,
                      right: isRtl ? null : 10,
                      left: isRtl ? 10 : null,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          LucideIcons.pin,
                          color: AppColors.whiteColor,
                          size: 4.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content Section
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  if (adTitle?.isNotEmpty == true && adTitle != "null")
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: textNormal(
                              adTitle!,
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.blackTextColor,
                              3.5.w,
                              FontWeight.w700,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Link preview
                  if (adLink?.isNotEmpty == true && adLink != "null")
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: .8.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            IconsaxPlusLinear.link,
                            size: 3.5.w,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                textNormal(
                                  _getDomainFromUrl(adLink!),
                                  AppColors.primaryColor,
                                  3.w,
                                  FontWeight.w600,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 0.2.h),
                                textNormal(
                                  "Tap to visit",
                                  AppColors.inActiveColor,
                                  2.8.w,
                                  FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            IconsaxPlusLinear.arrow_right_2,
                            size: 4.w,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      // If URL parsing fails, show a shortened version
      if (url.length > 30) {
        return '${url.substring(0, 30)}...';
      }
      return url;
    }
  }
}
//endregion

//region ChatMessage Model
class ChatMessage {
  final String message;
  final bool isFromSender;
  final String timestamp;
  final String? imageUrl;
  final String? senderName;
  final String messageId;
  final List<MessageReactions> reaction;
  final String messageType;
  final bool isPending;

  ChatMessage({
    required this.senderName,
    required this.message,
    required this.isFromSender,
    required this.timestamp,
    required this.imageUrl,
    required this.reaction,
    required this.messageId,
    required this.messageType,
    required this.isPending,
  });
}
//endregion

//region ChatView
class ChatView extends StatefulWidget {
  final UserChatModel? userChatModel;
  final bool isPin;
  final bool isGust;

  const ChatView({
    super.key,
    required this.userChatModel,
    required this.isPin,
    required this.isGust,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final controller = Get.put(ChatController());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !controller.isLoadingMore &&
          controller.hasMoreMessages) {
        controller.loadMoreMessages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget buildVoiceRecordingSection(ChatController controller, bool isRtl) {
    if (controller.isRecording) {
      return Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          child: EnhancedVoiceRecording(
            isRecording: controller.isRecording,
            onStartRecording: controller.startRecording,
            onStopRecording: controller.stopRecording,
            onCancelRecording: controller.cancelRecording,
            backgroundColor: pref!
                ? AppColors.darkcolor.withOpacity(0.3)
                : AppColors.whiteColor.withOpacity(0.3),
            iconColor:
                pref! ? AppColors.secondaryColor : AppColors.blackTextColor,
            waveColor: AppColors.primaryColor,
            timerColor: AppColors.primaryColor,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => controller.startRecording(),
        child: Icon(
          IconsaxPlusLinear.microphone,
          color: pref! ? AppColors.secondaryColor : AppColors.blackTextColor,
          size: 6.w,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // See chat_view_friend.dart for why this must stay Get.find, not Get.put.
    Get.find<ChatController>();
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        widget.isGust ? Get.back() : Get.offAll(() => const HomeView());
      },
      child: Scaffold(
        backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
        body: SafeArea(
          child: GetBuilder<ChatController>(
            builder: (controller) => controller.statuesRequest ==
                    StatuesRequest.loading
                ? Center(
                    child: textNormal(
                      S.of(context).joining,
                      AppColors.primaryColor,
                      3.5.w,
                      FontWeight.w500,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      image: _getBackgroundImage(widget.userChatModel!),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 2.h,
                        right: 3.w,
                        left: 3.w,
                      ),
                      child: Column(
                        children: [
                          _buildAppBar(controller, isRtl),
                          if (widget.isPin && _hasAd(widget.userChatModel!))
                            SizedBox(height: 2.h),
                          if (widget.isPin && _hasAd(widget.userChatModel!))
                            _buildPinnedAdBanner(widget.userChatModel!),
                          SizedBox(height: 2.h),
                          _buildMusicBar(controller, isRtl, context),
                          Expanded(
                            child: Obx(() {
                              return ListView.separated(
                                separatorBuilder: (context, index) {
                                  if (index >= controller.messages.length - 1) {
                                    return const SizedBox(height: 20);
                                  }
                                  final currentMessage =
                                      controller.messages[index];
                                  final nextMessage =
                                      controller.messages[index + 1];
                                  return SizedBox(
                                    height: nextMessage.senderName !=
                                            currentMessage.senderName
                                        ? 15
                                        : 0,
                                  );
                                },
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(
                                    vertical: 1.h, horizontal: 0),
                                reverse: true,
                                itemCount: controller.messages.length +
                                    (controller.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == controller.messages.length &&
                                      controller.isLoadingMore) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final message = controller.messages[index];
                                  final isLastInGroup = _isLastMessageInGroup(
                                      controller.messages, index);
                                  final isFirstInGroup = _isFirstMessageInGroup(
                                      controller.messages, index);
                                  return ChatBubbleWidget(
                                    name: message.senderName?.toString() ?? '',
                                    img: message.imageUrl?.toString() ?? 'null',
                                    message: message,
                                    showAvatar: isFirstInGroup,
                                    isFirstInGroup: isFirstInGroup,
                                    isLastInGroup: isLastInGroup,
                                    onLongPress: () => _showReactionBottomSheet(
                                        context, index, controller),
                                  );
                                },
                              );
                            }),
                          ),
                          _buildInputArea(controller, isRtl, context),
                          SizedBox(height: 2.5.h),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  DecorationImage? _getBackgroundImage(UserChatModel model) {
    if (model.userTheme.toString() != "null") {
      return DecorationImage(
        image: CachedNetworkImageProvider("${model.userTheme}"),
        fit: BoxFit.cover,
      );
    } else if (model.themeId?.toString() != "null") {
      return DecorationImage(
        image: CachedNetworkImageProvider("${model.themeId?.theme}"),
        fit: BoxFit.cover,
      );
    } else {
      return null;
    }
  }

  bool _hasAd(UserChatModel model) {
    return (model.adTitle?.isNotEmpty == true && model.adTitle != "null") ||
        (model.adLink?.isNotEmpty == true && model.adLink != "null") ||
        (model.adImage?.isNotEmpty == true && model.adImage != "null");
  }

  Widget _buildPinnedAdBanner(UserChatModel model) {
    return PinnedAdWidget(
      adTitle: model.adTitle,
      adLink: model.adLink,
      adImage: model.adImage,
      onTap: () {
        if (model.adLink?.isNotEmpty == true && model.adLink != "null") {
          print("Opening ad link: ${model.adLink}");
          // Uncomment to use url_launcher
          // try {
          //   final uri = Uri.parse(model.adLink!);
          //   launchUrl(uri, mode: LaunchMode.externalApplication);
          // } catch (e) {
          //   print("Error opening link: $e");
          // }
        }
      },
    );
  }

  Widget _buildAppBar(ChatController controller, bool isRtl) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Row(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.isGust
                          ? Get.back()
                          : Get.offAll(() => const HomeView());
                    },
                    child: Icon(
                      isRtl
                          ? IconsaxPlusLinear.arrow_right_3
                          : IconsaxPlusLinear.arrow_left_1,
                      size: 5.w,
                      color: pref!
                          ? AppColors.blackColor
                          : AppColors.blackTextColor,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    widget.userChatModel!.name!,
                    style: TextStyle(
                      color: pref!
                          ? AppColors.blackColor
                          : AppColors.blackTextColor,
                      fontSize: 4.5.w,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildAppBarActions(controller, isRtl),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarActions(ChatController controller, bool isRtl) {
    final isCurrentUser = widget.userChatModel!.user!.id.toString() ==
        sharedPreferences!.getString("id");
    final isGroup = widget.userChatModel!.status != "Friends" &&
        widget.userChatModel!.status != "Not Friend";

    if (isGroup) {
      if (isCurrentUser) {
        return Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            _buildMusicIcon(),
            const SizedBox(width: 16),
            _buildProfileIcon(controller),
            const SizedBox(width: 16),
            _buildSettingsIcon(),
            const SizedBox(width: 16),
            _buildCallMenu(isRtl),
          ],
        );
      } else {
        return Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            _buildMusicIcon(),
            const SizedBox(width: 16),
            _buildProfileIcon(controller),
            _buildCallMenu(isRtl),
          ],
        );
      }
    } else {
      return Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          _buildAudioCallIcon(),
          const SizedBox(width: 16),
          _buildVideoCallIcon(),
          const SizedBox(width: 16),
          _buildBlockIcon(controller),
        ],
      );
    }
  }

  Widget _buildMusicIcon() => GestureDetector(
        onTap: () => showBottomSheetChangeMusicWidget(context: context),
        child: Icon(
          IconsaxPlusLinear.music,
          color: pref! ? AppColors.blackColor : AppColors.blackColor,
          size: 5.5.w,
        ),
      );

  Widget _buildProfileIcon(ChatController controller) => GestureDetector(
        onTap: () {
          if (widget.isGust) {
            messageErrorWithButton(
              S.of(context).alert,
              S.of(context).pleaseLoginToAccess,
              () {
                Get.back();
                Get.back();
              },
              S.of(context).login,
            );
          } else {
            controller.getMembers();
            showBottomSheetControlPersonWidget(
              idAdmins: widget.userChatModel!.chatAdmins!,
              isNeedAccept: widget.userChatModel!.accept == "0",
              idOwner: widget.userChatModel!.user!.id.toString(),
              context: context,
            );
          }
        },
        child: Icon(
          IconsaxPlusLinear.profile,
          size: 5.5.w,
          color: pref! ? AppColors.blackColor : AppColors.blackColor,
        ),
      );

  Widget _buildSettingsIcon() => GestureDetector(
        onTap: () {
          Get.to(
            () => const Settings(),
            arguments: {"chatModel": widget.userChatModel},
            transition: Transition.leftToRight,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        child: Icon(
          IconsaxPlusLinear.setting,
          size: 5.5.w,
          color: pref! ? AppColors.blackColor : AppColors.blackColor,
        ),
      );

  Widget _buildCallMenu(bool isRtl) => PopupMenuButton<String>(
        color: pref! ? AppColors.blackColor : Colors.white,
        borderRadius: BorderRadius.circular(10),
        onSelected: (String value) async {
          final controller = Get.find<ChatController>();
          final isGroup = widget.userChatModel!.status == "Public" ||
              widget.userChatModel!.status == "Private";
          if (value == 'video_call') {
            controller.audio = false;
            await controller.getTokenCall(
                isGroub: isGroup,
                groubUsersNames: isGroup
                    ? {
                        int.parse(sharedPreferences!.getString("id")!):
                            sharedPreferences!.getString("name")!
                      }
                    : {},
                usernameFriend: isGroup ? "" : widget.userChatModel!.name);
          } else if (value == 'audio_call') {
            controller.audio = true;
            await controller.getTokenCall(
                isGroub: isGroup,
                groubUsersNames: isGroup
                    ? {
                        int.parse(sharedPreferences!.getString("id")!):
                            sharedPreferences!.getString("name")!
                      }
                    : {},
                usernameFriend: isGroup ? "" : widget.userChatModel!.name);
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'video_call',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textNormal(
                  S.of(context).videocall,
                  pref! ? AppColors.whiteColor : AppColors.blackColor,
                  3.5.w,
                  FontWeight.w500,
                ),
                SizedBox(width: 2.w),
                Icon(
                  IconsaxPlusLinear.video,
                  size: 5.w,
                  color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                )
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'audio_call',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textNormal(
                  S.of(context).audiocall,
                  pref! ? AppColors.whiteColor : AppColors.blackColor,
                  3.5.w,
                  FontWeight.w500,
                ),
                SizedBox(width: 2.w),
                Icon(
                  IconsaxPlusLinear.call,
                  size: 5.5.w,
                  color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                ),
              ],
            ),
          ),
        ],
        child: Icon(
          Icons.more_vert,
          size: 5.5.w,
          color: pref! ? AppColors.blackColor : AppColors.blackColor,
        ),
      );

  Widget _buildAudioCallIcon() => GestureDetector(
        onTap: () async {
          final controller = Get.find<ChatController>();
          final isGroup = widget.userChatModel!.status == "Public" ||
              widget.userChatModel!.status == "Private";
          controller.audio = true;
          await controller.getTokenCall(
              isGroub: isGroup,
              groubUsersNames: isGroup
                  ? {
                      int.parse(sharedPreferences!.getString("id")!):
                          sharedPreferences!.getString("name")!
                    }
                  : {},
              usernameFriend: isGroup ? "" : widget.userChatModel!.name);
        },
        child: Icon(
          IconsaxPlusLinear.call_calling,
          size: 5.5.w,
          color: pref! ? AppColors.blackColor : AppColors.blackColor,
        ),
      );

  Widget _buildVideoCallIcon() => GestureDetector(
        onTap: () async {
          final controller = Get.find<ChatController>();
          final isGroup = widget.userChatModel!.status == "Public" ||
              widget.userChatModel!.status == "Private";
          controller.audio = false;
          await controller.getTokenCall(
              isGroub: isGroup,
              groubUsersNames: isGroup
                  ? {
                      int.parse(sharedPreferences!.getString("id")!):
                          sharedPreferences!.getString("name")!
                    }
                  : {},
              usernameFriend: isGroup ? "" : widget.userChatModel!.name);
        },
        child: Icon(
          IconsaxPlusLinear.video,
          size: 5.5.w,
          color: pref! ? AppColors.blackColor : AppColors.blackColor,
        ),
      );

  Widget _buildBlockIcon(ChatController controller) => GestureDetector(
        onTap: () async {
          await controller.getMemberToBlock();
          messageErrorWithButton(
            S.of(context).warning,
            S.of(context).sureToBlock,
            () {
              controller.blockOrUnBlock(
                friendID: controller.memberIdToBlock[0].id.toString(),
                status: true,
              );
              widget.userChatModel!.isBlocked = "You blocked them";
              Get.back();
            },
            S.of(context).block,
          );
        },
        child: Icon(
          Icons.block,
          size: 5.5.w,
          color: AppColors.redColor,
        ),
      );

  Widget _buildMusicBar(
      ChatController controller, bool isRtl, BuildContext context) {
    if (controller.currentlyPlaying != null || controller.isRadioPlaying) {
      return Container(
        padding:
            EdgeInsets.symmetric(horizontal: isRtl ? 2.w : 4.w, vertical: 1.h),
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Icon(
              controller.isRadioPlaying ? Icons.radio : IconsaxPlusLinear.music,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: textNormal(
                controller.isRadioPlaying
                    ? "${S.of(context).radio} ${controller.currentRadioIndex! + 1}"
                    : S.of(context).nowPlaying('{music}'),
                AppColors.blackTextColor,
                3.5.w,
                FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (controller.isRadioPlaying) {
                  controller.stopRadio();
                }
              },
              child: Icon(IconsaxPlusLinear.close_circle, size: 4.w),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInputArea(
      ChatController controller, bool isRtl, BuildContext context) {
    final isBlocked = widget.userChatModel!.isBlocked;
    final isNotFriend = widget.userChatModel!.status == "Not Friend";
    final hasLastMessage = widget.userChatModel!.lastMessage != null;
    bool answer = controller.answer;

    print(
        "data chat >>>> $isNotFriend   ++  $isBlocked   ++  $answer  ++  $hasLastMessage");
    if (isNotFriend && !hasLastMessage && isBlocked == "None") {
      return _buildRequestFriendArea(controller, context);
    } else if (isBlocked == "You blocked them" ||
        isBlocked == "They blocked you") {
      if (isBlocked == "You blocked them") {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              textNormal(S.of(context).msgIBlock, AppColors.blackColor, 3.5.w,
                  FontWeight.w400),
              const SizedBox(width: 20),
              SizedBox(
                height: 2.h,
              ),
              Container(
                width: double.infinity,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.redColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textClick(S.of(context).unBlock, true, () {
                      controller.blockOrUnBlock(
                        friendID: controller.memberIdToBlock[0].id,
                        status: false,
                      );
                      widget.userChatModel!.isBlocked = "None";
                    }, AppColors.whiteColor, 4.w),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          child: textNormal(S.of(context).msgBlockUser, AppColors.blackColor,
              3.5.w, FontWeight.w400),
        );
      }
    } else if (isNotFriend &&
        hasLastMessage &&
        isBlocked == "None" &&
        answer == false &&
        widget.userChatModel!.user!.id.toString() !=
            sharedPreferences!.getString('id')) {
      return _buildAcceptOrCancelArea(controller, context);
    } else {
      return _buildMessageInput(controller, isRtl);
    }
  }

  Widget _buildRequestFriendArea(
      ChatController controller, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: .5.h),
        child: Row(
          textDirection: Directionality.of(context) == TextDirection.rtl
              ? TextDirection.rtl
              : TextDirection.ltr,
          children: [
            if (!controller.isRecording)
              GestureDetector(
                onTap: controller.sendImageMessage,
                child: Icon(
                  IconsaxPlusLinear.gallery,
                  size: 6.w,
                  color: pref!
                      ? AppColors.secondaryColor
                      : AppColors.blackTextColor,
                ),
              ),
            SizedBox(width: 2.w),
            buildVoiceRecordingSection(
                controller, Directionality.of(context) == TextDirection.rtl),
            if (!controller.isRecording) ...[
              SizedBox(width: 2.w),
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color:
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    fontSize: 3.5.w,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: S.of(context).sendYourMessage,
                    hintStyle: TextStyle(
                      color: pref!
                          ? AppColors.inActiveColor
                          : AppColors.black2TextColor,
                      fontSize: 3.5.w,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                  onSubmitted: (_) => controller.sendTextMessage(),
                  maxLines: null,
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: controller.sendTextMessage,
                child: Container(
                  width: 11.w,
                  height: 5.h,
                  decoration: ShapeDecoration(
                    color: pref!
                        ? AppColors.secondaryColor
                        : AppColors.buttoncolor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Center(
                    child: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? IconsaxPlusLinear.send_2
                          : IconsaxPlusLinear.send_2,
                      size: 4.w,
                      color:
                          pref! ? AppColors.blackColor : AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptOrCancelArea(
      ChatController controller, BuildContext context) {
    return Container(
      width: 80.w,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 65.w,
        child: Column(
          children: [
            textNormal(S.of(context).wantToSendMsg, AppColors.blackTextColor,
                3.5.w, FontWeight.w500),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    controller.answer = true;
                    controller.update();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check,
                            color: AppColors.primaryColor, size: 5.w),
                        textNormal("  ${S.of(context).accept}",
                            AppColors.primaryColor, 4.w, FontWeight.w400),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    print("user :: ${controller.memberIdToBlock[0].username}");
                    controller.blockOrUnBlock(
                      friendID: controller.memberIdToBlock[0].id,
                      status: true,
                    );
                    widget.userChatModel!.isBlocked = "You blocked them";
                    controller.update();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.redColor),
                    ),
                    child: textNormal("X ${S.of(context).cancel}",
                        AppColors.redColor, 4.w, FontWeight.w400),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatController controller, bool isRtl) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: isRtl ? 4.w : 4.w, vertical: .5.h),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            if (!controller.isRecording)
              GestureDetector(
                onTap: controller.sendImageMessage,
                child: Icon(
                  IconsaxPlusLinear.gallery,
                  size: 6.w,
                  color: pref!
                      ? AppColors.secondaryColor
                      : AppColors.blackTextColor,
                ),
              ),
            SizedBox(width: 2.w),
            buildVoiceRecordingSection(controller, isRtl),
            if (!controller.isRecording) ...[
              SizedBox(width: 2.w),
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color:
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    fontSize: 3.5.w,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: S.of(context).sendYourMessage,
                    hintStyle: TextStyle(
                      color: pref!
                          ? AppColors.inActiveColor
                          : AppColors.black2TextColor,
                      fontSize: 3.5.w,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                  onSubmitted: (_) => controller.sendTextMessage(),
                  maxLines: null,
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: controller.sendTextMessage,
                child: Container(
                  width: 11.w,
                  height: 5.h,
                  decoration: ShapeDecoration(
                    color: pref!
                        ? AppColors.secondaryColor
                        : AppColors.buttoncolor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Center(
                    child: Icon(
                      isRtl
                          ? IconsaxPlusLinear.send_2
                          : IconsaxPlusLinear.send_2,
                      size: 4.w,
                      color:
                          pref! ? AppColors.blackColor : AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReactionBottomSheet(
      BuildContext context, int messageIndex, ChatController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              S.of(context).react,
              style: TextStyle(
                color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                fontSize: 4.w,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildReactionButton('❤️', messageIndex, controller, context),
                _buildReactionButton('😂', messageIndex, controller, context),
                _buildReactionButton('😢', messageIndex, controller, context),
                _buildReactionButton('😮', messageIndex, controller, context),
                _buildReactionButton('😡', messageIndex, controller, context),
                _buildReactionButton('👍', messageIndex, controller, context),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(String emoji, int messageIndex,
      ChatController controller, BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.addReactionToMessage(
          messageIndex,
          emoji,
          controller.messages[messageIndex].messageId,
        );
        Navigator.pop(context);
      },
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color:
              pref! ? AppColors.blackColor.withOpacity(0.3) : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(child: Text(emoji, style: TextStyle(fontSize: 6.w))),
      ),
    );
  }

  bool _isLastMessageInGroup(List<ChatMessage> messages, int index) {
    if (index == 0) return true;
    return messages[index].senderName != messages[index - 1].senderName;
  }

  bool _isFirstMessageInGroup(List<ChatMessage> messages, int index) {
    if (index == messages.length - 1) return true;
    return messages[index].senderName != messages[index + 1].senderName;
  }
}
//endregion

//region ChatBubbleWidget
class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final VoidCallback onLongPress;
  final String name;
  final String img;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.onLongPress,
    required this.name,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0.w,
        vertical: isFirstInGroup
            ? 0.w
            : message.reaction.isNotEmpty
                ? 3.w
                : 3.w,
      ),
      child: Row(
        mainAxisAlignment: isRtl
            ? (message.isFromSender
                ? MainAxisAlignment.start
                : MainAxisAlignment.end)
            : (message.isFromSender
                ? MainAxisAlignment.end
                : MainAxisAlignment.start),
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          if (isRtl && message.isFromSender) SizedBox(width: 0.w),
          if (isRtl && message.isFromSender)
            _buildAvatar(showAvatar, true, name, img),
          if (!isRtl && !message.isFromSender)
            _buildAvatar(showAvatar, false, name, img),
          if (!isRtl && !message.isFromSender) SizedBox(width: 0.w),
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 70.w),
                    decoration: BoxDecoration(
                      color: message.isFromSender
                          ? (pref!
                              ? AppColors.darkcolor
                              : AppColors.buttoncolor)
                          : AppColors.whiteColor,
                      borderRadius:
                          _getBorderRadius(isRtl, message.isFromSender),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    child: Column(
                      crossAxisAlignment: isRtl
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        _buildMessageContent(
                          message.isPending,
                          message.messageType,
                          message.message,
                          message.isFromSender,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          message.timestamp.toString(),
                          style: TextStyle(
                            color: message.isFromSender
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                            fontSize: 2.5.w,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (message.reaction.isNotEmpty)
                    Positioned(
                      bottom: -10,
                      right: message.isFromSender ? 8 : null,
                      left: !message.isFromSender ? 8 : null,
                      child: InkWell(
                        onTap: () =>
                            _showReactionMessageBottomSheet(context, message),
                        child: Row(
                          children: [
                            Container(
                              width: 5.7.w,
                              height: 5.7.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  message.reaction[0].react!,
                                  style: TextStyle(fontSize: 3.5.w),
                                ),
                              ),
                            ),
                            if (message.reaction.length > 1)
                              Text(
                                "+${message.reaction.length - 1}",
                                style: TextStyle(fontSize: 2.5.w),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isRtl && !message.isFromSender)
            _buildAvatar(showAvatar, false, name, img),
          if (isRtl && !message.isFromSender) SizedBox(width: 2.w),
          if (!isRtl && message.isFromSender) SizedBox(width: 2.w),
          if (!isRtl && message.isFromSender)
            _buildAvatar(showAvatar, true, name, img),
        ],
      ),
    );
  }

  Widget _buildMessageContent(
      bool wait, String type, String content, bool isFromSender) {
    switch (type) {
      case 'text':
        return Text(
          content,
          style: TextStyle(
            color:
                isFromSender ? AppColors.whiteColor : AppColors.blackTextColor,
            fontSize: 3.w,
            fontWeight: FontWeight.w400,
          ),
        );
      case 'image':
        Widget imageWidget = content.startsWith('http')
            ? CachedNetworkImage(imageUrl: content)
            : Image.file(File(content));
        return Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: () => _showImageInScreen(imgUrl: content),
              child: imageWidget,
            ),
            if (wait) Icon(Icons.timelapse_rounded, size: 5.w),
          ],
        );
      case 'voice':
        return Stack(
          children: [
            AudioMessageWidget(
              url: content.startsWith('http') ? content : '',
              localPath: content.startsWith('http') ? null : content,
            ),
            if (wait) Icon(Icons.timelapse_rounded, size: 5.w),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  void _showImageInScreen({required String imgUrl}) {
    Get.defaultDialog(
      radius: 0,
      backgroundColor: AppColors.blackColor,
      title: S.of(Get.context!).imageViewerTitle,
      content: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20.0),
        minScale: 0.5,
        maxScale: 4.0,
        child: Container(
          color: AppColors.blackColor,
          height: 80.h,
          width: 100.w,
          child: CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool show, bool isSender, String name, String img) {
    print("image >>>>>>>>>>>> $img");
    return SizedBox(
      width: 10.w,
      height: 8.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: show
            ? CircleAvatar(
                radius: 4.w,
                backgroundColor:
                    isSender ? AppColors.buttoncolor : Colors.grey[300],
                backgroundImage: img.toString() != "null"
                    ? CachedNetworkImageProvider(" $img")
                    : null,
                child: img.toString() == "null"
                    ? Text(
                        name.isNotEmpty ? name[0] : '',
                        style: TextStyle(
                          color: isSender
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                          fontSize: 3.w,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              )
            : null,
      ),
    );
  }

  BorderRadius _getBorderRadius(bool isRtl, bool isSender) {
    const radius = Radius.circular(18);
    const smallRadius = Radius.circular(4);

    if (isSender) {
      if (isFirstInGroup && isLastInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? radius : smallRadius,
          topRight: isRtl ? smallRadius : radius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      }
      if (isLastInGroup) {
        return const BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomRight: radius,
          bottomLeft: radius,
        );
      } else if (isFirstInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? radius : smallRadius,
          topRight: isRtl ? smallRadius : radius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      } else {
        return BorderRadius.circular(12);
      }
    } else {
      if (isFirstInGroup && isLastInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? smallRadius : radius,
          topRight: isRtl ? radius : smallRadius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      }
      if (isLastInGroup) {
        return const BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomRight: radius,
          bottomLeft: radius,
        );
      } else if (isFirstInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? smallRadius : radius,
          topRight: isRtl ? radius : smallRadius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      } else {
        return BorderRadius.circular(12);
      }
    }
  }
}
//endregion

//region AudioMessageWidget
class AudioMessageWidget extends StatefulWidget {
  final String url;
  final String? localPath;

  const AudioMessageWidget({super.key, required this.url, this.localPath});

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  late AudioPlayer _player;
  bool isPlaying = false;
  Duration? duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      print("vvoice >>>>>>>>> ${widget.localPath}");
      print(" >>>>>>>>>");
      await _player.setLoopMode(LoopMode.off);
      if (widget.localPath != null && await File(widget.localPath!).exists()) {
        await _player.setFilePath(widget.localPath!);
      } else {
        await _player.setUrl(widget.url);
      }

      _player.durationStream.listen((d) {
        if (mounted) setState(() => duration = d ?? Duration.zero);
      });

      _player.positionStream.listen((p) {
        if (mounted) setState(() => position = p);
      });

      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              isPlaying = false;
              position = Duration.zero;
              _player.seek(Duration.zero);
              _player.stop();
            }
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.teal,
              size: 7.w,
            ),
            onPressed: () async {
              try {
                if (isPlaying) {
                  await _player.pause();
                } else {
                  await _player.play();
                }
              } catch (e) {
                debugPrint('Error during playback: $e');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${S.of(context).playbackError}: $e')));
              }
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  activeColor: Colors.teal,
                  inactiveColor: Colors.grey[400],
                  value: position.inSeconds.toDouble(),
                  max: duration?.inSeconds.toDouble() ?? 1.0,
                  onChanged: (value) async {
                    await _player.seek(Duration(seconds: value.toInt()));
                    setState(() => position = Duration(seconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position),
                        style: TextStyle(
                            fontSize: 2.5.w, color: Colors.grey[700])),
                    Text(_formatDuration(duration ?? Duration.zero),
                        style: TextStyle(
                            fontSize: 2.5.w, color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
//endregion

void _showReactionMessageBottomSheet(
    BuildContext context, ChatMessage chatMessage) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            S.of(context).react,
            style: TextStyle(
              color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
              fontSize: 4.w,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: 100.w,
            child: ListView.separated(
              itemCount: chatMessage.reaction.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(2.w),
              itemBuilder: (context, index) => Row(
                children: [
                  Text(chatMessage.reaction[index].react!,
                      style: TextStyle(fontSize: 6.w)),
                  const SizedBox(width: 10),
                  textNormal(
                    chatMessage.reaction[index].user!.username ==
                                sharedPreferences!.getString("usernameGust") ||
                            chatMessage.reaction[index].user!.username ==
                                sharedPreferences!.getString("username")
                        ? S.of(context).you
                        : chatMessage.reaction[index].user!.username,
                    AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    ),
  );
}
