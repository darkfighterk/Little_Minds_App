import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import '../helpers/validators.dart';
import '../widgets/custom_button.dart';
import 'home_view.dart';
import 'sign_up_view.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginController _loginController = LoginController();

  bool _loading = false;
  String _errorMessage = '';

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    final user = await _loginController.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _loading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeView(user: user)),
      );
    } else {
      setState(() => _errorMessage = "Invalid username or password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 500, // adjust size
                height: 500,
              ),
              const SizedBox(height: 00),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
                validator: Validators.validateUsername,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : CustomButton(text: "Login", onPressed: _login),
                  const SizedBox(height: 15),

TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpView(),
      ),
    );
  },
  child: const Text("Don't have an account? Sign Up"),
  ),
            ],
          ),
        ),
      ),
    );
  }
}
