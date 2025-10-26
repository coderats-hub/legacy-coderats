// Arquivo: badges/infra/BadgeEntity.java
package dev.coderats.backend.badges.infra;
// ... imports (jakarta.persistence, lombok, java.time, java.util.UUID) ...
import java.time.Instant;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "badges")
@Getter @Setter @NoArgsConstructor
public class BadgeEntity {
    @Id private UUID id;
    @Column(nullable = false) private String name;
    @Column(nullable = false) private String image;
    private String description;
    @Column(nullable = false) private int points;
    @Column(name = "created_at", nullable = false, updatable = false) private Instant createdAt;
    @Column(name = "updated_at", nullable = false) private Instant updatedAt;
    @Column(name = "deleted_at") private Instant deletedAt;
}
