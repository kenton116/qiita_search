import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qiita_search/models/article.dart';
import '../widgets/article_container.dart';
import 'package:qiita_search/widgets/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _searchBoolean = false;
  List<Article> articles = [];
  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchArticles(query: '');
  }

  Widget _searchTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 36,
      ),
      child: TextField(
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          hintText: '検索ワードを入力...',
          hintStyle: TextStyle(
            color: Colors.white60,
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
        onSubmitted: (String value) async {
          setState(() {
            articles.clear();
            _page = 1;
            _isLoading = true;
          });
          await _fetchArticles(query: value);
        },
      ),
    );
  }

  Widget _articleShow() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              if (index == articles.length - 1) {
                _fetchArticles(query: ''); 
              }
              return ArticleContainer(article: articles[index]);
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _searchBoolean ? _searchTextField() : const Text('Qiita Search App'),
        actions: !_searchBoolean
    ? [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _searchBoolean = true;
                });
              },
            ),
            if (FirebaseAuth.instance.currentUser != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ログアウトしました'),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                  child: const Text('ログアウト'),
                ),
              ),
          ],
        ),
      ]
    : [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _searchBoolean = false;
            });
          },
        )
      ],
      ),
      body: _searchBoolean ? _articleShow() : const LoginShow(),
    );
  }

  Future<void> _fetchArticles({required String query}) async {
    final uri = Uri.https('qiita.com', '/api/v2/items', {
      'query': 'title:$query',
      'per_page': '10',
      'page': _page.toString(),
    });
    final String token = dotenv.env['QIITA_ACCESS_TOKEN'] ?? '';

    final http.Response res = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      final List<dynamic> body = jsonDecode(res.body);
      setState(() {
        articles.addAll(
            body.map((dynamic json) => Article.fromJson(json)).toList());
        _page++;
        _isLoading = false;
      });
    } else {
      print('Failed to load articles');
      _isLoading = false;
    }
  }
}
