import 'package:example/manual/presentation/manual_call_screen.dart';
import 'package:example/vidu/presentation/landing_vidu_screen.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Features'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => LandingViduScreen()));
            },
            child: Text(
              'OpenVidu',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManualCallScreen()));
            },
            child: Text(
              'Manual Call',
            ),
          ),
        ],
      ),
    );
  }
}
