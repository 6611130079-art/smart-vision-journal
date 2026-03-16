import 'package:get_it/get_it.dart';
import '../../features/journal/data/datasources/ai_remote_datasource.dart';
import '../../features/journal/data/datasources/ml_vision_datasource.dart';
// --- 1. เพิ่ม Import ไฟล์ Local Data Source ---
import '../../features/journal/data/datasources/journal_local_datasource.dart'; 
import '../../features/journal/data/repositories/journal_repository_impl.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';
import '../network/dio_client.dart';
import '../../features/journal/presentation/bloc/journal_bloc.dart';

// สร้างตัวแปรส่วนกลางสำหรับเรียกใช้ get_it
final sl = GetIt.instance; // sl ย่อมาจาก Service Locator

Future<void> initDI() async {
  // ----------------------------------------------------------------------
  // 1. ลงทะเบียน Core (ระบบพื้นฐาน เช่น Network)
  // ----------------------------------------------------------------------
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ----------------------------------------------------------------------
  // 2. ลงทะเบียน Data Sources (เครื่องมือดึงข้อมูล)
  // ----------------------------------------------------------------------
  sl.registerLazySingleton<AIRemoteDataSource>(
    () => AIRemoteDataSource(dioClient: sl()), // sl() จะไปดึง DioClient มาใส่ให้
  );
  
  sl.registerLazySingleton<MLVisionDataSource>(
    () => MLVisionDataSource(),
  );

  // --- 2. เพิ่มการลงทะเบียน Local Data Source (ฐานข้อมูล) ตรงนี้ ---
  sl.registerLazySingleton<JournalLocalDataSource>(
    () => JournalLocalDataSource(),
  );

  // ----------------------------------------------------------------------
  // 3. ลงทะเบียน Repository (ตัวกลางจัดการข้อมูล)
  // ----------------------------------------------------------------------
  sl.registerLazySingleton<JournalRepository>(
    () => JournalRepositoryImpl(
      aiRemoteDataSource: sl(),
      mlVisionDataSource: sl(),
      localDataSource: sl(), // --- 3. เพิ่มบรรทัดนี้ เพื่อส่ง Database เข้าไปให้ Repository ---
    ),
  );

  // ----------------------------------------------------------------------
  // 4. ลงทะเบียน BLoC (ตัวจัดการ State หน้าจอ)
  // ----------------------------------------------------------------------
  sl.registerFactory(
    () => JournalBloc(repository: sl()),
  );
}