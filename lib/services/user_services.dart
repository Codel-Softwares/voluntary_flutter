import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String nomeUsuario;
  final String imagemPerfil;
  final String? tipoPerfil;

  UserProfile({
    required this.nomeUsuario,
    required this.imagemPerfil,
    this.tipoPerfil,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      nomeUsuario: data['nomeUsuario'] ?? '',
      imagemPerfil: data['imagemPerfil'] ?? '',
      tipoPerfil: data['tipoPerfil'],
    );
  }
}

Future<UserProfile?> getUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!doc.exists) return null;

  return UserProfile.fromMap(doc.data()!);
}
