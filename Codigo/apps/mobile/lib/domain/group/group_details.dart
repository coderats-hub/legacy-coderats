import 'group.dart';
import 'group_participant.dart';

class GroupDetails {
  final Group group;
  final List<GroupParticipant> participants;

  const GroupDetails({
    required this.group,
    required this.participants,
  });
}
