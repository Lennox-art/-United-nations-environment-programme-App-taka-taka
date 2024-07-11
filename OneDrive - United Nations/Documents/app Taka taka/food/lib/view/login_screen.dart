import 'package:flutter/material.dart';
import 'package:food/routes/routes.dart';
import '../view_model/auth_service.dart';

enum LoginMenu {
  intro,
  signUp,
  signIn,
  forgotPassword,
  verificationPage,
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

  void goToVerificationCodePage() {
    setState(() {
      menu = LoginMenu.verificationPage;
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
      default:
        return Container(); // Add a default case to avoid null return
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
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        title: const Text('App Taka taka'),
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
              const SizedBox(height: 20),
              const Text(
                "App Taka Taka ",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "Join us in making steps towards acheiving a zero waste at UNON compound",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: goToSignUpPage,
                child: const Text("Register"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: goToSignInPage,
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  SignInPage({
    required this.goToForgotPasswordPage,
    required this.goToSignUpPage,
    super.key,
  });

  final Function() goToForgotPasswordPage;
  final Function() goToSignUpPage;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscureText = true;

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
        //go to main menu
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.superPage.path, (_) => false);
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
      backgroundColor: Colors.white, // Set the background color to white
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
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: widget.goToForgotPasswordPage,
                child: const Text(
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
                onPressed: widget.goToSignUpPage,
                child: const Text("Don't have an account?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  SignUpPage({required this.goToSignInPage, super.key});

  final Function() goToSignInPage;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;

  Future<void> _signUp(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    await _authService.createAccount(email, password).then(
      (user) {
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account creation failed')),
          );
          return;
        }

        // Account creation is successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );

        //  sign in user
        _authService.signInWithEmailPassword(email, password)
            .then(
              (user) {

                Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.superPage.path, (_) => false);
              },
        )
            .catchError((e, trace) {
            print(trace.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );

            widget.goToSignInPage();

          },
        );

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Taka Taka App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/un-preview.png', height: 200),
              const SizedBox(height: 20),
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
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePasswordText
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePasswordText = !_obscurePasswordText;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePasswordText,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPasswordText
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPasswordText =
                            !_obscureConfirmPasswordText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPasswordText,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _signUp(context),
                child: const Text('Sign up'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: widget.goToSignInPage,
                child: const Text("Have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({required this.goToSignInPage, super.key});

  final Function() goToSignInPage;
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taka Taka App'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/un-preview.png',
                // Replace with your actual logo image asset path
                height: 200,
                width: 200,
              ),
              SizedBox(height: 20),
              Icon(
                Icons.lock,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                "Enter your email and we'll send you a link to change a new password",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your UN Email',
                  filled: true,
                  // fillColor: Colors.
                  // border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(30),
                  //   borderSide: BorderSide.none,
                  // ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle forgot password action
                  authService.resetPassword(emailController.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                ),
                child: Text('Send link',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: goToSignInPage,
                child: Text(
                  "Sign In",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerificationCodePage extends StatefulWidget {
  @override
  _VerificationCodePageState createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final TextEditingController _codeController = TextEditingController();
  final String email = 'contractor@un.org';
  final int _seconds = 33; // assuming a countdown of 33 seconds

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/un_logo.png',
                // Ensure the logo image is in the assets folder
                height: 100,
              ),
            ),
            SizedBox(height: 32.0),
            Center(
              child: Text(
                'Please check your UN email',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: Text(
                'We have sent the code to $email',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return Container(
                  width: 50.0,
                  child: TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24.0),
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 16.0),
            Center(
              child: Text(
                'Send code again 00:${_seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Handle verification code submission
              },
              child: Text(
                'Verify code',
                style: TextStyle(fontSize: 18.0),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.lightBlue,
                // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
