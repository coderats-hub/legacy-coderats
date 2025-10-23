package dev.coderats.backend.groups.infra;

import java.util.Optional;

import org.springframework.stereotype.Repository;

import dev.coderats.backend.groups.app.port.GroupRepository;
import dev.coderats.backend.groups.domain.Group;
import dev.coderats.backend.groups.domain.GroupId;
import lombok.RequiredArgsConstructor;

// Vai implementar o repositório de grupos usando JPA
@Repository
@RequiredArgsConstructor 
public class GroupRepositoryImpl implements GroupRepository {

    private final GroupJpaRepository jpaRepository; 
    private final GroupMapper mapper;              

    @Override
    public void save(Group group) {
        GroupEntity entity = mapper.toEntity(group);
        jpaRepository.save(entity);
    }

    @Override
    public Optional<Group> findById(GroupId groupId) {
        return jpaRepository.findById(groupId.asUuid())
                .map(mapper::toDomain); 
    }

    @Override
    public boolean existsByCode(String code) {
        return jpaRepository.existsByCode(code);
    }

    @Override
    public Optional<Group> findByCode(String code) {
        return jpaRepository.findByCode(code)
                .map(mapper::toDomain);
    }
}