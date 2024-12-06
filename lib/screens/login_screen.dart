import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();

  // セッション状態を削除する静的メソッド
  static Future<void> removeState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('remember_me');
    prefs.remove('email');
    prefs.remove('password');
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isRememberMeChecked = false;
  bool _isRegisterMode = false; // 登録モードかログインモードかを制御するフラグ

  @override
  void initState() {
    super.initState();
    _loadRememberMe(); // 保存されたセッション情報をロード
  }

  // 保存されたセッション情報をロード
  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRememberMeChecked = prefs.getBool('remember_me') ?? false;
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    });

    // 保存されたセッション情報がある場合、自動ログインを試行
    if (_isRememberMeChecked && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      _autoSignIn();
    }
  }

  // セッション情報を保存
  Future<void> _saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('remember_me', value);

    if (value) {
      prefs.setString('email', _emailController.text);
      prefs.setString('password', _passwordController.text);
    } else {
      prefs.remove('email');
      prefs.remove('password');
    }
  }

  // 自動ログインを試行
  Future<void> _autoSignIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()), // ログイン成功後にホーム画面へ遷移
      );
    } catch (e) {
      print('自動ログインに失敗しました: $e');
    }
  }

  // ログイン処理
  Future<void> _signInWithEmailAndPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // ログイン成功時、セッション情報を保存または削除
      if (_isRememberMeChecked) {
        _saveRememberMe(true);
      } else {
        _saveRememberMe(false);
      }

      // ホーム画面へ遷移
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        // パスワードが間違っている場合
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('パスワードが間違っています。')),
        );
      } else if (e.code == 'user-not-found') {
        // ユーザーが存在しない場合
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('このメールアドレスのアカウントは存在しません。')),
        );
      } else {
        // その他のFirebaseAuthエラー
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: ${e.message}')),
        );
      }
    } catch (e) {
      // その他のエラー処理
      print('エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインに失敗しました: $e')),
      );
    }
  }

  // 新規登録処理
  Future<void> _registerWithEmailAndPassword() async {
    try {
      // メールアドレスとパスワードで新しいアカウントを作成
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // 作成したユーザーのプロファイルを更新
      User? user = userCredential.user;
      await user?.updateDisplayName(_nameController.text);
      await user?.reload();
      user = _auth.currentUser;

      // セッション情報を保存または削除
      if (_isRememberMeChecked) {
        _saveRememberMe(true);
      } else {
        _saveRememberMe(false);
      }

      // ホーム画面へ遷移
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // すでに登録されているメールアドレスの場合
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('このユーザーは既に存在します。')),
        );
      } else {
        // その他のFirebaseAuthエラー
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    } catch (e) {
      // その他のエラー処理
      print('エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登録に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? '新規登録' : 'ログイン'), // モードに応じてタイトルを変更
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 登録モード時のみ名前フィールドを表示
            if (_isRegisterMode)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '名前'),
              ),
            if (_isRegisterMode)
              SizedBox(height: 20), // 登録モード時のフィールド間のスペース

            // メールアドレス入力フィールド
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
            ),
            SizedBox(height: 20),

            // パスワード入力フィールド
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true, // パスワードを非表示に
            ),
            SizedBox(height: 20),

            // 登録またはログインボタン
            ElevatedButton(
              onPressed: _isRegisterMode
                  ? _registerWithEmailAndPassword // 登録処理を実行
                  : _signInWithEmailAndPassword,   // ログイン処理を実行
              child: Text(_isRegisterMode ? 'メールで登録' : 'メールでログイン'),
            ),
            SizedBox(height: 20),

            // モード切替ボタン
            TextButton(
              onPressed: () {
                setState(() {
                  _isRegisterMode = !_isRegisterMode; // モードを切り替え
                });
              },
              child: Text(_isRegisterMode
                  ? '既にアカウントをお持ちですか？ログイン'
                  : 'アカウントをお持ちでない方はこちら'),
            ),

            SizedBox(height: 20),

            // セッションを保存するチェックボックス
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('セッションを保存'),
                Checkbox(
                  value: _isRememberMeChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isRememberMeChecked = value!;
                    });
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}