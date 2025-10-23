package dev.coderats.backend.groups.infra;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// Classe que representa a chave composta da entidade MembershipEntity
@Embeddable 
@Getter
@Setter
@NoArgsConstructor
public class MembershipEntityId implements Serializable {

    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "group_id")
    private UUID groupId;

    public MembershipEntityId(UUID userId, UUID groupId) {
        this.userId = userId;
        this.groupId = groupId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        MembershipEntityId that = (MembershipEntityId) o;
        return Objects.equals(userId, that.userId) &&
               Objects.equals(groupId, that.groupId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, groupId);
    }
}