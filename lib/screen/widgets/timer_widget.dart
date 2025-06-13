import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:just_audio/just_audio.dart';

import 'package:mine_space/screen/repo/setting_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class TimerWidget extends ConsumerStatefulWidget {
  final Duration initialDuration;
  final ValueChanged<Duration>? onDurationChanged;
  const TimerWidget({
    super.key,
    this.initialDuration = const Duration(minutes: 1),
    this.onDurationChanged,
  });

  @override
  ConsumerState<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget>
    with SingleTickerProviderStateMixin {
  Duration _remaining = Duration.zero;
  late Duration _tempDuration;
  Timer? _timer;
  bool _isRunning = false;
  bool _showSettings = true;
  bool _hasStarted = false;

  bool _isAlarmEnabled = true;

  late final AudioPlayer _audioPlayer;
  late final AnimationController _flashController;

  late TextEditingController _goalController;
  String _goalText = '';

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialDuration;
    _tempDuration = _remaining;
    _showSettings = true;
    _goalController = TextEditingController();
    _audioPlayer = AudioPlayer();
    _flashController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flashController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _flashController.forward();
      }
    });
  }

  void _startTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (_remaining.inSeconds > 0) {
        if (mounted) {
          setState(() => _remaining -= Duration(seconds: 1));
        }
      } else {
        if (_isAlarmEnabled) {
          try {
            // 안전장치: 오디오 재생 전 player가 이미 재생 중이면 중지
            if (_audioPlayer.playerState.playing) {
              await _audioPlayer.stop();
            }
            await _audioPlayer.setAsset('assets/Sound/alarm.mp3');
            await _audioPlayer.play();
          } catch (e) {
            debugPrint('오디오 재생 오류: $e');
          }
        }
        _timer?.cancel();
        if (mounted) {
          setState(() => _isRunning = false);
        }
      }
    });
    if (mounted) {
      setState(() {
        _isRunning = true;
        _hasStarted = true;
      });
    }
  }

  void _toggleRunPause() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _startTimer();
    }
  }

  Future<void> _confirmReset() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white.withOpacity(0),
            title: Text(
              '정말 그만둘까요...? 🥺',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('취소', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('확인', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (result == true) {
      _timer?.cancel();
      setState(() {
        _remaining = Duration.zero;
        _isRunning = false;
        _showSettings = true;
      });
    }
  }

  void _onDurationChanged(Duration newDuration) {
    _timer?.cancel();
    setState(() {
      _remaining = newDuration;
      _isRunning = false;
      _showSettings = false;
      _hasStarted = false;
    });
    if (widget.onDurationChanged != null) {
      widget.onDurationChanged!(newDuration);
    }
  }

  void _resetOnFinish() {
    setState(() {
      _showSettings = true;
      _remaining = widget.initialDuration;
      _isRunning = false;
      _goalText = '';
      _hasStarted = false;
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingProvider);

    if (_showSettings) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: SizedBox(
              height: 200,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness:
                      settings.textColor == Colors.white
                          ? Brightness.dark
                          : Brightness.light,
                ),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hms,
                  initialTimerDuration: _tempDuration,
                  onTimerDurationChanged: (newDur) {
                    setState(() {
                      _tempDuration = newDur;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          SizedBox(
            width: 270,
            child: TextField(
              style: TextStyle(
                color:
                    settings.textColor == Colors.white
                        ? Colors.white.withOpacity(0.9)
                        : Colors.black.withOpacity(0.9),
              ),
              cursorColor:
                  settings.textColor == Colors.white
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.3),
              controller: _goalController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '목표 입력',
                labelStyle: TextStyle(
                  color:
                      settings.textColor == Colors.white
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        settings.textColor == Colors.white
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.7),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        settings.textColor == Colors.white
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),

          GestureDetector(
            onTap: () {
              setState(() {
                _goalText = _goalController.text;
              });
              _onDurationChanged(_tempDuration);
            },
            child: Container(
              width: 340,
              height: 70,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color:
                    settings.textColor == Colors.white
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '도전하기 🚀',
                style: TextStyle(
                  fontFamily: 'AGR',
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          AlarmToggle(
            value: _isAlarmEnabled,
            textColor: settings.textColor,
            onChanged: (bool value) {
              setState(() {
                _isAlarmEnabled = value;
              });
            },
          ),
        ],
      );
    }
    if (_remaining.inSeconds > 0) {
      final totalSeconds = _tempDuration.inSeconds;
      final progress =
          totalSeconds > 0 ? _remaining.inSeconds / totalSeconds : 0.0;
      final hours = _remaining.inHours.toString().padLeft(2, '0');
      final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: Duration(milliseconds: 600),
                builder: (context, animatedProgress, child) {
                  return Container(
                    child: SizedBox(
                      width: 350,
                      height: 350,
                      child: CircularProgressIndicator(
                        value: animatedProgress,
                        strokeWidth: 2,
                        backgroundColor: Colors.black.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(settings.textColor),
                      ),
                    ),
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _goalText.isNotEmpty ? '\' ${_goalText} \'' : '남은시간',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'AGR',
                      fontWeight: FontWeight.w100,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '$hours:$minutes:$seconds',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 9,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleRunPause,
                child: Text(
                  _isRunning ? '일시정지' : (_hasStarted ? '이어하기' : '시작하기'),
                  style: TextStyle(
                    fontFamily: 'AGR',
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
              SizedBox(width: 30),
              GestureDetector(
                onTap: _confirmReset,
                child: Text(
                  '그만두기',
                  style: TextStyle(
                    fontFamily: 'AGR',
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Center(
        child: AnimatedBuilder(
          animation: _flashController,
          builder: (context, child) {
            return Opacity(opacity: 1.0 - _flashController.value, child: child);
          },
          child: Column(
            children: [
              Text(
                textAlign: TextAlign.center,
                _goalText.isNotEmpty
                    ? '\' ${_goalText} \' 가 끝났어요!'
                    : '수고했어요! 🎉',
                style: TextStyle(
                  fontSize: 60,
                  fontFamily: 'AGR',
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10),
              _goalText.isNotEmpty
                  ? Text(
                    '수고했어요! 🎉',
                    style: TextStyle(
                      fontSize: 35,
                      fontFamily: 'AGR',
                      fontWeight: FontWeight.w800,
                    ),
                  )
                  : SizedBox(),
              SizedBox(height: 50),
              GestureDetector(
                onTap: _resetOnFinish,
                child: Container(
                  width: 340,
                  height: 70,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        settings.textColor == Colors.white
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black12,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '다시하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "AGR",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

/// 알람 토글 위젯. 상태를 내부적으로 유지하며 부모와 onChanged로 통신
class AlarmToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color textColor;

  const AlarmToggle({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.textColor,
  }) : super(key: key);

  @override
  State<AlarmToggle> createState() => _AlarmToggleState();
}

class _AlarmToggleState extends State<AlarmToggle> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.value;
  }

  @override
  void didUpdateWidget(covariant AlarmToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _checked = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: .0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 0.7, // 원하는 크기로 조정 (예: 0.8은 80% 크기)
            child: Checkbox(
              value: _checked,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    _checked = value;
                  });
                  widget.onChanged(value);
                }
              },
              activeColor: widget.textColor,
              checkColor: Colors.black,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Flexible(
            child: Text(
              '타이머 종료 ',
              style: TextStyle(color: widget.textColor, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
