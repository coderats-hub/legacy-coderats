import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_database.dart';

/// Serviço responsável por conversar com a API HTTP.
const String _baseUrl =
    'database-coderats-dev.c54wg8cy4hhf.us-east-2.rds.amazonaws.com';

/// Lista os grupos do usuário autenticado.
///
/// A nova API expõe isso em `GET /users/me/groups`, que devolve
/// uma lista de GroupWithDetails. Aqui usamos apenas os campos
/// de Group e ignoramos o parâmetro [userId] na chamada HTTP;
/// ele continua sendo usado somente para a parte de cache/SQLite
/// (no GroupRepository / local_database).
Future<List<Group>> fetchGroupsForUser(String userId) async {
  final uri = Uri.parse('$_baseUrl/users/me/groups');
  final resp = await http.get(uri);

  if (resp.statusCode != 200) {
    throw Exception('GET /users/me/groups failed: ${resp.statusCode} '
        'body: ${resp.body}');
  }

  final decoded = json.decode(resp.body);

  // A especificação diz que é um array direto, mas deixamos robusto.
  final List<dynamic> list;
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map && decoded['data'] is List) {
    list = decoded['data'] as List;
  } else {
    throw Exception(
      'Unexpected payload for /users/me/groups: ${resp.body}',
    );
  }

  return list
      .map((e) =>
          Group.fromMap(_adaptGroupFromApi(Map<String, dynamic>.from(e as Map))))
      .toList();
}

/// Detalhes de um grupo + participantes (ranking).
///
/// A nova API expõe isso em `GET /groups/{groupId}` e retorna
/// um objeto GroupWithDetails:
///   - campos de Group (id, name, image, description, status, ...)
///   - participants: array com { id, name, image, points? }
Future<GroupDetails> fetchGroupDetails(String groupId) async {
  final uri = Uri.parse('$_baseUrl/groups/$groupId');
  final resp = await http.get(uri);

  if (resp.statusCode != 200) {
    throw Exception('GET /groups/$groupId failed: ${resp.statusCode} '
        'body: ${resp.body}');
  }

  final decoded = json.decode(resp.body);
  if (decoded is! Map<String, dynamic>) {
    throw Exception(
      'Unexpected payload for /groups/$groupId: ${resp.body}',
    );
  }

  final map = Map<String, dynamic>.from(decoded);

  // Monta o Group a partir do JSON da API (adaptando chaves/formatos).
  final group = Group.fromMap(_adaptGroupFromApi(map));

  // Lê a lista de participantes do JSON.
  final participantsJson = (map['participants'] as List?) ?? const [];

  final participants = participantsJson.map<GroupParticipantWithUser>((raw) {
    final p = Map<String, dynamic>.from(raw as Map);

    final String? userId =
        p['id'] != null ? p['id'].toString() : null; // id do usuário

    // Monta o usuário (User) com os campos que existem na API.
    final user = User(
      id: userId,
      name: (p['name'] ?? '') as String,
      email: null,
      image: p['image'] as String?,
      githubUser: (p['github_user'] ?? '') as String,
      githubId: 0, // a API de mock não envia github_id, usamos 0 como default
    );

    // Converte pontos (podem vir como string ou número).
    final dynamic rawPoints = p['points'];
    double points;
    if (rawPoints is num) {
      points = rawPoints.toDouble();
    } else if (rawPoints != null) {
      points = double.tryParse(rawPoints.toString()) ?? 0.0;
    } else {
      points = 0.0;
    }

    final participant = GroupParticipant(
      groupId: group.id,
      userId: user.id,
      role: null,
      points: points,
      createdAt: null,
    );

    return GroupParticipantWithUser(participant, user);
  }).toList();

  return GroupDetails(group: group, participants: participants);
}

/// Busca usuário(s) na API.
///
/// A nova especificação não possui mais `GET /users` com lista.
/// Para manter a assinatura existente e evitar quebrar código,
/// fazemos:
///   - `GET /users/me`
///   - se vier um objeto único, encapsulamos em uma lista com 1 User.
Future<List<User>> fetchUsers() async {
  final uri = Uri.parse('$_baseUrl/users/me');
  final resp = await http.get(uri);

  if (resp.statusCode != 200) {
    throw Exception('GET /users/me failed: ${resp.statusCode} '
        'body: ${resp.body}');
  }

  final decoded = json.decode(resp.body);

  if (decoded is List) {
    // Caso no futuro exista um endpoint que devolva lista,
    // adaptamos cada item.
    return decoded
        .map((e) => User.fromMap(
            _adaptUserFromApi(Map<String, dynamic>.from(e as Map))))
        .toList();
  } else if (decoded is Map<String, dynamic>) {
    // Comportamento atual do mock: objeto único (PrivateUserResponse).
    final user = User.fromMap(_adaptUserFromApi(decoded));
    return [user];
  } else {
    throw Exception('Unexpected payload for /users/me: ${resp.body}');
  }
}

/// Adapta o JSON de Group (Group ou GroupWithDetails) da API
/// para o formato esperado pelo modelo Group/SQLite.
///
/// - Converte `status` (bool/string/num) para 0/1.
/// - Normaliza nomes de campos de datas (snake_case vs camelCase).
Map<String, Object?> _adaptGroupFromApi(Map<String, dynamic> api) {
  final dynamic statusRaw = api['status'];
  final bool isActive = statusRaw == true ||
      statusRaw == 1 ||
      statusRaw == '1' ||
      statusRaw == 'true';

  Object? pick(Object? a, Object? b) => a ?? b;

  return <String, Object?>{
    'id': api['id'],
    'name': api['name'] ?? api['title'],
    'description': api['description'],
    'image': api['image'],
    'code': api['code'],
    'method': api['method'],
    // guardamos como inteiro 0/1 para manter compatibilidade com SQLite
    'status': isActive ? 1 : 0,
    'repository': api['repository'],
    'start_date': pick(api['start_date'], api['startDate']),
    'end_date': pick(api['end_date'], api['endDate']),
    'created_at': pick(api['created_at'], api['createdAt']),
    'updated_at': pick(api['updated_at'], api['updatedAt']),
    'deleted_at': pick(api['deleted_at'], api['deletedAt']),
  };
}

/// Adapta o JSON de usuário (PrivateUserResponse / UserBase)
/// para o formato esperado por User/SQLite.
Map<String, Object?> _adaptUserFromApi(Map<String, dynamic> api) {
  Object? pick(Object? a, Object? b) => a ?? b;

  return <String, Object?>{
    'id': api['id'],
    'name': api['name'],
    'email': api['email'],
    'image': api['image'],
    'github_user': api['github_user'],
    // API de mock não traz github_id; usamos 0 como default seguro.
    'github_id': api['github_id'] ?? 0,
    'created_at': pick(api['created_at'], api['createdAt']),
    'updated_at': pick(api['updated_at'], api['updatedAt']),
    'deleted_at': pick(api['deleted_at'], api['deletedAt']),
  };
}
