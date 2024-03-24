import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qiita_search/screens/search_screen.dart';
import 'package:qiita_search/screens/post_screen.dart';

class LoginShow extends StatefulWidget {
  const LoginShow({
    Key? key
    }) : super(key: key);

  @override
  State<LoginShow> createState() => _LoginShow();
}

class _LoginShow extends State<LoginShow> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (_isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.emailVerified) {
          return Scaffold(
            body: Center(
              child: Expanded(child: PostScreen())
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 300,
                    height: 50,
                    child: Text('ログイン',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'メールアドレスを入力...',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'パスワードを入力...',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _login();
                    },
                    child: const Text('ログイン'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _register();
                    },
                    child: const Text('新規登録'),
                  ),
                  TextButton(
                    child: const Text('パスワードリセット'),
                    onPressed: () async {
                      _resetPassword();
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (FirebaseAuth.instance.currentUser?.emailVerified == false) {
        await FirebaseAuth.instance.currentUser!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('認証が完了していません。認証メールを再送信しました'),
          ),
        );
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen()),
      );

    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.code);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('認証メールを送信しました'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.code);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('パスワードリセット用のメールを送信しました'),
        ),
      );
    } on FirebaseException catch (e) {
      print(e.code);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String errorCode) {
    setState(() {
      _isLoading = false;
    });
    switch (errorCode) {
      case 'invalid-email':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('そのメールアドレスは使えません'),
          ),
        );
        break;
      case 'user-disabled':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('そのメールアドレスは無効化されています'),
          ),
        );
        break;
      case 'too-many-requests':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('試行回数が制限を超えました'),
          ),
        );
        break;
      case 'invalid-credential':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('メールアドレスまたはパスワードが間違っています'),
          ),
        );
        break;
      case 'email-already-in-use':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('そのメールアドレスは既に使用されています'),
          ),
        );
        break;
      case 'operation-not-allowed':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('メール、パスワードでの認証が許可されていません'),
          ),
        );
        break;
      case 'weak-password':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('パスワードが簡単すぎます'),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('エラーが発生しました'),
          ),
        );
        break;
    }
  }
}
