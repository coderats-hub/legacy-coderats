package dev.coderats.backend.infra.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import dev.coderats.backend.domain.Group;

@Repository
public interface GroupRepository extends JpaRepository<Group, UUID> {

    /**
     * Encontra todos os grupos dos quais um usuário participa.
     * (Corrigido para aceitar UUID, como discutimos)
     */
    @Query("SELECT g FROM Group g JOIN g.participants p WHERE p.id.userId = :userId")
    List<Group> findGroupsByUserId(@Param("userId") UUID userId);

    /**
     * Encontra um grupo pelo seu código de convite.
     * (Necessário para o GroupService)
     */
    Optional<Group> findByCode(String code);

    /**
     * ADICIONE ESTE MÉTODO
     * Encontra grupos que ambos os usuários (userId1 e userId2) participam.
     */
    @Query("SELECT g FROM Group g "
            + "JOIN g.participants p1 "
            + "JOIN g.participants p2 "
            + "WHERE p1.id.userId = :userId1 "
            + "AND p2.id.userId = :userId2")
    List<Group> findCommonGroups(@Param("userId1") UUID userId1, @Param("userId2") UUID userId2);

}