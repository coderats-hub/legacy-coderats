package dev.coderats.backend.users.app.port;

import java.util.List;

import dev.coderats.backend.users.app.query.BadgeView;
import dev.coderats.backend.users.domain.UserId;

public interface BadgeQueryPort {
    // Para GET /users/me/badges
    List<BadgeView> findBadgesByUserId(UserId userId);
}