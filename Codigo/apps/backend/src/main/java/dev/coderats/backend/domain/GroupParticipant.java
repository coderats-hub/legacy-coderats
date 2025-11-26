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

    // --- Relacionamentos (O "Muitos" de volta para o "Um") ---

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId") // Mapeia o campo 'userId' do @EmbeddedId
    @JoinColumn(name = "user_id")
    @JsonIgnore
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("groupId") // Mapeia o campo 'groupId' do @EmbeddedId
    @JoinColumn(name = "group_id")
    @JsonIgnore
    private Group group;

    // --- Colunas Extras ---

    @Column(nullable = false)
    private String role;

    @CreationTimestamp // Usa o padrão do Hibernate para NOW()
    @Column(name = "joined_at", nullable = false, updatable = false)
    private OffsetDateTime joinedAt;

    // --- Construtores ---
    
    public GroupParticipant() {
    }
    
    // Construtor de conveniência que você já usa
    public GroupParticipant(UUID userId, UUID groupId, String role) {
        this.id = new GroupParticipantId(userId, groupId);
        this.role = role;
    }

    // --- Getters e Setters ---
    
    public GroupParticipantId getId() { return id; }
    public void setId(GroupParticipantId id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public Group getGroup() { return group; }
    public void setGroup(Group group) { this.group = group; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public OffsetDateTime getJoinedAt() { return joinedAt; }
    public void setJoinedAt(OffsetDateTime joinedAt) { this.joinedAt = joinedAt; }

    // Helpers (opcional, mas muito útil, como você usou no GroupService)
    public UUID getUserId() {
        return (this.id != null) ? this.id.getUserId() : null;
    }
    public UUID getGroupId() {
        return (this.id != null) ? this.id.getGroupId() : null;
    }
}
