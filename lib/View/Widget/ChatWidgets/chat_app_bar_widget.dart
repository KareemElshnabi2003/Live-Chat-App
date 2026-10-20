import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/create%20chat/settings.dart';
import 'package:live_chat/View/Screens/Chat%20Botton%20Sheet/show_bottom_change_music.dart';
import 'package:live_chat/View/Screens/Chat%20Botton%20Sheet/show_bottom_sheet_persons_chat.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/unblock_friend_dialog.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class ChatAppBarWidget extends StatelessWidget {
  final ChatController controller;
  final UserChatModel userChatModel;
  final bool isGust;
  final bool isRtl;

  const ChatAppBarWidget({
    super.key,
    required this.controller,
    required this.userChatModel,
    required this.isGust,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final isGroup = userChatModel.status != "Friends" &&
        userChatModel.status != "Not Friend";

    return Container(
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
                  if (controller.isFakeRequest && !controller.answer && userChatModel.status?.toLowerCase() != 'friends') {
                    final otherId = controller.getOtherUserId() ??
                        userChatModel.otherUserId ??
                        userChatModel.user?.id;
                    if (otherId != null) {
                      controller.cancelFakeFriendRequest(friendID: otherId);
                      controller.isFakeRequest = false;
                    }
                  }
                  if (Navigator.of(context).canPop()) {
                    Get.back();
                  } else {
                    Get.offAll(() => const HomeView());
                  }
                },
                child: Icon(
                  isRtl
                      ? IconsaxPlusLinear.arrow_right_3
                      : IconsaxPlusLinear.arrow_left_1,
                  size: 5.w,
                  color:
                      pref! ? AppColors.blackColor : AppColors.blackTextColor,
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: isGroup ? () => _openMembersSheet(context) : null,
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: (userChatModel.image != null &&
                                userChatModel.image!.trim() != "null" &&
                                userChatModel.image!.trim().isNotEmpty &&
                                userChatModel.image!.trim() != "image")
                            ? CachedNetworkImage(
                                imageUrl: userChatModel.image!.trim(),
                                fit: BoxFit.cover,
                                maxWidthDiskCache: 120,
                                maxHeightDiskCache: 120,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade300,
                                  alignment: Alignment.center,
                                  child: Text(
                                    (userChatModel.name ?? '').trim().isNotEmpty
                                        ? (userChatModel.name ?? '')
                                            .trim()[0]
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade300,
                                alignment: Alignment.center,
                                child: Text(
                                  (userChatModel.name ?? '').trim().isNotEmpty
                                      ? (userChatModel.name ?? '')
                                          .trim()[0]
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    SizedBox(
                      width: 35.w,
                      child: Text(
                        userChatModel.name ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: pref!
                              ? AppColors.blackColor
                              : AppColors.blackTextColor,
                          fontSize: 4.5.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildAppBarActions(context, isGroup),
        ],
      ),
    );
  }

  void _openMembersSheet(BuildContext context) {
    final bool isGuestUser = sharedPreferences?.getString("id") == null;
    if (isGuestUser) {
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
      final ownerId = userChatModel.user?.id?.toString() ??
          userChatModel.userId?.toString() ??
          '';
      showBottomSheetControlPersonWidget(
        idAdmins: userChatModel.chatAdmins ?? [],
        isNeedAccept: userChatModel.accept == "1",
        idOwner: ownerId,
        context: context,
      );
    }
  }

  Widget _buildJoinButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        final success = await controller.joinCurrentChat();
        if (success) {
          Get.snackbar(
            S.of(context).success,
            S.of(context).joinChatBody,
            backgroundColor: const Color(0xFF2E7D32),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            duration: const Duration(seconds: 2),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.w),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: pref! ? AppColors.secondaryColor : AppColors.primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_add_outlined,
              size: 4.5.w,
              color: pref! ? AppColors.blackColor : AppColors.whiteColor,
            ),
            SizedBox(width: 1.5.w),
            Text(
              S.of(context).joinNow,
              style: TextStyle(
                color: pref! ? AppColors.blackColor : AppColors.whiteColor,
                fontSize: 3.2.w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarActions(BuildContext context, bool isGroup) {
    if (isGroup && !controller.isJoined) {
      return _buildJoinButton(context);
    }

    final currentUserId = sharedPreferences?.getString("id")?.trim() ?? "";
    final isOwner = (userChatModel.user != null &&
            userChatModel.user!.id.toString() == currentUserId) ||
        (userChatModel.userId != null &&
            userChatModel.userId.toString() == currentUserId);

    final isAdmin = userChatModel.chatAdmins?.any(
            (admin) => admin.chatAdminId?.toString() == currentUserId) ??
        false;

    final canManageGroup = isOwner || isAdmin;
    final isPublic = userChatModel.status?.toLowerCase() == "public";
    final canShareGroup = isGroup && (isPublic || canManageGroup);
    final canMusic = isGroup && userChatModel.themeId != null;

    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAudioCallIcon(),
        const SizedBox(width: 12),
        _buildVideoCallIcon(),
        const SizedBox(width: 12),
        _buildMoreMenu(
          context,
          isGroup,
          canShareGroup,
          canMusic,
          canManageGroup,
        ),
      ],
    );
  }

  Widget _buildMoreMenu(
    BuildContext context,
    bool isGroup,
    bool canShareGroup,
    bool canMusic,
    bool canManageGroup,
  ) {
    return PopupMenuButton<String>(
      color: pref! ? AppColors.blackColor : Colors.white,
      borderRadius: BorderRadius.circular(10),
      onSelected: (String value) async {
        if (value == 'share') {
          final link = userChatModel.chatLink;
          if (link != null && link.isNotEmpty && link != "null") {
            controller.shareChat(link: link);
          } else {
            controller.shareChat(link: "");
          }
        } else if (value == 'music') {
          showBottomSheetChangeMusicWidget(context: context);
        } else if (value == 'members' || value == 'profile') {
          _openMembersSheet(context);
        } else if (value == 'settings') {
          Get.to(
            () => const Settings(),
            arguments: {"chatModel": userChatModel},
            transition: Transition.leftToRight,
            duration: const Duration(milliseconds: 400),
          );
        } else if (value == 'block') {
          await controller.getMemberToBlock();
          messageErrorWithButton(
            S.of(context).warning,
            S.of(context).sureToBlock,
            () {
              final blockId = controller.memberIdToBlock.isNotEmpty
                  ? controller.memberIdToBlock[0].id.toString()
                  : (userChatModel.user?.id?.toString() ??
                      userChatModel.userId?.toString() ??
                      '');
              controller.blockOrUnBlock(friendID: blockId, status: 1);
              userChatModel.isBlocked = "You blocked them";
              Get.back();
            },
            S.of(context).block,
          );
        } else if (value == 'unblock') {
          final blockId = controller.memberIdToBlock.isNotEmpty
              ? controller.memberIdToBlock[0].id.toString()
              : (userChatModel.user?.id?.toString() ??
                  userChatModel.userId?.toString() ??
                  '');
          final success = await controller.blockOrUnBlock(friendID: blockId, status: 0);
          if (success) {
            userChatModel.isBlocked = "None";
            userChatModel.status = "Not Friend";
            controller.update();
            if (context.mounted) {
              showUnblockFriendDialog(
                context: context,
                friendId: blockId,
                onSendRequest: () async {
                  final reqSuccess = await controller.sendFriendRequest(friendID: blockId);
                  if (reqSuccess) {
                    Get.snackbar(
                      S.of(context).success,
                      S.of(context).youSendRequest,
                      backgroundColor: const Color(0xFF2E7D32),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      duration: const Duration(seconds: 3),
                    );
                  }
                },
              );
            }
          }
        }
      },
      itemBuilder: (BuildContext context) => [
        if (canShareGroup)
          PopupMenuItem(
            value: 'share',
            child: _menuItem(S.of(context).share, IconsaxPlusLinear.share),
          ),
        if (canMusic)
          PopupMenuItem(
            value: 'music',
            child: _menuItem(S.of(context).music, IconsaxPlusLinear.music),
          ),
        if (isGroup)
          PopupMenuItem(
            value: 'members',
            child: _menuItem(S.of(context).members, IconsaxPlusLinear.people),
          ),
        if (isGroup && canManageGroup)
          PopupMenuItem(
            value: 'settings',
            child: _menuItem(S.of(context).settings, IconsaxPlusLinear.setting),
          ),
        if (!isGroup)
          PopupMenuItem(
            value: userChatModel.isBlocked == "You blocked them" ? 'unblock' : 'block',
            child: userChatModel.isBlocked == "You blocked them"
                ? _menuItem(S.of(context).unBlock, Icons.lock_open_rounded)
                : _menuItem(S.of(context).block, Icons.block),
          ),
      ],
      child: Icon(
        Icons.more_vert,
        size: 5.5.w,
        color: pref! ? AppColors.blackColor : AppColors.blackColor,
      ),
    );
  }

  Widget _menuItem(String title, IconData icon) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon,
              size: 5.w,
              color: pref! ? AppColors.whiteColor : AppColors.blackColor),
          SizedBox(width: 3.w),
          textNormal(title, pref! ? AppColors.whiteColor : AppColors.blackColor,
              3.5.w, FontWeight.w500),
        ],
      );

  Widget _buildAudioCallIcon() => GetBuilder<ChatController>(
        builder: (ctrl) {
          final isBlocked = userChatModel.isBlocked;
          final bool isBlockedByMe = isBlocked == "You blocked them";
          final bool isBlockedByThem = isBlocked == "They blocked you";
          final bool isGeneralBlocked =
              isBlockedByMe || isBlockedByThem || isBlocked == "blocked";
          final bool isGroup = userChatModel.status != "Friends" &&
              userChatModel.status != "Not Friend";
          final bool isBlockedSingleChat = !isGroup && isGeneralBlocked;

          final isCallActive = ctrl.isIncomingCallActive;
          return GestureDetector(
            onTap: () => _initCall(true),
            child: Icon(
              IconsaxPlusLinear.call_calling,
              size: 5.5.w,
              color: isBlockedSingleChat
                  ? (pref! ? Colors.white30 : Colors.black26)
                  : (isCallActive
                      ? Colors.green
                      : (pref! ? AppColors.whiteColor : AppColors.blackColor)),
            ),
          );
        },
      );

  Widget _buildVideoCallIcon() => GetBuilder<ChatController>(
        builder: (ctrl) {
          final isBlocked = userChatModel.isBlocked;
          final bool isBlockedByMe = isBlocked == "You blocked them";
          final bool isBlockedByThem = isBlocked == "They blocked you";
          final bool isGeneralBlocked =
              isBlockedByMe || isBlockedByThem || isBlocked == "blocked";
          final bool isGroup = userChatModel.status != "Friends" &&
              userChatModel.status != "Not Friend";
          final bool isBlockedSingleChat = !isGroup && isGeneralBlocked;

          final isCallActive = ctrl.isIncomingCallActive;
          return GestureDetector(
            onTap: () => _initCall(false),
            child: Icon(
              IconsaxPlusLinear.video,
              size: 5.5.w,
              color: isBlockedSingleChat
                  ? (pref! ? Colors.white30 : Colors.black26)
                  : (isCallActive
                      ? Colors.green
                      : (pref! ? AppColors.whiteColor : AppColors.blackColor)),
            ),
          );
        },
      );

  void _initCall(bool isAudio) async {
    final isGroup =
        userChatModel.status == "Public" || userChatModel.status == "Private";
    final isBlocked = userChatModel.isBlocked;
    final bool isBlockedByMe = isBlocked == "You blocked them";
    final bool isBlockedByThem = isBlocked == "They blocked you";
    final bool isGeneralBlocked =
        isBlockedByMe || isBlockedByThem || isBlocked == "blocked";

    if (!isGroup && isGeneralBlocked) {
      Get.snackbar(
        S.of(Get.context!).warning,
        isBlockedByThem
            ? S.of(Get.context!).msgBlockUser
            : S.of(Get.context!).msgIBlock,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.block, color: Colors.white),
      );
      return;
    }

    controller.audio = isAudio;
    final currentUserIdStr = sharedPreferences?.getString("id") ?? "0";
    final currentUserNameStr = sharedPreferences?.getString("name") ?? "";
    final currentUserId = int.tryParse(currentUserIdStr) ?? 0;

    await controller.getTokenCall(
      isGroub: isGroup,
      groubUsersNames: isGroup
          ? {
              currentUserId: currentUserNameStr,
            }
          : {},
      usernameFriend: isGroup ? "" : userChatModel.name,
      isJoin: false,
    );
  }
}
