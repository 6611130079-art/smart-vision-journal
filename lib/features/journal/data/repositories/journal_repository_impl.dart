import 'package:dartz/dartz.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/entities/journal_entry.dart';
import '../models/journal_entry_model.dart';
import '../datasources/ai_remote_datasource.dart';
import '../datasources/ml_vision_datasource.dart';
import '../datasources/journal_local_datasource.dart'; // <-- Import เพิ่ม

class JournalRepositoryImpl implements JournalRepository {
  final AIRemoteDataSource aiRemoteDataSource;
  final MLVisionDataSource mlVisionDataSource;
  final JournalLocalDataSource localDataSource; // <-- เพิ่มตัวแปรสำหรับ Database

  JournalRepositoryImpl({
    required this.aiRemoteDataSource,
    required this.mlVisionDataSource,
    required this.localDataSource, // <-- บังคับรับค่าผ่าน Constructor
  });

  @override
  Future<Either<Exception, String>> scanTextFromImage(bool fromCamera) async {
    try {
      final text = await mlVisionDataSource.scanTextFromImage(fromCamera: fromCamera);
      if (text != null && text.isNotEmpty) {
        return Right(text);
      } else {
        return Left(Exception('ไม่พบข้อความในรูปภาพ หรือยกเลิกการเลือกรูป'));
      }
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, String>> summarizeText(String text) async {
    try {
      final summary = await aiRemoteDataSource.summarizeText(text);
      return Right(summary);
    } catch (e) {
      return Left(Exception('AI สรุปข้อความล้มเหลว: $e'));
    }
  }

  // --- ฟังก์ชันบันทึกข้อมูล (ใหม่) ---
  @override
  Future<Either<Exception, void>> saveJournalEntry(JournalEntry entry) async {
    try {
      // แปลงจาก Entity เป็น Model ก่อนเซฟ
      final model = JournalEntryModel(
        text: entry.text,
        summary: entry.summary,
        createdAt: entry.createdAt,
      );
      await localDataSource.saveJournal(model);
      return const Right(null); // เซฟสำเร็จ คืนค่าว่างกลับไป
    } catch (e) {
      return Left(Exception('ไม่สามารถบันทึกข้อมูลได้: $e'));
    }
  }

  // --- ฟังก์ชันดึงข้อมูลทั้งหมด (ใหม่) ---
  @override
  Future<Either<Exception, List<JournalEntry>>> getSavedJournals() async {
    try {
      final models = await localDataSource.getSavedJournals();
      return Right(models); // คืนค่าข้อมูลที่ดึงมาได้
    } catch (e) {
      return Left(Exception('ไม่สามารถดึงข้อมูลได้: $e'));
    }
  }
}