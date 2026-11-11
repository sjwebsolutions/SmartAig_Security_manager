import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:security_manager/models/active_event_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LiveTelecastWidget extends StatefulWidget {
  final ActiveEventModel event;

  const LiveTelecastWidget({super.key, required this.event});

  @override
  State<LiveTelecastWidget> createState() => _LiveTelecastWidgetState();
}

class _LiveTelecastWidgetState extends State<LiveTelecastWidget> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant LiveTelecastWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.id != widget.event.id) {
      _controller?.dispose();
      _initPlayer();
    }
  }

  void _initPlayer() {
    final telecast = widget.event.liveTelecast;
    String? videoId = telecast?.youtubeVideoId;
    if ((videoId == null || videoId.isEmpty) && telecast?.youtubeUrl != null) {
      videoId = YoutubePlayer.convertUrlToId(telecast!.youtubeUrl!);
    }
    if (videoId != null && videoId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          isLive: false,
          forceHD: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telecast = widget.event.liveTelecast;
    if (telecast == null || !telecast.isLive || _controller == null) {
      return const SizedBox.shrink();
    }

    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        final wasPlaying = _controller!.value.isPlaying;
        Get.to(() => FullScreenVideoPage(
              controller: _controller!,
            ))?.then((_) {
          if (wasPlaying || _controller!.value.isPlaying) {
            _controller?.play();
          }
        });
      },
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: false,
        liveUIColor: Colors.transparent,
        bottomActions: [
          const SizedBox(width: 12),
          CurrentPosition(
            controller: _controller!,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: ProgressBar(
                isExpanded: false,
                controller: _controller!,
                colors: const ProgressBarColors(
                  playedColor: Color(0xFFDC2626),
                  handleColor: Color(0xFFDC2626),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PlaybackSpeedButton(
            controller: _controller!,
          ),
          FullScreenButton(
            controller: _controller!,
          ),
          const SizedBox(width: 8),
        ],
      ),
      builder: (context, player) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Telecast Badge Header
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.live_tv_rounded, color: Color(0xFFDC2626), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'LIVE TELECAST',
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Youtube Video Player
              player,
            ],
          ),
        );
      },
    );
  }
}

class FullScreenVideoPage extends StatefulWidget {
  final YoutubePlayerController controller;

  const FullScreenVideoPage({
    super.key,
    required this.controller,
  });

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    widget.controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    if (!widget.controller.value.isFullScreen && mounted) {
      Get.back();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    // Auto-resume video playback in portrait mode upon returning
    Future.microtask(() {
      widget.controller.play();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (widget.controller.value.isFullScreen) {
          widget.controller.toggleFullScreenMode();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: YoutubePlayer(
            controller: widget.controller,
            showVideoProgressIndicator: false,
            liveUIColor: Colors.transparent,
            bottomActions: [
              const SizedBox(width: 12),
              CurrentPosition(
                controller: widget.controller,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: ProgressBar(
                    isExpanded: false,
                    controller: widget.controller,
                    colors: const ProgressBarColors(
                      playedColor: Color(0xFFDC2626),
                      handleColor: Color(0xFFDC2626),
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PlaybackSpeedButton(
                controller: widget.controller,
              ),
              FullScreenButton(
                controller: widget.controller,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
