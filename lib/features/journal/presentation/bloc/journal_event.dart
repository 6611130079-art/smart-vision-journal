import 'package:equatable/equatable.dart';

abstract class JournalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event สำหรับกดปุ่มสแกนรูปภาพ
class ScanImageEvent extends JournalEvent {
  final bool fromCamera;
  ScanImageEvent({required this.fromCamera});

  @override
  List<Object?> get props => [fromCamera];
}

// Event สำหรับกดปุ่มให้ AI สรุป
class SummarizeTextEvent extends JournalEvent {
  final String text;
  SummarizeTextEvent({required this.text});

  @override
  List<Object?> get props => [text];
}

// Event สำหรับกดปุ่มบันทึกลง SQLite
class SaveJournalEvent extends JournalEvent {}
