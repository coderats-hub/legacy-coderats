// Arquivo: checkins/infra/CheckinEntity.java
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

@Entity @Table(name = "checkins")
@Getter @Setter @NoArgsConstructor
public class CheckinEntity {
    @Id private UUID id;
    @Column(name = "user_id", nullable = false) private UUID userId;
    @Column(name = "group_id", nullable = false) private UUID groupId;
    @Column(nullable = false) private String title;
    private String description;
    private String image;
    @Column(name = "summary_ai") private String summaryAi;
    @Column(nullable = false) private int points;
    @Column(name = "created_at", nullable = false, updatable = false) private Instant createdAt;
    @Column(name = "updated_at", nullable = false) private Instant updatedAt;
    @Column(name = "deleted_at") private Instant deletedAt;
}

// Arquivo: checkins/infra/LikeEntity.java



