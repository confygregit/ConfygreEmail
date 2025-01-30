import 'package:flutter/material.dart';
import '../components/GlobalVariables.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
    // getProfileInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            ProfileField(label: 'Email', value: userEmail.toString()),
            ProfileField(label: 'Username', value: userName.toString()),
            // ProfileField(label: 'Created At', value: '2023-01-01'),
            ProfileField(label: 'Available Clicks', value: '∞'),
            ProfileField(label: 'Membership', value: membershipType.toString()),
            ProfileField(label: 'Total Unsubscribed', value: totalUnsubscribedEmails.toString()),
            ProfileField(label: 'Total Deleted', value: totalDeletedEmails.toString()),
            // ProfileField(label: 'AccessToken', value: userAccessToken.toString()),
            // ProfileField(label: 'IdToken', value: userIdToken.toString()),
            Spacer(), // Pushes the button to the bottom
            // Center(
            //   child: GestureDetector(
            //     onTap: () {
            //       // Handle account deletion
            //       showDialog(
            //         context: context,
            //         builder: (context) => AlertDialog(
            //           title: Text('Delete Account'),
            //           content: Text(
            //               'Are you sure you want to delete your account? This action cannot be undone.'),
            //           actions: [
            //             TextButton(
            //               onPressed: () {
            //                 Navigator.pop(context); // Close the dialog
            //               },
            //               child: Text(
            //                 'Cancel',
            //                 style: TextStyle(color: Colors.black),
            //               ),
            //             ),
            //             ElevatedButton(
            //               onPressed: () {
            //                 // Implement delete account logic
            //                 // Navigator.pop(context); // Close the dialog
            //                 try{
            //                   deleteAccount();
            //                   googleSignIn.signOut();
            //                   objectBox?.removeUserCredential();
            //                   Supabase.instance.client.auth.signOut();
            //                   gettingEmails = false;
            //                   Future.delayed(Duration(seconds: 1), () {
            //                     Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            //                   });
            //                 } catch (ex) {
            //                   print(ex);
            //                 }
            //               },
            //               child: Text(
            //                 'Delete',
            //                 style: TextStyle(color: Colors.white),
            //               ),
            //               style: ElevatedButton.styleFrom(
            //                 backgroundColor: Colors.red,
            //               ),
            //             ),
            //           ],
            //         ),
            //       );
            //     },
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: Colors.red,
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Padding(
            //         padding: const EdgeInsets.all(15.0),
            //         child: Text(
            //             'Delete Account',
            //           style: TextStyle(
            //               color: Colors.white,
            //             fontSize: 15,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// Widget to display a profile field
class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
