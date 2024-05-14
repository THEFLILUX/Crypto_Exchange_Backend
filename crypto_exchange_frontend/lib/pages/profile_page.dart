import 'package:crypto_exchange_frontend/preferences/preferences.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPage(
      header: PageHeader(title: Text('Perfil')),
      content: Padding(
        padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
        child: Column(
          children: [
            UserDataBlock(),
            SizedBox(height: 30),
            Expanded(child: PublicPrivateKeyBox()),
          ],
        ),
      ),
    );
  }
}

class PublicPrivateKeyBox extends StatelessWidget {
  const PublicPrivateKeyBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InfoLabel(
            label: 'Llave pública',
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            child: SizedBox(
              height: double.infinity,
              child: Card(
                borderRadius: BorderRadius.circular(10),
                child: SelectableText(
                  Preferences.userPublicKey,
                  selectionControls: fluentTextSelectionControls,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: InfoLabel(
            label: 'Llave privada',
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            child: SizedBox(
              height: double.infinity,
              child: Card(
                borderRadius: BorderRadius.circular(10),
                child: SelectableText(
                  Preferences.userPrivateKey,
                  selectionControls: fluentTextSelectionControls,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UserDataBlock extends StatelessWidget {
  const UserDataBlock({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 100,
          backgroundColor: Colors.green,
          child: DefaultTextStyle(
            style: FluentTheme.of(context)
                .typography
                .title!
                .copyWith(fontSize: 80),
            child: Text(
              Preferences.userFirstName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      UserDataTale(
                        title: 'Nombre',
                        content: Preferences.userFirstName,
                      ),
                      UserDataTale(
                        title: 'Apellido',
                        content: Preferences.userLastName,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      UserDataTale(
                        title: 'País',
                        content: Preferences.userCountry,
                      ),
                      UserDataTale(
                        title: 'Correo',
                        content: Preferences.userEmail,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class UserDataTale extends StatelessWidget {
  const UserDataTale({
    required this.title,
    required this.content,
    super.key,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: title,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          borderRadius: BorderRadius.circular(10),
          child: SelectableText(
            content,
            selectionControls: fluentTextSelectionControls,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
