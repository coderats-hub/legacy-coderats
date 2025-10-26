package dev.coderats.backend.checkins.app.port;
import java.util.List;

import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.users.domain.UserId;
public interface GroupMembershipQueryPort {
    boolean isUserMemberOfGroup(UserId userId, GroupId groupId);
    List<GroupId> findGroupIdsByUserId(UserId userId);
}