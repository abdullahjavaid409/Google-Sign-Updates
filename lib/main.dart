import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Google Sign Update'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pressedGoogleSignIn,
              child: Text("Google Sign In"),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: _pressSignOut,
              child: Text("Google Sign Out"),
            ),
          ],
        ),
      ),
    );
  }

  void _pressedGoogleSignIn() async {
    await AuthRepo().signInWithGoogle();
  }

  _pressSignOut() async {
    await AuthRepo().signOut();
  }
}

class AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignIn _google() => GoogleSignIn(scopes: ['email']);

  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('[Auth] 🔵 Google sign-in started');

      final googleAccount = await _google().signIn();
      if (googleAccount == null) {
        debugPrint('[Auth] 🟡 Google sign-in cancelled');
        return null;
      }
      debugPrint('[Auth] ✅ Google account: ${googleAccount.email}');

      final googleTokens = await googleAccount.authentication;
      if (googleTokens.accessToken == null) {
        debugPrint('[Auth] 🔴 Google idToken missing');
        throw Exception('google_id_token_missing');
      }

      debugPrint('[Auth] 🔵 Firebase credential build');
      final credential = GoogleAuthProvider.credential(
        idToken: googleTokens.idToken,
        accessToken: googleTokens.accessToken,
      );

      debugPrint('[Auth] 🔵 Firebase sign-in');
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        debugPrint('[Auth] 🔴 Firebase user null');
        throw Exception('firebase_user_null');
      }

      debugPrint('[Auth] ✅ Logged in UID: ${user.uid}');
      return user;
    } catch (err, trace) {
      debugPrint('[Auth] 🔴 Error: $err');
      debugPrint('[Auth] 🔴 Stack: $trace');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('[Auth] 🔵 Sign-out started');
      await _google().signOut();
      await _auth.signOut();
      debugPrint('[Auth] ✅ Sign-out completed');
    } catch (err) {
      debugPrint('[Auth] 🔴 Sign-out failed: $err');
    }
  }
}
