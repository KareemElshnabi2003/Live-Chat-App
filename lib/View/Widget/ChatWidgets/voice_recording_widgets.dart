//region Voice Recording Wave Widget
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live_chat/Core/Constant/app_color.dart';

class VoiceRecordingWave extends StatefulWidget {
  final bool isRecording;
  final bool isPaused;
  final Color waveColor;

  const VoiceRecordingWave({super.key, required this.isRecording, required this.isPaused, required this.waveColor});

  @override
  State<VoiceRecordingWave> createState() => _VoiceRecordingWaveState();
}

class _VoiceRecordingWaveState extends State<VoiceRecordingWave> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final List<double> _heights = [0.4, 0.7, 1.0, 0.6, 0.8, 0.5, 0.9, 0.3, 0.6, 1.0, 0.5, 0.8];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(12, (index) => AnimationController(
      duration: Duration(milliseconds: 300 + (index * 50)),
      vsync: this,
    ));
    if (widget.isRecording && !widget.isPaused) _startAnimations();
  }

  @override
  void didUpdateWidget(VoiceRecordingWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !widget.isPaused) {
      _startAnimations();
    } else {
      _stopAnimations();
    }
  }

  void _startAnimations() {
    for (var ctrl in _controllers) { ctrl.repeat(reverse: true); }
  }
  void _stopAnimations() {
    for (var ctrl in _controllers) { ctrl.stop(); }
  }

  @override
  void dispose() {
    for (var ctrl in _controllers) { ctrl.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(12, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Container(
              width: 3,
              height: widget.isRecording ? (24 * _heights[index] * (_controllers[index].value * 0.5 + 0.5)) : 4,
              decoration: BoxDecoration(color: widget.waveColor, borderRadius: BorderRadius.circular(2)),
            );
          },
        );
      }),
    );
  }
}
//endregion

//region Enhanced Voice Recording Widget
class EnhancedVoiceRecording extends StatefulWidget {
  final bool isRecording;
  final bool isPaused;
  final bool pref;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onCancelRecording;
  final VoidCallback onPauseRecording;
  final VoidCallback onResumeRecording;

  const EnhancedVoiceRecording({
    super.key, required this.isRecording, required this.isPaused,
    required this.onStartRecording, required this.onStopRecording, required this.onCancelRecording,
    required this.onPauseRecording, required this.onResumeRecording, required this.pref,
  });

  @override
  State<EnhancedVoiceRecording> createState() => _EnhancedVoiceRecordingState();
}

class _EnhancedVoiceRecordingState extends State<EnhancedVoiceRecording> with SingleTickerProviderStateMixin {
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    if (widget.isRecording) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!widget.isRecording) { timer.cancel(); return; }
      if (!widget.isPaused) {
        setState(() { _recordingDuration += const Duration(seconds: 1); });
      }
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.pref ? AppColors.darkcolor : AppColors.whiteColor;
    final Color textColor = widget.pref ? Colors.white : Colors.black87;

    if (!widget.isRecording) {
      return GestureDetector(
        onLongPressStart: (_) => widget.onStartRecording(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.mic, color: AppColors.primaryColor, size: 24),
        ),
      );
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onCancelRecording,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.isPaused ? widget.onResumeRecording : widget.onPauseRecording,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color:widget.pref ? Colors.grey.shade800 : Colors.grey.shade200, shape: BoxShape.circle),
              child: Icon(widget.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: textColor, size: 16),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onStopRecording,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: VoiceRecordingWave(isRecording: widget.isRecording, isPaused: widget.isPaused, waveColor: Colors.teal.shade500)),
          const SizedBox(width: 8),
          Text(_formatDuration(_recordingDuration), style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          FadeTransition(
            opacity: widget.isPaused ? const AlwaysStoppedAnimation(1.0) : _blinkController,
            child: Icon(Icons.fiber_manual_record, color: widget.isPaused ? Colors.grey : Colors.red, size: 12),
          ),
        ],
      ),
    );
  }
}
//endregion

