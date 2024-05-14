import 'package:crypto_exchange_frontend/pages/pages.dart';
import 'package:crypto_exchange_frontend/preferences/preferences.dart';
import 'package:crypto_exchange_frontend/providers/providers.dart';
import 'package:crypto_exchange_frontend/services/services.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return NavigationView(
      appBar: NavigationAppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: DefaultTextStyle(
            style: FluentTheme.of(context).typography.title!,
            child: const Text('Crypto Exchange'),
          ),
        ),
        leading: Center(
          child: SvgPicture.asset(
            'assets/bitcoin-logo.svg',
            color: themeProvider.currentThemeName == 'light'
                ? Colors.black
                : Colors.white,
            fit: BoxFit.fitHeight,
          ),
        ),
        actions: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                    child: DefaultTextStyle(
                      style: FluentTheme.of(context)
                          .typography
                          .bodyStrong!
                          .copyWith(fontSize: 20),
                      child: const Text('Salir'),
                    ),
                    onPressed: () => _showLogoutOptions(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      pane: NavigationPane(
        header: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: DefaultTextStyle(
            style: FluentTheme.of(context).typography.bodyStrong!,
            child: Text('ID: ${Preferences.userId}'),
          ),
        ),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.all_currency),
            title: const Text('Transacciones'),
            body: const TransactionsPage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.cloud_secure),
            title: const Text('Blockchain'),
            body: const BlockchainPage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.teamwork),
            title: const Text('Mineros'),
            body: const MinersPage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.user_followed),
            title: const Text('Perfil'),
            body: const ProfilePage(),
          ),
        ],
        selected: _currentPage,
        onChanged: (i) {
          setState(() {
            _currentPage = i;
          });
        },
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Ajustes'),
            body: const SettingsPage(),
          ),
        ],
      ),
    );
  }

  void _showLogoutOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que desea cerrar la sesión?'),
        actions: [
          Button(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Sí'),
            onPressed: () async {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              // ignore: use_build_context_synchronously
              await Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
