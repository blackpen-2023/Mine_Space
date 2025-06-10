import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mine_space/features/widgets/music_widget.dart';
import 'package:mine_space/features/widgets/sound_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  bool _showSoundWidget = true;
  bool _showMusicWidget = true;
  bool _isMusicHovered = false;
  bool _isSoundHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1920&q=80',
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: Colors.black.withOpacity(0.1), // 살짝 어둡게(선택)
            ),
          ),
          Column(
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
                      style: TextStyle(fontSize: 30, height: 0.8),
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
              Column(
                children: [
                  SizedBox(
                    child: Column(
                      children: [
                        Text(
                          '남은시간',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        Text(
                          '00:00:00',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('일시정지'),
                        SizedBox(width: 30),
                        Text('그만두기'),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('나만의 공간 만들기', style: TextStyle(fontSize: 30)),
                      ],
                    ),

                    Row(children: [Text('BLACKPEN SOFT.')]),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 100,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  MouseRegion(
                    onEnter: (_) => setState(() => _isMusicHovered = true),
                    onExit: (_) => setState(() => _isMusicHovered = false),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showMusicWidget = !_showMusicWidget;
                        });
                      },
                      child: Icon(
                        Icons.music_note,
                        color: _isMusicHovered ? Colors.amber : Colors.white,
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => setState(() => _isSoundHovered = true),
                    onExit: (_) => setState(() => _isSoundHovered = false),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showSoundWidget = !_showSoundWidget;
                        });
                      },
                      child: Icon(
                        Icons.graphic_eq,
                        color: _isSoundHovered ? Colors.amber : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 360,
            child: SoundWidget(visible: _showSoundWidget),
          ),
          Positioned(
            right: 16,
            bottom: 160,
            child: MusicWidget(visible: _showMusicWidget),
          ),
        ],
      ),
    );
  }
}
