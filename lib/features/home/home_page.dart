import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mine_space/features/repo/setting_provider.dart';
import 'package:mine_space/features/widgets/%08timer_widget.dart';
import 'package:mine_space/features/widgets/music_widget.dart';
import 'package:mine_space/features/widgets/sound_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePage();
}

class _HomePage extends ConsumerState<HomePage> {
  bool _showSoundWidget = true;
  bool _showMusicWidget = true;
  bool _isMusicHovered = false;
  bool _isSoundHovered = false;
  bool _isBottomHovered = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingProvider);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color:
                  settings.bgType == BackgroundType.color
                      ? settings.bgColor
                      : null,
              image:
                  settings.bgType == BackgroundType.image
                      ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(settings.bgImageUrl),
                      )
                      : null,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: Colors.black.withOpacity(0.1), // 살짝 어둡게(선택)
            ),
          ),
          DefaultTextStyle(
            style: TextStyle(color: settings.textColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('소개'),
                          SizedBox(width: 20),
                          Text('사용방법'),
                          SizedBox(width: 20),
                          Text('홈'),
                        ],
                      ),
                      Text(
                        '나만의 집중공간',
                        style: TextStyle(
                          fontSize: 30,
                          height: 0.8,
                          color: settings.textColor,
                        ),
                      ),
                      Row(
                        children: [
                          Text('설정'),
                          Text('설정'),
                          Text('설정'),
                          Text('설정'),
                        ],
                      ),
                    ],
                  ),
                ),
                TimerWidget(),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(),
                      Row(children: [Text('BLACKPEN SOFT.')]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 70,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text('사운드 컨드롤', style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 10),
                  MouseRegion(
                    onEnter: (_) => setState(() => _isMusicHovered = true),
                    onExit: (_) => setState(() => _isMusicHovered = false),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showMusicWidget = !_showMusicWidget;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              _isMusicHovered ? Colors.white24 : Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.music_note,
                          color: _isMusicHovered ? Colors.amber : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  MouseRegion(
                    onEnter: (_) => setState(() => _isSoundHovered = true),
                    onExit: (_) => setState(() => _isSoundHovered = false),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showSoundWidget = !_showSoundWidget;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              _isSoundHovered ? Colors.white24 : Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.graphic_eq,
                          color: _isSoundHovered ? Colors.amber : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 300,
            child: SoundWidget(visible: _showSoundWidget),
          ),
          Positioned(
            right: 16,
            bottom: 140,
            child: MusicWidget(visible: _showMusicWidget),
          ),
          Positioned(
            left: 30,
            bottom: 70,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isBottomHovered = true),
              onExit: (_) => setState(() => _isBottomHovered = false),
              child: GestureDetector(
                onTap: () async {
                  final notifier = ref.read(settingProvider.notifier);
                  final tmpSettings = {
                    'type': settings.bgType,
                    'url': settings.bgImageUrl,
                    'color': settings.bgColor,
                    'textColor': settings.textColor,
                  };
                  await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      BackgroundType tmpType = settings.bgType;
                      String tmpUrl = settings.bgImageUrl;
                      Color tmpColor = settings.bgColor;
                      Color tmpTextColor = settings.textColor;
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(title: Text('배경 유형 선택')),
                                  RadioListTile<BackgroundType>(
                                    title: Text('이미지'),
                                    value: BackgroundType.image,
                                    groupValue: tmpType,
                                    onChanged: (val) {
                                      setModalState(() => tmpType = val!);
                                      notifier.setBackgroundType(val!);
                                    },
                                  ),
                                  RadioListTile<BackgroundType>(
                                    title: Text('단색'),
                                    value: BackgroundType.color,
                                    groupValue: tmpType,
                                    onChanged: (val) {
                                      setModalState(() => tmpType = val!);
                                      notifier.setBackgroundType(val!);
                                    },
                                  ),
                                  if (tmpType == BackgroundType.image)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: '이미지 URL',
                                        ),
                                        controller: TextEditingController(
                                          text: tmpUrl,
                                        ),
                                        onChanged: (v) {
                                          tmpUrl = v;
                                          notifier.setBackgroundImageUrl(v);
                                        },
                                      ),
                                    ),
                                  if (tmpType == BackgroundType.color)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          [
                                            Colors.black,
                                            Colors.white,
                                            Colors.blue,
                                            Colors.red,
                                          ].map((c) {
                                            return GestureDetector(
                                              onTap: () {
                                                setModalState(
                                                  () => tmpColor = c,
                                                );
                                                notifier.setBackgroundColor(c);
                                              },
                                              child: Container(
                                                margin: EdgeInsets.all(8),
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: c,
                                                  border:
                                                      tmpColor == c
                                                          ? Border.all(
                                                            width: 2,
                                                            color: Colors.amber,
                                                          )
                                                          : null,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ListTile(title: Text('글자 색상 선택')),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        [Colors.white, Colors.black].map((c) {
                                          return GestureDetector(
                                            onTap: () {
                                              setModalState(
                                                () => tmpTextColor = c,
                                              );
                                              notifier.setTextColor(c);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(8),
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: c,
                                                border:
                                                    tmpTextColor == c
                                                        ? Border.all(
                                                          width: 2,
                                                          color: Colors.amber,
                                                        )
                                                        : null,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.of(context).pop({
                                          'type': tmpType,
                                          'url': tmpUrl,
                                          'color': tmpColor,
                                          'textColor': tmpTextColor,
                                        }),
                                    child: Text('확인'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                  // No need to update parent state here, as changes are already applied.
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        _isBottomHovered
                            ? Colors.white.withOpacity(1.0)
                            : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '나만의 공간 만들기',
                    style: TextStyle(fontSize: 20, color: settings.textColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
