package dev.coderats.backend.groups.api;

import org.springframework.stereotype.Component;

import dev.coderats.backend.groups.api.dto.GroupCreateDTO;
import dev.coderats.backend.groups.api.dto.GroupResponseDTO;
import dev.coderats.backend.groups.app.command.CreateGroupCommand;
import dev.coderats.backend.groups.domain.Group;
import dev.coderats.backend.groups.domain.GroupMethod;
import dev.coderats.backend.users.domain.UserId;

@Component
public class GroupApiMapper {

    public CreateGroupCommand toCommand(GroupCreateDTO dto, UserId creatorId) {
        
        GroupMethod methodEnum = null; 
        if (dto.method() != null) {
            try {
                methodEnum = GroupMethod.valueOf(dto.method().toUpperCase());
            } catch (IllegalArgumentException e) {
            }
        }
        
        return new CreateGroupCommand(
                dto.name(),
                dto.description(),
                dto.image(),
                dto.code(),
                methodEnum,
                dto.repository(),
                dto.startDate(),
                dto.endDate(),
                creatorId
        );
    }

    public GroupResponseDTO toResponseDTO(Group group) {
        return new GroupResponseDTO(
                group.id().asUuid(),
                group.name(),
                group.description(),
                group.image(),
                group.code(),
                group.method().toString(),
                group.status().toString(),
                group.repository().orElse(null),
                group.startDate(),
                group.endDate().orElse(null),
                group.createdAt()
        );
    }
}