import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dineall/screen/login_screen.dart';
import 'package:dineall/service/user_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSettingItem(context, 'Account info', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account info tapped')),
              );
            }),
            _buildDivider(),
            _buildSettingItem(context, 'Saved addresses', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved addresses tapped')),
              );
            }),
            _buildDivider(),
            _buildSettingItem(context, 'Change email', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change email tapped')),
              );
            }),
            _buildDivider(),
            _buildSettingItem(context, 'Change password', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change password tapped')),
              );
            }),
            _buildDivider(),
            _buildSettingItem(context, 'Notifications', status: 'Enabled', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications settings tapped')),
              );
            }),
            _buildDivider(),
            _buildSettingItem(context, 'Country', status: 'Egypt', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Country selection tapped')),
              );
            }),
            _buildDivider(),
            _buildSettingItem(context, 'Log out', isDestructive: false, onTap: () {
               UserService().logout();
               Navigator.pushAndRemoveUntil(
                 context,
                 MaterialPageRoute(builder: (context) => const LoginScreen()),
                 (route) => false,
               );
            }),
             _buildDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, {String? status, bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: isDestructive ? Colors.red : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (status != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: Color(0xFFEEEEEE),
      indent: 16,
    );
  }
}
