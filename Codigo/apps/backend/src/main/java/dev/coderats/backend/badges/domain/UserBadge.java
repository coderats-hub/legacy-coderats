package dev.coderats.backend.badges.domain;

import java.time.Instant;
import java.util.Objects;

import dev.coderats.backend.shared.domain.Clock;
import dev.coderats.backend.users.domain.UserId;

/**
 * Entidade que representa a conquista de uma Badge por um Usuário.
 * Mapeia a tabela 'user_badges'.
 * Possui chave composta (userId, badgeId).
 */
public class UserBadge {
    
    private final UserId userId;
    private final BadgeId badgeId;
    private final int points; // Pontos registrados no momento da conquista
    private final Instant awardedAt;

    private UserBadge(UserId userId, BadgeId badgeId, int points, Instant awardedAt) {
        this.userId = Objects.requireNonNull(userId);
        this.badgeId = Objects.requireNonNull(badgeId);
        this.points = points;
        this.awardedAt = Objects.requireNonNull(awardedAt);
    }
    
    public static UserBadge create(UserId userId, BadgeId badgeId, int pointsAwarded, Clock clock) {
        return new UserBadge(userId, badgeId, pointsAwarded, clock.now());
    }
    
    public static UserBadge reconstitute(UserId userId, BadgeId badgeId, int points, Instant awardedAt) {
        return new UserBadge(userId, badgeId, points, awardedAt);
    }

    public UserId userId() { return userId; }
    public BadgeId badgeId() { return badgeId; }
    public int points() { return points; }
    public Instant awardedAt() { return awardedAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserBadge userBadge = (UserBadge) o;
        return userId.equals(userBadge.userId) && badgeId.equals(userBadge.badgeId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, badgeId);
    }
}