package dev.coderats.backend.checkins.infra;
import java.time.Instant;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "likes", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"checkin_id", "user_id"})
})
@Getter @Setter @NoArgsConstructor
public class LikeEntity {
    @Id private UUID id;
    @Column(name = "checkin_id", nullable = false) private UUID checkinId;
    @Column(name = "user_id", nullable = false) private UUID userId;
    @Column(name = "created_at", nullable = false, updatable = false) private Instant createdAt;
}