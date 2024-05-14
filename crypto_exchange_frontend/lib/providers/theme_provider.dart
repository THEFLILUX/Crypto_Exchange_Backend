import 'package:crypto_exchange_frontend/theme/app_theme.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required bool isDarkMode}) {
    currentTheme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
    currentThemeName = isDarkMode ? 'dark' : 'light';
  }

  late FluentThemeData currentTheme;
  late String currentThemeName;

  void setLightMode() {
    currentTheme = AppTheme.lightTheme;
    currentThemeName = 'light';
    notifyListeners();
  }

  void setDarkMode() {
    currentTheme = AppTheme.darkTheme;
    currentThemeName = 'dark';
    notifyListeners();
  }
}
