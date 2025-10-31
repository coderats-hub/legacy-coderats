package dev.coderats.backend.domain;

import java.util.UUID;

import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "group_participants") // Nome da sua tabela
public class GroupParticipant {

    @EmbeddedId
    private GroupParticipantId id;

    private String role;

    // Construtor padrão exigido pelo JPA
    public GroupParticipant() {
    }

    public GroupParticipant(GroupParticipantId id, String role) {
        this.id = id;
        this.role = role;
    }
    
    // Construtor de conveniência
    public GroupParticipant(UUID userId, UUID groupId, String role) {
        this.id = new GroupParticipantId(userId, groupId);
        this.role = role;
    }

    // Getters e Setters
    public GroupParticipantId getId() {
        return id;
    }

    public void setId(GroupParticipantId id) {
        this.id = id;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
    
    // Métodos de atalho (opcional, mas útil)
    public UUID getUserId() {
        return this.id != null ? this.id.getUserId() : null;
    }
    
    public UUID getGroupId() {
        return this.id != null ? this.id.getGroupId() : null;
    }
}