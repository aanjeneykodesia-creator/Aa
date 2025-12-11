import 'package:flutter/material.dart';
import 'services/firestore_service.dart';

class JobDetailsPage extends StatefulWidget {
  final String jobId;

  JobDetailsPage({required this.jobId});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  TextEditingController otpC = TextEditingController();
  String message = "";

  Future verifyOtp() async {
    bool ok = await FirestoreService.verifyOTP(widget.jobId, otpC.text);

    setState(() {
      message = ok ? "OTP Verified Successfully" : "Incorrect OTP";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Verification")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpC,
              decoration: InputDecoration(labelText: "Enter OTP"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOtp,
              child: Text("Verify OTP"),
            ),
            SizedBox(height: 20),
            Text(message, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}