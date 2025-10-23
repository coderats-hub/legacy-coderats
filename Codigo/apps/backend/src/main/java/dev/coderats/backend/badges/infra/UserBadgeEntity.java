package dev.coderats.backend.badges.infra;

import java.time.Instant;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "user_badges")
@Getter @Setter @NoArgsConstructor
public class UserBadgeEntity {
    @EmbeddedId
    private UserBadgeEntityId id;
    
    @Column(nullable = false)
    private int points; // Pontos no momento da conquista
    
    @Column(name = "awarded_at", nullable = false, updatable = false)
    private Instant awardedAt;
}