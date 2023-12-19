import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:otp_gen/common/colors/colors.dart';
import 'package:otp_gen/features/qr/screens/scan_qr_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> initBiometric() async {
    final LocalAuthentication localAuth = LocalAuthentication();
    bool isBiometricAvailable = await localAuth.canCheckBiometrics;
    bool isUser = await localAuth.authenticate(
      localizedReason: "Vidyutkawach",
      biometricOnly: isBiometricAvailable,
      useErrorDialogs: true,
      stickyAuth: true,
    );
    return isUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vidyutkawach',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkBlue),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: AppColors.darkBlue,
        body: FutureBuilder(
            future: initBiometric(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }
              if (snapshot.data == true) {
                return const ScanQRScreen();
              } else {
                return Center(
                  child: SizedBox(
                    child: Text(
                      snapshot.data.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }
}
