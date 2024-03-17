import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginShow extends StatefulWidget {
  const LoginShow({super.key});

  @override
  State<LoginShow> createState() => _LoginShow();
}

class _LoginShow extends State<LoginShow> {
  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();

    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ログインしました',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        child: const Text('ログアウト'))
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: email,
                        decoration: InputDecoration(
                            labelText: 'メールアドレスを入力してください',
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: password,
                        decoration: InputDecoration(
                            labelText: 'パスワードを入力してください',
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: email.text, password: password.text);
                        } on FirebaseAuthException catch (e) {
                          print('エラー: ${e.code}');
                          if (e.code == 'invalid-email') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('そのメールアドレスは使えません'),
                              ),
                            );
                          } else if (e.code == 'user-disabled') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('そのメールアドレスは無効化されています'),
                              ),
                            );
                          } else if (e.code == 'too-many-requests') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('試行回数が制限を超えました'),
                              ),
                            );
                          } else if (e.code == 'invalid-credential') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('メールアドレスまたはパスワードが間違っています'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text('ログイン')
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: email.text, password: password.text);
                          } on FirebaseAuthException catch (e) {
                            print('エラー: ${e.code}');
                            if (e.code == 'email-already-in-use') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('そのメールアドレスは既に使用されています'),
                                ),
                              );
                            } else if (e.code == 'invalid-email') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('そのメールアドレスは使用できません'),
                                ),
                              );
                            } else if (e.code == 'operation-not-allowed') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('メール、パスワードでの認証が許可されていません'),
                                ),
                              );
                            } else if (e.code == 'weak-password') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('パスワードが簡単すぎます'),
                                ),
                              );
                            }
                          }
                        },
                        child: Text('新規登録')
                    ),
                  TextButton(
                    child: const Text('パスワードリセット'),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('パスワードリセット用のメールを送信しました'),
                          ),
                        );
                      } on FirebaseException catch (e) {
                        print(e.code);
                      }
                  }),
                  ],
                ),
              ),
            );
          }
        });
  }
}
