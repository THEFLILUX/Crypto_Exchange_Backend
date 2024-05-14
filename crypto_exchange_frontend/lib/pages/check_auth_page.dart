import 'package:crypto_exchange_frontend/pages/pages.dart';
import 'package:crypto_exchange_frontend/services/services.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class CheckAuthPage extends StatelessWidget {
  const CheckAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Center(
      child: FutureBuilder(
        future: authService.readPrivateKey(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          }

          if (snapshot.data == '') {
            Future.microtask(() {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder<dynamic>(
                  pageBuilder: (_, __, ___) => const LoginPage(),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            });
            // Future.microtask(() {
            //   Navigator.pushReplacement(context, PageRouteBuilder(
            //     pageBuilder: (_, __, ___) => const HomePage(),
            //     transitionDuration: const Duration(seconds: 0),
            //   ));
            // });
          } else {
            Future.microtask(() {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder<dynamic>(
                  pageBuilder: (_, __, ___) => const HomePage(),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            });
          }

          return Container();
        },
      ),
    );
  }
}
