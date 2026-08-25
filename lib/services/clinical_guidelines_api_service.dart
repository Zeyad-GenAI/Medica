import 'dart:convert';

import 'package:http/http.dart' as http;

class ClinicalGuidelinesApi {
  ClinicalGuidelinesApi({http.Client? client}) : _client = client ?? http.Client();

  ClinicalGuidelinesApi._internal() : _client = http.Client();

  static final ClinicalGuidelinesApi instance =
  ClinicalGuidelinesApi._internal();

  static const String defaultBaseUrl =
      'https://enduring-unapperceived-sharlene.ngrok-free.dev';

  final http.Client _client;
  String? _token;
  String? _sessionId;
  ApiUser? _currentUser;

  String get baseUrl => const String.fromEnvironment(
    'CLINICAL_API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );

  String? get token => _token;
  String? get sessionId => _sessionId;
  ApiUser? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<ApiUser> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/auth/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'username': username.trim(),
        'password': password,
      }),
    );

    final data = _decodeObject(response);
    _throwIfNotSuccessful(response, data);

    final loginResponse = ApiLoginResponse.fromJson(data);
    _token = loginResponse.token;
    _currentUser = ApiUser(
      username: loginResponse.username,
      name: loginResponse.name,
      role: loginResponse.role,
    );

    // This ID is sent in every /chat request and keeps this conversation
    // separate from other devices or users.
    _sessionId = 'mobile_${loginResponse.username}_${DateTime.now().millisecondsSinceEpoch}';

    return _currentUser!;
  }

  Future<ApiUser> signup({
    required String username,
    required String password,
    required String name,
    String role = 'patient',
  }) async {
    final response = await _client.post(
      _uri('/auth/signup'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'username': username.trim(),
        'password': password,
        'name': name.trim(),
        'role': role,
      }),
    );

    final data = _decodeObject(response);
    _throwIfNotSuccessful(response, data);

    final loginResponse = ApiLoginResponse.fromJson(data);
    _token = loginResponse.token;
    _currentUser = ApiUser(
      username: loginResponse.username,
      name: loginResponse.name,
      role: loginResponse.role,
    );
    _sessionId = 'mobile_${loginResponse.username}_${DateTime.now().millisecondsSinceEpoch}';

    return _currentUser!;
  }

  Future<ChatResult> sendMessage(String message) async {
    if (!isAuthenticated) {
      throw const ApiException(
        'You must log in to the Clinical Guidelines API first.',
      );
    }

    final currentSessionId = _sessionId;
    if (currentSessionId == null || currentSessionId.isEmpty) {
      throw const ApiException('Chat session is not initialized.');
    }

    final response = await _client.post(
      _uri('/chat'),
      headers: _jsonHeaders(authenticated: true),
      body: jsonEncode({
        'session_id': currentSessionId,
        'message': message.trim(),
      }),
    );

    final data = _decodeObject(response);
    _throwIfNotSuccessful(response, data);

    return ChatResult.fromJson(data);
  }

  Future<List<ApiChatMessage>> loadHistory() async {
    if (!isAuthenticated) {
      throw const ApiException(
        'You must log in to load chat history.',
      );
    }

    final currentSessionId = _sessionId;
    if (currentSessionId == null || currentSessionId.isEmpty) {
      return <ApiChatMessage>[];
    }

    final response = await _client.get(
      _uri('/chat/sessions/$currentSessionId/history'),
      headers: _jsonHeaders(authenticated: true),
    );

    final data = _decodeObject(response);
    _throwIfNotSuccessful(response, data);

    final messages = data['messages'];
    if (messages is! List) return <ApiChatMessage>[];

    return messages
        .whereType<Map<String, dynamic>>()
        .map(ApiChatMessage.fromJson)
        .toList();
  }

  Future<void> logout() async {
    if (isAuthenticated) {
      try {
        await _client.post(
          _uri('/auth/logout'),
          headers: _jsonHeaders(authenticated: true),
        );
      } finally {
        clearLocalSession();
      }
    } else {
      clearLocalSession();
    }
  }

  void clearLocalSession() {
    _token = null;
    _sessionId = null;
    _currentUser = null;
  }

  void dispose() {
    _client.close();
  }

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalizedBase$path');
  }

  Map<String, String> _jsonHeaders({bool authenticated = false}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': '1',
      if (authenticated && _token != null)
        'Authorization': 'Bearer $_token',
    };
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.body.trim().isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{'data': decoded};
    } catch (_) {
      return <String, dynamic>{'raw': response.body};
    }
  }

  void _throwIfNotSuccessful(
      http.Response response,
      Map<String, dynamic> data,
      ) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    throw ApiException(
      _extractErrorMessage(data, response.statusCode),
      statusCode: response.statusCode,
    );
  }

  String _extractErrorMessage(Map<String, dynamic> data, int statusCode) {
    final detail = data['detail'];
    if (detail is String && detail.isNotEmpty) return detail;

    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] != null) {
        return first['msg'].toString();
      }
      return detail.join(', ');
    }

    if (data['message'] is String) return data['message'] as String;
    if (data['raw'] is String) return data['raw'] as String;

    return 'API request failed with status $statusCode.';
  }
}

class ApiLoginResponse {
  final String token;
  final String username;
  final String role;
  final String name;

  const ApiLoginResponse({
    required this.token,
    required this.username,
    required this.role,
    required this.name,
  });

  factory ApiLoginResponse.fromJson(Map<String, dynamic> json) {
    return ApiLoginResponse(
      token: json['token']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? 'patient',
      name: json['name']?.toString() ?? '',
    );
  }
}

class ApiUser {
  final String username;
  final String name;
  final String role;

  const ApiUser({
    required this.username,
    required this.name,
    required this.role,
  });
}

class ChatResult {
  final String sessionId;
  final String answer;
  final List<ApiSource> sources;

  const ChatResult({
    required this.sessionId,
    required this.answer,
    required this.sources,
  });

  factory ChatResult.fromJson(Map<String, dynamic> json) {
    final rawSources = json['sources'];

    return ChatResult(
      sessionId: json['session_id']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      sources: rawSources is List
          ? rawSources
          .whereType<Map<String, dynamic>>()
          .map(ApiSource.fromJson)
          .toList()
          : <ApiSource>[],
    );
  }
}

class ApiSource {
  final String source;
  final int? page;
  final String? type;

  const ApiSource({
    required this.source,
    required this.page,
    required this.type,
  });

  factory ApiSource.fromJson(Map<String, dynamic> json) {
    return ApiSource(
      source: json['source']?.toString() ?? 'Clinical guideline',
      page: json['page'] is int
          ? json['page'] as int
          : int.tryParse(json['page']?.toString() ?? ''),
      type: json['type']?.toString(),
    );
  }
}

class ApiChatMessage {
  final String role;
  final String content;

  const ApiChatMessage({
    required this.role,
    required this.content,
  });

  factory ApiChatMessage.fromJson(Map<String, dynamic> json) {
    return ApiChatMessage(
      role: json['role']?.toString() ?? 'assistant',
      content: json['content']?.toString() ?? '',
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
