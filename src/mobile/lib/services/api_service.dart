import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiService {
  final Dio _dio;
  final Logger _logger = Logger();

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  )) {
    // 添加拦截器记录请求
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.i('API 请求: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i('API 响应: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('API 错误: $error');
        return handler.next(error);
      },
    ));
  }

  /// 语音识别
  Future<Map<String, dynamic>> recognizeSpeech({
    required String audioData,
    String format = 'wav',
    int sampleRate = 16000,
  }) async {
    try {
      final response = await _dio.post(
        '/speech/recognize',
        data: {
          'audioData': audioData,
          'format': format,
          'sampleRate': sampleRate,
        },
      );

      return response.data['data'];
    } catch (e) {
      _logger.e('语音识别失败: $e');
      rethrow;
    }
  }

  /// 意图识别
  Future<Map<String, dynamic>> recognizeIntent({
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        '/intent/recognize',
        data: {'text': text},
      );

      return response.data['data'];
    } catch (e) {
      _logger.e('意图识别失败: $e');
      rethrow;
    }
  }

  /// 创建客户
  Future<Map<String, dynamic>> createCustomer({
    required String name,
    String? phone,
    String? email,
    String? carModel,
  }) async {
    try {
      final response = await _dio.post(
        '/crm/customer/create',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'carModel': carModel,
        },
      );

      return response.data['data'];
    } catch (e) {
      _logger.e('创建客户失败: $e');
      rethrow;
    }
  }

  /// 添加跟进记录
  Future<Map<String, dynamic>> addFollowup({
    required String customerId,
    required String content,
    String? nextAction,
  }) async {
    try {
      final response = await _dio.post(
        '/crm/followup/add',
        data: {
          'customerId': customerId,
          'content': content,
          'nextAction': nextAction,
        },
      );

      return response.data['data'];
    } catch (e) {
      _logger.e('添加跟进记录失败: $e');
      rethrow;
    }
  }

  /// 获取每日报告
  Future<Map<String, dynamic>> getDailyReport({
    String? date,
    String? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;
      if (userId != null) queryParams['userId'] = userId;

      final response = await _dio.get(
        '/reports/daily',
        queryParameters: queryParams,
      );

      return response.data['data'];
    } catch (e) {
      _logger.e('获取每日报告失败: $e');
      rethrow;
    }
  }
}
