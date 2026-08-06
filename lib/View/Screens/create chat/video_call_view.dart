import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/video_call_controller.dart';
import 'package:live_chat/generated/l10n.dart';

class VideoCallPage extends StatelessWidget {
  const VideoCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<VideoCallController>(
      init: VideoCallController(),
      builder: (controller) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (!didPop) {
            await controller.endCall();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildAppBar(context, controller),
          body: SafeArea(top: false, child: _buildBody(context, controller)),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, VideoCallController controller) {
    return AppBar(
      title: Column(
        children: [
          Text(
            controller.isGroubCall
                ? S.of(context).groupVideoCall
                : S.of(context).videoCall,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          if (controller.remoteUserCount > 0)
            Text(
              '${controller.remoteUserCount + 1} ${S.of(context).participants}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
        ],
      ),
      backgroundColor: Colors.blue,
      centerTitle: true,
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => controller.endCall(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, VideoCallController controller) {
    return controller.hasError
        ? _buildErrorView(context, controller)
        : _buildVideoCallInterface(context, controller);
  }

  Widget _buildErrorView(BuildContext context, VideoCallController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).connectionFailed,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.permissionStatus,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.retryConnection(),
                  icon: const Icon(Icons.refresh),
                  label: Text(S.of(context).retry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.endCall(),
                  icon: const Icon(Icons.close),
                  label: Text(S.of(context).exit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCallInterface(
      BuildContext context, VideoCallController controller) {
    return Stack(
      children: [
        _buildVideoGrid(context, controller),
        _buildStatusIndicators(context, controller),
        _buildCallControls(context, controller),
      ],
    );
  }

  Widget _buildVideoGrid(BuildContext context, VideoCallController controller) {
    final remoteUsers = controller.remoteUsers;
    final totalUsers = remoteUsers.length + 1;

    if (remoteUsers.isEmpty) {
      return _buildWaitingView(context, controller);
    } else if (totalUsers == 2) {
      return _buildOneToOneLayout(context, controller);
    } else if (totalUsers <= 4) {
      return _buildGridLayout(context, controller, 2);
    } else if (totalUsers <= 9) {
      return _buildGridLayout(context, controller, 3);
    } else {
      return _buildGridLayout(context, controller, 4);
    }
  }

  Widget _buildOneToOneLayout(
      BuildContext context, VideoCallController controller) {
    return Stack(
      children: [
        Positioned.fill(
          child: _renderRemoteVideo(
              context, controller, controller.remoteUsers[0]),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: _buildLocalVideoTile(context, controller, 120, 160),
        ),
      ],
    );
  }

  Widget _buildGridLayout(
      BuildContext context, VideoCallController controller, int columns) {
    final remoteUsers = controller.remoteUsers;
    final allUsers = [0, ...remoteUsers];

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.75,
      ),
      itemCount: allUsers.length > columns * columns
          ? columns * columns
          : allUsers.length,
      itemBuilder: (context, index) {
        if (index >= allUsers.length) return const SizedBox();
        final uid = allUsers[index];
        return _buildVideoTile(context, controller, uid, isLocal: uid == 0);
      },
    );
  }

  Widget _buildVideoTile(
      BuildContext context, VideoCallController controller, int uid,
      {required bool isLocal}) {
    final userName = isLocal
        ? controller.localUserName
        : controller.userNamesMap[uid] ??
            controller.remoteUserName ??
            'User $uid';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isLocal
              ? (controller.cameraEnabled && !controller.isVideoStopped
                  ? Colors.green
                  : Colors.red)
              : (controller.isRemoteVideoEnabled(uid)
                  ? Colors.blue
                  : Colors.red),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            isLocal
                ? _renderLocalVideoInGrid(context, controller)
                : _renderRemoteVideo(context, controller, uid),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLocal
                          ? (controller.isMuted ? Icons.mic_off : Icons.mic)
                          : Icons.person,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalVideoTile(BuildContext context,
      VideoCallController controller, double width, double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: controller.cameraEnabled && !controller.isVideoStopped
              ? Colors.green
              : Colors.red,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            _renderLocalVideo(context, controller),
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  controller.localUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicators(
      BuildContext context, VideoCallController controller) {
    return Positioned(
      top: 20,
      left: 20,
      child: AnimatedContainer(
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
                controller.isMuted ? Icons.mic_off : Icons.mic,
                key: ValueKey(controller.isMuted),
                color: controller.isMuted ? Colors.red : Colors.green,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                controller.isVideoStopped ? Icons.videocam_off : Icons.videocam,
                key: ValueKey(controller.isVideoStopped),
                color: controller.isVideoStopped ? Colors.red : Colors.green,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.signal_cellular_alt,
              color: controller.networkQuality == S.of(context).networkGood
                  ? Colors.green
                  : controller.networkQuality == "Poor"
                      ? Colors.orange
                      : Colors.red,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControls(
      BuildContext context, VideoCallController controller) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMuteButton(context, controller),
            _buildVideoButton(context, controller),
            _buildCameraSwitchButton(context, controller),
            _buildEndCallButton(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildMuteButton(
      BuildContext context, VideoCallController controller) {
    return _buildControlButton(
      context: context,
      icon: controller.isMuted ? Icons.mic_off : Icons.mic,
      backgroundColor: controller.isMuted ? Colors.red : Colors.grey[700]!,
      onPressed: () => controller.toggleMute(),
      tooltip: controller.isMuted ? S.of(context).unmute : S.of(context).mute,
    );
  }

  Widget _buildVideoButton(
      BuildContext context, VideoCallController controller) {
    return _buildControlButton(
      context: context,
      icon: controller.isVideoStopped ? Icons.videocam_off : Icons.videocam,
      backgroundColor:
          controller.isVideoStopped ? Colors.red : Colors.grey[700]!,
      onPressed: () => controller.toggleVideo(),
      tooltip: controller.isVideoStopped
          ? S.of(context).startVideo
          : S.of(context).stopVideo,
    );
  }

  Widget _buildCameraSwitchButton(
      BuildContext context, VideoCallController controller) {
    return _buildControlButton(
      context: context,
      icon: Icons.flip_camera_ios,
      backgroundColor: Colors.grey[700]!,
      onPressed:
          controller.canSwitchCamera ? () => controller.switchCamera() : null,
      tooltip: S.of(context).switchCamera,
      enabled: controller.canSwitchCamera,
    );
  }

  Widget _buildEndCallButton(
      BuildContext context, VideoCallController controller) {
    return _buildControlButton(
      context: context,
      icon: Icons.call_end,
      backgroundColor: Colors.red,
      onPressed: () => controller.endCall(),
      tooltip: S.of(context).endCall,
      size: 60,
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback? onPressed,
    required String tooltip,
    double size = 50,
    bool enabled = true,
  }) {
    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: enabled ? backgroundColor : Colors.grey[600],
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(size / 2),
            onTap: enabled ? onPressed : null,
            child: AnimatedScale(
              scale: enabled ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: enabled ? Colors.white : Colors.white54,
                size: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildConnectionStatus(
      BuildContext context, VideoCallController controller) {
    final status = controller.permissionStatus;
    final hasError = controller.hasError;

    if (status != "Connected! Local UID: 0" && !hasError) {
      return Positioned(
        bottom: 120,
        left: 20,
        right: 20,
        child: AnimatedOpacity(
          opacity: 0.9,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _renderLocalVideo(
      BuildContext context, VideoCallController controller) {
    if (controller.localUserJoined &&
        controller.engine != null &&
        !controller.isVideoStopped) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: controller.engine!,
          canvas: const VideoCanvas(
            uid: 0,
            renderMode: RenderModeType.renderModeHidden,
            // Remove mirrorMode here - let Agora handle it automatically
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.isVideoStopped ? Icons.videocam_off : Icons.person,
                color: Colors.white54,
                size: 30,
              ),
              const SizedBox(height: 4),
              Text(
                controller.isVideoStopped
                    ? S.of(context).videoOff
                    : controller.localUserName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _renderLocalVideoInGrid(
      BuildContext context, VideoCallController controller) {
    if (controller.localUserJoined &&
        controller.engine != null &&
        !controller.isVideoStopped) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: controller.engine!,
          canvas: const VideoCanvas(
            uid: 0,
            renderMode: RenderModeType.renderModeHidden,
            // Remove mirrorMode here too
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.isVideoStopped ? Icons.videocam_off : Icons.person,
                color: Colors.white54,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                controller.isVideoStopped
                    ? S.of(context).videoOff
                    : controller.localUserName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _renderRemoteVideo(
      BuildContext context, VideoCallController controller, int uid) {
    final userName = controller.userNamesMap[uid] ??
        controller.remoteUserName ??
        'User $uid';

    if (controller.engine == null) {
      return _buildVideoPlaceholder(context, uid, S.of(context).connecting,
          userName: userName);
    }

    if (!controller.isRemoteVideoEnabled(uid)) {
      return _buildVideoPlaceholder(context, uid, S.of(context).cameraOff,
          userName: userName);
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: controller.engine!,
        canvas: VideoCanvas(
          uid: uid,
          renderMode: RenderModeType.renderModeHidden,
        ),
        connection: RtcConnection(channelId: VideoCallController.channelName),
      ),
    );
  }

  Widget _buildVideoPlaceholder(BuildContext context, int uid, String message,
      {required String userName}) {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Icon(
                message == S.of(context).cameraOff
                    ? Icons.videocam_off
                    : Icons.person,
                size: 30,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingView(
      BuildContext context, VideoCallController controller) {
    return Stack(
      children: [
        Positioned.fill(
          child: controller.localUserJoined &&
                  controller.engine != null &&
                  !controller.isVideoStopped
              ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: controller.engine!,
                    canvas: const VideoCanvas(
                      uid: 0,
                      renderMode: RenderModeType.renderModeHidden,
                      mirrorMode: VideoMirrorModeType.videoMirrorModeEnabled,
                    ),
                  ),
                )
              : Container(color: Colors.black),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      size: 60,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    controller.isJoined
                        ? S.of(context).waitingForOthers
                        : S.of(context).connecting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (controller.isJoined) ...[
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
