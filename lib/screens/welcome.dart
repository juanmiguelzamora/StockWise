import 'package:flutter/material.dart';
import 'package:stock_wise/screens/login.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent, width: 2),
                ),
                child: Image.asset('assets/welcome.png',
                height: 350,
                fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Let's Get",
                  style: TextStyle(
                    height: 1.50,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),


              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Started",
                  style: TextStyle(
                    height: .40,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),


              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Everything works better together",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),


              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    //To do here is to add a navigation to the next screen okay mark

                    Navigator.push(
                        context,
                    MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Let's Go",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 50,)
            ],
          ),
          ),
      ),
    );
  }
}