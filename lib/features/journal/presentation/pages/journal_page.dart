import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import 'saved_journals_page.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ BlocProvider เพื่อสร้างและจัดการ BLoC ในหน้านี้
    return BlocProvider(
      create: (context) => sl<JournalBloc>(),
      child: const JournalView(),
    );
  }
}

class JournalView extends StatelessWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.book, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Smart Vision Journal'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'เปลี่ยนธีม',
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleThemeEvent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'ดูบันทึก',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SavedJournalsPage()),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<JournalBloc, JournalState>(
        listener: (context, state) {
          // ถ้าเกิด Error ให้โชว์แถบแจ้งเตือนด้านล่าง (SnackBar)
          if (state is JournalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }

          // ถ้าบันทึกสำเร็จแล้ว ให้โชว์ SnackBar
          if (state is JournalTextSummarized && state.saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('บันทึกเรียบร้อยแล้ว'), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- ส่วนปุ่มควบคุม ---
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.read<JournalBloc>().add(ScanImageEvent(fromCamera: true)),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('ถ่ายรูป'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.read<JournalBloc>().add(ScanImageEvent(fromCamera: false)),
                          icon: const Icon(Icons.image),
                          label: const Text('เลือกรูป'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- ส่วนแสดงผลโหลดดิ้ง ---
                  if (state is JournalLoading)
                    const Center(child: CircularProgressIndicator()),

                  // --- ส่วนแสดงข้อความที่สแกนได้ ---
                  const Text('ข้อความที่สแกนได้:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      state is JournalTextScanned ? state.scannedText : 
                      state is JournalTextSummarized ? 'สแกนสำเร็จแล้ว (ดูผลสรุปด้านล่าง)' : 'ยังไม่มีข้อมูล',
                      maxLines: 10,
                      
                    ),
                  ),

                  // --- ปุ่มสรุปด้วย AI ---
                  if (state is JournalTextScanned)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      onPressed: () => context.read<JournalBloc>().add(SummarizeTextEvent(text: state.scannedText)),
                      child: const Text('สรุปเนื้อหาด้วย Gemini AI'),
                    ),

                  const SizedBox(height: 20),

                  // --- ส่วนแสดงผลสรุปจาก AI ---
                  if (state is JournalTextSummarized) ...[
                    const Text('สรุปโดย AI:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(state.summary),
                    ),

                    if (!state.saved)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        onPressed: () => context.read<JournalBloc>().add(SaveJournalEvent()),
                        child: const Text('บันทึก'),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}