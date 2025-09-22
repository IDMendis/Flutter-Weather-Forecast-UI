import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFA500), // Orange
              const Color(0xFF8A2BE2).withOpacity(0.6), // Purple
              const Color(0xFF000000), // Black
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Timezone, greet and more icon in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Timezone and greet in a RichText
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.openSans(height: 1.1),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'GMT\n',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w100,
                            color: const Color(0xFFFFFFFF).withOpacity(0.7),
                          ),
                        ),

                        //greet-----------
                        TextSpan(
                          text: 'Good Afternoon!',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                          )
                        )
                      ],
                    ),
                  ),


                  //container 
                  Container(
                    padding: const EdgeInsets.all(2.0),
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.0),
                      border: Border.all(
                        width: 0.4,
                        color: Color(0xFFFFFFFF),
                      )
                    ),

                    //more icons
                    child: Icon(
                      Icons.more_vert_outlined,
                      color: Color(0xFFFFFFFF) ,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage(
                      "assets/images/sunny.png"
                    ),
                    )
                  ),
                ),
              ),


              // temperature, humidity date and time

              Padding(padding: const EdgeInsets.only(top: 16.0),
               child:  RichText(
                    text: TextSpan(
                      style: GoogleFonts.openSans(height: 1.1),
                      children: <TextSpan>[
                        TextSpan(
                          text: '36C\n',
                          style: TextStyle(
                            fontSize: 75.0,
                            fontWeight: FontWeight.w100,
                            color: const Color(0xFFFFFFFF).withOpacity(0.7),
                          ),
                        ),

                        //temperature
                        TextSpan(
                          text: 'Humidity: 20%\n',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                         TextSpan(
                          text: 'Tuesday, 12:00 PM',
                          style: TextStyle(
                            fontSize: 14.0,
                          
                            color: const Color(0xFFFFFFFF).withOpacity(0.7),
                          )
                        )                      ],
                    ),
                  ),


              ),
            ],
          ),
        ),
      ),
    );
  }
}
