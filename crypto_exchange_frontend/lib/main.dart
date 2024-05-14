import 'dart:io';

import 'package:crypto_exchange_frontend/pages/pages.dart';
import 'package:crypto_exchange_frontend/pages/verification_register.dart';
import 'package:crypto_exchange_frontend/preferences/aes_encrypt.dart';
import 'package:crypto_exchange_frontend/preferences/preferences.dart';
import 'package:crypto_exchange_frontend/providers/providers.dart';
import 'package:crypto_exchange_frontend/services/services.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  AESEncrypt.init();

  if (!kIsWeb) {
    // Modificación de mínimo tamaño de ventana para desktop
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      setWindowTitle('Crypto Exchange');
      setWindowMinSize(const Size(1920, 1080));
    }
  }

  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginFormProvider()),
        ChangeNotifierProvider(create: (_) => RegisterFormProvider()),
        ChangeNotifierProvider(create: (_) => TransactionFormProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(isDarkMode: Preferences.isDarkMode),
        ),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BlockService()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Exchange',
      initialRoute: '/check_auth',
      routes: {
        '/check_auth': (_) => const CheckAuthPage(),
        '/login': (_) => const LoginPage(),
        '/verification_login': (_) => const VerificationLoginPage(),
        '/register': (_) => const RegisterPage(),
        '/verification_register': (_) => const VerificationRegisterPage(),
        '/home': (_) => const HomePage(),
      },
      theme: Provider.of<ThemeProvider>(context).currentTheme,
    );
  }
}
