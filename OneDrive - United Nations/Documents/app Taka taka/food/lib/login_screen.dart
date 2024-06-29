import 'package:flutter/material.dart';
import 'auth_service.dart';

enum LoginMenu {
  intro,
  signUp,
  signIn,
  forgotPassword,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginMenu menu = LoginMenu.intro;

  void goToSignUpPage() {
    setState(() {
      menu = LoginMenu.signUp;
    });
  }

  void goToSignInPage() {
    setState(() {
      menu = LoginMenu.signIn;
    });
  }

  void goToForgotPasswordPage() {
    setState(() {
      menu = LoginMenu.forgotPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (menu) {
      case LoginMenu.intro:
        return IntroductionPage(
          goToSignUpPage: goToSignUpPage,
          goToSignInPage: goToSignInPage,
        );
      case LoginMenu.signUp:
        return SignUpPage(
          goToSignInPage: goToSignInPage,
        );
      case LoginMenu.signIn:
        return SignInPage(
          goToForgotPasswordPage: goToForgotPasswordPage,
          goToSignUpPage: goToSignUpPage,
        );
      case LoginMenu.forgotPassword:
        return ForgotPasswordPage(
          goToSignInPage: goToSignInPage,
        );
    }
  }
}

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({
    required this.goToSignInPage,
    required this.goToSignUpPage,
    super.key,
  });

  final Function() goToSignInPage;
  final Function() goToSignUpPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(
            "Taka Taka",
            style: TextStyle(),
          ),
          Text("Join us in making steps towards environmental change"),
          ElevatedButton(onPressed: goToSignUpPage, child: Text("Register")),
          ElevatedButton(onPressed: goToSignInPage, child: Text("Login")),
        ],
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  SignInPage(
      {required this.goToForgotPasswordPage,
      required this.goToSignUpPage,
      super.key});

  final Function() goToForgotPasswordPage;
  final Function() goToSignUpPage;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> _login(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    await _authService.signInWithEmailPassword(email, password).then(
      (user) {
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed')),
          );
          return;
        }

        // Login successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
        //todo go to main menu
      },
    ).catchError(
      (e, trace) {
        print(trace.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taka Taka App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/un-preview.png',
                width: 200,
                height: 150,
                fit: BoxFit.cover,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: goToForgotPasswordPage,
                child: Text(
                  "Forgot Password?",
                  textAlign: TextAlign.end,
                ),
              ),
              ElevatedButton(
                onPressed: () => _login(context),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: goToSignUpPage,
                child: const Text("Don't have an account?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  SignUpPage({required this.goToSignInPage, super.key});

  final Function() goToSignInPage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> _signUp(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    await _authService.createAccount(email, password).then(
      (user) {
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account failed')),
          );
          return;
        }

        // Account creation in successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account successful')),
        );

        //todo go to login page
      },
    ).catchError(
      (e, trace) {
        print(trace.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taka Taka App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _signUp(context),
                child: const Text('Sign up'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: goToSignInPage,
                child: Text("Have an account? Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({required this.goToSignInPage, super.key});

  final Function() goToSignInPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Forgot password"),
          TextButton(
            onPressed: goToSignInPage,
            child: Text("Sign In"),
          ),
        ],
      ),
    );
  }
}
