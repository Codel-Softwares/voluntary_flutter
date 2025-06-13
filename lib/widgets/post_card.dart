// lib/widgets/post_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String currentUserUid;
  final VoidCallback onDelete;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const PostCard({
    Key? key,
    required this.post,
    required this.currentUserUid,
    required this.onDelete,
    required this.onLike,
    required this.onComment,
  }) : super(key: key);

  // Função para buscar o nome do autor do post em tempo real.
  Future<String> _fetchAuthorName(String uid) async {
    if (uid.isEmpty) return 'Anônimo';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        // IMPORTANTE: Confirme que o campo do nome do usuário na sua coleção 'users'
        // no Firestore se chama 'name'. Se for outro nome (ex: 'nome'), ajuste aqui.
        return (doc.data() as Map<String, dynamic>)['name'] ?? 'Nome não disponível';
      }
      return 'Usuário desconhecido';
    } catch (e) {
      print('Erro ao buscar nome do usuário no PostCard: $e');
      // Como fallback, usa o nome que já estava salvo no post, se existir.
      if (post.authorName.isNotEmpty && post.authorName != 'Anônimo') {
        return post.authorName;
      }
      return 'Erro ao carregar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do Card com o nome do autor
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                  backgroundColor: Colors.black12,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FutureBuilder<String>(
                    future: _fetchAuthorName(post.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Carregando...", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey));
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Text(
                          snapshot.data!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        );
                      } else {
                        // Fallback caso o Future falhe ou não retorne dados
                        return Text(
                          post.authorName.isNotEmpty ? post.authorName : 'Anônimo',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                    },
                  ),
                ),
                if (post.uid == currentUserUid)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey[700]),
                    onPressed: onDelete,
                    tooltip: 'Excluir Post',
                  ),
              ],
            ),
          ),
          
          // Imagem do Post
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 250,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                    height: 250,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)
                );
              },
            ),

          // Descrição do Post
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(post.description),
          ),

          // Tags do Post
          if (post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: post.tags.map((tag) => Chip(label: Text(tag, style: TextStyle(fontSize: 12)), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact)).toList(),
              ),
            ),
          
          const Divider(height: 1, indent: 16, endIndent: 16),

          // Botões de Ação (Like, Comentário)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: Icon(
                    post.likedBy.contains(currentUserUid) ? Icons.favorite : Icons.favorite_border,
                    color: post.likedBy.contains(currentUserUid) ? Colors.red : Colors.grey[700],
                  ),
                  label: Text('${post.likes}'),
                  onPressed: onLike,
                ),
                TextButton.icon(
                  icon: Icon(Icons.comment_outlined, color: Colors.grey[700]),
                  label: Text('${post.comments.length}'),
                  onPressed: onComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}