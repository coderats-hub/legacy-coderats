package dev.coderats.backend.users.infra;

import org.springframework.stereotype.Component;

import dev.coderats.backend.users.domain.User;
import dev.coderats.backend.users.domain.UserId;

@Component
public class UserMapper {

    public User toDomain(UserEntity entity) {
        if (entity == null) return null;
        
        return User.reconstitute(
            UserId.of(entity.getId().toString()),
            entity.getName(),
            entity.getEmail(),
            entity.getImage(),
            entity.getGithubUser(),
            entity.getCreatedAt(),
            entity.getUpdatedAt(),
            entity.getDeletedAt()
        );
    }
    
    public void toEntity(User domain, UserEntity entity) {
        entity.setId(domain.id().asUuid());
        entity.setName(domain.name());
        entity.setEmail(domain.email()); 
        entity.setImage(domain.image().orElse(null));
        entity.setGithubUser(domain.githubUser().orElse(null));
        entity.setCreatedAt(domain.createdAt());
        entity.setUpdatedAt(domain.updatedAt());
        entity.setDeletedAt(domain.deletedAt().orElse(null));
    }

    public UserEntity toNewEntity(User domain) {
        UserEntity entity = new UserEntity();
        this.toEntity(domain, entity);
        return entity;
    }
}