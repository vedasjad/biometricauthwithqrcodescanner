import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:otp_gen/common/colors/colors.dart';
import 'package:otp_gen/models/employee.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  String qrData = "";
  int beginTime = 0;
  int secondsLeft = 0;

  Map<String, int> letterCounts = {};
  String otp = "";
  Employee employee = Employee(
      empID: "empID", id: "id", key: "key", username: "username", role: "role");

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
    secondsLeft =
        60 - ((DateTime.now().millisecondsSinceEpoch - beginTime) ~/ 1000);
    if (secondsLeft <= 1) {
      setState(() {
        beginTime = DateTime.now().millisecondsSinceEpoch;
      });
    }
    if (secondsLeft >= 59) {
      setState(() {
        generateOTP();
      });
    }
  }

  Timer timer = Timer(const Duration(seconds: 1), () {});

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    if (!timer.isActive) {
      timer = Timer.periodic(oneSecond, (Timer t) {
        setState(() {
          updateSecondsLeft();
        });
      });
    }
  }

  Future saveQRData() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'EmployeeData';
    prefs.setString(key, employee.toJson().toString());
    // Employee employee = Employee.fromJson(jsonDecode(prefs.getString('EmployeeData')??""));
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
      ),
      backgroundColor: Colors.white.withOpacity(0.9),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: otp == ""
                  ? MobileScanner(
                      controller: MobileScannerController(
                        detectionSpeed: DetectionSpeed.normal,
                        facing: CameraFacing.back,
                      ),
                      onDetect: (capture) => _onQRDetected(capture),
                    )
                  : Column(
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
                child: otp != ""
                    ? Column(
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
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        color: AppColors.darkBlue,
                        alignment: Alignment.center,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "Scan QR Code",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRDetected(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    String qrData = barcodes.first.rawValue!;
    employee = Employee.fromJson(jsonDecode(qrData));
    await saveQRData();
    setState(() {
      beginTime = DateTime.now().millisecondsSinceEpoch;
      startTimer();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
