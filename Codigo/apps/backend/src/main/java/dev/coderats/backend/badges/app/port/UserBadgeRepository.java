package dev.coderats.backend.badges.app.port;

import java.util.List;

import dev.coderats.backend.badges.domain.UserBadge;
import dev.coderats.backend.users.domain.UserId;

public interface UserBadgeRepository {
    void save(UserBadge userBadge);
    List<UserBadge> findByUserId(UserId userId);
}