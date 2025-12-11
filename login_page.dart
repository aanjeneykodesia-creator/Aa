import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/location_service.dart';
import 'services/firestore_service.dart';
import 'manufacturer_page.dart';
import 'transporter_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nameC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController dlC = TextEditingController();

  File? imageFile;
  String role = "transporter";

  bool loading = false;

  Future pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => imageFile = File(img.path));
  }

  Future loginUser() async {
    if (nameC.text.isEmpty || phoneC.text.isEmpty || dlC.text.isEmpty || imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => loading = true);

    final loc = await LocationService.getLocation();
    final city = await LocationService.getCityFromCoordinates(loc["lat"], loc["lng"]);

    String userId = await FirestoreService.saveUser(
      name: nameC.text,
      phone: phoneC.text,
      dl: dlC.text,
      role: role,
      imageFile: imageFile!,
      lat: loc["lat"],
      lng: loc["lng"],
      city: city,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("logged_in", true);
    prefs.setString("role", role);
    prefs.setString("user_id", userId);

    setState(() => loading = false);

    if (role == "manufacturer") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ManufacturerPage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TransporterPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kirana's Professional Login")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameC, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: phoneC, decoration: InputDecoration(labelText: "Phone Number")),
            TextField(controller: dlC, decoration: InputDecoration(labelText: "Driving License No")),

            SizedBox(height: 15),

            imageFile == null
                ? Text("No Image Selected")
                : Image.file(imageFile!, height: 120),

            ElevatedButton(
              onPressed: pickImage,
              child: Text("Pick Profile Photo"),
            ),

            SizedBox(height: 20),

            DropdownButton<String>(
              value: role,
              items: [
                DropdownMenuItem(value: "manufacturer", child: Text("Manufacturer")),
                DropdownMenuItem(value: "transporter", child: Text("Transporter")),
              ],
              onChanged: (val) => setState(() => role = val!),
            ),

            SizedBox(height: 20),

            loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginUser,
                    child: Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
