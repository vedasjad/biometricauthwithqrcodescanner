import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/colors/colors.dart';
import '../../../common/utils/utils.dart';
import '../../../models/employee.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String qrData = "";
  int secondsLeft = 0;

  Map<String, int> letterCounts = {};
  String otp = "000000";
  Employee employee = Employee(
      empID: "empID", id: "id", key: "key", username: "username", role: "role");
  Future getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    employee = Employee.fromJson(jsonDecode(prefs.getString(AppUtils.userKey) ??
        jsonEncode(Employee(
                empID: "empID",
                id: "id",
                key: "key",
                username: "username",
                role: "role"))
            .toString()));
    if (employee.role != "role") {
      return true;
    }
    return false;
  }

  generateOTP() {
    String month = DateTime.now().month.toString();
    String day = DateTime.now().day.toString();
    String hours = DateTime.now().hour.toString();
    String minutes = DateTime.now().minute.toString();
    String year = DateTime.now().year.toString();
    String data = employee.key + year + month + day + hours + minutes;
    final lettersToCount = ['1', '2', '6', '7', '5', '9'];

    letterCounts = <String, int>{
      '1': 0,
      '2': 0,
      '6': 0,
      '7': 0,
      '5': 0,
      '9': 0
    };

    for (String letter in data.runes.map((rune) => String.fromCharCode(rune))) {
      if (lettersToCount.contains(letter)) {
        letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
      }
    }
    otp = letterCounts.values.map((count) => count.toString()).join();
  }

  updateSecondsLeft() {
    secondsLeft = 59 - DateTime.now().second;
    generateOTP();
  }

  Timer timer = Timer(const Duration(seconds: 1), () {});

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    timer = Timer.periodic(oneSecond, (Timer t) {
      setState(() {
        updateSecondsLeft();
      });
    });
  }

  f() async {
    await getUserInfo();
    setState(() {
      startTimer();
    });
  }

  @override
  void initState() {
    f();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(AppUtils.userKey);
    exit(exitCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Vidyutkawach",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.darkBlue,
        surfaceTintColor: AppColors.darkBlue,
        actions: [
          IconButton(
            onPressed: () => logout(),
            icon: const Icon(Icons.logout),
            color: Colors.white,
          )
        ],
      ),
      backgroundColor: Colors.white.withOpacity(0.9),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.darkBlue,
                    ),
                    child: Text(
                      otp,
                      style: const TextStyle(
                        fontSize: 25,
                        letterSpacing: 5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Text("OTP valid for"),
                  Text("${secondsLeft < 10 ? "0" : ""}$secondsLeft secs"),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              color: AppColors.darkBlue,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${employee.username.toUpperCase()} ",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "@${employee.empID}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      employee.role.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
