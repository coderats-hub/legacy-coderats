package dev.coderats.backend.groups.infra;

import java.time.Instant;

import dev.coderats.backend.groups.domain.GroupRole;
import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// Entidade JPA que representa a associação entre um usuário e um grupo
@Entity
@Table(name = "group_participants")
@Getter
@Setter
@NoArgsConstructor
public class MembershipEntity {

    @EmbeddedId
    private MembershipEntityId id;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private GroupRole role;

    @Column(nullable = false)
    private int points;

    @Column(name = "joined_at", nullable = false, updatable = false)
    private Instant joinedAt;
}