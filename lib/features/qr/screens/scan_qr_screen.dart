import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:otp_gen/common/colors/colors.dart';
import 'package:otp_gen/features/otp/screens/otp_screen.dart';
import 'package:otp_gen/models/employee.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/utils/utils.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  Employee employee = Employee(
      empID: "empID", id: "id", key: "key", username: "username", role: "role");
  Future saveQRData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppUtils.userKey, jsonEncode(employee).toString());
  }

  getUserInfo() async {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          if (snapshot.data == true) {
            return const OTPScreen();
          }
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
                    child: MobileScanner(
                      controller: MobileScannerController(
                        detectionSpeed: DetectionSpeed.normal,
                        facing: CameraFacing.back,
                      ),
                      onDetect: (capture) => _onQRDetected(capture),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: AppColors.darkBlue,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
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
        });
  }

  void _onQRDetected(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    String qrData = barcodes.first.rawValue!;
    employee = Employee.fromJson(jsonDecode(qrData));
    await saveQRData();
    setState(() {});
  }
}
