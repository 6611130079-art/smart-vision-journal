import 'package:equatable/equatable.dart';

// นี่คือโครงสร้างข้อมูลหลักที่เราจะใช้ในแอป
class JournalEntry extends Equatable {
  final int? id;
  final String text; // ข้อความต้นฉบับ
  final String summary; // ข้อความที่ AI สรุป
  final DateTime createdAt; // วันที่บันทึก

  const JournalEntry({
    this.id, 
    required this.text, 
    required this.summary, 
    required this.createdAt
  });

  @override
  List<Object?> get props => [id, text, summary, createdAt];
}