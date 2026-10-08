// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/storetext.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

void showBottomSheetControlPersonWidget({
  required BuildContext context,
  required String idOwner,
  required bool isNeedAccept,
  required List<ChatAdmins> idAdmins,
}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final scrollController = ScrollController();

  // 🚨 التعديل هنا
  if (!Get.isRegistered<ChatController>()) {
    Get.put(ChatController());
  }
  final controller = Get.find<ChatController>();

  _setupScrollListener(scrollController, controller);

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
    context: context,
    builder: (context) => GetBuilder<ChatController>(
      builder: (c) => _buildBottomSheetContent(
        context: context,
        controller: c,
        scrollController: scrollController,
        isRtl: isRtl,
        idOwner: idOwner,
        idAdmins: idAdmins,
        isNeedAccept: isNeedAccept,
      ),
    ),
  ).whenComplete(() {
    scrollController.dispose();
  });
}

void _setupScrollListener(
    ScrollController scrollController, ChatController controller) {
  scrollController.addListener(() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreMembers();
    }
  });
}

Widget _buildBottomSheetContent({
  required BuildContext context,
  required ChatController controller,
  required ScrollController scrollController,
  required bool isRtl,
  required String idOwner,
  required List<ChatAdmins> idAdmins,
  required bool isNeedAccept,
}) {
  return AnimatedPadding(
    duration: const Duration(milliseconds: 300),
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
      left: isRtl ? 0 : 4.w,
      right: isRtl ? 4.w : 0,
    ),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 80.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTopHandle(),
          _buildCloseButton(isRtl),
          _buildPersonImagesStack(),
          SizedBox(height: 2.h),
          _buildTabButtons(controller, isNeedAccept, isRtl),
          SizedBox(height: 2.h),
          _buildMemberList(
            controller: controller,
            scrollController: scrollController,
            idOwner: idOwner,
            idAdmins: idAdmins,
            isNeedAccept: isNeedAccept,
          ),
        ],
      ),
    ),
  );
}

Widget _buildTopHandle() {
  return Container(
    height: 4,
    width: 70,
    margin: const EdgeInsets.symmetric(vertical: 8),
    color: pref! ? AppColors.whiteColor : AppColors.blackColor,
  );
}

Widget _buildCloseButton(bool isRtl) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    child: Row(
      mainAxisAlignment:
          isRtl ? MainAxisAlignment.end : MainAxisAlignment.start,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        textClick(
          S.of(Get.context!).close,
          true,
          () => Get.back(),
          pref! ? AppColors.whiteColor : AppColors.blackColor,
          3.5.w,
        ),
      ],
    ),
  );
}

Widget _buildPersonImagesStack() {
  return SizedBox(
    width: 100.w,
    height: 40.w,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        _buildPositionedImage(
          top: 0,
          bottom: 0,
          right: 40.w,
          left: 13.w,
          image: AppImages.personImg,
        ),
        _buildPositionedImage(
          right: 32.w,
          left: 32.w,
          height: 37.w,
          width: 30.w,
          image: AppImages.personColorImg,
        ),
        _buildPositionedImage(
          top: 0,
          bottom: 0,
          right: 23.w,
          left: 30.w,
          image: AppImages.personImg,
        ),
      ],
    ),
  );
}

Widget _buildPositionedImage({
  double? top,
  double? bottom,
  double? right,
  double? left,
  double? height,
  double? width,
  required String image,
}) {
  return Positioned(
    top: top,
    bottom: bottom,
    right: right,
    left: left,
    child: Container(
      height: height ?? 40.w,
      width: width ?? 30.w,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.fill,
        ),
      ),
    ),
  );
}

Widget _buildTabButtons(
    ChatController controller, bool isNeedAccept, bool isRtl) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _buildTabButton(
        text: S.of(Get.context!).members,
        isActive: controller.memberClick,
        onTap: () => controller.changeClick(true),
      ),
      if (isNeedAccept)
        _buildTabButton(
          text: S.of(Get.context!).requestToSend,
          isActive: !controller.memberClick,
          onTap: () => controller.changeClick(false),
        ),
    ],
  );
}

Widget _buildTabButton({
  required String text,
  required bool isActive,
  required VoidCallback onTap,
}) {
  final color = isActive
      ? (pref! ? AppColors.whiteColor : AppColors.blackTextColor)
      : AppColors.inActiveColor;

  return InkWell(
    onTap: onTap,
    child: textNormal(
      text,
      color,
      3.5.w,
      FontWeight.w600,
    ),
  );
}

Widget _buildMemberList({
  required ChatController controller,
  required ScrollController scrollController,
  required String idOwner,
  required List<ChatAdmins> idAdmins,
  required bool isNeedAccept,
}) {
  return Expanded(
    child: SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          _buildMembersContent(
            controller: controller,
            idOwner: idOwner,
            idAdmins: idAdmins,
            isNeedAccept: isNeedAccept,
          ),
          _buildLoadingIndicator(controller, isNeedAccept),
          _buildEndOfListIndicator(controller, isNeedAccept),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

Widget _buildMembersContent({
  required ChatController controller,
  required String idOwner,
  required List<ChatAdmins> idAdmins,
  required bool isNeedAccept,
}) {
  final isRequestTab = isNeedAccept && !controller.memberClick;
  final isMembersTab = controller.memberClick;

  if (isRequestTab) {
    return _buildRequestList(controller, idOwner, idAdmins);
  } else if (isMembersTab) {
    return _buildMemberListContent(controller, idOwner, idAdmins);
  }

  return const SizedBox.shrink();
}

Widget _buildRequestList(
    ChatController controller, String idOwner, List<ChatAdmins> idAdmins) {
  if (controller.statuesRequestMembers == StatuesRequest.loading &&
      controller.memmbersRequests.isEmpty) {
    return loading(10.h);
  }

  if (controller.memmbersRequests.isEmpty &&
      controller.statuesRequestMembers != StatuesRequest.loading) {
    return Center(child: noData(S.of(Get.context!).noMembers));
  }

  return _buildPaginatedMemberList(
    controller: controller,
    idOwner: idOwner,
    idAdmins: idAdmins,
    isNeedAccept: true,
  );
}

Widget _buildMemberListContent(
    ChatController controller, String idOwner, List<ChatAdmins> idAdmins) {
  if (controller.statuesRequestMembers == StatuesRequest.loading &&
      controller.members.isEmpty) {
    return loading(10.h);
  }

  if (controller.members.isEmpty &&
      controller.statuesRequestMembers != StatuesRequest.loading) {
    return Center(child: noData(S.of(Get.context!).noMembers));
  }

  return _buildPaginatedMemberList(
    controller: controller,
    idOwner: idOwner,
    idAdmins: idAdmins,
    isNeedAccept: false,
  );
}

Widget _buildLoadingIndicator(ChatController controller, bool isNeedAccept) {
  final isLoading =
      (controller.memberClick && controller.isLoadingMoreMembers) ||
          (!controller.memberClick && controller.isLoadingMoreRequests);

  if (!isLoading) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: pref! ? AppColors.whiteColor : AppColors.primaryColor,
    ),
  );
}

Widget _buildEndOfListIndicator(ChatController controller, bool isNeedAccept) {
  final hasReachedEnd = (controller.memberClick &&
          !controller.hasMoreMembers &&
          controller.members.isNotEmpty) ||
      (!controller.memberClick &&
          !controller.hasMoreRequests &&
          controller.memmbersRequests.isNotEmpty);

  if (!hasReachedEnd) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: textNormal(
      S.of(Get.context!).noMembers,
      AppColors.inActiveColor,
      3.w,
      FontWeight.w400,
    ),
  );
}

Widget _buildPaginatedMemberList({
  required ChatController controller,
  required bool isNeedAccept,
  required String idOwner,
  required List<ChatAdmins> idAdmins,
}) {
  final membersList =
      isNeedAccept ? controller.memmbersRequests : controller.members;

  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    itemCount: membersList.length,
    separatorBuilder: (context, index) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final member = membersList[index];
      return _cardPerson(
        power: member.power,
        idPerson: member.id.toString(),
        isGust: member.isGuest!,
        isFriend: member.requestStatus!,
        isAdmin: idAdmins
            .any((element) => element.chatAdminId == member.id.toString()),
        isOwner: member.id.toString() == idOwner,
        isNeedAccept: isNeedAccept,
        ttitle: member.username!,
        onPressChat: () => controller.createChatFriend(friendID: member.id),
        onPressAdd: () => controller.sendFriendRequest(friendID: member.id),
        onPressRemove: () => controller.sendFriendRequest(friendID: member.id),
        onPressAccept: () => controller.acceptNeedTochat(membeerId: member.id!),
      );
    },
  );
}

class _cardPerson extends StatefulWidget {
  final String ttitle;
  final VoidCallback onPressChat;
  final VoidCallback onPressAdd;
  final VoidCallback onPressRemove;
  final VoidCallback onPressAccept;
  final bool isNeedAccept;
  final bool isAdmin;
  final bool isOwner;
  final String isFriend;
  final bool isGust;
  final String idPerson;
  final PowerModel? power;

  const _cardPerson({
    required this.ttitle,
    required this.onPressChat,
    required this.onPressAdd,
    required this.onPressRemove,
    required this.isNeedAccept,
    required this.isAdmin,
    required this.isOwner,
    required this.isFriend,
    required this.onPressAccept,
    required this.isGust,
    required this.idPerson,
    required this.power,
  });

  @override
  State<_cardPerson> createState() => _cardPersonState();
}

class _cardPersonState extends State<_cardPerson>
    with SingleTickerProviderStateMixin {
  bool isRotated = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          _buildUserInfo(isRtl),
          if (widget.isNeedAccept) _buildAcceptButton(isRtl),
          if (_shouldShowActionButtons) _buildActionButtons(isRtl),
        ],
      ),
    );
  }

  Widget _buildUserInfo(bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 65.w,
          child: widget.power.toString() != "null"
              ? PowerTextWidget(
                  powerModel: widget.power!, displyText: widget.ttitle)
              : textNormal(
                  widget.ttitle,
                  pref! ? AppColors.inActiveColor : AppColors.blackTextColor,
                  3.5.w,
                  FontWeight.w400,
                ),
        ),
        if (!widget.isNeedAccept)
          Padding(
            padding: EdgeInsets.only(right: 3.5.w, left: 3.5.w),
            child: textNormal(
              _getUserRoleText(),
              AppColors.inActiveColor,
              3.w,
              FontWeight.w400,
            ),
          ),
      ],
    );
  }

  String _getUserRoleText() {
    if (widget.isAdmin) return S.of(context).admin;
    if (widget.isOwner) return S.of(context).owner;
    return S.of(context).member;
  }

  Widget _buildAcceptButton(bool isRtl) {
    return _buildActionContainer(
      isRtl: isRtl,
      child: InkWell(
        onTap: widget.onPressAccept,
        child: _buildIconButton(
          icon: Icons.check,
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isRtl) {
    if (!_shouldShowActionButtons) return const SizedBox();

    return _buildActionContainer(
      isRtl: isRtl,
      child: _buildFriendStatusActions(isRtl),
    );
  }

  Widget _buildFriendStatusActions(bool isRtl) {
    switch (widget.isFriend) {
      case "none":
      case "request_sent":
        return _buildAddAndChatActions(isRtl);
      case "request_recived":
        return _buildPendingAction();
      default:
        return _buildChatAction();
    }
  }

  Widget _buildAddAndChatActions(bool isRtl) {
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _buildChatButton(),
      ],
    );
  }

  Widget _buildChatButton() {
    return InkWell(
      onTap: widget.onPressChat,
      child: _buildIconButton(
        icon: LucideIcons.messageCircle300,
      ),
    );
  }

  Widget _buildPendingAction() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onPressChat,
          child: _buildIconButton(
            icon: Icons.watch_later_outlined,
            size: 6.w,
          ),
        ),
      ],
    );
  }

  Widget _buildChatAction() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onPressChat,
          child: _buildIconButton(
            icon: LucideIcons.messageCircle200,
            size: 6.w,
          ),
        ),
      ],
    );
  }

  Widget _buildActionContainer({
    required bool isRtl,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.only(
        right: isRtl ? 1.3.w : 6.w,
        left: isRtl ? 6.w : 1.3.w,
      ),
      height: 14.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        borderRadius: _getActionContainerBorderRadius(isRtl),
      ),
      child: child,
    );
  }

  BorderRadius _getActionContainerBorderRadius(bool isRtl) {
    return BorderRadius.only(
      topLeft: isRtl ? Radius.zero : const Radius.circular(25),
      bottomLeft: isRtl ? Radius.zero : const Radius.circular(25),
      topRight: isRtl ? const Radius.circular(25) : Radius.zero,
      bottomRight: isRtl ? const Radius.circular(25) : Radius.zero,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    double size = 16,
  }) {
    return Container(
      height: 12.w,
      width: 12.w,
      decoration: ShapeDecoration(
        color: pref! ? AppColors.blackColor : AppColors.bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: size,
          color: pref! ? AppColors.secondaryColor : AppColors.blackColor,
        ),
      ),
    );
  }

  bool get _shouldShowActionButtons {
    return widget.isOwner == false &&
        widget.isNeedAccept == false &&
        !widget.isGust &&
        sharedPreferences!.getString("id") != widget.idPerson;
  }
}
