import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:footnet/screens/match_screen.dart';
import 'package:footnet/screens/news_screen.dart';
import 'package:footnet/screens/login_screen.dart';
import 'package:footnet/screens/profile_screen.dart';
import 'live_data_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _initial = 'N';
  String? _photoUrl;
  User? _user;

  static List<Widget> _widgetOptions = <Widget>[
    NewsScreen(),
    LiveDataScreen(),
    MatchScreen(),
    Text('Quiz', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar los datos del usuario desde Firebase
  void _loadUserData() {
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      String? userName = _user?.displayName;
      setState(() {
        _initial = (userName != null && userName.isNotEmpty)
            ? userName.substring(0, 1).toUpperCase()
            : 'N';
        _photoUrl = _user?.photoURL;
      });
    }
  }

  // Método para manejar la navegación en el BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to FootNet'),
        leading: GestureDetector(
          onTap: () async {
            // Navegamos al ProfileScreen y esperamos hasta que se cierre
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  onPictureSelected: (String photoUrl) {
                    setState(() {
                      _photoUrl = photoUrl;
                    });
                  },
                ),
              ),
            );

            // Recargar datos del usuario después de volver del ProfileScreen
            _loadUserData();
          },
          child: CircleAvatar(
            backgroundColor: Colors.red,
            backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
            child: _photoUrl == null
                ? Text(
                    _initial,
                    style: TextStyle(color: Colors.white),
                  )
                : null,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await LoginScreen.removeState();
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            backgroundColor: Colors.amber[500],
            label: 'ニュース',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: '試合情報',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'トーナメント',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'クイズ',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onItemTapped,
      ),
    );
  }
}