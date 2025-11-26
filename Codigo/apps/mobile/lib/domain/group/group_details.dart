import 'group.dart';
import 'group_participant.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'group': group.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }
}