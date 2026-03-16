import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry_model.dart';

class JournalLocalDataSource {
  static Database? _database;

  // ฟังก์ชันดึง Database ถ้ายังไม่มีจะสร้างใหม่
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journal.db');
    return _database!;
  }

  // ฟังก์ชันเริ่มต้นสร้างไฟล์ฐานข้อมูล
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB, // ถ้าเปิดแอปครั้งแรก ให้ไปสร้างตาราง
    );
  }

  // ฟังก์ชันสร้างตาราง (Table) ชื่อ 'journals'
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        summary TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // --- 1. ฟังก์ชันบันทึกข้อมูล (Insert) ---
  Future<void> saveJournal(JournalEntryModel entry) async {
    final db = await database;
    await db.insert(
      'journals', 
      entry.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace, // ถ้าข้อมูลชนกันให้เซฟทับ
    );
  }

  // --- 2. ฟังก์ชันดึงข้อมูลทั้งหมด (Query) ---
  Future<List<JournalEntryModel>> getSavedJournals() async {
    final db = await database;
    // ดึงข้อมูลโดยเรียงจากวันที่สร้างล่าสุด (DESC)
    final maps = await db.query('journals', orderBy: 'createdAt DESC');
    
    // แปลงข้อมูลที่ได้จาก SQLite (Map) กลับเป็น Model List
    return maps.map((map) => JournalEntryModel.fromMap(map)).toList();
  }
}