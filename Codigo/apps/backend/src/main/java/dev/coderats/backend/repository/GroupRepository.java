package dev.coderats.backend.repository;

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

    @Query(value = """
            SELECT g.*
            FROM groups g
            JOIN group_participants gp ON gp.group_id = g.id
            WHERE gp.user_id = CAST(:userId AS UUID)
            AND g.deleted_at IS NULL
            ORDER BY g.created_at DESC
            """, nativeQuery = true)
    List<Group> findGroupsByUserId(@Param("userId") String userId);
    
    Optional<Group> findByCode(String code);
}
