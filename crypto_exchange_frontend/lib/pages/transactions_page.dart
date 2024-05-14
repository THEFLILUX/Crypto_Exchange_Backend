import 'package:crypto_exchange_frontend/models/models.dart';
import 'package:crypto_exchange_frontend/preferences/preferences.dart';
import 'package:crypto_exchange_frontend/providers/providers.dart';
import 'package:crypto_exchange_frontend/services/services.dart';
import 'package:encrypt/encrypt.dart' as crypto;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<BlockService>(context, listen: false).getUsersAndBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final blockService = Provider.of<BlockService>(context);

    if (blockService.isLoadingUsersAndBalance) {
      return ScaffoldPage(
        header: const PageHeader(title: Text('Transacciones')),
        content: Center(
          child: ProgressRing(activeColor: Colors.green),
        ),
      );
    }

    if (blockService.availableUsers.isEmpty) {
      return const ScaffoldPage(
        header: PageHeader(title: Text('Transacciones')),
        content: Padding(
          padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
          child: Stack(
            children: [
              SizedBox.expand(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AvailableBalance(),
                    SizedBox(height: 10),
                    AvailableUsersTitle(),
                    Expanded(
                      child: Center(
                        child: Text('No hay más usuarios registrados'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ScaffoldPage(
      header: const PageHeader(title: Text('Transacciones')),
      content: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
        child: Stack(
          children: [
            const SizedBox.expand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvailableBalance(),
                  SizedBox(height: 10),
                  AvailableUsersTitle(),
                  Expanded(
                    child: SizedBox.expand(
                      child: AvailableUsersList(),
                    ),
                  ),
                ],
              ),
            ),
            if (Provider.of<TransactionFormProvider>(context).isLoading)
              const Positioned(
                bottom: 0,
                right: 0,
                child: ProcessingTransactionCard(),
              ),
          ],
        ),
      ),
    );
  }
}

class AvailableUsersTitle extends StatelessWidget {
  const AvailableUsersTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: FluentTheme.of(context).typography.subtitle!,
      child: const Text('Usuarios disponibles'),
    );
  }
}

class AvailableBalance extends StatelessWidget {
  const AvailableBalance({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final blockService = Provider.of<BlockService>(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          DefaultTextStyle(
            style: FluentTheme.of(context).typography.subtitle!,
            child: const Text('Saldo disponible'),
          ),
          DefaultTextStyle(
            style: FluentTheme.of(context).typography.display!,
            child: Text(blockService.balance.toStringAsFixed(3)),
          ),
        ],
      ),
    );
  }
}

class AvailableUsersList extends StatelessWidget {
  const AvailableUsersList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final blockService = Provider.of<BlockService>(context);

    return ListView.builder(
      itemCount: blockService.availableUsers.length,
      itemBuilder: (context, index) {
        final title = '${blockService.availableUsers[index].firstName} '
            '${blockService.availableUsers[index].lastName}';
        final subtitle = blockService.availableUsers[index].email;
        return AvailableUserListTile(
          title: title,
          subtitle: subtitle!,
          index: index,
          listLength: blockService.availableUsers.length,
          user: blockService.availableUsers[index],
        );
      },
    );
  }
}

class AvailableUserListTile extends StatelessWidget {
  const AvailableUserListTile({
    required this.title,
    required this.subtitle,
    required this.index,
    required this.listLength,
    required this.user,
    super.key,
  });

  final String title;
  final String subtitle;
  final int index;
  final int listLength;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final blockService = Provider.of<BlockService>(context);
    final transactionForm = Provider.of<TransactionFormProvider>(context);

    return Column(
      children: [
        SizedBox(
          height: 80,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                flex: 20,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: DefaultTextStyle(
                      style: FluentTheme.of(context).typography.title!,
                      child: Text(
                        title[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  title: Text(title),
                  subtitle: Text(subtitle),
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 40,
                  child: FilledButton(
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all<Color>(Colors.green),
                      shape: ButtonState.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () {
                      blockService.selectedUser = user;
                      _showInsertAmount(context, transactionForm);
                    },
                    child: const Center(
                      child: Text(
                        'Transferir',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
        if (index != listLength - 1) const Divider() else Container(),
      ],
    );
  }

  void _showInsertAmount(
    BuildContext context,
    TransactionFormProvider transactionForm,
  ) {
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: const Text('Nueva transacción'),
        content: Form(
          key: transactionForm.formKey,
          child: SizedBox(
            height: 125,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Ingrese el monto a transferir',
                  style: TextStyle(fontSize: 16),
                ),
                AmountInput(transactionForm: transactionForm),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Use "." para separar decimales'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Button(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Confirmar'),
            onPressed: () async {
              FocusScope.of(context).unfocus();

              if (!transactionForm.isValidForm()) return;

              final blockService =
                  Provider.of<BlockService>(context, listen: false);

              // Comenzar a cargar el loading
              transactionForm.isLoading = true;

              // Cerrar dialog
              Navigator.pop(context);

              // Crear objeto de transacción (comisión 5%)
              final transactionModel = TransactionModel(
                from: Preferences.userEmail,
                to: blockService.selectedUser.email,
                amount: transactionForm.ammount,
                fee: transactionForm.ammount * 0.05,
              );

              // Crear firma de transacción
              final rsaKeyHelper = RsaKeyHelper();
              final publicKey = rsaKeyHelper
                  // ignore: leading_newlines_in_multiline_strings
                  .parsePublicKeyFromPem('''-----BEGIN RSA PUBLIC KEY-----
${Preferences.userPublicKey}
-----END RSA PUBLIC KEY-----''');
              final privateKey = rsaKeyHelper
                  // ignore: leading_newlines_in_multiline_strings
                  .parsePrivateKeyFromPem('''-----BEGIN RSA PRIVATE KEY-----
${Preferences.userPrivateKey}
-----END RSA PRIVATE KEY-----''');
              final signer = crypto.Signer(
                crypto.RSASigner(
                  crypto.RSASignDigest.SHA256,
                  publicKey: publicKey,
                  privateKey: privateKey,
                ),
              );
              final signature = signer.sign('bloque firmado').base64;

              // Enviar transacción al servidor
              final errorMessage = await blockService.newTransaction(
                transactionModel,
                signature,
              );

              if (errorMessage != null) {
                transactionForm.isLoading = false;
                await blockService.getUserBalance(initialLoad: false);
              } else {
                transactionForm.isLoading = false;
                await blockService.getUserBalance(initialLoad: false);
              }
            },
          ),
        ],
      ),
    );
  }
}

class AmountInput extends StatelessWidget {
  const AmountInput({
    required this.transactionForm,
    super.key,
  });

  final TransactionFormProvider transactionForm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextFormBox(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (text) {
          transactionForm.ammount = double.tryParse(text) ?? 0;
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.singleLineFormatter,
        ],
        validator: (text) {
          if (text == null || text.isEmpty) {
            return 'Ingrese un monto';
          }
          if (double.tryParse(text) == null || double.tryParse(text)! <= 0) {
            return 'Ingrese un monto válido';
          }
          // Verificar que el saldo no sea mayor al que se tiene
          final blockService =
              Provider.of<BlockService>(context, listen: false);
          if (transactionForm.ammount > blockService.balance) {
            return 'No puede tranferir un saldo mayor al que tiene';
          }
          return null;
        },
      ),
    );
  }
}

class ProcessingTransactionCard extends StatelessWidget {
  const ProcessingTransactionCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 60,
      child: Card(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const Text(
                'Procesando transacción...',
                style: TextStyle(fontSize: 14, fontFamily: 'RobotoMono'),
              ),
              Expanded(child: Container()),
              ProgressBar(activeColor: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}
