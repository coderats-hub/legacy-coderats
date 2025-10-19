package dev.coderats.backend.users.domain;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;

import dev.coderats.backend.shared.domain.Clock;

public class User {

    private final UserId id;
    private String name;
    private final String email; 
    private String image;
    private String githubUser;

    private final Instant createdAt;
    private Instant updatedAt;
    private Instant deletedAt;

    private User(
            UserId id,
            String name,
            String email,
            String image,
            String githubUser,
            Instant createdAt,
            Instant updatedAt,
            Instant deletedAt
    ) {
        this.id = Objects.requireNonNull(id);
        this.name = Objects.requireNonNull(name);
        this.email = Objects.requireNonNull(email);
        this.image = image;
        this.githubUser = githubUser;
        this.createdAt = Objects.requireNonNull(createdAt);
        this.updatedAt = Objects.requireNonNull(updatedAt);
        this.deletedAt = deletedAt;
    }

    public static User create(
            String name,
            String email,
            String image,
            String githubUser,
            Clock clock
    ) {
        final Instant now = clock.now();
        return new User(
                UserId.newId(),
                name,
                email,
                image,
                githubUser,
                now,
                now,
                null
        );
    }

    public static User reconstitute(
            UserId id,
            String name,
            String email,
            String image,
            String githubUser,
            Instant createdAt,
            Instant updatedAt,
            Instant deletedAt
    ) {
        return new User(id, name, email, image, githubUser, createdAt, updatedAt, deletedAt);
    }

    public void updateProfile(
            String name,
            String image,
            String githubUser,
            Clock clock
    ) {
        this.name = Objects.requireNonNullElse(name, this.name);
        this.image = image; 
        this.githubUser = githubUser; 
        this.updatedAt = clock.now();
    }

    public void markDeleted(Clock clock) {
        this.deletedAt = clock.now();
        this.updatedAt = clock.now();
    }

    public UserId id() { return id; }
    public String name() { return name; }
    public String email() { return email; }
    public Optional<String> image() { return Optional.ofNullable(image); }
    public Optional<String> githubUser() { return Optional.ofNullable(githubUser); }
    public Instant createdAt() { return createdAt; }
    public Instant updatedAt() { return updatedAt; }
    public Optional<Instant> deletedAt() { return Optional.ofNullable(deletedAt); }
    
    public boolean isDeleted() {
        return this.deletedAt != null;
    }
}