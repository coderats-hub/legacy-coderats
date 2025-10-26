package dev.coderats.backend.groups.infra;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Repository;

import dev.coderats.backend.groups.app.port.MembershipRepository;
import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.groups.domain.GroupRole;
import dev.coderats.backend.groups.domain.Membership;
import dev.coderats.backend.users.domain.UserId;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class MembershipRepositoryImpl implements MembershipRepository {

    private final MembershipJpaRepository jpaRepository;
    private final MembershipMapper mapper;

    @Override
    public void save(Membership membership) {
        MembershipEntity entity = mapper.toEntity(membership);
        jpaRepository.save(entity);
    }

    @Override
    public Optional<Membership> findById(GroupId groupId, UserId userId) {
        MembershipEntityId id = new MembershipEntityId(
                userId.asUuid(),
                groupId.asUuid()
        );
        return jpaRepository.findById(id).map(mapper::toDomain);
    }

    @Override
    public List<Membership> findByGroupId(GroupId groupId) {
        return jpaRepository.findById_GroupId(groupId.asUuid())
                .stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
    }

    @Override
    public List<Membership> findByUserId(UserId userId) {
        return jpaRepository.findById_UserId(userId.asUuid())
                .stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
    }

    @Override
    public void delete(Membership membership) {
        MembershipEntity entity = mapper.toEntity(membership);
        jpaRepository.delete(entity);
    }

    @Override
    public int countAdmins(GroupId groupId) {
        return jpaRepository.countById_GroupIdAndRole(groupId.asUuid(), GroupRole.ADMIN);
    }
}
