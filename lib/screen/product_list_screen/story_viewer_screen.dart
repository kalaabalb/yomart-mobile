import 'package:e_commerce_flutter/models/story.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

typedef StoryRenew = Future<Story?> Function(String id);

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({
    required this.stories,
    required this.initialIndex,
    required this.renewStory,
    super.key,
  });

  final List<Story> stories;
  final int initialIndex;
  final StoryRenew renewStory;

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  VideoPlayerController? _controller;
  int _index = 0;
  bool _loading = true;
  bool _failed = false;
  bool _moving = false;

  @override
  void initState() {
    super.initState();
    _index = widget.stories.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.stories.length - 1);
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    if (widget.stories.isEmpty) return;
    final old = _controller;
    _controller = null;
    await old?.dispose();
    if (!mounted) return;
    setState(() {
      _loading = true;
      _failed = false;
      _moving = false;
    });
    try {
      final story = await widget.renewStory(widget.stories[_index].id);
      if (story == null || !isSafeStoryPlaybackUrl(story.playbackUrl)) {
        throw StateError('Story playback link is unavailable.');
      }
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(story.playbackUrl));
      _controller = controller;
      controller.addListener(_onVideoUpdate);
      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  void _onVideoUpdate() {
    final controller = _controller;
    if (!mounted || controller == null || !controller.value.isInitialized) {
      return;
    }
    if (controller.value.hasError) {
      setState(() {
        _failed = true;
        _loading = false;
      });
    } else if (controller.value.duration > Duration.zero &&
        controller.value.position >= controller.value.duration &&
        !_moving) {
      _moving = true;
      _next();
    } else {
      setState(() {});
    }
  }

  Future<void> _next() async {
    if (_index + 1 >= widget.stories.length) {
      if (mounted) Navigator.of(context).maybePop();
      return;
    }
    setState(() => _index++);
    await _loadCurrent();
  }

  Future<void> _previous() async {
    if (_index == 0) {
      final controller = _controller;
      if (controller?.value.isInitialized == true) {
        await controller!.seekTo(Duration.zero);
      }
      return;
    }
    setState(() => _index--);
    await _loadCurrent();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
              child: Text('No stories available.',
                  style: TextStyle(color: Colors.white))));
    }
    final story = widget.stories[_index];
    final value = _controller?.value;
    final position = value?.position ?? Duration.zero;
    final duration = value?.duration ?? Duration.zero;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final durationMs = duration.inMilliseconds.toDouble();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(children: [
            Positioned.fill(
              child: Center(
                child: _failed
                    ? _PlaybackError(onRetry: _loadCurrent)
                    : _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : AspectRatio(
                            aspectRatio: value!.aspectRatio,
                            child: VideoPlayer(_controller!)),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _loading || _failed,
                child: Row(children: [
                  Expanded(
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _previous)),
                  Expanded(
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent, onTap: _next)),
                ]),
              ),
            ),
            Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Column(children: [
                  Row(
                      children: List.generate(widget.stories.length, (index) {
                    final fill = index < _index
                        ? 1.0
                        : index == _index
                            ? progress
                            : 0.0;
                    return Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                    value: fill,
                                    minHeight: 3,
                                    backgroundColor: Colors.white38,
                                    valueColor: const AlwaysStoppedAnimation(
                                        Colors.white)))));
                  })),
                  const SizedBox(height: 13),
                  Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(story.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                          if (story.subtitle.isNotEmpty)
                            Text(story.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12))
                        ])),
                    IconButton(
                        tooltip: value?.isPlaying == true
                            ? 'Pause story'
                            : 'Play story',
                        color: Colors.white,
                        onPressed: _controller == null
                            ? null
                            : () => value?.isPlaying == true
                                ? _controller!.pause()
                                : _controller!.play(),
                        icon: Icon(value?.isPlaying == true
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded)),
                    IconButton(
                        tooltip: 'Close stories',
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close_rounded)),
                  ]),
                ])),
            Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                    child: IconButton(
                        tooltip: 'Previous story',
                        onPressed: _previous,
                        color: Colors.white70,
                        icon:
                            const Icon(Icons.chevron_left_rounded, size: 34)))),
            Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                    child: IconButton(
                        tooltip: 'Next story',
                        onPressed: _next,
                        color: Colors.white70,
                        icon: const Icon(Icons.chevron_right_rounded,
                            size: 34)))),
            if (value?.isInitialized == true && durationMs > 0)
              Positioned(
                left: 24,
                right: 24,
                bottom: 12,
                child: StorySeekBar(
                  position: position,
                  duration: duration,
                  onSeek: (target) => _controller?.seekTo(target),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class StorySeekBar extends StatefulWidget {
  const StorySeekBar({
    required this.position,
    required this.duration,
    required this.onSeek,
    super.key,
  });

  final Duration position;
  final Duration duration;
  final Future<void>? Function(Duration target) onSeek;

  @override
  State<StorySeekBar> createState() => _StorySeekBarState();
}

class _StorySeekBarState extends State<StorySeekBar> {
  double? _previewMs;

  @override
  Widget build(BuildContext context) {
    final durationMs = widget.duration.inMilliseconds.toDouble();
    if (durationMs <= 0) return const SizedBox.shrink();
    final positionMs =
        widget.position.inMilliseconds.toDouble().clamp(0.0, durationMs);
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Text(_formatDuration(widget.position),
                style: const TextStyle(color: Colors.white, fontSize: 11)),
            Expanded(
              child: Slider(
                key: const ValueKey('story-seek-slider'),
                min: 0,
                max: durationMs,
                value: (_previewMs ?? positionMs).clamp(0.0, durationMs),
                onChanged: (milliseconds) =>
                    setState(() => _previewMs = milliseconds),
                onChangeEnd: (milliseconds) async {
                  await widget
                      .onSeek(Duration(milliseconds: milliseconds.round()));
                  if (mounted) setState(() => _previewMs = null);
                },
              ),
            ),
            Text(_formatDuration(widget.duration),
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _PlaybackError extends StatelessWidget {
  const _PlaybackError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded,
            color: Colors.white70, size: 38),
        const SizedBox(height: 12),
        const Text('This story could not be played.',
            style: TextStyle(color: Colors.white)),
        const SizedBox(height: 10),
        OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white)),
      ]);
}
