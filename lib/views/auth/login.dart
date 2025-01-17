import 'package:filmu_nams/views/resources/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Background(
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 164,
                    child: Container(
                      width: width,
                      height: 94,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Positioned(
                    top: 115,
                    child: SvgPicture.asset(
                      'assets/Logo.svg',
                      height: 179,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 100, right: 25, left: 25),
              width: width,
              height: 475,
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: Text(
                    'Laipni lūdzam!',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        decoration: TextDecoration.none),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                  child: TextFormField(
                    cursorColor: Color.fromARGB(255, 123, 123, 123),
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'epasts@epasts.lv',
                      labelText: 'E-pasts',
                      suffixIcon: Icon(
                        Icons.email,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 35),
                  child: TextFormField(
                    cursorColor: Color.fromARGB(255, 123, 123, 123),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'dro\$aParole1',
                      labelText: 'Parole',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: _toggle,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 23, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 119, 41, 32),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/google.png',
                          width: 25,
                          color: Colors.white,
                        ),
                        iconSize: 48,
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 23, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 119, 41, 32),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/facebook.png',
                          width: 25,
                          color: Colors.white,
                        ),
                        iconSize: 48,
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Nav konta?",
                          style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 167, 167, 167),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text("Piereġistrēties"),
                        )
                      ],
                    ),
                    FilledButton(
                      onPressed: () {},
                      child: Text(
                        "Ielogoties",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}
