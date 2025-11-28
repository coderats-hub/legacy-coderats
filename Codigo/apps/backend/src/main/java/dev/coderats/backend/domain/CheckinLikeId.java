package dev.coderats.backend.domain;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

public class CheckinLikeId implements Serializable {
    
    private UUID checkinId;
    private UUID userId;
    
    public CheckinLikeId() {}
    
    public CheckinLikeId(UUID checkinId, UUID userId) {
        this.checkinId = checkinId;
        this.userId = userId;
    }
    
    public UUID getCheckinId() {
        return checkinId;
    }
    
    public void setCheckinId(UUID checkinId) {
        this.checkinId = checkinId;
    }
    
    public UUID getUserId() {
        return userId;
    }
    
    public void setUserId(UUID userId) {
        this.userId = userId;
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        CheckinLikeId that = (CheckinLikeId) o;
        return Objects.equals(checkinId, that.checkinId) && Objects.equals(userId, that.userId);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(checkinId, userId);
    }
}
