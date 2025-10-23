package dev.coderats.backend.badges.infra;

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
public class UserBadgeEntityId implements Serializable {
    @Column(name = "user_id") private UUID userId;
    @Column(name = "badge_id") private UUID badgeId;

    public UserBadgeEntityId(UUID userId, UUID badgeId) {
        this.userId = userId;
        this.badgeId = badgeId;
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserBadgeEntityId that = (UserBadgeEntityId) o;
        return Objects.equals(userId, that.userId) && Objects.equals(badgeId, that.badgeId);
    }
    @Override
    public int hashCode() {
        return Objects.hash(userId, badgeId);
    }
}