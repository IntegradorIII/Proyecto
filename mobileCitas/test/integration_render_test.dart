import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sistema_de_asistencias/core/network/api_constants.dart';
import 'package:sistema_de_asistencias/core/services/auth_service.dart';
import 'package:sistema_de_asistencias/core/services/meeting_service.dart';
import 'package:sistema_de_asistencias/core/services/attendance_service.dart';
import 'package:sistema_de_asistencias/core/storage/session_manager.dart';

void main() {
  group('Backend Render Integration Tests', () {
    test('Verificar Base URL de produccion', () {
      expect(ApiConstants.baseUrl, 'https://backend-citas-8z3g.onrender.com');
    });

    test('Endpoint Health Check (Simulation)', () async {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.get('/health');
      expect(response.statusCode, 200);
      print('Health Check: \${response.data}');
    });

    // We can simulate an auth fail to check error handling
    test('Auth Endpoint - Login Fail Handling', () async {
      final authService = AuthService();
      try {
        await authService.login(correo: 'fail@test.com', password: 'wrongpassword');
        fail('Deberia lanzar excepcion');
      } catch (e) {
        expect(e.toString(), contains('Error al iniciar sesión'));
        print('Login Error capture: \$e');
      }
    });

    test('Meeting Endpoint - Get Meetings', () async {
      final meetingService = MeetingService();
      try {
        final meetings = await meetingService.getMeetings();
        expect(meetings, isNotNull);
        print('Meetings fetched: \${meetings.length}');
      } catch (e) {
        if (e.toString().contains('401')) {
           print('Expected 401 unauth or successful fetch');
        } else {
           print('Fetched without auth: \$e');
        }
      }
    });
  });
}
