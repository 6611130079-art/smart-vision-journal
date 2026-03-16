import '../../domain/entities/journal_entry.dart';

// Model จะสืบทอดจาก Entity และเพิ่มฟังก์ชันแปลงข้อมูลไป-กลับ สำหรับ SQLite (Map)
class JournalEntryModel extends JournalEntry {
  const JournalEntryModel({
    super.id,
    required super.text,
    required super.summary,
    required super.createdAt,
  });

  // แปลงจากข้อมูลในฐานข้อมูล (Map) มาเป็น Object ในแอป
  factory JournalEntryModel.fromMap(Map<String, dynamic> map) {
    return JournalEntryModel(
      id: map['id'],
      text: map['text'],
      summary: map['summary'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // แปลงจาก Object ในแอป กลับไปเป็น Map เพื่อเซฟลงฐานข้อมูล
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'summary': summary,
      'createdAt': createdAt.toIso8601String(), // วันที่ต้องแปลงเป็น String ก่อนเซฟลง SQLite
    };
  }
}