import 'package:flutter/material.dart';
import 'package:footnet/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePictureScreen extends StatefulWidget {
  final Function(String) onPictureSelected;

  ProfilePictureScreen({required this.onPictureSelected});

  @override
  _ProfilePictureScreenState createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<dynamic> _players = [];
  bool _isLoading = false;

  // APIを使って選手を検索
  Future<void> _searchPlayers(String query) async {
    setState(() {
      _isLoading = true;
      _players = [];
    });

    const String apiUrl = 'https://v3.football.api-sports.io/players/profiles';
    String apiKey = _apiService.apiKey;

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?search=$query'),
        headers: {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': 'v3.football.api-sports.io',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> filteredPlayers = data['response']
            .where((player) =>
                player['player'] != null && player['player']['id'] != null)
            .toList();

        setState(() {
          _players = filteredPlayers;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データ取得エラー: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('選手検索エラー: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール画像の選択'),
        backgroundColor: Colors.amber,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '選手を検索',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.trim().length >= 3) {
                      _searchPlayers(_searchController.text.trim());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('3文字以上入力してください')),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _players.isEmpty
                        ? Center(child: Text('選手が見つかりませんでした'))
                        : ListView.builder(
                            itemCount: _players.length,
                            itemBuilder: (context, index) {
                              final player = _players[index]['player'];
                              final photoUrl =
                                  'https://media.api-sports.io/football/players/${player['id']}.png';
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(photoUrl),
                                ),
                                title: Text(player['name'] ?? '名前不明'),
                                subtitle: Text(player['birth']['date'] ?? '生年月日不明'),
                                onTap: () {
                                  widget.onPictureSelected(photoUrl);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}