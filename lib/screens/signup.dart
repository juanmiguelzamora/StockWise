import 'package:flutter/material.dart';
import 'package:stock_wise/screens/login.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _Signup();
}



class _Signup extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _obscureText = true;

  final double logoHeight = 120;
  final double logoWidth = 120;


  //First Image Logo//
  Widget buildStockWiseLogo() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 12.0),
      child: Image.asset(
        'assets/stockwise_logo.png',
        height: logoHeight,
        width: logoWidth,
        fit: BoxFit.contain,
      ),
    );
  }


  //Second Image Logo//
  Widget buildSignup() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Center(
        child: Image.asset(
          'assets/signup_second_logo.png',
          height: logoHeight,
          width: logoWidth,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

//Welcome TextField// Create a new account TextField//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildStockWiseLogo(),
          buildSignup(),

          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'Welcome',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(left: 16, top: 4),
            child: Text(
              'Create an new account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ),



          //Email container//Text Field//
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'JohnDoe@gmail.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),



          //Password container//Password Text Field//
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),


                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,

                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16,vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),





          //Confirm Password container// Confirm Password TextField//
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),


                const SizedBox(height: 10),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Confirm your Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16,vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),





          //Blue Signup button// Signup TextField//
          Center(
            heightFactor: 2,
            child: SizedBox(
              width: 380,
              height: 50,
              child: ElevatedButton(
                onPressed: () {


                  //Signup Logic where to go//



                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Signup',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),




          //Already have an account TextField// Login TextField//
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account',
                style: TextStyle(
                  height: 5,
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () {


                  //Logic that go to Login//
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );




                },
                child: Text(
                  " Login",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),








        ],
      ),
    );
  }




}