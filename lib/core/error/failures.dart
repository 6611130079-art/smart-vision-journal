import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

// สำหรับ Error จากฐานข้อมูล Local 
class DatabaseFailure extends Failure {}

// สำหรับ Error จากการเรียก API (เช่น Gemini) [cite: 50]
class ServerFailure extends Failure {}

// สำหรับกรณีไม่มีอินเทอร์เน็ต (Offline-first) [cite: 42]
class ConnectionFailure extends Failure {}