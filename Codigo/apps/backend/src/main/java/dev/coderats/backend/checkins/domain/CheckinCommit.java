package dev.coderats.backend.checkins.domain;

import java.time.Instant;
import java.util.Objects;

import dev.coderats.backend.shared.domain.Clock;

// Entidade de junção M-N (como Membership)
public class CheckinCommit {
    private final CheckinId checkinId;
    private final CommitId commitId;
    private final Instant associatedAt;

    private CheckinCommit(CheckinId checkinId, CommitId commitId, Instant associatedAt) {
        this.checkinId = Objects.requireNonNull(checkinId);
        this.commitId = Objects.requireNonNull(commitId);
        this.associatedAt = Objects.requireNonNull(associatedAt);
    }
    
    public static CheckinCommit create(CheckinId checkinId, CommitId commitId, Clock clock) {
        return new CheckinCommit(checkinId, commitId, clock.now());
    }
    
    public static CheckinCommit reconstitute(CheckinId checkinId, CommitId commitId, Instant associatedAt) {
        return new CheckinCommit(checkinId, commitId, associatedAt);
    }

    // Getters
    public CheckinId checkinId() { return checkinId; }
    public CommitId commitId() { return commitId; }
    public Instant associatedAt() { return associatedAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        CheckinCommit that = (CheckinCommit) o;
        return checkinId.equals(that.checkinId) && commitId.equals(that.commitId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(checkinId, commitId);
    }
}