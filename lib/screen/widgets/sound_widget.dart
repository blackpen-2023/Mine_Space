import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mine_space/screen/repo/setting_provider.dart';

class SoundWidget extends ConsumerStatefulWidget {
  final bool visible;
  const SoundWidget({Key? key, required this.visible}) : super(key: key);

  @override
  ConsumerState<SoundWidget> createState() => _SoundWidgetState();
}

class _SoundWidgetState extends ConsumerState<SoundWidget> {
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
    final settings = ref.watch(settingProvider);

    if (!_isReady) {
      return Visibility(
        visible: widget.visible,
        child: Container(
          width: 250,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: settings.textColor.withOpacity(0.4),
            border: Border.all(color: settings.textColor, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
              settings.textColor == Colors.white
                  ? Colors.white
                  : Colors.white.withOpacity(0.2),
            ),
          ),
        ),
      );
    }

    return Visibility(
      visible: widget.visible,
      child: Column(
        key: ValueKey('sound-on'),
        children: [
          Container(
            width: 250,
            //height: 100,
            padding: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: settings.textColor.withOpacity(0.4),
              border: Border.all(color: settings.textColor, width: 1),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.music_note_outlined,
                            size: 14,
                            color:
                                settings.textColor == Colors.white
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                          ),
                          SizedBox(width: 5),
                          Text(
                            '빗소리',
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  settings.textColor == Colors.white
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
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
                                  color:
                                      settings.textColor == Colors.white
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.2),
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
                                  color:
                                      settings.textColor == Colors.white
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 250,
                  height: 40,
                  decoration: BoxDecoration(
                    color: settings.textColor.withOpacity(0.05),
                    border: Border.all(
                      color: settings.textColor.withOpacity(0.1),
                      width: 0.1,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.volume_down,
                          size: 24,
                          color:
                              settings.textColor == Colors.white
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.2),
                        ),
                        Expanded(
                          child: Slider(
                            activeColor:
                                settings.textColor == Colors.white
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                            inactiveColor:
                                settings.textColor == Colors.white
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.2),
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
                        Icon(
                          Icons.volume_up,
                          size: 24,
                          color:
                              settings.textColor == Colors.white
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
