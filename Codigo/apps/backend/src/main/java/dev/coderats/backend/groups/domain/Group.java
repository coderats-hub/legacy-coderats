package dev.coderats.backend.groups.domain;

import java.net.URI;
import java.time.Instant;
import java.util.Objects;
import java.util.Optional;

import dev.coderats.backend.shared.domain.Clock;

// Relação básica de um grupo
// Funciona como um model padrão
// Contém atributos e métodos relacionados a um grupo como GroupId, GroupMethod, GroupStatus, etc.
public class Group {

    private final GroupId id;
    private String name;
    private String image;
    private final String code; // Variáveis com final não podem ser alteradas após a criação
    private final GroupMethod method; // É um enum definido em GroupMethod.java, para não ter erros de variações
    private GroupStatus status;
    private String description;
    private URI repository;
    private final Instant startDate;
    private final Instant endDate;

    private final Instant createdAt;
    private Instant updatedAt;
    private Instant deletedAt;

    private Group(
            GroupId id,
            String name,
            String image,
            String code,
            GroupMethod method,
            GroupStatus status,
            String description,
            URI repository,
            Instant startDate,
            Instant endDate,
            Instant createdAt,
            Instant updatedAt,
            Instant deletedAt
    ) {
        this.id = Objects.requireNonNull(id);
        this.name = Objects.requireNonNull(name);
        this.image = image;
        this.code = Objects.requireNonNull(code);
        this.method = method;
        this.status = Objects.requireNonNull(status);
        this.description = description;
        this.repository = repository;
        this.startDate = Objects.requireNonNull(startDate);
        this.endDate = endDate;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.deletedAt = deletedAt;
    }

    public static Group create(String name, String image, String code, GroupMethod method,
                               GroupStatus status, String description, URI repository,
                               Instant startDate, Instant endDate, Clock clock) {

        return new Group(
                GroupId.newId(),
                name,
                image,
                code,
                method,
                status,
                description,
                repository,
                startDate,
                endDate,
                clock.now(),
                clock.now(),
                null
        );
    }

    public static Group reconstitute(GroupId id, String name, String image, String code, GroupMethod method,
                                     GroupStatus status, String description, URI repository,
                                     Instant startDate, Instant endDate,
                                     Instant createdAt, Instant updatedAt, Instant deletedAt) {
        return new Group(id, name, image, code, method, status, description,
                repository, startDate, endDate, createdAt, updatedAt, deletedAt);
    }

    public void updateDetails(String name, String description, URI repository, Clock clock) {
        this.name = name;
        this.description = description;
        this.repository = repository;
        this.updatedAt = clock.now();
    }

    public void markDeleted(Clock clock) {
        this.deletedAt = clock.now();
        this.status = GroupStatus.INACTIVE;
    }

    public GroupId id() { return id; }
    public String name() { return name; }
    public String image() { return image; }
    public String code() { return code; }
    public GroupMethod method() { return method; }
    public GroupStatus status() { return status; }
    public String description() { return description; }
    public Optional<URI> repository() { return Optional.ofNullable(repository); }
    public Instant startDate() { return startDate; }
    public Optional<Instant> endDate() { return Optional.ofNullable(endDate); }
    public Instant createdAt() { return createdAt; }
    public Instant updatedAt() { return updatedAt; }
    public Optional<Instant> deletedAt() { return Optional.ofNullable(deletedAt); }
}
