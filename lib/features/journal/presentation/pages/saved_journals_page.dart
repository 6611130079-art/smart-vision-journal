import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../../../core/di/injection.dart';

class SavedJournalsPage extends StatelessWidget {
  const SavedJournalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = sl<JournalRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.book, color: Colors.white),
            const SizedBox(width: 8),
            const Text('บันทึกทั้งหมด'),
          ],
        ),
      ),
      body: FutureBuilder(
        future: repository.getSavedJournals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('ไม่มีข้อมูลบันทึก'));
          }

          final Either<Exception, List<JournalEntry>> result = snapshot.data as Either<Exception, List<JournalEntry>>;

          return result.fold(
            (error) => Center(child: Text('ดึงข้อมูลไม่สำเร็จ: ${error.toString()}')),
            (entries) {
              if (entries.isEmpty) {
                return const Center(child: Text('ยังไม่มีบันทึก'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final time = entry.createdAt.toLocal().toString().split('.').first;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            time,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.summary,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(entry.text),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
