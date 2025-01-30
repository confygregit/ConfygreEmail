import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'login_page.dart';

class IntroScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "",
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/intro1.jpg',
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        PageViewModel(
          title: "",
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/intro2.jpg',
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        PageViewModel(
          title: "",
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/intro3.jpg',
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ],
      onDone: () {
        // Navigate to the next screen
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      onSkip: () {
        // Skip directly to the home screen
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      showSkipButton: false,
      //skip: const Text("Skip"),
      next: const Icon(Icons.arrow_forward, color: Colors.black,),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
      dotsDecorator: DotsDecorator(
        activeColor: Colors.black, // Active dot color
        color: Colors.black.withOpacity(0.3), // Inactive dot color
        size: const Size(10.0, 10.0), // Inactive dot size
        activeSize: const Size(12.0, 12.0), // Active dot size
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ), // Shape of active dot
      ),
    );
  }
}
