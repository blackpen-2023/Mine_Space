import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundWidget extends StatefulWidget {
  final bool visible;
  const SoundWidget({Key? key, required this.visible}) : super(key: key);

  @override
  State<SoundWidget> createState() => _SoundWidgetState();
}

class _SoundWidgetState extends State<SoundWidget> {
  late AudioPlayer _player;
  double _volume = 1.0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    // 초기 볼륨 설정
    _player.setVolume(_volume);
    _prepareAudio();
  }

  Future<void> _prepareAudio() async {
    await _player.setAsset('assets/Sound/test.mp3');
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _play() {
    _player.play();
  }

  void _pause() {
    _player.pause();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return Visibility(
        visible: widget.visible,
        child: Container(
          width: 300,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.4),
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    return Visibility(
      visible: widget.visible,
      child: Column(
        key: ValueKey('sound-on'),
        children: [
          Container(
            width: 300,
            //height: 100,
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('빗소리', style: TextStyle(fontSize: 20)),
                      Row(
                        children: [
                          StreamBuilder<PlayerState>(
                            stream: _player.playerStateStream,
                            builder: (context, snapshot) {
                              final isPlaying = snapshot.data?.playing ?? false;
                              return GestureDetector(
                                onTap: () {
                                  isPlaying ? _player.pause() : _player.play();
                                },
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  size: 28,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          StreamBuilder<LoopMode>(
                            stream: _player.loopModeStream,
                            builder: (context, snapshot) {
                              final loopMode = snapshot.data ?? LoopMode.off;
                              return GestureDetector(
                                onTap: () {
                                  final nextMode =
                                      loopMode == LoopMode.off
                                          ? LoopMode.one
                                          : LoopMode.off;
                                  _player.setLoopMode(nextMode);
                                },
                                child: Icon(
                                  loopMode == LoopMode.off
                                      ? Icons.repeat
                                      : Icons.repeat_one,
                                  size: 28,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 300,
            //height: 100,
            padding: EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.volume_down, size: 24),
                  Expanded(
                    child: Slider(
                      activeColor: Colors.black12,
                      inactiveColor: Colors.grey.withOpacity(0.1),
                      min: 0.0,
                      max: 1.0,
                      value: _volume,
                      onChanged: (value) {
                        setState(() {
                          _volume = value;
                        });
                        _player.setVolume(value);
                      },
                    ),
                  ),
                  Icon(Icons.volume_up, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
