import 'dart:io';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:permission_handler/permission_handler.dart';

part 'speech_service.g.dart';

@riverpod
class SpeechService extends _$SpeechService {
  bool _isRecording = false;
  bool _hasPermission = false;
  String? _recognizedText;

  @override
  bool build() => _hasPermission;

  /// 检查录音权限
  Future<bool> checkPermission() async {
    final status = await Permission.microphone.request();
    _hasPermission = status.isGranted;
    return _hasPermission;
  }

  /// 开始录音
  Future<void> startRecording() async {
    if (!_hasPermission) {
      final granted = await checkPermission();
      if (!granted) {
        throw Exception('录音权限被拒绝');
      }
    }

    _isRecording = true;
    state = true;
  }

  /// 停止录音
  Future<String> stopRecording() async {
    if (!_isRecording) {
      throw Exception('没有进行录音');
    }

    _isRecording = false;
    state = false;

    // TODO: 调用后端语音识别 API
    // 暂时返回模拟数据
    await Future.delayed(const Duration(seconds: 1));
    
    _recognizedText = '帮我新建一个客户张三';
    return _recognizedText!;
  }

  /// 获取识别的文本
  String? get recognizedText => _recognizedText;

  /// 是否正在录音
  bool get isRecording => _isRecording;
}
