package dev.coderats.backend.domain;

import java.time.OffsetDateTime;
import java.util.UUID;

import org.hibernate.annotations.CreationTimestamp;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;

@Entity
@Table(name = "group_participants")
public class GroupParticipant {

    @EmbeddedId
    private GroupParticipantId id = new GroupParticipantId();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId") 
    @JoinColumn(name = "user_id")
    @JsonIgnore
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("groupId") 
    @JoinColumn(name = "group_id")
    @JsonIgnore
    private Group group;

    @Column(nullable = false)
    private String role;

    @Column(nullable = false)
    private int points = 0; 

    @CreationTimestamp
    @Column(name = "joined_at", nullable = false, updatable = false)
    private OffsetDateTime joinedAt;

    public GroupParticipant() {
    }
    
    public GroupParticipant(UUID userId, UUID groupId, String role) {
        this.id = new GroupParticipantId(userId, groupId);
        this.role = role;
        this.points = 0; 
    }

    public GroupParticipant(User user, Group group, String role) {
        this.id = new GroupParticipantId(user.getId(), group.getId());
        this.user = user;
        this.group = group;
        this.role = role;
        this.points = 0;
    }

    public void addPoints(int pointsToAdd) {
        if (pointsToAdd > 0) {
            this.points += pointsToAdd;
        }
    }

    public GroupParticipantId getId() { return id; }
    public void setId(GroupParticipantId id) { this.id = id; }
    
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public Group getGroup() { return group; }
    public void setGroup(Group group) { this.group = group; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }
    
    public OffsetDateTime getJoinedAt() { return joinedAt; }
    public void setJoinedAt(OffsetDateTime joinedAt) { this.joinedAt = joinedAt; }

    public UUID getUserId() {
        return (this.id != null) ? this.id.getUserId() : null;
    }
    public UUID getGroupId() {
        return (this.id != null) ? this.id.getGroupId() : null;
    }
}