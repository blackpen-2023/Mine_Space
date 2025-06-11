import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mine_space/screen/repo/setting_provider.dart';
import 'package:mine_space/screen/widgets/timer_widget.dart';
import 'package:mine_space/screen/widgets/music_widget.dart';
import 'package:mine_space/screen/widgets/sound_widget.dart';

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

  late Timer _textSwitchTimer;
  bool _showMainText = true;

  @override
  void initState() {
    super.initState();
    _textSwitchTimer = Timer.periodic(Duration(seconds: 8), (timer) {
      setState(() {
        _showMainText = !_showMainText;
      });
    });
  }

  @override
  void dispose() {
    _textSwitchTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingProvider);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 500),
            child: Container(
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
                        : settings.bgType == BackgroundType.local
                        ? DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(settings.bgImageUrl),
                        )
                        : null,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: settings.blurLevel,
              sigmaY: settings.blurLevel,
            ),
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
                        ],
                      ),
                      AnimatedSwitcher(
                        duration: Duration(seconds: 1),
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: 230, // 가장 긴 문구보다 여유 있는 크기
                          key: ValueKey(_showMainText),
                          child: Text(
                            _showMainText ? 'Mine Space' : '나만의 집중공간',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              height: 0.8,
                              color: settings.textColor,
                            ),
                          ),
                        ),
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
                      Row(
                        children: [
                          Text(
                            'BLACKPEN SOFT.',
                            style: TextStyle(
                              color:
                                  settings.textColor == Colors.white
                                      ? Colors.white
                                      : Colors.black26,
                            ),
                          ),
                        ],
                      ),
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
              padding: EdgeInsets.only(left: 20, right: 8, bottom: 8, top: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2320),
              ),
              child: Row(
                children: [
                  Text(
                    '사운드 패널',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color:
                          settings.textColor == Colors.white
                              ? Colors.white.withOpacity(0.4)
                              : Colors.black45,
                    ),
                  ),
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.music_note,
                          color:
                              settings.textColor == Colors.white
                                  ? Colors.white
                                  : Colors.black26,
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.graphic_eq,
                          color:
                              settings.textColor == Colors.white
                                  ? Colors.white
                                  : Colors.black26,
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
                  await showModalBottomSheet(
                    backgroundColor: Colors.white.withOpacity(0.6),
                    barrierColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      BackgroundType tmpType = settings.bgType;
                      String tmpUrl = settings.bgImageUrl;
                      Color tmpColor = settings.bgColor;
                      final notifier = ref.read(settingProvider.notifier);
                      final TextEditingController urlController =
                          TextEditingController(text: tmpUrl);
                      double tmpBlur = settings.blurLevel;

                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          final settings = ref.watch(settingProvider); // 상태 최신화
                          return Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: Container(
                              //color: Colors.white12,
                              padding: EdgeInsets.symmetric(
                                vertical: 30,
                                horizontal: 20,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '배경사진 설정',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                    SizedBox(height: 10),

                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black,
                                            Colors.black,
                                            Colors.black,
                                            Colors.transparent,
                                          ],
                                          stops: [0.0, 0.9, 0.95, 1.0],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: Container(
                                        height: 380,
                                        child: GridView.count(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 1.6,
                                          physics: BouncingScrollPhysics(),
                                          children: [
                                            ...[
                                              'assets/Image/wallpaper/city/city_1.jpg',
                                              'assets/Image/wallpaper/city/city_2.jpg',
                                              'assets/Image/wallpaper/city/city_3.jpg',
                                              'assets/Image/wallpaper/city/city_4.jpg',
                                              'assets/Image/wallpaper/mountain/mountain_1.jpg',
                                              'assets/Image/wallpaper/mountain/mountain_2.jpg',
                                              'assets/Image/wallpaper/mountain/mountain_3.jpg',
                                              'assets/Image/wallpaper/mountain/mountain_4.jpg',
                                              'assets/Image/wallpaper/mountain/mountain_5.jpg',
                                              'assets/Image/wallpaper/mountain/mountain_6.jpg',
                                              'assets/Image/wallpaper/mountain/mountain_7.jpg',
                                              'assets/Image/wallpaper/night/night_1.jpg',
                                              'assets/Image/wallpaper/night/night_2.png',
                                              'assets/Image/wallpaper/night/night_3.jpg',
                                              'assets/Image/wallpaper/etc/ocean_1.jpg',
                                              'assets/Image/wallpaper/etc/road_1.jpg',
                                              'assets/Image/wallpaper/etc/space_1.jpg',
                                            ].map((path) {
                                              return GestureDetector(
                                                onTap: () {
                                                  setModalState(() {});
                                                  notifier.setBackgroundType(
                                                    BackgroundType.local,
                                                  );
                                                  notifier
                                                      .setBackgroundImageUrl(
                                                        path,
                                                      );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(path),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          settings.bgImageUrl ==
                                                                      path &&
                                                                  settings.bgType ==
                                                                      BackgroundType
                                                                          .local
                                                              ? Colors
                                                                  .orangeAccent
                                                              : Colors.grey,
                                                      width:
                                                          settings.bgImageUrl ==
                                                                      path &&
                                                                  settings.bgType ==
                                                                      BackgroundType
                                                                          .local
                                                              ? 4
                                                              : 1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    Text(
                                      '시스템 이미지',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                    SizedBox(height: 10),
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black,
                                            Colors.black,
                                            Colors.transparent,
                                          ],
                                          stops: [0.0, 0.02, 0.98, 1.0],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 0,
                                        ),
                                        child: Row(
                                          children:
                                              [
                                                'assets/Image/wallpaper/system/system_1.jpg',
                                                'assets/Image/wallpaper/system/system_2.jpg',
                                              ].map((path) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    setModalState(() {});
                                                    notifier.setBackgroundType(
                                                      BackgroundType.local,
                                                    );
                                                    notifier
                                                        .setBackgroundImageUrl(
                                                          path,
                                                        );
                                                  },
                                                  child: Container(
                                                    width: 160,
                                                    height: 100,
                                                    margin: EdgeInsets.only(
                                                      right: 12,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage(path),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            settings.bgImageUrl ==
                                                                        path &&
                                                                    settings.bgType ==
                                                                        BackgroundType
                                                                            .local
                                                                ? Colors
                                                                    .orangeAccent
                                                                : Colors.grey,
                                                        width:
                                                            settings.bgImageUrl ==
                                                                        path &&
                                                                    settings.bgType ==
                                                                        BackgroundType
                                                                            .local
                                                                ? 4
                                                                : 1,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    /*Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: urlController,
                                            decoration: InputDecoration(
                                              labelText: '이미지 URL',
                                            ),
                                            onChanged: (val) {
                                              setModalState(() {
                                                tmpUrl = val;
                                                tmpType = BackgroundType.image;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        TextButton(
                                          onPressed: () {
                                            final trimmed =
                                                urlController.text.trim();
                                            if (trimmed.isNotEmpty) {
                                              notifier.setBackgroundType(
                                                BackgroundType.image,
                                              );
                                              notifier.setBackgroundImageUrl(
                                                trimmed,
                                              );
                                            }
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('적용'),
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),*/
                                    SizedBox(height: 20),
                                    // 단색 배경과 흐림 정도를 같은 줄에 배치
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(' 단색 배경'),
                                            Row(
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
                                                        notifier
                                                            .setBackgroundType(
                                                              BackgroundType
                                                                  .color,
                                                            );
                                                        notifier
                                                            .setBackgroundColor(
                                                              c,
                                                            );
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.all(
                                                          4,
                                                        ),
                                                        width: 30,
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                          color: c,
                                                          border:
                                                              tmpColor == c
                                                                  ? Border.all(
                                                                    width: 2,
                                                                    color:
                                                                        Colors
                                                                            .amber,
                                                                  )
                                                                  : null,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 40),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('흐림 단계'),
                                              Container(
                                                width: double.infinity,
                                                child: Slider(
                                                  activeColor: Colors.black,
                                                  inactiveColor:
                                                      Colors.grey.shade300,
                                                  value: tmpBlur,
                                                  min: 0,
                                                  max: 20,
                                                  divisions: 4,
                                                  label: tmpBlur
                                                      .toStringAsFixed(0),
                                                  onChanged: (val) {
                                                    setModalState(() {
                                                      tmpBlur = val;
                                                    });
                                                    notifier.setBlurLevel(val);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color:
                        settings.textColor == Colors.white
                            ? _isBottomHovered
                                ? Colors.white.withOpacity(0.4)
                                : Colors.white.withOpacity(0.3)
                            : _isBottomHovered
                            ? Colors.black.withOpacity(0.8)
                            : Colors.black.withOpacity(0.3),
                  ),
                  child: Text(
                    '배경 편집하기',
                    style: TextStyle(
                      fontSize: 17,
                      color:
                          settings.textColor == Colors.white
                              ? Colors.white.withOpacity(0.8)
                              : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 120,
            child: Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(settingProvider);
                final notifier = ref.read(settingProvider.notifier);
                final isWhite = settings.textColor == Colors.white;
                return Container(
                  width: 70,
                  height: 30,
                  child: AnimatedToggleSwitch<bool>.dual(
                    current: isWhite,
                    first: true,
                    second: false,
                    indicatorSize: Size(250, 30),
                    //spacing: 1.0,
                    style: ToggleStyle(
                      backgroundColor:
                          isWhite
                              ? Colors.black.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30.0),
                      indicatorColor:
                          isWhite
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black.withOpacity(0.4),
                      borderColor: Colors.transparent,
                      boxShadow: const [],
                    ),
                    onChanged: (value) {
                      final newColor = value ? Colors.white : Colors.black;
                      notifier.setTextColor(newColor);
                    },
                    iconBuilder:
                        (value) =>
                            value
                                ? Icon(
                                  Icons.light_mode_outlined,
                                  color: Colors.amber,
                                )
                                : Icon(
                                  Icons.dark_mode_outlined,
                                  color: Colors.black,
                                ),
                    /*textBuilder:
                            (value) => Text(
                              value ? "라이트" : "다크",
                              style: TextStyle(
                                color: value ? Colors.white : Colors.black,
                                fontSize: 14,
                              ),
                            ),*/
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
