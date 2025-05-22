import 'package:flutter/material.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String currentUserUid;
  final VoidCallback onDelete;

  const PostCard({
    required this.post,
    required this.currentUserUid,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
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
            Image.network(post.imageUrl),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(post.description),
          ),
        ],
      ),
    );
  }
}
