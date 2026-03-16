import 'package:equatable/equatable.dart';

abstract class JournalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class JournalInitial extends JournalState {} // สถานะเริ่มต้น
class JournalLoading extends JournalState {} // สถานะกำลังโหลด (หมุนๆ)

class JournalTextScanned extends JournalState { // สแกนข้อความสำเร็จ
  final String scannedText;
  JournalTextScanned(this.scannedText);

  @override
  List<Object?> get props => [scannedText];
}

class JournalTextSummarized extends JournalState { // สรุปข้อความสำเร็จ
  final String originalText; // ข้อความต้นฉบับที่สแกนได้
  final String summary;
  final bool saved; // บันทึกลง SQLite แล้วหรือยัง

  JournalTextSummarized({
    required this.originalText,
    required this.summary,
    this.saved = false,
  });

  @override
  List<Object?> get props => [originalText, summary, saved];
}

class JournalError extends JournalState { // เกิดข้อผิดพลาด
  final String message;
  JournalError(this.message);

  @override
  List<Object?> get props => [message];
}