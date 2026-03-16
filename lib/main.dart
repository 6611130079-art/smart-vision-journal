import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection.dart';
import 'features/journal/presentation/pages/journal_page.dart';
import 'features/journal/presentation/bloc/theme_bloc.dart';
import 'features/journal/presentation/bloc/theme_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initDI(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Smart Vision Journal',
            theme: themeState.themeData,
            home: const JournalPage(), 
          );
        },
      ),
    );
  }
}