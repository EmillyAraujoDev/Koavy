import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    // Em produção, a URL deve apontar para o host do servidor REST.
    // Usamos 10.0.2.2 como padrão para emuladores Android (que mapeia para o localhost da máquina hospedeira).
    baseUrl: "http://8080/koavy/api/public", 
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
          // Token expirado ou inválido: limpa o storage local
          SharedPreferences.getInstance().then((prefs) {
            prefs.remove('koavy_token');
            prefs.remove('koavy_user');
          });
        }
        return handler.next(e);
      },
    ));
  }

  /// Autentica o usuário com e-mail e senha tradicionais na API PHP.
  Future<Response> login(String email, String senha) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'senha': senha,
      });
      
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('koavy_token', response.data['token']);
        // CORREÇÃO: Salva o objeto usuário como string JSON válida
        await prefs.setString('koavy_user', jsonEncode(response.data['user']));
      }
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }

  /// Autentica o usuário via Google Sign-In enviando o idToken (credential) à API PHP.
  Future<Response> googleLogin(String idToken, {String? email, String? name}) async {
    try {
      final response = await _dio.post('/google-login', data: {
        'credential': idToken,
        'email': email,
        'nome': name,
      });
      
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('koavy_token', response.data['token']);
        await prefs.setString('koavy_user', jsonEncode(response.data['user']));
      }
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }

  /// Realiza o encerramento da sessão local.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('koavy_token');
    await prefs.remove('koavy_user');
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

  Future<Response> getRelatorios() async {
    return _dio.get('/relatorios');
  }

  Future<Response> registrarEmergencia(double bpm, double sat, String desc) async {
    return _dio.post('/emergencia', data: {
      'batMomento': bpm,
      'satMomento': sat,
      'tipo': 'CRITICO',
      'descricao': desc,
      'latitude': 0.0,
      'longitude': 0.0,
    });
  }
}
