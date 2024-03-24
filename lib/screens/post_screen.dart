import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qiita_search/models/post-article.dart';
import 'package:qiita_search/widgets/post_article_container.dart';

class PostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('articles')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts yet'));
          }
          List<QueryDocumentSnapshot> reversedDocs =
              snapshot.data!.docs.reversed.toList();
          return ListView.builder(
            itemCount: reversedDocs.length,
            itemBuilder: (context, index) {
              final postArticle =
                  PostArticle.fromFirestore(reversedDocs[index]);
              final article = postArticle;
              return PostArticleContainer(article: article);
            },
          );
        },
      ),
    );
  }
}
