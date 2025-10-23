package dev.coderats.backend.groups.infra;

import java.time.Instant;
import java.util.UUID;

import dev.coderats.backend.groups.domain.GroupMethod;
import dev.coderats.backend.groups.domain.GroupStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// Faz a conexão entre o banco de dados e a aplicação
// Se o banco de dados mudar, só precisamos alterar essa classe
@Entity
@Table(name = "groups")
@Getter
@Setter
@NoArgsConstructor
public class GroupEntity {

    @Id
    private UUID id;

    @Column(nullable = false)
    private String name;

    private String description;

    private String image;

    @Column(unique = true)
    private String code;

    @Column(name = "method")
    @Enumerated(EnumType.STRING) 
    private GroupMethod method;

    @Column(name = "status", nullable = false)
    @Enumerated(EnumType.STRING)
    private GroupStatus status;

    private String repository; 

    @Column(name = "start_date", nullable = false)
    private Instant startDate;

    @Column(name = "end_date")
    private Instant endDate;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Column(name = "deleted_at")
    private Instant deletedAt;
}