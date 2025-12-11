import 'package:flutter/material.dart';
import '../widgets/app_ui.dart';
import 'ip.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _flag = '';
  String _ip = '';

  @override
  void initState() {
    super.initState();
    _loadIpInfo();
  }

  Future<void> _loadIpInfo() async {
    try {
      final data = await server();
      setState(() {
        _flag = data['flag'] ?? '';
        _ip = data['ip'] ?? '';
      });
    } catch (e) {
      // ignore for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        appBackground(),
        const AppTopBar(title: 'Profile'),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome Guest',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_flag  $_ip',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
