// lib/widgets/post_card.dart
import 'package:flutter/material.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String currentUserUid;
  final VoidCallback onDelete;
  final VoidCallback onLike;      // Novo: Callback para quando o botão de like é pressionado
  final VoidCallback onComment;   // Novo: Callback para quando o botão de comentário é pressionado

  const PostCard({
    required this.post,
    required this.currentUserUid,
    required this.onDelete,
    required this.onLike,    // Requerido no construtor
    required this.onComment, // Requerido no construtor
  });

  @override
  Widget build(BuildContext context) {
    // Verifica se o usuário atual já curtiu o post para mudar o ícone
    final bool hasLiked = post.likedBy.contains(currentUserUid);

    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha o conteúdo à esquerda
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.userProfileImage.isNotEmpty
                  ? post.userProfileImage
                  : 'https://via.placeholder.com/50'),
            ),
            title: Text(post.username),
            subtitle: Text("#${post.tipoPerfil}"),
            trailing: post.userUid == currentUserUid
                ? IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  )
                : null,
          ),
          if (post.imageUrl.isNotEmpty)
            Image.network(
              post.imageUrl,
              width: double.infinity, // Ocupa a largura total do cartão
              fit: BoxFit.cover,       // Garante que a imagem preencha o espaço sem distorcer
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(post.description),
          ),
          // Seção de botões de interação (Like e Comentário)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribui os elementos horizontalmente
              children: [
                // Botão de Like e contador
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        hasLiked ? Icons.favorite : Icons.favorite_border, // Ícone preenchido se curtiu
                        color: hasLiked ? Colors.red : Colors.grey,       // Cor vermelha se curtiu
                      ),
                      onPressed: onLike, // Chama o callback onLike
                    ),
                    Text('${post.likes} Likes'), // Mostra o número de likes
                  ],
                ),
                // Botão de Comentários
                IconButton(
                  icon: Icon(Icons.comment_outlined),
                  onPressed: onComment, // Chama o callback onComment
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}