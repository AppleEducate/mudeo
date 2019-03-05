import 'package:flutter/material.dart';
import 'package:mudeo/ui/app/form_card.dart';
import 'package:mudeo/ui/app/progress_button.dart';
import 'package:mudeo/ui/auth/login_vm.dart';
import 'package:mudeo/utils/localization.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    Key key,
    @required this.viewModel,
  }) : super(key: key);

  final LoginVM viewModel;


  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginView> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _secretController = TextEditingController();
  final _oneTimePasswordController = TextEditingController();

  static const String OTP_ERROR = 'OTP_REQUIRED';

  final FocusNode _focusNode1 = new FocusNode();

  bool _isSelfHosted = false;
  bool _autoValidate = false;

  @override
  void didChangeDependencies() {
    final state = widget.viewModel.authState;
    _emailController.text = state.email;
    _passwordController.text = state.password;
    _secretController.text = state.secret;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _secretController.dispose();

    super.dispose();
  }

  void _submitForm() {
    final bool isValid = _formKey.currentState.validate();

    setState(() {
      _autoValidate = !isValid;
    });

    if (!isValid) {
      return;
    }

    widget.viewModel.onLoginPressed(context,
        email: _emailController.text,
        password: _passwordController.text,
        url: _urlController.text,
        secret: _secretController.text,
        oneTimePassword: _oneTimePasswordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final viewModel = widget.viewModel;
    final error = viewModel.authState.error ?? '';
    final isOneTimePassword =
        error.contains(OTP_ERROR) || _oneTimePasswordController.text.isNotEmpty;

    if (!viewModel.authState.isInitialized) {
      return Container();
    }

    return Stack(
      children: <Widget>[
        SizedBox(
          height: 250.0,
          child: ClipPath(
            clipper: ArcClipper(),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      //Colors.grey.shade800,
                      //Colors.black87,
                      Theme.of(context).buttonColor,
                      Theme.of(context).buttonColor.withOpacity(.7),
                    ],
                  )),
            ),
          ),
        ),
        ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Image.asset('assets/images/logo.png',
                  width: 100.0, height: 100.0),
            ),
            Form(
              key: _formKey,
              child: FormCard(
                children: <Widget>[
                  isOneTimePassword
                      ? TextFormField(
                    controller: _oneTimePasswordController,
                    autocorrect: false,
                    decoration: InputDecoration(
                        labelText: localization.oneTimePassword),
                  )
                      : Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            labelText: localization.email),
                        keyboardType: TextInputType.emailAddress,
                        autovalidate: _autoValidate,
                        validator: (val) =>
                        val.isEmpty || val.trim().isEmpty
                            ? localization.pleaseEnterYourEmail
                            : null,
                        onFieldSubmitted: (String value) =>
                            FocusScope.of(context)
                                .requestFocus(_focusNode1),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        autocorrect: false,
                        autovalidate: _autoValidate,
                        decoration: InputDecoration(
                            labelText: localization.password),
                        validator: (val) =>
                        val.isEmpty || val.trim().isEmpty
                            ? localization.pleaseEnterYourPassword
                            : null,
                        obscureText: true,
                        focusNode: _focusNode1,
                        onFieldSubmitted: (value) => _submitForm(),
                      ),
                    ],
                  ),
                  viewModel.authState.error == null || error.contains(OTP_ERROR)
                      ? Container()
                      : Container(
                    padding: EdgeInsets.only(top: 26.0),
                    child: Center(
                      child: Text(
                        viewModel.authState.error,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  ProgressButton(
                    padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                    isLoading: viewModel.isLoading,
                    label: localization.login.toUpperCase(),
                    onPressed: () => _submitForm(),
                  ),
                  isOneTimePassword
                      ? Container()
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton(
                          onPressed: () => viewModel.onGoogleLoginPressed(
                              context,
                              _urlController.text,
                              _secretController.text),
                          child: Text(localization.googleLogin)),
                    ],
                  ),
                  isOneTimePassword && !viewModel.isLoading
                      ? Padding(
                    padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                    child: ElevatedButton(
                      label: localization.cancel.toUpperCase(),
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          _oneTimePasswordController.text = '';
                        });
                        viewModel.onCancel2FAPressed();
                      },
                    ),
                  )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// https://github.com/iampawan/Flutter-UI-Kit
class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 30);

    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    final secondControlPoint =
    Offset(size.width - (size.width / 4), size.height);
    final secondPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
