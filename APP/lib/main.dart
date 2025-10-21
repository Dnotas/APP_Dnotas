import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'services/boleto_notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar apenas Supabase (rápido)
  await SupabaseService.initialize();
  
  runApp(const DNotasApp());
}

class DNotasApp extends StatelessWidget {
  const DNotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'DNOTAS',
            theme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            home: FutureBuilder(
              future: _initializeApp(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Colors.black,
                    body: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                }
                
                return Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isLoading) {
                      return const Scaffold(
                        backgroundColor: Colors.black,
                        body: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      );
                    }
                    
                    return authProvider.isAuthenticated 
                        ? const HomeScreen() 
                        : const LoginScreen();
                  },
                );
              },
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}

Future<void> _initializeApp() async {
  try {
    // Inicializar notificações em background (não bloqueia UI)
    await Future.wait([
      NotificationService.initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('Timeout na inicialização de notificações - continuando sem elas');
        },
      ),
      BoletoNotificationService.initialize().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print('Timeout na inicialização de notificações de boletos - continuando sem elas');
        },
      ),
    ]);
  } catch (e) {
    print('Erro na inicialização: $e');
  }
}

