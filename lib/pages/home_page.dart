import 'package:flutter/material.dart';
import '../components/GlobalVariables.dart';
import '../components/bottom_nav_bar.dart';
import '../components/emails.dart';
import '../pages/app_settings_page.dart';
import '../pages/error_page.dart';
import '../pages/history_page.dart';
import '../pages/login_page.dart';
import '../pages/profile_page.dart';
import '../pages/tiles_page.dart';
import '../components/gmail_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0;
  String pageTile = "Home";

  void navigationBottomBar(int index) async {

    // if(index == 3)
    //   await getProfileInfo();

    setState(() {
      _selectedIndex = index;

      switch(index){
        case 0:
          pageTile = "Home";
          break;
        case 1:
          pageTile = "History";
          break;
        case 2:
          pageTile = "App Settings";
          break;
        case 3:
          pageTile = "Profile";
          break;
      }

    });
  }

  final List<Widget> _pages = [
    const Tiles(),
    const HistoryPage(),
    const AppSettings(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          pageTile,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
            builder: (context) => IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Icon(Icons.menu),
                ))) ,
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage())),
                child: const Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text('Home', style: TextStyle(color: Colors.white, fontSize: 25),),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  String url = "https://google.com/";
                  try{
                    Uri uri = Uri.parse(url);
                    await launchUrl(
                      uri, mode: LaunchMode.externalApplication,
                    );
                  } catch (ex) {
                    print(ex);
                  }
                },
                child: const Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text('FAQ', style: TextStyle(color: Colors.white, fontSize: 25),),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  String url = "https://google.com/";
                  try{
                    Uri uri = Uri.parse(url);
                    await launchUrl(
                    uri, mode: LaunchMode.externalApplication,
                    );
                  } catch (ex) {
                    print(ex);
                  }
                },
                child: const Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text('Report an issue', style: TextStyle(color: Colors.white, fontSize: 25),),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  String url = "https://google.com/";
                  try{
                    Uri uri = Uri.parse(url);
                    await launchUrl(
                    uri, mode: LaunchMode.externalApplication,
                    );
                  } catch (ex) {
                    print(ex);
                  }
                },
                child: const Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text('About us', style: TextStyle(color: Colors.white, fontSize: 25),),
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () => Navigator.push(context,
              //       MaterialPageRoute(builder: (context) => ErrorPage())),
              //   child: const Padding(
              //     padding: const EdgeInsets.only(left: 25.0),
              //     child: ListTile(
              //       title: Text('Error Page', style: TextStyle(color: Colors.white, fontSize: 25),),
              //     ),
              //   ),
              // ),
              GestureDetector(
                onTap: () {
                },
                child: const Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text('Test', style: TextStyle(color: Colors.white, fontSize: 25),),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  try{
                    googleSignIn.signOut();
                    objectBox?.removeUserCredential();
                    gettingEmails = false;
                    Future.delayed(Duration(seconds: 1), () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    });
                  } catch (ex) {
                    print(ex);
                  }
                },
                child: const Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text('Log out', style: TextStyle(color: Colors.redAccent, fontSize: 25),),
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () {
              //     // DateTime testTime = DateTime.now().toUtc().add(Duration(days: 60));
              //     // insertMembershipData("test@test.com", "Free", testTime);
              //     checkIfEmailExists("test1@test.com");
              //   },
              //   child: const Padding(
              //     padding: const EdgeInsets.only(left: 25.0),
              //     child: ListTile(
              //       title: Text('test', style: TextStyle(color: Colors.redAccent, fontSize: 25),),
              //     ),
              //   ),
              // )
            ],
          )
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigationBottomBar(index),
      ),
    );
  }
}
