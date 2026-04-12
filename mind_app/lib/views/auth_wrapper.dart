import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'login_view.dart';
import 'main_tab_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF3AAFFF);
    final Color spinnerColor = isDark ? const Color(0xFF3AAFFF) : Colors.white;

    return StreamBuilder<firebase.User?>(
      stream: firebase.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: CircularProgressIndicator(color: spinnerColor),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated, need to fetch their profile data
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: bgColor,
                  body: Center(
                    child: CircularProgressIndicator(color: spinnerColor),
                  ),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                
                // Add token explicitly since fromJson expects it 
                // (though in Firebase flow we don't strictly require it natively)
                userData['token'] = 'firebase_token';
                userData['id'] = snapshot.data!.uid;

                final user = User.fromJson(userData);
                return MainTabView(user: user);
              }

              // Failed to load user profile or it doesn't exist
              firebase.FirebaseAuth.instance.signOut();
              return const LoginView();
            },
          );
        }

        // Not authenticated
        return const LoginView();
      },
    );
  }
}
