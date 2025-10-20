package dev.coderats.backend.badges.domain;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;

import dev.coderats.backend.shared.domain.Clock;

public class Badge {
    
    private final BadgeId id;
    private String name;
    private String image;
    private String description;
    private int points; 

    private final Instant createdAt;
    private Instant updatedAt;
    private Instant deletedAt;

    private Badge(BadgeId id, String name, String image, String description, int points, Instant createdAt, Instant updatedAt, Instant deletedAt) {
        this.id = Objects.requireNonNull(id);
        this.name = Objects.requireNonNull(name);
        this.image = Objects.requireNonNull(image);
        this.description = description;
        this.points = points;
        this.createdAt = Objects.requireNonNull(createdAt);
        this.updatedAt = Objects.requireNonNull(updatedAt);
        this.deletedAt = deletedAt;
    }
    
    public static Badge create(String name, String image, String description, int points, Clock clock) {
        final Instant now = clock.now();
        return new Badge(BadgeId.newId(), name, image, description, points, now, now, null);
    }
    
    public static Badge reconstitute(BadgeId id, String name, String image, String description, int points, Instant createdAt, Instant updatedAt, Instant deletedAt) {
        return new Badge(id, name, image, description, points, createdAt, updatedAt, deletedAt);
    }
    
    public void updateDetails(String name, String image, String description, int points, Clock clock) {
        this.name = name;
        this.image = image;
        this.description = description;
        this.points = points;
        this.updatedAt = clock.now();
    }
    
    public void markDeleted(Clock clock) {
        this.deletedAt = clock.now();
        this.updatedAt = clock.now();
    }
    
    // Getters
    public BadgeId id() { return id; }
    public String name() { return name; }
    public String image() { return image; }
    public Optional<String> description() { return Optional.ofNullable(description); }
    public int points() { return points; }
    public Instant createdAt() { return createdAt; }
    public Instant updatedAt() { return updatedAt; }
    public Optional<Instant> deletedAt() { return Optional.ofNullable(deletedAt); }
}