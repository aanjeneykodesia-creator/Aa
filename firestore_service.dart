import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static Future<String> saveUser({
    required String name,
    required String phone,
    required String dl,
    required String role,
    required File imageFile,
    required double lat,
    required double lng,
    required String city,
  }) async {
    String userId = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = _storage.ref("users/$userId.jpg");
    await ref.putFile(imageFile);
    String imageUrl = await ref.getDownloadURL();

    await _db.collection("users").doc(userId).set({
      "name": name,
      "phone": phone,
      "dl": dl,
      "role": role,
      "image": imageUrl,
      "lat": lat,
      "lng": lng,
      "city": city,
      "created_at": DateTime.now(),
    });

    return userId;
  }

  static Future<String> createJob({
    required String manufacturerId,
    required double lat,
    required double lng,
    required String city,
  }) async {
    String jobId = DateTime.now().millisecondsSinceEpoch.toString();

    await _db.collection("jobs").doc(jobId).set({
      "manufacturer_id": manufacturerId,
      "lat": lat,
      "lng": lng,
      "city": city,
      "status": "pending",
      "transporter_id": "",
      "otp": "",
      "created_at": DateTime.now(),
    });

    return jobId;
  }

  static Future acceptJob(String jobId, String transporterId) async {
    await _db.collection("jobs").doc(jobId).update({
      "status": "accepted",
      "transporter_id": transporterId,
    });
  }

  static Future saveOTP(String jobId, String otp) async {
    await _db.collection("jobs").doc(jobId).update({
      "otp": otp,
    });
  }

  static Future<bool> verifyOTP(String jobId, String otp) async {
    final doc = await _db.collection("jobs").doc(jobId).get();

    if (!doc.exists) return false;

    return doc["otp"] == otp;
  }
}
