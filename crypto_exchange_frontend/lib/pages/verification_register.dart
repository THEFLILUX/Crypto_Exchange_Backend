import 'package:crypto_exchange_frontend/models/models.dart';
import 'package:crypto_exchange_frontend/providers/providers.dart';
import 'package:crypto_exchange_frontend/services/services.dart';
import 'package:crypto_exchange_frontend/widgets/widgets.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class VerificationRegisterPage extends StatelessWidget {
  const VerificationRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final userModel = ModalRoute.of(context)!.settings.arguments! as UserModel;

    return ChangeNotifierProvider(
      create: (_) => VerificationFormProvider(),
      child: VerificationRegisterScaffold(
        themeProvider: themeProvider,
        userModel: userModel,
      ),
    );
  }
}

class VerificationRegisterScaffold extends StatelessWidget {
  const VerificationRegisterScaffold({
    required this.themeProvider,
    required this.userModel,
    super.key,
  });

  final ThemeProvider themeProvider;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Stack(
        children: [
          SwitcherTheme(themeProvider: themeProvider),
          Center(
            child: Form(
              key: Provider.of<VerificationFormProvider>(context).formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LogoAndTitle(themeProvider: themeProvider),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingresa el código enviado por correo electrónico',
                  ),
                  const SizedBox(height: 20),
                  RegisterCodeInput(
                    verificationForm:
                        Provider.of<VerificationFormProvider>(context),
                  ),
                  const SizedBox(height: 20),
                  RegisterSendCodeButton(userModel: userModel),
                  const SizedBox(height: 40),
                  const RegisterCancelButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterCodeInput extends StatelessWidget {
  const RegisterCodeInput({
    required this.verificationForm,
    super.key,
  });

  final VerificationFormProvider verificationForm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 60,
            child: TextFormBox(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (text) {
                verificationForm.firstDigit = text;
                if (text.length == 1) {
                  FocusScope.of(context).nextFocus();
                }
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (text) {
                return (text != null && text.length == 1) ? null : 'Falta';
              },
            ),
          ),
          SizedBox(
            width: 60,
            child: TextFormBox(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (text) {
                verificationForm.secondDigit = text;
                if (text.length == 1) {
                  FocusScope.of(context).nextFocus();
                }
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (text) {
                return (text != null && text.length == 1) ? null : 'Falta';
              },
            ),
          ),
          SizedBox(
            width: 60,
            child: TextFormBox(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (text) {
                verificationForm.thirdDigit = text;
                if (text.length == 1) {
                  FocusScope.of(context).nextFocus();
                }
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (text) {
                return (text != null && text.length == 1) ? null : 'Falta';
              },
            ),
          ),
          SizedBox(
            width: 60,
            child: TextFormBox(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (text) {
                verificationForm.fourthDigit = text;
                if (text.length == 1) {
                  FocusScope.of(context).nextFocus();
                }
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (text) {
                return (text != null && text.length == 1) ? null : 'Falta';
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterSendCodeButton extends StatelessWidget {
  const RegisterSendCodeButton({
    required this.userModel,
    super.key,
  });

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    final verificationForm = Provider.of<VerificationFormProvider>(context);

    return SizedBox(
      width: 400,
      child: FilledButton(
        onPressed: verificationForm.isLoading
            ? null
            : () async {
                // Exit keyboard
                FocusScope.of(context).unfocus();

                // Enviar código a backend
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                if (!verificationForm.isValidForm()) return;
                verificationForm.isLoading = true;

                // Recibir objeto UserModel y enviar POST
                final errorMessage =
                    await authService.verifySecurityCodeRegister(
                  userModel,
                  '${verificationForm.firstDigit}'
                  '${verificationForm.secondDigit}'
                  '${verificationForm.thirdDigit}'
                  '${verificationForm.fourthDigit}',
                );
                if (errorMessage != null) {
                  // ignore: use_build_context_synchronously
                  _showErrorDialog(context, errorMessage);
                  verificationForm.isLoading = false;
                } else {
                  verificationForm.isLoading = false;
                  // ignore: use_build_context_synchronously
                  await Navigator.pushReplacementNamed(context, '/home');
                }
              },
        child: Text(verificationForm.isLoading ? 'Espere...' : 'Enviar código'),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          FilledButton(
            child: const Text('Ok'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class RegisterCancelButton extends StatelessWidget {
  const RegisterCancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Button(
        child: const Text('Cancelar'),
        onPressed: () => _showCancelOptions(context),
      ),
    );
  }

  void _showCancelOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: const Text('Salir'),
        content: const Text('¿Seguro que desea cancelar la operación?'),
        actions: [
          Button(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Sí'),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/register'),
          ),
        ],
      ),
    );
  }
}
