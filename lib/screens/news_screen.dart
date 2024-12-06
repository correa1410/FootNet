// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:html/parser.dart' as html; // Importa el paquete para analizar HTML
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<Map<String, String>> _newsItems = [];

  @override
  void initState() {
    super.initState();
    _fetchRSSFeed();
  }

  Future<void> _fetchRSSFeed() async {
    final url = 'https://web.gekisaka.jp/feed?category=foreign';
    try {
      // Define los encabezados personalizados
      final headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
      };

      // Realiza la solicitud con los encabezados
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        
        // Usa Future.wait para manejar una lista de futures
        final newsItems = await Future.wait(items.map((item) async {
          final title = item.findElements('title').single.text;
          final link = item.findElements('link').single.text;
          final pubDate = item.findElements('pubDate').isNotEmpty
              ? item.findElements('pubDate').single.text
              : '';
          final creator = item.findElements('dc:creator').isNotEmpty
              ? item.findElements('dc:creator').single.text
              : 'Desconocido';

          // Extrae la URL de la imagen desde la página de la noticia
          //final imageUrl = await _fetchImageUrlFromPage(link);
          final imageUrl = 'f.image.geki.jp/data/image/news/2560/419000/418017/news_418017_1.webp';
          // Formatea la fecha
          String fechaFormateada = '';
          if (pubDate.isNotEmpty) {
            try {
              final dateTime = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(pubDate);
              fechaFormateada = DateFormat('yyyy-MM-dd').format(dateTime);
            } catch (e) {
              print('Error al formatear la fecha: $e');
            }
          }

          return {
            'title': title,
            'link': link,
            'imageUrl': imageUrl,
            'date': fechaFormateada,
            'creator': creator,
          };
        }).toList());

        setState(() {
          _newsItems = newsItems;
        });
      } else {
        print('Error al cargar el feed RSS: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar el feed RSS: $e');
    }
  }

  // Función para extraer la URL de la imagen desde la metaetiqueta `og:image`
  Future<String?> _fetchImageUrlFromPage(String link) async {
    try {
      final response = await http.get(Uri.parse(link));
      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        final metaTag = document.querySelector('meta[property="og:image"]');
        return metaTag != null ? metaTag.attributes['content'] : null;
      }
    } catch (e) {
      print('Error al cargar la página de la noticia: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _newsItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _newsItems.length,
              itemBuilder: (context, index) {
                final newsItem = _newsItems[index];
                return GestureDetector(
                  onTap: () {
                    _openNewsLink(newsItem['link']);
                  },
                  child: Container(
                    color: Colors.grey[30],
                    margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        SizedBox(height: 10),
                        Text(
                          newsItem['title'] ?? 'Sin título',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${newsItem['date']} - ${newsItem['creator']}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _openNewsLink(String? url) async {
    if (url != null && await canLaunch(url)) {
      await launch(url);
    } else {
      print('No se pudo abrir el enlace: $url');
    }
  }
}
