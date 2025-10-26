package dev.coderats.backend.checkins.infra;
import java.time.Instant;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "comments")
@Getter @Setter @NoArgsConstructor
public class CommentEntity {
    @Id private UUID id;
    @Column(name = "checkin_id", nullable = false) private UUID checkinId;
    @Column(name = "user_id", nullable = false) private UUID userId;
    @Column(nullable = false) private String content;
    @Column(name = "created_at", nullable = false, updatable = false) private Instant createdAt;
    @Column(name = "updated_at", nullable = false) private Instant updatedAt;
    @Column(name = "deleted_at") private Instant deletedAt;
}