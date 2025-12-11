import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/firestore_service.dart';

class TransporterPage extends StatefulWidget {
  @override
  State<TransporterPage> createState() => _TransporterPageState();
}

class _TransporterPageState extends State<TransporterPage> {
  String transporterId = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    transporterId = prefs.getString("user_id")!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transporter Dashboard")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("jobs")
            .where("status", isEqualTo: "pending")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data!.docs;

          if (jobs.isEmpty) {
            return Center(child: Text("No jobs available"));
          }

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, i) {
              final job = jobs[i];

              return Card(
                child: ListTile(
                  title: Text("Pickup City: ${job['city']}"),
                  subtitle: Text(
                    "Lat: ${job['lat']}\nLng: ${job['lng']}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await FirestoreService.acceptJob(job.id, transporterId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Job Accepted")),
                      );
                    },
                    child: Text("Accept"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}