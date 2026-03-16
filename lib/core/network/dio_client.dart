import 'package:dio/dio.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        // Base URL ของ Google Generative Language API (v1beta)
        // ไม่ใส่ '/' ท้าย แล้วให้ endpoint เริ่มด้วย '/' เพื่อให้ join ได้ถูกต้อง
        baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        // ให้ Dio ไม่โยน exception อัตโนมัติเมื่อ status != 200
        validateStatus: (_) => true,
      ),
    );

    // เพิ่ม Interceptor ตามที่โจทย์บังคับ (พิมพ์ Log และแทรก API Key อย่างปลอดภัย)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // ไม่ใส่ API key อัตโนมัติที่นี่แล้ว (ควบคุมใน datasource)
        print('🌐 [DIO] ส่งข้อมูล: ${options.method} ${options.uri}');
        print('🌐 [DIO] Headers: ${options.headers}');
        print('🌐 [DIO] ข้อมูล (body): ${options.data}');
        return handler.next(options); // ส่งคำขอต่อไป
      },
      onResponse: (response, handler) {
        print('✅ [DIO] สำเร็จ: ${response.statusCode}');
        print('✅ [DIO] Response headers: ${response.headers}');
        print('✅ [DIO] Response body: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        final status = e.response?.statusCode;
        final body = e.response?.data;
        print('❌ [DIO] เกิดข้อผิดพลาด: ${e.message} (status=$status, body=$body)');
        return handler.next(e);
      },
    ));
  }
}