import 'package:flutter/material.dart';
import 'package:stock_wise/screens/signup.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool RemmeberMe = false;
  bool _obscureText = true;

  //First Image Logo//
  Widget buildStockWiseLogo(double logoHeight, double logoWidth) {
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
  Widget buildTabletImage(double logoHeight, double logoWidth) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Center(
        child: Image.asset(
          'assets/tablet_login_picture.png',
          height: logoHeight,
          width: logoWidth,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width * 0.05;
    final double logoHeight = screenSize.height * 0.15;
    final double logoWidth = screenSize.width * 0.3;
    final double buttonWidth = screenSize.width * 0.9;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.height * 0.04),
              buildStockWiseLogo(logoHeight, logoWidth),
              buildTabletImage(logoHeight, logoWidth),

              Padding(
                padding: EdgeInsets.only(top: screenSize.height * 0.02),
                child: Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.09,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: screenSize.height * 0.005),
                child: Text(
                  'Please enter your details to login.',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.045,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ),

              //Email Text and Container//
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: screenSize.height * 0.012),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'JohnDoe@gmail.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.04,
                          vertical: screenSize.height * 0.018,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),

              //Password and Forget Password//
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Forget password logic
                        },
                        child: const Text(
                          'Forget Password',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenSize.height * 0.008),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: 'Enter your Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.04,
                        vertical: screenSize.height * 0.018,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.012),
                  Row(
                    children: [
                      Checkbox(
                        value: RemmeberMe,
                        onChanged: (value) {
                          setState(() {
                            RemmeberMe = value!;
                          });
                        },
                      ),
                      const Text("Remember Me"),
                    ],
                  ),

                  Center(
                    heightFactor: 2,
                    child: SizedBox(
                      width: buttonWidth,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Signup()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Dont have an account?',
                        style: TextStyle(
                          height: 5,
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Signup()),
                          );
                        },
                        child: const Text(
                          " Register",
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
            ],
          ),
        ),
      ),
    );
  }
}