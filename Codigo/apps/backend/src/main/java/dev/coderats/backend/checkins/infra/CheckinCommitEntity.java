package dev.coderats.backend.checkins.infra;

import java.time.Instant;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "checkin_commits")
@Getter @Setter @NoArgsConstructor
public class CheckinCommitEntity {
    @EmbeddedId
    private CheckinCommitEntityId id;
    
    @Column(name = "associated_at", nullable = false, updatable = false)
    private Instant associatedAt;
}
