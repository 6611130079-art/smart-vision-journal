import 'package:dartz/dartz.dart';
import '../entities/journal_entry.dart'; // <-- เพิ่มบรรทัดนี้เพื่อรู้จัก JournalEntry

abstract class JournalRepository {
  Future<Either<Exception, String>> scanTextFromImage(bool fromCamera);
  Future<Either<Exception, String>> summarizeText(String text);
  
  // --- เพิ่ม 2 บรรทัดนี้สำหรับจัดการฐานข้อมูลออฟไลน์ ---
  Future<Either<Exception, void>> saveJournalEntry(JournalEntry entry);
  Future<Either<Exception, List<JournalEntry>>> getSavedJournals();
}