package dev.coderats.backend.groups.domain;

import java.time.Instant;
import java.util.Objects;

import dev.coderats.backend.shared.domain.Clock;
import dev.coderats.backend.users.domain.UserId; 

public class Membership {

    private final MembershipId id;
    private final GroupId groupId;
    private final UserId userId;
    private GroupRole role; 
    private int points;
    private final Instant joinedAt;

    private Membership(
            MembershipId id,
            GroupId groupId,
            UserId userId,
            GroupRole role,
            int points,
            Instant joinedAt
    ) {
        this.id = Objects.requireNonNull(id);
        this.groupId = Objects.requireNonNull(groupId);
        this.userId = Objects.requireNonNull(userId);
        this.role = Objects.requireNonNull(role);
        this.points = points; 
        this.joinedAt = Objects.requireNonNull(joinedAt);
    }

    public static Membership create(GroupId groupId, UserId userId, GroupRole role, Clock clock) {
        final Instant now = clock.now();
        return new Membership(
                MembershipId.newId(),
                groupId,
                userId,
                role,
                0,
                now
        );
    }

    public static Membership reconstitute(
            MembershipId id,
            GroupId groupId,
            UserId userId,
            GroupRole role,
            int points, 
            Instant joinedAt
    ) {
        return new Membership(id, groupId, userId, role, points, joinedAt);
    }

    public void promoteToAdmin(Clock clock) {
        if (this.role == GroupRole.ADMIN) return;
        this.role = GroupRole.ADMIN;
    }

    public void demoteToMember(Clock clock) {
        if (this.role == GroupRole.MEMBER) return;
        this.role = GroupRole.MEMBER;
    }

    public void addPoints(int pointsToAdd, Clock clock) {
        if (pointsToAdd <= 0) {
            return; 
        }
        this.points += pointsToAdd;
    }

    
    public MembershipId id() { return id; }
    public GroupId groupId() { return groupId; }
    public UserId userId() { return userId; }
    public GroupRole role() { return role; }
    public int points() { return points; }
    public Instant joinedAt() { return joinedAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Membership that = (Membership) o;
        return id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}