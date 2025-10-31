package dev.coderats.backend.domain;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

@Embeddable
public class GroupParticipantId implements Serializable {

    @Column(name = "user_id") // Mapeia para a coluna no banco de dados
    private UUID userId;

    @Column(name = "group_id") // Mapeia para a coluna no banco de dados
    private UUID groupId;

    // Construtor padrão é exigido pelo JPA
    public GroupParticipantId() {
    }

    public GroupParticipantId(UUID userId, UUID groupId) {
        this.userId = userId;
        this.groupId = groupId;
    }

    // Getters e Setters
    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public UUID getGroupId() {
        return groupId;
    }

    public void setGroupId(UUID groupId) {
        this.groupId = groupId;
    }

    // `equals()` e `hashCode()` são ESSENCIAIS para chaves compostas
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        GroupParticipantId that = (GroupParticipantId) o;
        return Objects.equals(userId, that.userId) &&
               Objects.equals(groupId, that.groupId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, groupId);
    }
}