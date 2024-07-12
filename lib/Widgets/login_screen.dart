import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jp_optical/Widgets/Header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Perform login logic here
      final email = _emailController.text;
      final password = _passwordController.text;
      print('Email: $email, Password: $password');
      // Show a success message, navigate to another screen, etc.
    }
  }
 void handleOnClickHamburger(String action) {
    setState(() {
      if (action == 'show_drawer') { 
      } else { 
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Material(child:
    Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Header(onClickHamburger: handleOnClickHamburger, showCart: true, showBackArrow: true, routeFromHome: false,),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _login,
            child: const Text('Login'),
          ),
        ],
      ),
    ));
  }
}