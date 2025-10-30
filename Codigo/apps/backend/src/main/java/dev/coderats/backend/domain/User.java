package dev.coderats.backend.domain;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

@Entity
@Table(name = "users")
public class User {

  @Id
  @GeneratedValue
  private UUID id;

  @Column(nullable = false)
  private String name;

  @Column(unique = true)
  private String email;

  @Column(columnDefinition = "TEXT")
  private String image;

  @Column(name = "github_user", nullable = false, unique = true, length = 100)
  private String githubUser;

  @Column(name = "github_id", nullable = false, unique = true)
  private Long githubId;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @Column(name = "deleted_at")
  private OffsetDateTime deletedAt;

  @PrePersist
  void prePersist() {
    createdAt = updatedAt = OffsetDateTime.now(ZoneOffset.UTC);
  }

  @PreUpdate
  void preUpdate() {
    updatedAt = OffsetDateTime.now(ZoneOffset.UTC);
  }

  // =============================================
  // GETTERS
  // =============================================

  public UUID getId() {
    return id;
  }

  public String getName() {
    return name;
  }

  public String getEmail() {
    return email;
  }

  public String getImage() {
    return image;
  }

  public String getGithubUser() {
    return githubUser;
  }

  public Long getGithubId() {
    return githubId;
  }

  public OffsetDateTime getCreatedAt() {
    return createdAt;
  }

  public OffsetDateTime getUpdatedAt() {
    return updatedAt;
  }

  public OffsetDateTime getDeletedAt() {
    return deletedAt;
  }

  // =============================================
  // SETTERS
  // =============================================

  public void setId(UUID id) {
    this.id = id;
  }

  public void setName(String name) {
    this.name = name;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public void setImage(String image) {
    this.image = image;
  }

  public void setGithubUser(String githubUser) {
    this.githubUser = githubUser;
  }

  public void setGithubId(Long githubId) {
    this.githubId = githubId;
  }

  public void setCreatedAt(OffsetDateTime createdAt) {
    this.createdAt = createdAt;
  }

  public void setUpdatedAt(OffsetDateTime updatedAt) {
    this.updatedAt = updatedAt;
  }

  public void setDeletedAt(OffsetDateTime deletedAt) {
    this.deletedAt = deletedAt;
  }
}
