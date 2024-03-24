import 'package:flutter/material.dart';
import 'package:qiita_search/models/post-article.dart';
import 'package:intl/intl.dart';
import 'package:qiita_search/screens/article_screen.dart';
import 'package:qiita_search/models/article.dart';

class PostArticleContainer extends StatelessWidget {
  const PostArticleContainer({
    Key? key,
    required this.article,
  }) : super(key: key);

  final PostArticle article;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            article.postUserEmail,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              article.comment,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8,),
        GestureDetector(
          onTap: () {
            final Article convertedArticle = article.toArticle();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => ArticleScreen(article: convertedArticle)),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('yyyy/MM/dd').format(article.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '#${article.tags.join(' #')}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(article.userImage),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      article.userId,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            color: Colors.grey,
            height: 30,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
