import 'package:flutter/material.dart';

class GetOtpPage extends StatefulWidget {
  const GetOtpPage({super.key});

  @override
  State<GetOtpPage> createState() => _GetOtpPageState();
}

class _GetOtpPageState extends State<GetOtpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lupa password')),
      body: Placeholder(),
    );
  }
}
