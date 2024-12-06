import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:footnet/services/api_service.dart';

class MatchScreen extends StatefulWidget {
  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late WebViewController _controller;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _allLeagues = [];
  List<Map<String, dynamic>> _filteredLeagues = [];
  String _searchQuery = '';

  final List<int> _importantLeagueIds = [39, 140, 135, 78, 61, 2]; // 主要リーグとチャンピオンズリーグのID

  @override
  void initState() {
    super.initState();
    _loadLeagues();
  }

  void _loadLeagues() async {
    try {
      final leagues = await _apiService.getLeagues() as List<dynamic>;

      _allLeagues = leagues.cast<Map<String, dynamic>>();

      // 主要リーグだけをフィルタリングして初期表示
      _filteredLeagues = _allLeagues.where((league) {
        return _importantLeagueIds.contains(league['league']['id']);
      }).toList();

      setState(() {
        _isLoading = false;
      });

      _loadWebViewContent();
    } catch (e) {
      print("リーグの読み込み中にエラーが発生しました: $e");
    }
  }

  Future<String> _getHtmlContent() async {
    try {
      // CSSファイルの内容を読み込む
      String cssContent = await DefaultAssetBundle.of(context)
          .loadString('assets/api-football.css');

      // リーグリンクを生成
      String leagueLinks = _filteredLeagues.map((league) {
        final leagueId = league['league']['id'];
        final leagueName = league['league']['name'];
        final leagueLogo = league['league']['logo'];
        return '''
        <div style="display: flex; align-items: center; margin: 5px 0;">
          <img src="$leagueLogo" width="20" height="20" alt="$leagueName Logo" style="margin-right: 5px;">
          <a href="#" class="_link" data-league="$leagueId" style="text-decoration: none; color: #333; font-weight: bold;">$leagueName</a>
        </div>
        ''';
      }).join("");

      // HTMLコンテンツを作成
      return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>Leagues</title>
          <style>
            $cssContent
          </style>
        </head>
        <body>
          $leagueLinks
          <script>
            
          </script>
          <div id="wg-api-football-standings"
            data-host="v3.football.api-sports.io"
            data-key="${_apiService.apiKey}"
            data-league="${_filteredLeagues.isNotEmpty ? _filteredLeagues[0]['league']['id'] : ''}"
            data-season="2024"
            data-theme="true"
            data-show-errors="false"
            class="wg_loader">
          </div>
          <script type="module" src="https://widgets.api-sports.io/2.0.3/widgets.js"></script>
          <script>
            document.addEventListener('click', function (event) {
              if (!event.target.matches('._link')) return;
              event.preventDefault();

              let leagueId = event.target.getAttribute('data-league');
              let mainWidget = document.getElementById('wg-api-football-standings');
              mainWidget.setAttribute('data-league', leagueId);
              mainWidget.classList.add('wg_loader');
              mainWidget.innerHTML = '';
              window.document.dispatchEvent(new Event("DOMContentLoaded", {
                bubbles: true,
                cancelable: true
              }));
            });
          </script>
        </body>
      </html>
      ''';
    } catch (e) {
      print("HTML生成中にエラーが発生しました: $e");
      return '''
      <!DOCTYPE html>
      <html>
        <body>
          <h1>コンテンツの生成中にエラーが発生しました</h1>
        </body>
      </html>
      ''';
    }
  }

  void _loadWebViewContent() async {
    String htmlContent = await _getHtmlContent();
    _controller.loadUrl(
      Uri.dataFromString(htmlContent, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString(),
    );
  }

  void _filterLeagues(String query) {
    setState(() {
      _searchQuery = query;

      if (_searchQuery.isEmpty) {
        // 検索クエリが空の場合、主要リーグのみを表示
        _filteredLeagues = _allLeagues.where((league) {
          return _importantLeagueIds.contains(league['league']['id']);
        }).toList();
      } else {
        // 検索クエリでリーグをフィルタリング
        _filteredLeagues = _allLeagues.where((league) {
          final leagueName = league['league']['name'].toLowerCase();
          return leagueName.contains(query.toLowerCase());
        }).toList();
      }

      _loadWebViewContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'リーグを検索',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _filterLeagues,
                ),
              ),
              Expanded(
                child: WebView(
                  initialUrl: '',
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller = webViewController;
                    if (!_isLoading) {
                      _loadWebViewContent();
                    }
                  },
                  javascriptMode: JavascriptMode.unrestricted,
                ),
              ),
            ],
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
