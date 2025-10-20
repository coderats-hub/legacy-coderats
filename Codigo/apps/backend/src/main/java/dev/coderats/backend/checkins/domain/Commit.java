package dev.coderats.backend.checkins.domain;

import java.time.Instant;
import java.util.Objects;

import dev.coderats.backend.shared.domain.Clock;

public class Commit {
    private final CommitId id;
    private final String link;
    private final String title;
    private final String hash; // Único
    private final Instant createdAt;
    
    private Commit(CommitId id, String link, String title, String hash, Instant createdAt) {
        this.id = Objects.requireNonNull(id);
        this.link = Objects.requireNonNull(link);
        this.title = Objects.requireNonNull(title);
        this.hash = Objects.requireNonNull(hash);
        this.createdAt = Objects.requireNonNull(createdAt);
    }
    
    public static Commit create(String link, String title, String hash, Clock clock) {
        return new Commit(CommitId.newId(), link, title, hash, clock.now());
    }

    public static Commit reconstitute(CommitId id, String link, String title, String hash, Instant createdAt) {
        return new Commit(id, link, title, hash, createdAt);
    }
    
    // Getters
    public CommitId id() { return id; }
    public String link() { return link; }
    public String title() { return title; }
    public String hash() { return hash; }
    public Instant createdAt() { return createdAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Commit commit = (Commit) o;
        return hash.equals(commit.hash); // Commits são únicos pelo hash
    }

    @Override
    public int hashCode() {
        return Objects.hash(hash);
    }
}