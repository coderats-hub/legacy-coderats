package dev.coderats.backend.features.group;

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

@Entity
@Table(name = "group_participants")
@IdClass(GroupParticipantId.class)
public class GroupParticipant {
    
    @Id
    @Column(name = "user_id")
    private UUID userId;
    
    @Id
    @Column(name = "group_id")
    private UUID groupId;
    
    @Column(nullable = false)
    private String role = "member"; // admin or member
    
    @Column(nullable = false)
    private int points = 0;
    
    @Column(name = "joined_at", nullable = false)
    private OffsetDateTime joinedAt;
    
    public GroupParticipant() {}
    
    public GroupParticipant(UUID userId, UUID groupId, String role) {
        this.userId = userId;
        this.groupId = groupId;
        this.role = role;
        this.joinedAt = OffsetDateTime.now(ZoneOffset.UTC);
    }

    // Getters and Setters
    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }
    
    public UUID getGroupId() { return groupId; }
    public void setGroupId(UUID groupId) { this.groupId = groupId; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }
    
    public OffsetDateTime getJoinedAt() { return joinedAt; }
    public void setJoinedAt(OffsetDateTime joinedAt) { this.joinedAt = joinedAt; }
}

// Classe para chave composta
class GroupParticipantId {
    private UUID userId;
    private UUID groupId;
    
    public GroupParticipantId() {}
    
    public GroupParticipantId(UUID userId, UUID groupId) {
        this.userId = userId;
        this.groupId = groupId;
    }
    
    // equals, hashCode e getters/setters necessários para JPA
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof GroupParticipantId)) return false;
        GroupParticipantId that = (GroupParticipantId) o;
        return userId.equals(that.userId) && groupId.equals(that.groupId);
    }
    
    @Override
    public int hashCode() {
        return userId.hashCode() + groupId.hashCode();
    }
    
    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }
    
    public UUID getGroupId() { return groupId; }
    public void setGroupId(UUID groupId) { this.groupId = groupId; }
}
