package dev.coderats.backend.users.app.port;

import java.util.List;

import dev.coderats.backend.groups.app.query.GroupDetailsView;
import dev.coderats.backend.users.app.query.GroupSummaryView;
import dev.coderats.backend.users.domain.UserId;

public interface GroupQueryPort {
    // Para GET /users/{userId}
    List<GroupSummaryView> findCommonGroups(UserId userA, UserId userB);
    
    // Para GET /users/me/groups
    List<GroupDetailsView> findGroupsWithDetailsByUserId(UserId userId);
}