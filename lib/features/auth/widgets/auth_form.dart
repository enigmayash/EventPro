
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class AuthForm extends StatefulWidget {
  final VoidCallback onSubmit;  // Callback when the form is submitted
   bool isLogin;           // Flag to check whether it's for login or signup

   AuthForm({
    Key? key,
    required this.onSubmit,
    required this.isLogin,
  }) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  // Validate email
  String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an email';
  }
  // Simple regex for email validation
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;  // return null if validation passes
}

  // Validate password
  String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null; // Return null if the password is valid
}

  // Handle form submission
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailError,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16.0),

            // Password Field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError,
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 16.0),

            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.isLogin ? 'Login' : 'Sign Up'),
            ),

            // Switch between login and signup
            TextButton(
              onPressed: () {
                setState(() {
                  widget.isLogin = !widget.isLogin;
                });
              },
              child: Text(widget.isLogin
                  ? 'Don\'t have an account? Sign up'
                  : 'Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
