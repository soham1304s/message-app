import 'package:chatting_app/config/theme/app_theme.dart';
import 'package:chatting_app/data/repositories/chat_repository.dart';
import 'package:chatting_app/data/services/service_locator.dart';
import 'package:chatting_app/firebase_options.dart';
import 'package:chatting_app/logic/cubits/auth/auth_cubit.dart';
import 'package:chatting_app/logic/cubits/auth/auth_state.dart';
import 'package:chatting_app/logic/observer/app_life_cycle_observer.dart';
import 'package:chatting_app/presentation/home/home_screen.dart';
import 'package:chatting_app/presentation/screens/auth/login_screen.dart';
import 'package:chatting_app/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print("Starting Firebase initialization...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed: $e");
    runApp(const FirebaseErrorApp(error: "Firebase initialization failed"));
    return;
  }
  await setupServiceLocator();
  runApp(const MyApp());
}

class FirebaseErrorApp extends StatelessWidget {
  final String error;
  const FirebaseErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Error: $error\nPlease check Firebase configuration."),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifeCycleObserver? _lifeCycleObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLifeCycleObserver();
  }

  void _initializeLifeCycleObserver() {
    final authCubit = getIt<AuthCubit>();
    authCubit.stream.listen((state) {
      if (state.status == AuthStatus.authenticated && state.user != null) {
        _lifeCycleObserver?.dispose();
        _lifeCycleObserver = AppLifeCycleObserver(
          userId: state.user!.uid,
          chatRepository: getIt<ChatRepository>(),
        );
      }
    });
    if (authCubit.state.status == AuthStatus.authenticated &&
        authCubit.state.user != null) {
      _lifeCycleObserver = AppLifeCycleObserver(
        userId: authCubit.state.user!.uid,
        chatRepository: getIt<ChatRepository>(),
      );
    }
  }

  @override
  void dispose() {
    _lifeCycleObserver?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Messenger App',
        navigatorKey: getIt<AppRouter>().navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          bloc: getIt<AuthCubit>(),
          builder: (context, state) {
            if (state.status == AuthStatus.initial || state.status == AuthStatus.loading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == AuthStatus.authenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

extension on AppLifeCycleObserver? {
  void dispose() {}
}