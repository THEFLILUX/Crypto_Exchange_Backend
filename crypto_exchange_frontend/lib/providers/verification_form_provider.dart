import 'package:fluent_ui/fluent_ui.dart';

class VerificationFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String firstDigit = '';
  String secondDigit = '';
  String thirdDigit = '';
  String fourthDigit = '';

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }
}
