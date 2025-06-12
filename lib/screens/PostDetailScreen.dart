// lib/screens/post_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/post.dart'; // Importe seu modelo Post

class PostDetailScreen extends StatefulWidget {
  final Post post; // Este widget AGORA espera um objeto Post

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // Você pode adicionar controladores para entrada de comentários aqui
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do Post"),
        backgroundColor: Colors.blueAccent, // Ou sua cor de tema
      ),
      body: Column(
        children: [
          // Informações do Post (já existentes do PostCard, mas em uma tela separada)
          Card(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(widget.post.userProfileImage.isNotEmpty
                        ? widget.post.userProfileImage
                        : 'https://via.placeholder.com/50'),
                  ),
                  title: Text(widget.post.username),
                  subtitle: Text("#${widget.post.tipoPerfil}"),
                ),
                if (widget.post.imageUrl.isNotEmpty)
                  Image.network(
                    widget.post.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.post.description),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 20),
                      SizedBox(width: 4),
                      Text('${widget.post.likes} Likes'),
                    ],
                  ),
                ),
                Divider(), // Separador para a seção de comentários
              ],
            ),
          ),
          // Seção de Comentários
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Substitua pelo número real de comentários do post
              itemBuilder: (context, index) {
                // Aqui você carregaria e exibiria os comentários do Firestore para este post
                // Por enquanto, é apenas um placeholder
                return ListTile(
                  leading: CircleAvatar(
                    child: Text("U${index + 1}"), // Placeholder para imagem de perfil do comentador
                  ),
                  title: Text("Comentador ${index + 1}"),
                  subtitle: Text("Este é um comentário de exemplo ${index + 1}."),
                );
              },
            ),
          ),
          // Campo para adicionar novo comentário
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Escreva um comentário...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    ),
                    maxLines: null, // Permite múltiplas linhas
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () {
                    // Lógica para enviar o comentário para o Firestore
                    print("Comentário enviado: ${_commentController.text}");
                    _commentController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}