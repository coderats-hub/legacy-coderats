import 'package:coderats/domain/group/group.dart';
import 'package:coderats/domain/group/group_participant.dart';

class GroupDetails {
  final Group group;
  final List<GroupParticipant> participants;

  const GroupDetails({
    required this.group,
    required this.participants,
  });

  factory GroupDetails.fromJson(Map<String, dynamic> json) {
    return GroupDetails(
      group: json.containsKey('group') 
          ? Group.fromJson(json['group']) 
          : Group.fromJson(json),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => GroupParticipant.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory GroupDetails.fromCheckinList(String groupId, List<dynamic> list) {
    final Map<String, GroupParticipant> uniqueAuthors = {};

    for (var item in list) {
      if (item['author'] != null) {
        final author = GroupParticipant.fromJson(item['author']);
        uniqueAuthors[author.id] = author;
      }
    }

    final sortedParticipants = uniqueAuthors.values.toList()
      ..sort((a, b) => b.points.compareTo(a.points));

    return GroupDetails(
      group: Group(
        id: groupId,
        name: '', 
        startDate: DateTime.now(), 
        status: true,
      ),
      participants: sortedParticipants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group': group.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }
}
