package dev.coderats.backend.groups.infra;

import java.net.URI;
import java.net.URISyntaxException;

import org.springframework.stereotype.Component;

import dev.coderats.backend.groups.domain.Group;
import dev.coderats.backend.groups.domain.GroupId;


// Mapeia entre GroupEntity (banco de dados) e Group (domínio)
@Component
public class GroupMapper {

    public Group toDomain(GroupEntity entity) {
        if (entity == null) return null;

        URI repositoryUri = null;
        if (entity.getRepository() != null && !entity.getRepository().isBlank()) {
            try {
                repositoryUri = new URI(entity.getRepository());
            } catch (URISyntaxException e) {
            }
        }

        return Group.reconstitute(
                GroupId.of(entity.getId().toString()),
                entity.getName(),
                entity.getImage(),
                entity.getCode(),
                entity.getMethod(),
                entity.getStatus(),
                entity.getDescription(),
                repositoryUri,
                entity.getStartDate(),
                entity.getEndDate(),
                entity.getCreatedAt(),
                entity.getUpdatedAt(),
                entity.getDeletedAt()
        );
    }

    public GroupEntity toEntity(Group domain) {
        if (domain == null) return null;
        
        GroupEntity entity = new GroupEntity();
        
        entity.setId(domain.id().asUuid());
        entity.setName(domain.name());
        entity.setImage(domain.image());
        entity.setCode(domain.code());
        entity.setMethod(domain.method());
        entity.setStatus(domain.status());
        entity.setDescription(domain.description());
        entity.setRepository(domain.repository().map(URI::toString).orElse(null));
        entity.setStartDate(domain.startDate());
        entity.setEndDate(domain.endDate().orElse(null));
        entity.setCreatedAt(domain.createdAt());
        entity.setUpdatedAt(domain.updatedAt());
        entity.setDeletedAt(domain.deletedAt().orElse(null));
        
        return entity;
    }
}