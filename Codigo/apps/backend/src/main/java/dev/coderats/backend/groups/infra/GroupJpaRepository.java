package dev.coderats.backend.groups.infra;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

// Interface JPA para operações de banco de dados relacionadas a grupos
public interface GroupJpaRepository extends JpaRepository<GroupEntity, UUID> {

    
    boolean existsByCode(String code);

    Optional<GroupEntity> findByCode(String code);
}