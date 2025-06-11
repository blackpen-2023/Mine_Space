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

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_remaining.inSeconds > 0) {
        setState(() => _remaining -= Duration(seconds: 1));
      } else {
        // Play finish sound using just_audio
        _audioPlayer.setAsset('assets/Sound/alarm.mp3').then((_) {
          _audioPlayer.play();
        });
        _timer?.cancel();
        setState(() => _isRunning = false);
      }
    });
    setState(() {
      _isRunning = true;
      _hasStarted = true;
    });
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
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    _timer?.cancel();
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
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
      );
    }
    if (_remaining.inSeconds > 0) {
      final totalSeconds = widget.initialDuration.inSeconds;
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
                ),
              ),
              SizedBox(width: 30),
              GestureDetector(onTap: _confirmReset, child: Text('그만두기')),
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
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 10),
              _goalText.isNotEmpty
                  ? Text(
                    '수고했어요! 🎉',
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
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
                    style: TextStyle(color: Colors.white, fontSize: 20),
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
