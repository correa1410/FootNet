import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:footnet/services/api_service.dart';

class LiveDataScreen extends StatefulWidget {
  @override
  _LiveDataScreenState createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  late WebViewController _controller;
  final ApiService _apiService = ApiService();

  // Variable para manejar la fecha
  DateTime selectedDate = DateTime.now();

  // Función para generar el HTML dinámicamente
  Future<String> _getHtmlWithDate(String date) async {
    String cssContent = await DefaultAssetBundle.of(context)
        .loadString('assets/api-football.css');
    String htmlContent = '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Widget Personalizado</title>
        <style>
          $cssContent
        </style>
      </head>
      <body>
        <div id="wg-api-football-fixtures"
            data-host="v3.football.api-sports.io"
            data-refresh="60"
            data-date="$date" 
            data-key="${_apiService.apiKey}" 
            data-theme="false"
            data-modal-standings="true"
            data-show-errors="false"
            class="api_football_loader">
        </div>
        <script
            type="module"
            src="https://widgets.api-sports.io/football/1.1.8/widget.js">
        </script>
      </body>
    </html>
    ''';
    return htmlContent;
  }

  // Función para recargar el WebView con la fecha seleccionada
  void _loadMatches(DateTime date) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date); // Formato requerido
    String htmlContent = await _getHtmlWithDate(formattedDate);
    _controller.loadUrl(
      Uri.dataFromString(htmlContent, mimeType: 'text/html', encoding: utf8).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de control para cambiar la fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.subtract(Duration(days: 1)); // Retrocede un día
                  });
                  _loadMatches(selectedDate); // Recarga el WebView
                },
              ),
              Text(
                DateFormat('yyyy-MM-dd').format(selectedDate), // Muestra la fecha seleccionada
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.add(Duration(days: 1)); // Avanza un día
                  });
                  _loadMatches(selectedDate); // Recarga el WebView
                },
              ),
            ],
          ),
          // WebView para mostrar los partidos
          Expanded(
            child: WebView(
              initialUrl: '',
              onWebViewCreated: (WebViewController webViewController) async {
                _controller = webViewController;
                _loadMatches(selectedDate); // Carga inicial con la fecha actual
              },
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
        ],
      ),
    );
  }
}
