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
  Widget buildTabletImage() {
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

    //Welcome Back TextField// Please enter your details to login TextField//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildStockWiseLogo(),
          buildTabletImage(),

          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(left: 16, top: 4),
            child: Text(
              'Please enter your details to login.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ),


          //Email Text and Container//
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
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

          //Password and Forget Password//
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
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


                        //Make Forget password logic where to go//


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

                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'Enter your Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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


                //Remember Me CheckBox// pero dko ma align sa container
                const SizedBox(height: 10),
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



                //Blue Login Button//
                Center(
                  heightFactor: 2,
                  child: SizedBox(
                    width: 520,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {


                        //Login Logic where to go//
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Signup()),
                        );



                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                          'Login',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),



                //Don't have an account TextField// Register TextField//
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Dont have an account?',
                      style: TextStyle(
                        height: 10,
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {


                        //Logic that go to signup//
                        Navigator.push(
                            context,
                          MaterialPageRoute(builder: (context) => const Signup()),
                        );




                      },
                      child: Text(
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
          ),
        ],
      ),
    );
  }
}