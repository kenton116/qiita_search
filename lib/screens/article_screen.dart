import 'package:flutter/material.dart';
import 'package:qiita_search/models/article.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late WebViewController controller;
  final TextEditingController _textFieldController = TextEditingController();
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(widget.article.url),
      );
  }

  void addData(BuildContext context, String comment) async {
    try {
      await firestore.collection('articles').add({
        'title': widget.article.title,
        'createdAt': widget.article.createdAt,
        'tags': widget.article.tags,
        'likesCount': widget.article.likesCount.toString(),
        'userImage': widget.article.user.profileImageUrl,
        'userId': widget.article.user.id,
        'url': widget.article.url,
        'comment': comment,
        'postUserEmail': user!.email,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('投稿しました'),
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _showDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('コメントを追加'),
          content: TextField(
            controller: _textFieldController,
            maxLines: 3,
            maxLength: 180,
            decoration: const InputDecoration(hintText: "コメントを入力してください"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('投稿'),
              onPressed: () {
                addData(context, _textFieldController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      actions: [
  StreamBuilder(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasData) {
        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton.icon(
            label: const Text('投稿'),
            icon: const Icon(Icons.send),
            onPressed: () => _showDialog(context),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton.icon(
            label: const Text('投稿'),
            icon: const Icon(Icons.send),
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
          ),
        );
      }
    },
  )
],

    ),
    body: WebViewWidget(controller: controller),
  );
}
}
