import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/input/filled_text_icon_button.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkTheme = true;
  String _language = 'Latviešu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Iestatījumi',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: Background(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Valoda'),
                _buildLanguageSelector(),
                _buildDivider(),
                _buildSectionHeader('Paziņojumi'),
                _buildSwitchTile('E-pasta paziņojumi', _emailNotifications,
                    (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                }),
                _buildSwitchTile('Push paziņojumi', _pushNotifications,
                    (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                }),
                _buildDivider(),
                _buildSectionHeader('Izskats'),
                _buildSwitchTile('Tumšais režīms', _darkTheme, (value) {
                  setState(() {
                    _darkTheme = value;
                  });
                }),
                _buildDivider(),
                _buildSectionHeader('Konta opcijas'),
                _buildAccountButton('Profila detaļas', Icons.person, () {
                  Navigator.pushNamed(context, '/profile/details');
                }),
                _buildAccountButton('Mainīt paroli', Icons.lock, () {
                  // Navigate to password change screen
                }),
                _buildAccountButton('Privātuma iestatījumi', Icons.privacy_tip,
                    () {
                  // Navigate to privacy settings
                }),
                _buildDivider(),
                _buildSectionHeader('Programma'),
                _buildInfoTile('Versija', '1.0.0'),
                _buildInfoTile('Izstrādātājs', 'Filmu Nams'),
                _buildDivider(),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: header2,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: red003.withAlpha(100),
      thickness: 2,
      height: 32,
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      decoration: classicDecorationSharper,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButton<String>(
        iconEnabledColor: Colors.white,
        underline: Container(),
        style: bodyMedium,
        value: _language,
        isExpanded: true,
        dropdownColor: red002,
        items: ['Latviešu', 'English', 'Русский'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _language = value!;
          });
        },
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      decoration: darkDecorationSharper,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: SwitchListTile(
        title: Text(
          title,
          style: bodyMedium,
        ),
        value: value,
        onChanged: onChanged,
        activeColor: red003,
        activeTrackColor: red001,
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey[800],
      ),
    );
  }

  Widget _buildAccountButton(
      String title, IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(icon, size: 22),
            ),
            Center(
              child: Text(
                title,
                style: bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      decoration: darkDecorationSharper,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: bodyMedium),
          Text(value, style: bodyMedium.copyWith(color: red003)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FilledTextIconButton(
        icon: Icons.logout,
        title: "Izlogoties",
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
        },
        paddingY: 8,
      ),
    );
  }
}
