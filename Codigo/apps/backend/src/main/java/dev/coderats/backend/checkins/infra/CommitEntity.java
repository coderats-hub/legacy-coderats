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

@Entity @Table(name = "commits")
@Getter @Setter @NoArgsConstructor
public class CommitEntity {
    @Id private UUID id;
    @Column(nullable = false) private String link;
    @Column(nullable = false) private String title;
    @Column(nullable = false, unique = true) private String hash;
    @Column(name = "created_at", nullable = false, updatable = false) private Instant createdAt;
}