package dev.coderats.backend.badges.app.port;

import java.util.List;
import java.util.Optional;

import dev.coderats.backend.badges.domain.Badge;
import dev.coderats.backend.badges.domain.BadgeId;

public interface BadgeRepository {
    void save(Badge badge);
    Optional<Badge> findById(BadgeId badgeId);
    List<Badge> findAll();
}
