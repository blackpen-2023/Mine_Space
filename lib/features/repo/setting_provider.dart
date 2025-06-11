import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BackgroundType { image, color }

class SettingState {
  final BackgroundType bgType;
  final String bgImageUrl;
  final Color bgColor;
  final Color textColor;

  const SettingState({
    this.bgType = BackgroundType.image,
    this.bgImageUrl =
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1920&q=80',
    this.bgColor = Colors.black,
    this.textColor = Colors.white,
  });

  SettingState copyWith({
    BackgroundType? bgType,
    String? bgImageUrl,
    Color? bgColor,
    Color? textColor,
  }) {
    return SettingState(
      bgType: bgType ?? this.bgType,
      bgImageUrl: bgImageUrl ?? this.bgImageUrl,
      bgColor: bgColor ?? this.bgColor,
      textColor: textColor ?? this.textColor,
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
}

final settingProvider = StateNotifierProvider<SettingNotifier, SettingState>((
  ref,
) {
  return SettingNotifier();
});
