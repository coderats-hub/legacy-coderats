package dev.coderats.backend.checkins.app.port;
import java.util.List;
import java.util.Optional;

import dev.coderats.backend.checkins.domain.CheckinId;
import dev.coderats.backend.checkins.domain.Like;
import dev.coderats.backend.users.domain.UserId;

public interface LikeRepository {
    void save(Like like);
    void delete(Like like);
    Optional<Like> findByCheckinIdAndUserId(CheckinId checkinId, UserId userId);
    List<Like> findByCheckinId(CheckinId checkinId);
    boolean existsByCheckinIdAndUserId(CheckinId checkinId, UserId userId);
}