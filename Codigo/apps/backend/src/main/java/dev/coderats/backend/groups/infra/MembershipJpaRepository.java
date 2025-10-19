package dev.coderats.backend.groups.infra;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import dev.coderats.backend.groups.domain.GroupRole;

public interface MembershipJpaRepository extends JpaRepository<MembershipEntity, MembershipEntityId> {

    List<MembershipEntity> findById_GroupId(UUID groupId);

    List<MembershipEntity> findById_UserId(UUID userId);
    
    int countById_GroupIdAndRole(UUID groupId, GroupRole role);
}