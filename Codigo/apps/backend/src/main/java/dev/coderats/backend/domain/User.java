package dev.coderats.backend.domain;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID; // Importar List

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(nullable = false)
    private String name;
    
    @Column(unique = true)
    private String email;
    
    private String image;

    @Column(name = "github_user", nullable = false, unique = true)
    private String githubUser;

    @Column(name = "github_id", nullable = false, unique = true)
    private Long githubId; // Mapeado de BIGINT

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;
    
    @Column(name = "deleted_at")
    private OffsetDateTime deletedAt;
    
    // --- A RELAÇÃO QUE FALTAVA ---
    // Um Usuário tem Muitas "participações" (GroupParticipant)
    // "mappedBy = 'user'" diz ao Hibernate que o campo 'user'
    // na classe GroupParticipant é o dono deste relacionamento.

    @JsonIgnore
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<GroupParticipant> participants;
    
    // --- Fim da Relação ---

    // (Getters e Setters para todos os campos, incluindo a nova lista 'participants')

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public String getGithubUser() { return githubUser; }
    public void setGithubUser(String githubUser) { this.githubUser = githubUser; }
    public Long getGithubId() { return githubId; }
    public void setGithubId(Long githubId) { this.githubId = githubId; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; }
    public OffsetDateTime getDeletedAt() { return deletedAt; }
    public void setDeletedAt(OffsetDateTime deletedAt) { this.deletedAt = deletedAt; }
    
    // Getter e Setter para a relação
    public List<GroupParticipant> getParticipants() { return participants; }
    public void setParticipants(List<GroupParticipant> participants) { this.participants = participants; }
}
