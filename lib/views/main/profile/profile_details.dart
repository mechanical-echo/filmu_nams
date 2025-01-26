import 'package:filmu_nams/views/resources/decorations/background.dart';
import 'package:filmu_nams/views/resources/decorations/profile_image.dart';
import 'package:filmu_nams/views/resources/input/filled_icon_button.dart';
import 'package:filmu_nams/views/resources/input/text_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProfileDetails extends StatelessWidget {
  ProfileDetails({super.key});

  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPasswordConfirmationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final textFieldWidth = width * 0.82;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Profila detaļas',
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
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 38.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ProfileImage(
                        width: 130,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user!.displayName ?? 'Vārds Uzvārds',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Reģistrēts:',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            DateFormat(
                                    '${DateFormat.DAY}.${DateFormat.NUM_MONTH}.${DateFormat.YEAR} ${DateFormat.HOUR24}:${DateFormat.MINUTE}',
                                    'lv')
                                .format(user!.metadata.creationTime ??
                                    DateTime.now()),
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: textFieldWidth,
                      child: TextInput(
                        controller: nameController,
                        labelText: "Vārds",
                        hintText: "Ievadiet vārdu",
                        icon: Icon(Icons.person),
                        obscureText: false,
                        margin: [20, 20, 20, 20],
                      ),
                    ),
                    FilledIconButton(onPressed: () {}, icon: Icons.save)
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    SizedBox(
                      width: textFieldWidth,
                      child: TextInput(
                        controller: emailController,
                        labelText: "E-pasts",
                        hintText: "Ievadiet e-pastu",
                        icon: Icon(Icons.email),
                        obscureText: false,
                        margin: [20, 20, 20, 20],
                      ),
                    ),
                    FilledIconButton(onPressed: () {}, icon: Icons.save)
                  ],
                ),
                Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: textFieldWidth,
                      child: TextInput(
                        controller: oldPasswordController,
                        labelText: "Vecā parole",
                        hintText: "Ievadiet paroli",
                        obscureText: true,
                        margin: [20, 20, 20, 20],
                      ),
                    ),
                    SizedBox(
                      width: textFieldWidth,
                      child: TextInput(
                        controller: newPasswordController,
                        labelText: "Jauna parole",
                        hintText: "Ievadiet paroli",
                        obscureText: true,
                        margin: [20, 20, 20, 20],
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: textFieldWidth,
                          child: TextInput(
                            controller: newPasswordConfirmationController,
                            labelText: "Jaunā parole atkārtoti",
                            hintText: "Ievadiet paroli",
                            icon: Icon(Icons.email),
                            obscureText: true,
                            margin: [20, 20, 20, 20],
                          ),
                        ),
                        FilledIconButton(onPressed: () {}, icon: Icons.save)
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
