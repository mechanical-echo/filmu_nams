import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/providers/theme_provider.dart';
import 'package:filmu_nams/views/client/main/profile/password_change.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _language = 'Latviešu';
  bool _showMaxwell = false;

  void _showMaxwellPopup() {
    setState(() {
      _showMaxwell = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            backgroundColor: Colors.transparent,
            clipBehavior: Clip.none,
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -35,
                    child: Icon(
                      Icons.settings_outlined,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    'Iestatījumi',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Background(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16, top: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Tēma',
                      [
                        _buildThemeSelector(themeProvider),
                      ],
                    ),
                    _buildSection(
                      'Informācija',
                      [
                        _buildInfoItem('Versija', '0.0.1'),
                        _buildInfoItem('Izstrādātājs', 'Sofija Dišlovaja 4PT-1',
                            onTap: _showMaxwellPopup),
                      ],
                    ),
                    _buildSection(
                      'Konta opcijas',
                      [
                        _buildButton(
                          'Mainīt paroli',
                          Icons.lock_outline,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PasswordChangePage(),
                              ),
                            );
                          },
                        ),
                        _buildButton(
                          'Izlogoties',
                          Icons.logout_outlined,
                          () {
                            FirebaseAuth.instance.signOut();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_showMaxwell)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showMaxwell = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/Maxwell.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 16),
        Divider(
          color: Colors.white.withOpacity(0.1),
          height: 1,
        ),
      ],
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            'Sarkana/tumša',
            Icons.dark_mode_outlined,
            themeProvider.currentThemeEnum == AppTheme.redDark,
            () => themeProvider.setTheme(AppTheme.redDark),
          ),
          Divider(
            color: Theme.of(context).colorScheme.outline,
            height: 1,
          ),
          _buildThemeOption(
            'Zila/tumša',
            Icons.dark_mode_outlined,
            themeProvider.currentThemeEnum == AppTheme.blueDark,
            () => themeProvider.setTheme(AppTheme.blueDark),
          ),
          Divider(
            color: Theme.of(context).colorScheme.outline,
            height: 1,
          ),
          _buildThemeOption(
            'Sarkana/gaiša',
            Icons.light_mode_outlined,
            themeProvider.currentThemeEnum == AppTheme.redLight,
            () => themeProvider.setTheme(AppTheme.redLight),
          ),
          Divider(
            color: Theme.of(context).colorScheme.outline,
            height: 1,
          ),
          _buildThemeOption(
            'Zila/gaiša',
            Icons.light_mode_outlined,
            themeProvider.currentThemeEnum == AppTheme.blueLight,
            () => themeProvider.setTheme(AppTheme.blueLight),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
