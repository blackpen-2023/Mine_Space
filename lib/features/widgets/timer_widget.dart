import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

import 'package:mine_space/features/repo/setting_provider.dart';
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

class _TimerWidgetState extends ConsumerState<TimerWidget> {
  Duration _remaining = Duration.zero;
  late Duration _tempDuration;
  Timer? _timer;
  bool _isRunning = false;
  bool _showSettings = true;

  late TextEditingController _goalController;
  String _goalText = '';

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialDuration;
    _tempDuration = _remaining;
    _showSettings = true;
    _goalController = TextEditingController();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_remaining.inSeconds > 0) {
        setState(() => _remaining -= Duration(seconds: 1));
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
      }
    });
    setState(() => _isRunning = true);
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
            title: Text('정말 그만두시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('확인'),
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
          SizedBox(height: 10),
          SizedBox(
            width: 300,
            child: TextField(
              cursorColor:
                  settings.textColor == Colors.white
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.3),
              controller: _goalController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '목표 글귀 입력',
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
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        settings.textColor == Colors.white
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              setState(() {
                _goalText = _goalController.text;
              });
              _onDurationChanged(_tempDuration);
            },
            child: Text('설정하기'),
          ),
        ],
      );
    }
    if (_remaining.inSeconds > 0) {
      final hours = _remaining.inHours.toString().padLeft(2, '0');
      final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
      return Column(
        children: [
          SizedBox(
            child: Column(
              children: [
                Text(
                  '남은시간',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
                ),
                Text(
                  _remaining.inSeconds > 0
                      ? '$hours:$minutes:$seconds'
                      : (_goalText.isNotEmpty ? _goalText : '목표에 달성했어요!'),
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _toggleRunPause,
                  child: Text(_isRunning ? '일시정지' : '재생'),
                ),
                SizedBox(width: 30),
                GestureDetector(onTap: _confirmReset, child: Text('그만두기')),
              ],
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Column(
          children: [
            Text('종료되었습니다!'),
            ElevatedButton(onPressed: _resetOnFinish, child: Text('리셋하기')),
          ],
        ),
      );
    }
  }
}
