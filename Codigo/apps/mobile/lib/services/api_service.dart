import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_database.dart';

//comentário só pra dar push


const String _baseUrl = 'https://virtserver.swaggerhub.com/pucminas-1a5/raquelCodeRats/1';


Future<List<Group>> fetchGroupsForUser(String userId) async {
  final resp = await http.get(Uri.parse('$_baseUrl/users/$userId/groups'));
  if (resp.statusCode != 200) {
    throw Exception('GET /users/$userId/groups failed: ${resp.statusCode}');
  }
  final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
  return data.map((e) => Group.fromMap(Map<String, Object?>.from(e as Map))).toList();
}


Future<GroupDetails> fetchGroupDetails(String id) async {

  final resp = await http.get(Uri.parse('$_baseUrl/groups/$id'));

  if (resp.statusCode != 200) {
    throw Exception('GET /groups/$id failed: ${resp.statusCode}');
  }

  final Map<String, dynamic> data = json.decode(resp.body) as Map<String, dynamic>;


  final group = Group.fromMap(Map<String, Object?>.from(data['group'] as Map));
  final List<dynamic> parts = (data['participants'] as List<dynamic>? ) ?? [];


  // Fetch all users (mock provides /users). We'll match by user_id.
  final users = await fetchUsers();
  final Map<String, User> usersById = {for (var u in users) u.id: u};

  final enriched = parts.map((raw) {
    final m = Map<String, Object?>.from(raw as Map);
    final gp = GroupParticipant.fromMap(m);
    final user = usersById[gp.userId] ?? User(id: gp.userId, name: 'Unknown', githubUser: '', githubId: 0);
    return GroupParticipantWithUser(gp, user);
  }).toList();

  return GroupDetails(group: group, participants: enriched);
}


Future<List<User>> fetchUsers() async {
  final resp = await http.get(Uri.parse('$_baseUrl/users'));
  if (resp.statusCode != 200) {
    throw Exception('GET /users failed: ${resp.statusCode}');
  }
  final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
  return data.map((e) => User.fromMap(Map<String, Object?>.from(e as Map))).toList();
}