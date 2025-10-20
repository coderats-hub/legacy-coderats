package dev.coderats.backend.checkins.domain;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;

import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.shared.domain.Clock;
import dev.coderats.backend.users.domain.UserId;

public class Checkin {
    private final CheckinId id;
    private final UserId userId;
    private final GroupId groupId;
    private String title;
    private String description;
    private String image;
    private String summaryAi;
    private int points;
    private final Instant createdAt;
    private Instant updatedAt;
    private Instant deletedAt;
    
    // Construtor privado
    private Checkin(CheckinId id, UserId userId, GroupId groupId, String title, String description, String image, String summaryAi, int points, Instant createdAt, Instant updatedAt, Instant deletedAt) {
        this.id = Objects.requireNonNull(id);
        this.userId = Objects.requireNonNull(userId);
        this.groupId = Objects.requireNonNull(groupId);
        this.title = Objects.requireNonNull(title);
        this.description = description;
        this.image = image;
        this.summaryAi = summaryAi;
        this.points = points;
        this.createdAt = Objects.requireNonNull(createdAt);
        this.updatedAt = Objects.requireNonNull(updatedAt);
        this.deletedAt = deletedAt;
    }

    public static Checkin create(UserId userId, GroupId groupId, String title, String description, String image, String summaryAi, int points, Clock clock) {
        final Instant now = clock.now();
        return new Checkin(CheckinId.newId(), userId, groupId, title, description, image, summaryAi, points, now, now, null);
    }
    
    public static Checkin reconstitute(CheckinId id, UserId userId, GroupId groupId, String title, String description, String image, String summaryAi, int points, Instant createdAt, Instant updatedAt, Instant deletedAt) {
        return new Checkin(id, userId, groupId, title, description, image, summaryAi, points, createdAt, updatedAt, deletedAt);
    }
    
    public void markDeleted(Clock clock) {
        this.deletedAt = clock.now();
        this.updatedAt = clock.now();
    }
    
    // Getters
    public CheckinId id() { return id; }
    public UserId userId() { return userId; }
    public GroupId groupId() { return groupId; }
    public String title() { return title; }
    public Optional<String> description() { return Optional.ofNullable(description); }
    public Optional<String> image() { return Optional.ofNullable(image); }
    public Optional<String> summaryAi() { return Optional.ofNullable(summaryAi); }
    public int points() { return points; }
    public Instant createdAt() { return createdAt; }
    public Instant updatedAt() { return updatedAt; }
    public Optional<Instant> deletedAt() { return Optional.ofNullable(deletedAt); }
}
