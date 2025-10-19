package dev.coderats.backend.groups.infra;

import org.springframework.stereotype.Component;

import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.groups.domain.Membership;
import dev.coderats.backend.users.domain.UserId;

// Mapper para converter entre MembershipEntity e Membership (domínio)
@Component
public class MembershipMapper {

    public Membership toDomain(MembershipEntity entity) {
        if (entity == null) return null;

        return Membership.reconstitute(
                GroupId.of(entity.getId().getGroupId().toString()),
                UserId.of(entity.getId().getUserId().toString()),
                entity.getRole(),
                entity.getPoints(),
                entity.getJoinedAt()
        );
    }

    public MembershipEntity toEntity(Membership domain) {
        if (domain == null) return null;

        MembershipEntityId id = new MembershipEntityId(
                domain.userId().asUuid(),
                domain.groupId().asUuid()
        );
        
        MembershipEntity entity = new MembershipEntity();
        entity.setId(id);
        entity.setRole(domain.role());
        entity.setPoints(domain.points());
        entity.setJoinedAt(domain.joinedAt());
        
        return entity;
    }
}