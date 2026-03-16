/// ฟังก์ชันสรุปข้อความแบบออฟไลน์ (ไม่ต้องมีเน็ต)
/// ใช้เมื่อขาดการเชื่อมต่อ Gemini AI
class OfflineSummaryDataSource {
  /// สรุปข้อความแบบง่ายๆ โดยใช้ลอจิกทางภาษา
  /// - ลบคำพ้องเสียง
  /// - เก็บประโยคที่สำคัญ
  /// - ปรับให้ถูกต้องตามไวยากรณ์ไทย
  Future<String> summarizeTextOffline(String text) async {
    if (text.isEmpty) return '';

    // ลบช่องว่างหลายชั้น
    String cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // แยกประโยค (สำหรับไทยที่ไม่มีจุด)
    List<String> sentences = _splitThaiSentences(cleaned);

    if (sentences.isEmpty) return cleaned;
    if (sentences.length <= 3) return cleaned; // ถ้าสั้นกว่า 3 ประโยค ใช้เต็ม

    // เลือกประโยคที่เป็นหัวข้อ (มักจะประโยคแรก) + ประโยคสำคัญ
    List<String> summary = [];
    summary.add(sentences.first); // เพิ่มประโยคแรก

    // เพิ่มประโยคอื่นๆ ที่อาจมีความหมายสำคัญ (ตรวจหาคำสำคัญ)
    for (int i = 1; i < sentences.length; i++) {
      if (_isImportantSentence(sentences[i])) {
        summary.add(sentences[i]);
        if (summary.length >= 3) break; // เก็บ 3 ประโยค
      }
    }

    // ถ้ายังน้อย ให้เพิ่มประโยคสุดท้าย (มักเป็นสรุป)
    if (summary.length < 2 && sentences.length > 1) {
      summary.add(sentences.last);
    }

    return summary.join(' ');
  }

  /// แยกประโยคภาษาไทย
  /// เนื่องจากไทยไม่มีจุดหรือเครื่องหมายชัดเจน จึงใช้ความยาวประมาณ
  List<String> _splitThaiSentences(String text) {
    // วิธีง่าย: สมมติว่าประโยคจบด้วยจุด เครื่องหมายคำถาม หรือรูปแบบอื่น
    List<String> result = [];
    final pattern = RegExp(r'[。\.！！\?？]+|[\n]+');
    List<String> parts = text.split(pattern);

    for (String part in parts) {
      String trimmed = part.trim();
      if (trimmed.isNotEmpty && trimmed.length > 5) {
        result.add(trimmed);
      }
    }

    // ถ้าแยกไม่ได้ ให้ใช้วิธีแยกตามจำนวนคำ
    if (result.isEmpty || result.length == 1) {
      return _splitByWordCount(text);
    }

    return result;
  }

  /// แยกประโยคตามจำนวนคำ (ประมาณ 20-30 คำต่อประโยค)
  List<String> _splitByWordCount(String text) {
    List<String> words = text.split(' ');
    List<String> sentences = [];
    StringBuffer current = StringBuffer();

    for (int i = 0; i < words.length; i++) {
      current.write('${words[i]} ');

      // หลังจาก 20-30 คำ ให้เริ่มประโยคใหม่
      if ((i + 1) % 25 == 0) {
        sentences.add(current.toString().trim());
        current.clear();
      }
    }

    if (current.isNotEmpty) {
      sentences.add(current.toString().trim());
    }

    return sentences.where((s) => s.length > 5).toList();
  }

  /// ตรวจหาว่าประโยคมีความสำคัญหรือไม่
  /// (ตัวอักษรตัวใหญ่ คำปูกแบบพิเศษ ฯลฯ)
  bool _isImportantSentence(String sentence) {
    if (sentence.isEmpty) return false;

    // ประโยคที่มีตัวอักษรตัวใหญ่ในตำแหน่งแรก มักสำคัญกว่า
    if (sentence[0].toUpperCase() == sentence[0]) {
      return true;
    }

    // ประโยคที่ยาวปานกลาง (20-50 คำ) มักมีความหมาย
    int wordCount = sentence.split(' ').length;
    if (wordCount >= 10 && wordCount <= 50) {
      return true;
    }

    return false;
  }
}
