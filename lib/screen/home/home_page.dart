import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  bool _audioVisible = true;
  bool _isAudioHovered = false;
  bool _isBottomHovered = false;
  bool _hasShownIntro = false;
  bool _hideAllWidgets = false;

  late Timer _textSwitchTimer;
  bool _showMainText = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textSwitchTimer = Timer.periodic(Duration(seconds: 8), (timer) {
      setState(() {
        _showMainText = !_showMainText;
      });
    });
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownIntro) {
        _hasShownIntro = true;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('안내'),
                content: Text('안내사항'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('확인'),
                  ),
                ],
              ),
        );
      }
    });*/
  }

  @override
  void dispose() {
    _textSwitchTimer.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingProvider);
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyF) {
          setState(() => _hideAllWidgets = !_hideAllWidgets);
        }
      },
      child: Scaffold(
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
                color: Colors.black.withOpacity(_hideAllWidgets ? 0.3 : 0.1),
              ),
            ),
            DefaultTextStyle(
              style: TextStyle(color: settings.textColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: !_hideAllWidgets,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          /*Row(
                          children: [
                            Text('소개'),
                            SizedBox(width: 20),
                            Text('사용방법'),
                          ],
                        ),*/
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
                                _showMainText ? '나만의 집중공간' : 'MineSpace',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontFamily: 'AGR',
                                  fontWeight: FontWeight.w800,
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
                  ),
                  TimerWidget(),
                  Visibility(
                    visible: !_hideAllWidgets,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'BLACKPEN SOFT.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color:
                                      settings.textColor == Colors.white
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              Text(
                                'ⓒ 2025. 배규민 All rights reserved.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      settings.textColor == Colors.white
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.black.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: !_hideAllWidgets,
              child: Positioned(
                right: 16,
                bottom: 70,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 14,
                    right: 6,
                    bottom: 4,
                    top: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        settings.textColor == Colors.white
                            ? Colors.grey.withOpacity(0.1)
                            : Colors.black45,

                    borderRadius: BorderRadius.circular(100),
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
                                  : Colors.white.withOpacity(0.4),
                        ),
                      ),
                      SizedBox(width: 10),
                      MouseRegion(
                        onEnter: (_) => setState(() => _isAudioHovered = true),
                        onExit: (_) => setState(() => _isAudioHovered = false),
                        child: GestureDetector(
                          onTap:
                              () => setState(
                                () => _audioVisible = !_audioVisible,
                              ),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  _isAudioHovered
                                      ? Colors.white24
                                      : Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.volume_up,
                              color: settings.textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !_hideAllWidgets,
              child: Positioned(
                right: 16,
                bottom: 140,
                child: CombinedAudioWidget(visible: _audioVisible),
              ),
            ),
            Positioned(
              left: 30,
              bottom: 70,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isBottomHovered = true),
                onExit: (_) => setState(() => _isBottomHovered = false),
                child: Row(
                  children: [
                    Visibility(
                      visible: !_hideAllWidgets,
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
                              final notifier = ref.read(
                                settingProvider.notifier,
                              );
                              final TextEditingController urlController =
                                  TextEditingController(text: tmpUrl);
                              double tmpBlur = settings.blurLevel;

                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  final settings = ref.watch(
                                    settingProvider,
                                  ); // 상태 최신화
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '배경사진 설정',
                                              style: TextStyle(
                                                color: Colors.black87,
                                              ),
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
                                                  physics:
                                                      BouncingScrollPhysics(),
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
                                                          notifier
                                                              .setBackgroundType(
                                                                BackgroundType
                                                                    .local,
                                                              );
                                                          notifier
                                                              .setBackgroundImageUrl(
                                                                path,
                                                              );
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                                  image:
                                                                      AssetImage(
                                                                        path,
                                                                      ),
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
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
                                                                              BackgroundType.local
                                                                      ? Colors
                                                                          .orangeAccent
                                                                      : Colors
                                                                          .grey,
                                                              width:
                                                                  settings.bgImageUrl ==
                                                                              path &&
                                                                          settings.bgType ==
                                                                              BackgroundType.local
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
                                              style: TextStyle(
                                                color: Colors.black87,
                                              ),
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
                                                scrollDirection:
                                                    Axis.horizontal,
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
                                                            setModalState(
                                                              () {},
                                                            );
                                                            notifier
                                                                .setBackgroundType(
                                                                  BackgroundType
                                                                      .local,
                                                                );
                                                            notifier
                                                                .setBackgroundImageUrl(
                                                                  path,
                                                                );
                                                          },
                                                          child: Container(
                                                            width: 160,
                                                            height: 100,
                                                            margin:
                                                                EdgeInsets.only(
                                                                  right: 12,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                image:
                                                                    AssetImage(
                                                                      path,
                                                                    ),
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
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
                                                                                BackgroundType.local
                                                                        ? Colors
                                                                            .orangeAccent
                                                                        : Colors
                                                                            .grey,
                                                                width:
                                                                    settings.bgImageUrl ==
                                                                                path &&
                                                                            settings.bgType ==
                                                                                BackgroundType.local
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                                  () =>
                                                                      tmpColor =
                                                                          c,
                                                                );
                                                                notifier.setBackgroundType(
                                                                  BackgroundType
                                                                      .color,
                                                                );
                                                                notifier
                                                                    .setBackgroundColor(
                                                                      c,
                                                                    );
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets.all(
                                                                      4,
                                                                    ),
                                                                width: 30,
                                                                height: 30,
                                                                decoration: BoxDecoration(
                                                                  color: c,
                                                                  border:
                                                                      tmpColor ==
                                                                              c
                                                                          ? Border.all(
                                                                            width:
                                                                                2,
                                                                            color:
                                                                                Colors.amber,
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('흐림 단계'),
                                                      Container(
                                                        width: double.infinity,
                                                        child: Slider(
                                                          activeColor:
                                                              Colors.black,
                                                          inactiveColor:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                          value: tmpBlur,
                                                          min: 0,
                                                          max: 20,
                                                          divisions: 4,
                                                          label: tmpBlur
                                                              .toStringAsFixed(
                                                                0,
                                                              ),
                                                          onChanged: (val) {
                                                            setModalState(() {
                                                              tmpBlur = val;
                                                            });
                                                            notifier
                                                                .setBlurLevel(
                                                                  val,
                                                                );
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 8,
                          ),
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
                  ],
                ),
              ),
            ),
            Positioned(
              left: 30,
              bottom: 30,
              child: GestureDetector(
                onTap: () => setState(() => _hideAllWidgets = !_hideAllWidgets),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: settings.textColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _hideAllWidgets ? '모두 보기' : '모두 가리기',
                    style: TextStyle(color: settings.textColor),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !_hideAllWidgets,
              child: Positioned(
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
            ),
          ],
        ),
      ),
    );
  }
}

class CombinedAudioWidget extends ConsumerWidget {
  final bool visible;
  const CombinedAudioWidget({Key? key, required this.visible})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingProvider);
    if (!visible) return SizedBox.shrink();

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: settings.textColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: settings.textColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: settings.textColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 사운드 위젯
                SoundWidget(visible: true),
                SizedBox(height: 8),
                // 뮤직 위젯
                MusicWidget(visible: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
