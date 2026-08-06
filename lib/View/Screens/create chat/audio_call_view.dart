import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/audio_call_controller.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class AudioCallPage extends StatelessWidget {
  const AudioCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AudioCallController>(
      init: AudioCallController(),
      builder: (controller) => PopScope(
        canPop: false,
        // ignore: deprecated_member_use
        onPopInvoked: (didPop) async {
          if (!didPop) {
            await controller.endCall();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: _buildAppBar(context, controller),
          body: SafeArea(top: false, child: _buildBody(context, controller)),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AudioCallController controller) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          textNormal(
              controller.isGroupCall.value
                  ? S.of(context).groupAudioCall
                  : S.of(context).audioCall,
              Colors.white,
              4.4.w,
              FontWeight.w700),
          if (controller.isGroupCall.value && controller.participantCount > 1)
            Text(
              '${controller.participantCount} ${S.of(context).participants}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70),
            )
          else if (!controller.isGroupCall.value &&
              controller.remoteUid.value != null)
            Text(
              controller.remoteUserName.value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70),
            ),
        ],
      ),
      backgroundColor: Colors.black87,
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: controller.endCall,
      ),
    );
  }

  Widget _buildBody(BuildContext context, AudioCallController controller) {
    return controller.hasError
        ? _buildErrorView(context, controller)
        : Stack(
            children: [
              _buildMainContent(context, controller),
              _buildStatusIndicators(context, controller),
              _buildCallControls(context, controller),
            ],
          );
  }

  Widget _buildErrorView(BuildContext context, AudioCallController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 20),
            Text(
              S.of(context).connectionError,
              style: TextStyle(
                  color: Colors.red[300],
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              controller.permissionStatus.value,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildErrorButton(
                  context: context,
                  icon: Icons.refresh,
                  label: S.of(context).retry,
                  color: Colors.blue,
                  onPressed: controller.retryConnection,
                ),
                _buildErrorButton(
                  context: context,
                  icon: Icons.close,
                  label: S.of(context).exit,
                  color: Colors.grey[700]!,
                  onPressed: controller.endCall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, AudioCallController controller) {
    return controller.isGroupCall.value
        ? _buildGroupCallLayout(context, controller)
        : _buildSingleCallLayout(context, controller);
  }

  Widget _buildSingleCallLayout(
      BuildContext context, AudioCallController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLocalUserAvatar(controller),
          const SizedBox(height: 20),
          Text(
            controller.localUserName.value,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildStatusText(context, controller),
          const SizedBox(height: 20),
          _buildRemoteUserAvatar(context, controller),
          _buildWaitingIndicator(context, controller),
        ],
      ),
    );
  }

  Widget _buildGroupCallLayout(
      BuildContext context, AudioCallController controller) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildStatusText(context, controller),
        const SizedBox(height: 30),
        Expanded(
          child: controller.participants.isEmpty
              ? _buildWaitingIndicator(context, controller)
              : _buildParticipantsGrid(context, controller),
        ),
      ],
    );
  }

  Widget _buildParticipantsGrid(
      BuildContext context, AudioCallController controller) {
    final participants = controller.participants;
    final crossAxisCount = participants.length <= 2
        ? 1
        : participants.length <= 4
            ? 2
            : 3;

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return _buildParticipantCard(
          context: context,
          controller: controller,
          name: participant['name'] ?? 'User $index',
          uid: participant['uid'],
          isMuted: participant['isMuted'] ?? false,
          isSpeaking: participant['isSpeaking'] ?? false,
          isLocal: participant['uid'] == controller.remoteUid,
        );
      },
    );
  }

  Widget _buildParticipantCard({
    required BuildContext context,
    required AudioCallController controller,
    required String name,
    required int uid,
    required bool isMuted,
    required bool isSpeaking,
    required bool isLocal,
  }) {
    return Obx(() {
      controller.participantsList.firstWhereOrNull((p) => p.uid == uid);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSpeaking ? Colors.green : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSpeaking
              ? [
                  BoxShadow(
                    color: Colors.green.shade300,
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAvatar(isLocal, isMuted),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            if (isMuted) _buildMutedBadge(context),
            if (controller.isGroupCall.value && !isLocal)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        isMuted ? Icons.mic : Icons.mic_off,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          controller.muteParticipant(uid, !isMuted),
                      tooltip:
                          isMuted ? S.of(context).unmute : S.of(context).mute,
                    ),
                    // IconButton(
                    //   icon: const Icon(IconsaxPlusLinear.user_remove, size: 16, color: Colors.white),
                    //   onPressed: () => controller.removeParticipant(uid),
                    //   tooltip: S.of(context).removeParticipant,
                    // ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildAvatar(bool isLocal, bool isMuted) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isLocal
            ? (isMuted ? Colors.red[700] : Colors.blue[700])
            : Colors.green[700],
        shape: BoxShape.circle,
      ),
      child: Icon(
        isLocal && isMuted ? Icons.mic_off : Icons.person,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMutedBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic_off, size: 12, color: Colors.red),
          const SizedBox(width: 4),
          Text(
            S.of(context).muted,
            style: const TextStyle(color: Colors.red, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalUserAvatar(AudioCallController controller) {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color:
                controller.isMuted.value ? Colors.red[700] : Colors.blue[700],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: controller.isMuted.value
                    ? Colors.red.withOpacity(0.3)
                    : Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              controller.isMuted.value ? Icons.mic_off : Icons.person,
              key: ValueKey(controller.isMuted.value),
              size: 60,
              color: Colors.white,
            ),
          ),
        ));
  }

  Widget _buildStatusText(
      BuildContext context, AudioCallController controller) {
    return Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            controller.statusText,
            key: ValueKey(controller.statusText),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ));
  }

  Widget _buildRemoteUserAvatar(
      BuildContext context, AudioCallController controller) {
    return Obx(() {
      if (controller.remoteUid.value != null && !controller.isGroupCall.value) {
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              controller.remoteUserName.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildWaitingIndicator(
      BuildContext context, AudioCallController controller) {
    return Obx(() => controller.isWaiting
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).connecting,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          )
        : const SizedBox.shrink());
  }

  Widget _buildStatusIndicators(
      BuildContext context, AudioCallController controller) {
    return Positioned(
      top: 20,
      left: 20,
      child: Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    controller.isMuted.value ? Icons.mic_off : Icons.mic,
                    key: ValueKey(controller.isMuted.value),
                    color: controller.isMuted.value ? Colors.red : Colors.green,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    controller.speakerEnabled.value
                        ? Icons.volume_up
                        : Icons.phone,
                    key: ValueKey(controller.speakerEnabled.value),
                    color: controller.speakerEnabled.value
                        ? Colors.blue
                        : Colors.grey,
                    size: 16,
                  ),
                ),
                if (controller.participants.isNotEmpty ||
                    controller.remoteUid.value != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          )),
    );
  }

  Widget _buildCallControls(
      BuildContext context, AudioCallController controller) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              context: context,
              icon: controller.isMuted.value ? Icons.mic_off : Icons.mic,
              backgroundColor:
                  controller.isMuted.value ? Colors.red : Colors.grey[700]!,
              onPressed: controller.toggleMute,
              tooltip: controller.isMuted.value
                  ? S.of(context).unmute
                  : S.of(context).mute,
            ),
            _buildControlButton(
              context: context,
              icon: controller.speakerEnabled.value
                  ? Icons.volume_up
                  : Icons.volume_down,
              backgroundColor: controller.speakerEnabled.value
                  ? Colors.blue
                  : Colors.grey[700]!,
              onPressed: controller.toggleSpeaker,
              tooltip: controller.speakerEnabled.value
                  ? S.of(context).useEarpiece
                  : S.of(context).useSpeaker,
            ),
            _buildControlButton(
              context: context,
              icon: Icons.call_end,
              backgroundColor: Colors.red,
              onPressed: controller.endCall,
              tooltip: S.of(context).endCall,
              size: 60,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
    required String tooltip,
    double size = 50,
  }) {
    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(size / 2),
            onTap: onPressed,
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}
