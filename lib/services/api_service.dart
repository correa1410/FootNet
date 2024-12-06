import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String apiKey = '1c7bee047114a48fa9ea51b9b1b0dd04';

  Future<dynamic> getTeamMatches({required int teamId}) async {
    String url = 'https://v3.football.api-sports.io/fixtures?team=$teamId';

    final response = await http.get(
      Uri.parse(url),
      headers: {'X-Auth-Token': apiKey},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['response'];
    } else {
      throw Exception('Error al cargar los datos de los partidos del equipo');
    }
  }

  Future<dynamic> getNews() async {
    String url = 'https://v3.football.api-sports.io/news';

    final response = await http.get(
      Uri.parse(url),
      headers: {'X-Auth-Token': apiKey},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['response'];
    } else {
      throw Exception('No se pudieron obtener las noticias');
    }
  }

  // Método para obtener las ligas
  Future<List<dynamic>> getLeagues() async {
    final response = await http.get(
      Uri.parse("https://v3.football.api-sports.io/leagues"),
      headers: {
        "x-apisports-key": apiKey,
        "x-rapidapi-host": "v3.football.api-sports.io"
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['response'];
    } else {
      throw Exception('Error al obtener las ligas');
    }
  }
}
