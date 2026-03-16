import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/network/dio_client.dart';

class AIRemoteDataSource {
  final DioClient dioClient;

  AIRemoteDataSource({required this.dioClient});

  Future<String> summarizeText(String text) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('ไม่พบ API Key ในไฟล์ .env');
      }

      // เรียกใช้งาน Generative Language API (รุ่น v1beta2) โดยใช้โมเดล Gemini
      // โดย URL จะถูกประกอบจาก baseUrl ใน DioClient + endpoint ที่นี่
      // เรียกใช้งาน Generative Language API v1beta (Gemini) โดยใช้โมเดลที่มีให้สำหรับคีย์นี้
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';
      final response = await dioClient.dio.post(
        url,
        data: {
          "contents": [
            {
              "parts": [
                {
                  "text": "ช่วยสรุปข้อความต่อไปนี้ให้เข้าใจง่าย สั้นกระชับ เป็นภาษาไทย:\n\n$text"
                }
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final summary = data['candidates'][0]['content']['parts'][0]['text'];
        return summary;
      } else {
        final status = response.statusCode;
        final body = response.data;
        final uri = response.requestOptions.uri;
        final method = response.requestOptions.method;
        final requestData = response.requestOptions.data;
        throw Exception(
          'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: $status, uri=$uri, method=$method, request=$requestData, body=$body'
        );
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final uri = e.requestOptions.uri;
      final method = e.requestOptions.method;
      final data = e.requestOptions.data;
      throw Exception(
        'ไม่สามารถเชื่อมต่อ AI ได้: ${e.message} (status=$status, uri=$uri, method=$method, data=$data, body=$body)'
      );
    } catch (e) {
      throw Exception('ไม่สามารถเชื่อมต่อ AI ได้: $e');
    }
  }
}