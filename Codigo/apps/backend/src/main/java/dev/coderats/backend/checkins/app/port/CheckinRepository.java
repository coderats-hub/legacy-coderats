package dev.coderats.backend.checkins.app.port;
import java.util.List;
import java.util.Optional;
import dev.coderats.backend.checkins.app.query.FeedCheckinView;
import dev.coderats.backend.checkins.domain.Checkin;
import dev.coderats.backend.checkins.domain.CheckinId;
import dev.coderats.backend.users.domain.UserId;
import dev.coderats.backend.groups.domain.GroupId;

public interface CheckinRepository {
    void save(Checkin checkin);
    Optional<Checkin> findById(CheckinId checkinId);
    
    // Para o Feed
    List<FeedCheckinView> findFeed(List<GroupId> groupIds, UserId authenticatedUserId, int limit, int offset);
    
    // Para o GetGroupDetails (Porta de saída do módulo 'groups')
    List<Checkin> findRecentByGroupId(GroupId groupId, int limit);
}
