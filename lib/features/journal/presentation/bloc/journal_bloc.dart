import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final JournalRepository repository;

  JournalBloc({required this.repository}) : super(JournalInitial()) {
    on<ScanImageEvent>(_onScanImage);
    on<SummarizeTextEvent>(_onSummarizeText);
    on<SaveJournalEvent>(_onSaveJournal);
  }

  // ฟังก์ชันจัดการตอนผู้ใช้กดสแกนรูป
  Future<void> _onScanImage(ScanImageEvent event, Emitter<JournalState> emit) async {
    emit(JournalLoading()); // บอก UI ให้แสดงที่หมุนๆ โหลดดิ้ง
    
    // เรียกใช้ Repository ที่เราเขียนไว้ (ฝั่งซ้าย=Error, ฝั่งขวา=Success)
    final result = await repository.scanTextFromImage(event.fromCamera);
    
    result.fold(
      (error) => emit(JournalError(error.toString())), // ถ้าพัง ส่ง State Error ไปบอก UI
      (text) => emit(JournalTextScanned(text, saved: false)),        // ถ้าสำเร็จ ส่งข้อความที่สแกนได้ไปโชว์
    );
  }

  // ฟังก์ชันจัดการตอนผู้ใช้กดสรุปข้อความ
  Future<void> _onSummarizeText(SummarizeTextEvent event, Emitter<JournalState> emit) async {
    emit(JournalLoading());
    final result = await repository.summarizeText(event.text);
    result.fold(
      (error) => emit(JournalError(error.toString())),
      (summary) => emit(JournalTextSummarized(originalText: event.text, summary: summary)),
    );
  }

  Future<void> _onSaveJournal(SaveJournalEvent event, Emitter<JournalState> emit) async {
    late JournalEntry entry;

    if (state is JournalTextScanned) {
      final current = state as JournalTextScanned;
      entry = JournalEntry(
        text: current.scannedText,
        summary: current.scannedText, // ใช้ข้อความต้นฉบับเป็นสรุปชั่วคราว
        createdAt: DateTime.now(),
      );
    } else if (state is JournalTextSummarized) {
      final current = state as JournalTextSummarized;
      entry = JournalEntry(
        text: current.originalText,
        summary: current.summary,
        createdAt: DateTime.now(),
      );
    } else {
      return; // ถ้า state ไม่ใช่ scanned หรือ summarized ไม่ทำอะไร
    }

    emit(JournalLoading());

    final result = await repository.saveJournalEntry(entry);
    result.fold(
      (error) => emit(JournalError(error.toString())),
      (_) {
        // บันทึกสำเร็จ emit state ใหม่ด้วย saved = true
        if (state is JournalTextScanned) {
          final current = state as JournalTextScanned;
          emit(JournalTextScanned(current.scannedText, saved: true));
        } else if (state is JournalTextSummarized) {
          final current = state as JournalTextSummarized;
          emit(JournalTextSummarized(originalText: current.originalText, summary: current.summary, saved: true));
        }
      },
    );
  }
}
