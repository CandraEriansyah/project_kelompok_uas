import 'package:flutter/material.dart';
import 'package:project_kelompok_uas/custom_button.dart';
import 'package:project_kelompok_uas/data_teams.dart';
import 'package:project_kelompok_uas/login_page.dart';
import 'package:project_kelompok_uas/scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome Apps FootBoll"),
      ),
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Wrap(
              runSpacing: 10,
              spacing: 10,
              children: [
                TextButton(
                    onPressed: (() {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return Scanning();
                        },
                      ));
                    }),
                    child: CustomWidget(
                        label: "Scanner", icon: Icons.qr_code_scanner)),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => insert_teams()));
                    },
                    child: CustomWidget(
                      label: "Insert Teams",
                      icon: Icons.insert_chart,
                    )),
                TextButton(
                    onPressed: () async {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      setState(() {
                        preferences.remove("is_login");
                        preferences.remove("username");
                      });

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => PageLogin(),
                        ),
                        (route) => false,
                      );
                    },
                    child: CustomWidget(label: 'Logout', icon: Icons.logout))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
