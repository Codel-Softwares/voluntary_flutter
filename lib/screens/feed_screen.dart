// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
//import '../widgets/post_view.dart'; 
import '../screens/PostDetailScreen.dart'; // <--- Importe a NOVA tela de detalhes

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      setState(() {
        _loading = true;
      });
      // Certifique-se de ordenar pelo campo de data/hora que você usa
      final QuerySnapshot snapshot = await _firestore.collection('posts').orderBy('createdAt', descending: true).get();
      setState(() {
        _posts = snapshot.docs.map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        _loading = false;
      });
    } catch (e) {
      print("Erro ao carregar posts: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      fetchPosts(); // Recarrega os posts após a exclusão
    } catch (e) {
      print("Erro ao deletar post: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao deletar post: $e")));
    }
  }

  Future<void> _toggleLike(Post post) async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Você precisa estar logado para curtir.")));
      return;
    }

    final String currentUserId = _auth.currentUser!.uid;
    final DocumentReference postRef = _firestore.collection('posts').doc(post.id);

    try {
      // Verifica se o usuário já curtiu
      if (post.likedBy.contains(currentUserId)) {
        // Descurtir: remover o usuário da lista e decrementar likes
        await postRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        // Curtir: adicionar o usuário à lista e incrementar likes
        await postRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([currentUserId]),
        });
      }
      fetchPosts(); // Recarrega os posts para refletir a mudança de like
    } catch (e) {
      print("Erro ao dar/tirar like: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao curtir/descurtir: $e")));
    }
  }

  void _navigateToComments(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post), // <--- Agora aponta para a NOVA tela
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      // Caso não haja usuário logado, você pode redirecionar para a tela de login
      // Ou mostrar uma mensagem e um botão de login.
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Você precisa estar logado para ver o feed."),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login'); // Ou sua rota de login
                },
                child: Text("Fazer Login"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Feed de Posts"),
        backgroundColor: Colors.blueAccent, // Ou sua cor de tema
        actions: [
          /*IconButton(
            icon: Icon(Icons.add_box_outlined), // Ícone para criar novo post
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostView()), // Navega para a tela de CRIAÇÃO de post
              ).then((_) => fetchPosts()); // Recarrega posts ao voltar da criação
            },
          ),*/
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              // Navegue para a tela de login ou a tela inicial
              Navigator.of(context).pushReplacementNamed('/login'); // Assumindo rota '/login'
            },
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(child: Text("Nenhum post encontrado. Que tal criar um?"))
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final Post post = _posts[index];
                    return PostCard(
                      post: post,
                      currentUserUid: currentUser.uid,
                      onDelete: () => _deletePost(post.id),
                      onLike: () => _toggleLike(post),
                      onComment: () => _navigateToComments(post),
                    );
                  },
                ),
    );
  }
}