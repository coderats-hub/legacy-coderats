package dev.coderats.backend.features.group;

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

@Entity
@Table(name = "groups") // nome da tabela no banco
public class Group {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(nullable = false)
    private String name;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(columnDefinition = "TEXT")
    private String image;
    
    @Column(unique = true, length = 50)
    private String code;
    
    @Column(columnDefinition = "TEXT")
    private String method;
    
    @Column(nullable = false)
    private boolean status = true;
    
    @Column(columnDefinition = "TEXT")
    private String repository;
    
    @Column(name = "start_date", nullable = false)
    private OffsetDateTime startDate;
    
    @Column(name = "end_date")
    private OffsetDateTime endDate;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @Column(name = "deleted_at")
    private OffsetDateTime deletedAt;

    public Group() {
    }

    public Group(UUID id, String name, String description, String image, String code, String repository, String method,
                 boolean status, OffsetDateTime startDate, OffsetDateTime endDate) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.image = image;
        this.code = code;
        this.repository = repository;
        this.method = method;
        this.status = status;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    @PrePersist
    void prePersist() {
        createdAt = updatedAt = OffsetDateTime.now(ZoneOffset.UTC);
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = OffsetDateTime.now(ZoneOffset.UTC);
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getRepository() {
        return repository;
    }

    public void setRepository(String repository) {
        this.repository = repository;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public OffsetDateTime getStartDate() {
        return startDate;
    }

    public void setStartDate(OffsetDateTime startDate) {
        this.startDate = startDate;
    }

    public OffsetDateTime getEndDate() {
        return endDate;
    }

    public void setEndDate(OffsetDateTime endDate) {
        this.endDate = endDate;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(OffsetDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public OffsetDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(OffsetDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }
}
