import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BackgroundType { image, color, local }

class SettingState {
  final BackgroundType bgType;
  final String bgImageUrl;
  final Color bgColor;
  final Color textColor;
  final double blurLevel;

  const SettingState({
    this.bgType = BackgroundType.image,
    this.bgImageUrl = 'assets/Image/wallpaper/mountain/mountain_1.jpg',
    this.bgColor = Colors.black,
    this.textColor = Colors.white,
    this.blurLevel = 10.0,
  });

  SettingState copyWith({
    BackgroundType? bgType,
    String? bgImageUrl,
    Color? bgColor,
    Color? textColor,
    double? blurLevel,
  }) {
    return SettingState(
      bgType: bgType ?? this.bgType,
      bgImageUrl: bgImageUrl ?? this.bgImageUrl,
      bgColor: bgColor ?? this.bgColor,
      textColor: textColor ?? this.textColor,
      blurLevel: blurLevel ?? this.blurLevel,
    );
  }
}

class SettingNotifier extends StateNotifier<SettingState> {
  SettingNotifier() : super(const SettingState());

  void setBackgroundType(BackgroundType type) {
    state = state.copyWith(bgType: type);
  }

  void setBackgroundImageUrl(String url) {
    state = state.copyWith(bgImageUrl: url);
  }

  void setBackgroundColor(Color color) {
    state = state.copyWith(bgColor: color);
  }

  void setTextColor(Color color) {
    state = state.copyWith(textColor: color);
  }

  void setBlurLevel(double level) {
    state = state.copyWith(blurLevel: level);
  }
}

final settingProvider = StateNotifierProvider<SettingNotifier, SettingState>((
  ref,
) {
  return SettingNotifier();
});
