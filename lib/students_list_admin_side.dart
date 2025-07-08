import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class StudentsListAdminSide extends StatefulWidget {
  const StudentsListAdminSide({Key? key}) : super(key: key);

  @override
  State<StudentsListAdminSide> createState() => _StudentsListAdminSideState();
}

class _StudentsListAdminSideState extends State<StudentsListAdminSide> {
  List<Map<String, dynamic>> allStudents = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    final dbRef = FirebaseDatabase.instance.ref('PG_helper/tblUser');

    dbRef.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null) return;

      final all = Map<String, dynamic>.from(data as Map);

      final students = all.entries.map((e) {
        final user = Map<String, dynamic>.from(e.value);
        return {
          'name': "${user['FirstName'] ?? ''} ${user['LastName'] ?? ''}".trim(),
          'contact': user['ContactNumber'] ?? '',
        };
      }).toList();

      setState(() {
        allStudents = students;
        _filterStudents();
        isLoading = false;
      });
    });
  }

  void _filterStudents() {
    final query = searchQuery.toLowerCase();
    filteredStudents = allStudents.where((student) {
      return student['name'].toLowerCase().contains(query);
    }).toList();
  }

  void _callStudent(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }

  void _messageStudent(String number) async {
    final Uri smsUri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch SMS app')),
      );
    }
  }

  void _openWhatsApp(String number) async {
    final Uri whatsappUri = Uri.parse("https://wa.me/$number");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WhatsApp not installed or number invalid')),
      );
    }
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final name = student['name'];
    final contact = student['contact'];
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade200,
          child: Text(firstLetter,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(contact),
        trailing: Wrap(
          spacing: 10,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _callStudent(contact),
            ),
            IconButton(
              icon: const Icon(Icons.message, color: Colors.blueAccent),
              onPressed: () => _messageStudent(contact),
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
              onPressed: () => _openWhatsApp(contact),
            ),

          ],
        ),
        onTap: () => _callStudent(contact), // Optional direct call on tap
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f6f7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // back button color
        title: const Text(
          "Students List",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                  _filterStudents();
                });
              },
            ),
          ),
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text("No students found."))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                return _buildStudentCard(filteredStudents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
