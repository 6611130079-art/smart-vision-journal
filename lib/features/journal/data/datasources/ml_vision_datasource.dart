import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MLVisionDataSource {
  final ImagePicker _imagePicker = ImagePicker();

  // ฟังก์ชันสำหรับเลือกรูปและดึงข้อความ
  Future<String?> scanTextFromImage({required bool fromCamera}) async {
    try {
      // 1. เลือกรูปจากกล้อง (Camera) หรือ แกลเลอรี (Gallery)
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (image == null) return null; // ถ้าผู้ใช้กดยกเลิก ไม่ได้เลือกรูป ให้ส่งค่าว่างกลับไป

      // 2. แปลงไฟล์รูปภาพให้อยู่ในรูปแบบที่ ML Kit รู้จัก
      final inputImage = InputImage.fromFilePath(image.path);

      // 3. เรียกใช้งาน Text Recognizer (ตัวอ่านข้อความ)
      final textRecognizer = TextRecognizer(); 

      // 4. สั่งให้ประมวลผลอ่านข้อความจากรูป
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // 5. ปิดการทำงานเมื่อเสร็จสิ้นเพื่อคืนพื้นที่หน่วยความจำให้เครื่อง
      await textRecognizer.close();

      // 6. ส่งข้อความที่อ่านได้ทั้งหมดกลับไปให้แอป
      return recognizedText.text;
      
    } catch (e) {
      // ดักจับ Error เผื่อแอปไม่มีสิทธิ์เข้าถึงกล้องหรือเกิดข้อผิดพลาดอื่นๆ
      throw Exception('เกิดข้อผิดพลาดในการสแกนข้อความ: $e');
    }
  }

  // Add this dispose method here for resource cleanup
  void dispose() {
    // No persistent recognizer to close, but can add if needed for other resources

    return null;
    
  }
}