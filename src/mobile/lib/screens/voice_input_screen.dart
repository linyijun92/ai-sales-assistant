import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/speech_service.dart';
import '../services/api_service.dart';

part 'voice_input_screen.g.dart';

@riverpod
class VoiceInputState extends _$VoiceInputState {
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _recognizedText;
  String? _intentText;
  String? _resultMessage;
  bool _isSuccess = false;

  bool get isRecording => _isRecording;
  String? get recognizedText => _recognizedText;
  String? get intentText => _intentText;
  String? get resultMessage => _resultMessage;
  bool get isSuccess => _isSuccess;
  bool get isProcessing => _isProcessing;

  void setRecording(bool value) {
    _isRecording = value;
    state = DateTime.now().millisecondsSinceEpoch;
  }

  void setProcessing(bool value) {
    _isProcessing = value;
    state = DateTime.now().millisecondsSinceEpoch;
  }

  void setRecognizedText(String? value) {
    _recognizedText = value;
    state = DateTime.now().millisecondsSinceEpoch;
  }

  void setIntentText(String? value) {
    _intentText = value;
    state = DateTime.now().millisecondsSinceEpoch;
  }

  void setResultMessage(String? value, {bool success = false}) {
    _resultMessage = value;
    _isSuccess = success;
    state = DateTime.now().millisecondsSinceEpoch;
  }

  void reset() {
    _isRecording = false;
    _isProcessing = false;
    _recognizedText = null;
    _intentText = null;
    _resultMessage = null;
    _isSuccess = false;
    state = DateTime.now().millisecondsSinceEpoch;
  }
}

class VoiceInputScreen extends ConsumerStatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  ConsumerState<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends ConsumerState<VoiceInputScreen> {
  final ApiService _apiService = ApiService();
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final speechService = ref.read(speechServiceProvider.notifier);
    await speechService.checkPermission();
  }

  Future<void> _startRecording() async {
    final speechService = ref.read(speechServiceProvider.notifier);
    
    try {
      await speechService.startRecording();
      ref.read(voiceInputStateProvider.notifier).setRecording(true);
      ref.read(voiceInputStateProvider.notifier).setResultMessage(null);
      _showResult = false;
    } catch (e) {
      _showError('启动录音失败: ${e.toString()}');
    }
  }

  Future<void> _stopRecording() async {
    final speechService = ref.read(speechServiceProvider.notifier);
    
    try {
      final text = await speechService.stopRecording();
      ref.read(voiceInputStateProvider.notifier).setRecording(false);
      ref.read(voiceInputStateProvider.notifier).setRecognizedText(text);
      
      // 识别意图
      await _recognizeIntent(text);
    } catch (e) {
      _showError('语音识别失败: ${e.toString()}');
    }
  }

  Future<void> _recognizeIntent(String text) async {
    ref.read(voiceInputStateProvider.notifier).setProcessing(true);

    try {
      final result = await _apiService.recognizeIntent(text: text);
      
      final intent = result['intent'] as String?;
      final confidence = result['confidence'] as double?;
      final entities = result['entities'] as Map<String, dynamic>?;
      
      ref.read(voiceInputStateProvider.notifier).setIntentText(
        '意图: ${intent ?? "未知"}, 置信度: ${(confidence ?? 0.0 * 100).toStringAsFixed(0)}%',
      );
      
      _showResult = true;
    } catch (e) {
      _showError('意图识别失败: ${e.toString()}');
    } finally {
      ref.read(voiceInputStateProvider.notifier).setProcessing(false);
    }
  }

  void _showError(String message) {
    ref.read(voiceInputStateProvider.notifier).setResultMessage(message, success: false);
    _showResult = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceInputStateProvider);
    final speechService = ref.watch(speechServiceProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mic,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              state.isRecording ? '正在录音...' : '点击麦克风开始',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 48),
            
            // 录音按钮
            ElevatedButton.icon(
              onPressed: state.isRecording ? _stopRecording : _startRecording,
              icon: Icon(state.isRecording ? Icons.stop : Icons.mic),
              label: Text(state.isRecording ? '停止录音' : '开始录音'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                backgroundColor: state.isRecording ? Colors.red : Colors.blue,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 识别结果
            if (state.recognizedText != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '识别结果：',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(state.recognizedText ?? ''),
              ),
            ],
            
            // 意图识别结果
            if (state.intentText != null) ...[
              const SizedBox(height: 16),
              Text(
                '意图识别：',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(state.intentText ?? ''),
              ),
            ],
            
            // 处理中提示
            if (state.isProcessing) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
