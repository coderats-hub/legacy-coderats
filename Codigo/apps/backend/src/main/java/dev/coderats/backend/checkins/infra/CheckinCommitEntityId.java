package dev.coderats.backend.checkins.infra;
import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Embeddable
@Getter @Setter @NoArgsConstructor
public class CheckinCommitEntityId implements Serializable {
    @Column(name = "checkin_id") private UUID checkinId;
    @Column(name = "commit_id") private UUID commitId;

    public CheckinCommitEntityId(UUID checkinId, UUID commitId) {
        this.checkinId = checkinId;
        this.commitId = commitId;
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        CheckinCommitEntityId that = (CheckinCommitEntityId) o;
        return Objects.equals(checkinId, that.checkinId) && Objects.equals(commitId, that.commitId);
    }
    @Override
    public int hashCode() {
        return Objects.hash(checkinId, commitId);
    }
}