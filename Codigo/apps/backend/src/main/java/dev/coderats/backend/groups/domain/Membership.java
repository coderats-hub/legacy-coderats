package dev.coderats.backend.groups.domain;

import java.time.Instant;
import java.util.Objects;

import dev.coderats.backend.shared.domain.Clock;
import dev.coderats.backend.users.domain.UserId;

// Relação básica de associação entre usuário e grupo
// Funciona como um model padrão
public class Membership {

    private final GroupId groupId;
    private final UserId userId;

    private GroupRole role;
    private int points;
    private final Instant joinedAt;

    private Membership(
            GroupId groupId,
            UserId userId,
            GroupRole role,
            int points,
            Instant joinedAt
    ) {
        this.groupId = Objects.requireNonNull(groupId);
        this.userId = Objects.requireNonNull(userId);
        this.role = Objects.requireNonNull(role);

        if (points < 0) {
            throw new IllegalArgumentException("Points cannot be negative");
        }
        this.points = points;
        this.joinedAt = Objects.requireNonNull(joinedAt);
    }

    public static Membership create(GroupId groupId, UserId userId, GroupRole role, Clock clock) {
        return new Membership(
                groupId,
                userId,
                role,
                0,
                clock.now()
        );
    }

    public static Membership reconstitute(
            GroupId groupId,
            UserId userId,
            GroupRole role,
            int points,
            Instant joinedAt
    ) {
        return new Membership(groupId, userId, role, points, joinedAt);
    }

    public void promoteToAdmin() {
        if (this.role == GroupRole.ADMIN) {
            return;
        }
        this.role = GroupRole.ADMIN;
    }

    public void demoteToMember() {
        if (this.role == GroupRole.MEMBER) {
            return;
        }
        this.role = GroupRole.MEMBER;
    }

    public void addPoints(int pointsToAdd) {
        if (pointsToAdd <= 0) {
            return;
        }
        this.points += pointsToAdd;
    }

    public GroupId groupId() {
        return groupId;
    }

    public UserId userId() {
        return userId;
    }

    public GroupRole role() {
        return role;
    }

    public int points() {
        return points;
    }

    public Instant joinedAt() {
        return joinedAt;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        Membership that = (Membership) o;
        return groupId.equals(that.groupId)
                && userId.equals(that.userId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(groupId, userId);
    }

    @Override
    public String toString() {
        return "Membership{"
                + "groupId=" + groupId
                + ", userId=" + userId
                + ", role=" + role
                + ", points=" + points
                + ", joinedAt=" + joinedAt
                + '}';
    }
}
