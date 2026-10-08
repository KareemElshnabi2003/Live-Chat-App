
//region AudioMessageWidget

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class AudioMessageWidget extends StatefulWidget {
  final String url;
  final String? localPath;
  final bool pref;
  const AudioMessageWidget({super.key, required this.url, this.localPath, required this.pref});

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  late AudioPlayer _player;
  bool isPlaying = false;
  Duration? duration = Duration.zero;
  Duration position = Duration.zero;
  double playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _player.setLoopMode(LoopMode.off);
      if (widget.localPath != null && await File(widget.localPath!).exists()) {
        await _player.setFilePath(widget.localPath!);
      } else {
        await _player.setUrl(widget.url);
      }
      _player.durationStream.listen((d) { if (mounted) setState(() => duration = d ?? Duration.zero); });
      _player.positionStream.listen((p) { if (mounted) setState(() => position = p); });
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
    } catch (e) { debugPrint('Error initializing audio: $e'); }
  }

  void _toggleSpeed() {
    setState(() {
      playbackSpeed = playbackSpeed == 1.0 ? 1.5 : (playbackSpeed == 1.5 ? 2.0 : 1.0);
      _player.setSpeed(playbackSpeed);
    });
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }

  String _formatDuration(Duration d) {
    final seconds = d.inSeconds % 60;
    return '${d.inMinutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final Color activeColor = widget.pref ? const Color(0xFFC3D849) : AppColors.primaryColor;
    final Color darkBg = widget.pref ? const Color(0xFF1E1E1E) : Colors.grey.shade100;
    final Color unplayedLineColor = widget.pref ? Colors.white : Colors.black38;
    final Color textColor = widget.pref ? Colors.grey.shade400 : Colors.grey.shade700;
    final Color speedBtnBg = widget.pref ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.05);

    double progress = (duration?.inMilliseconds ?? 0) > 0
        ? position.inMilliseconds / duration!.inMilliseconds
        : 0.0;
    progress = progress.clamp(0.0, 1.0);

    return Container(
      width: 65.w,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              if (isPlaying) { await _player.pause(); } else { await _player.play(); }
            },
            child: Container(
              width: 12.w, height: 12.w,
              decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
              child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 8.w),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                          end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                          colors: [activeColor, unplayedLineColor],
                          stops: [progress, progress],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(20, (index) {
                          double height = [10, 15, 20, 12, 25, 18, 10, 30, 22, 14, 28, 16, 20, 12, 26, 18, 14, 22, 10, 15][index].toDouble();
                          return Container(
                              width: 3.5,
                              height: height,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              )
                          );
                        }),
                      ),
                    ),
                    SliderTheme(
                      data: const SliderThemeData(
                        trackHeight: 30,
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                      ),
                      child: Slider(
                        value: position.inSeconds.toDouble(),
                        max: duration?.inSeconds.toDouble() ?? 1.0,
                        onChanged: (value) async {
                          await _player.seek(Duration(seconds: value.toInt()));
                          setState(() => position = Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _toggleSpeed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: speedBtnBg,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text('${playbackSpeed.toStringAsFixed(0)}x', style: TextStyle(fontSize: 2.8.w, color: textColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Text(_formatDuration(position), style: TextStyle(fontSize: 3.w, color: textColor)),
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