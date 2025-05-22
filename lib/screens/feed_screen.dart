import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
//import '../services/user_service.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Post> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    final List<Post> posts = [];

    for (var doc in snapshot.docs) {
      final postData = doc.data();
      final userDoc = await _firestore.collection('usuarios').doc(postData['userUid']).get();
      final userData = userDoc.data() ?? {};

      posts.add(Post(
        id: doc.id,
        description: postData['description'],
        imageUrl: postData['imageUrl'],
        userUid: postData['userUid'],
        username: userData['nomeUsuario'] ?? 'Desconhecido',
        userProfileImage: userData['imagemPerfil'] ?? '',
        tipoPerfil: userData['tipoPerfil'] ?? 'Usuário',
        likes: postData['likes'] ?? 0,
        location: postData['location'],
      ));
    }

    setState(() {
      _posts = posts;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feed')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: _posts[index],
                  currentUserUid: _auth.currentUser!.uid,
                  onDelete: () => fetchPosts(),
                );
              },
            ),
    );
  }
}
