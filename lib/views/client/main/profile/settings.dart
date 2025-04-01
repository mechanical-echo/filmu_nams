import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/input/filled_text_icon_button.dart';
import 'package:filmu_nams/providers/color_context.dart';
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = ColorContext.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: colors.color001,
        ),
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.none,
        title: Container(
          decoration: colors.classicDecorationDark,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -35,
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
              Text(
                'Iestatījumi',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
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
                // header('Valoda', colors),
                // languageSelector(colors),
                // divider(colors),
                header('Tēma', colors),
                themeSelector(themeProvider, colors),
                divider(colors),
                header('Informācija', colors),
                info('Versija', '0.0.1', colors),
                info('Izstrādātājs', 'Sofija Dišlovaja 4PT-1', colors),
                divider(colors),
                header('Konta opcijas', colors),
                button('Mainīt paroli', Icons.lock, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PasswordChangePage()),
                  );
                }, colors),
                logout(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget header(String title, ColorContext colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: colors.header2,
      ),
    );
  }

  Widget divider(ColorContext colors) {
    return Divider(
      color: colors.color003.withAlpha(100),
      thickness: 2,
      height: 32,
    );
  }

  Widget languageSelector(ColorContext colors) {
    final backgroundColor = colors.classicDecorationSharper.color!;
    return Container(
      decoration: colors.classicDecorationSharper,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButton<String>(
        iconEnabledColor: colors.textColorFor(backgroundColor),
        underline: Container(),
        style: colors.bodyMediumFor(backgroundColor),
        value: _language,
        isExpanded: true,
        dropdownColor: colors.color002,
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

  Widget themeSelector(ThemeProvider themeProvider, ColorContext colors) {
    final backgroundColor = colors.classicDecorationSharper.color!;
    return Column(
      spacing: 15,
      children: [
        Container(
          decoration: colors.classicDecorationSharper,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pašreizējā tēma: ${themeProvider.getThemeName()}',
                style: colors.bodyMediumFor(backgroundColor),
              ),
              Icon(
                Icons.color_lens,
                color: colors.textColorFor(backgroundColor),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            circle(AppTheme.redDark, Colors.red, themeProvider, true),
            circle(AppTheme.blueDark, Colors.blue, themeProvider, true),
            circle(AppTheme.redLight, Colors.red, themeProvider, false),
            circle(AppTheme.blueLight, Colors.blue, themeProvider, false),
          ],
        ),
      ],
    );
  }

  Widget circle(
      AppTheme theme, Color color, ThemeProvider themeProvider, bool isDark) {
    final bool isSelected = themeProvider.currentThemeEnum == theme;

    return GestureDetector(
      onTap: () => themeProvider.setTheme(theme),
      child: Container(
        width: 60,
        height: 60,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -23,
              top: -23,
              child: Transform.rotate(
                angle: 0.785398,
                child: Container(
                  color: isDark ? Colors.black : Colors.white,
                  width: 60,
                  height: 60,
                ),
              ),
            ),
            if (isSelected)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget button(
      String title,
      IconData icon,
      VoidCallback onPressed,
      ColorContext colors,
    ) {
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
                style: TextStyle(
                  color: colors.smokeyWhite,
                  fontSize: 15
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget info(String title, String value, ColorContext colors) {
    return GestureDetector(
      onTap: title == "Izstrādātājs" ? () => _showDeveloperDialog() : null,
      child: Container(
        decoration: colors.darkDecorationSharper,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: colors.bodyMedium),
            Text(value,
                style: colors.bodyMedium.copyWith(color: colors.color003)),
          ],
        ),
      ),
    );
  }

  void _showDeveloperDialog() {
    final colors = ColorContext.of(context);

    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.color003.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    "assets/Maxwell.gif",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Ok!"),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.elasticOut,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 800),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
    );
  }

  Widget logout() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FilledTextIconButton(
        icon: Icons.logout,
        title: "Izlogoties",
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        paddingY: 8,
      ),
    );
  }
}
