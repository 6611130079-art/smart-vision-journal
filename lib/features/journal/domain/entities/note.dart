import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content; // ข้อความที่ได้จาก Google ML Kit
  final String summary; // ข้อความที่สรุปโดย Gemini LLM
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, content, summary, createdAt];
}