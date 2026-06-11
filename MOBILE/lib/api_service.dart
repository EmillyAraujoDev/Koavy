import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2/koavy/api/public", // 10.0.2.2 é o localhost do host no emulador Android
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('koavy_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 401) {
          // Tratar logout por token expirado aqui
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> login(String email, String senha) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'senha': senha,
      });
      
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('koavy_token', response.data['token']);
        await prefs.setString('koavy_user', response.data['user'].toString());
      }
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> getBatimentos() async {
    return _dio.get('/batimentos');
  }

  Future<Response> registrarBatimento(double bpm, {double? sat}) async {
    return _dio.post('/batimentos', data: {
      'bpm': bpm,
      'saturacao': sat,
    });
  }
}
