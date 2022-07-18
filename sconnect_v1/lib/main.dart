import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sconnect_v1/providers/user_provider.dart';
import 'package:sconnect_v1/screens/home_or_username_screen.dart';
import 'package:sconnect_v1/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sconnect_v1/screens/no_internet_screen.dart';
import 'package:sconnect_v1/widgets/snackbar.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAzi9gq-bTleVcfzoUJg8hA0koC0YVTpeI",
        appId: "1:701608064897:web:c10c955c138dde95a41a80",
        messagingSenderId: "701608064897",
        projectId: "sconnect-aca0c",
        storageBucket: "sconnect-aca0c.appspot.com",
        authDomain: "sconnect-aca0c.firebaseapp.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<ConnectivityResult> _connectionStream =
      Connectivity().onConnectivityChanged;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'SConnect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return HomeorUsernameScreen(id: _auth.currentUser!.uid);
              }
              if (snapshot.hasError) {
                snackBar(context, snapshot.error.toString());
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.white,
                ),
              );
            }
            return LoginScreen();
          },
        ),
      ),
    );
  }
}
