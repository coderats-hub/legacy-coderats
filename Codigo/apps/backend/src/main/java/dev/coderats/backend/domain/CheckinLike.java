package dev.coderats.backend.domain;

import java.time.OffsetDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

@Entity
@Table(name = "checkin_likes")
@IdClass(CheckinLikeId.class)
public class CheckinLike {
    
    @Id
    @Column(name = "checkin_id")
    private UUID checkinId;
    
    @Id
    @Column(name = "user_id")
    private UUID userId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "checkin_id", insertable = false, updatable = false)
    private Checkin checkin;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;
    
    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;
    
    public CheckinLike() {}
    
    public CheckinLike(UUID checkinId, UUID userId) {
        this.checkinId = checkinId;
        this.userId = userId;
    }
    
    @PrePersist
    void prePersist() {
        createdAt = OffsetDateTime.now();
    }
    
    // Getters e Setters
    public UUID getCheckinId() { return checkinId; }
    public void setCheckinId(UUID checkinId) { this.checkinId = checkinId; }
    
    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }
    
    public Checkin getCheckin() { return checkin; }
    public void setCheckin(Checkin checkin) { this.checkin = checkin; }
    
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
