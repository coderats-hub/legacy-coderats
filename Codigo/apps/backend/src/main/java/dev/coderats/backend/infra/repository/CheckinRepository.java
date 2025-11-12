package dev.coderats.backend.infra.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import dev.coderats.backend.domain.Checkin;

@Repository
public interface CheckinRepository extends JpaRepository<Checkin, UUID> {
    
    @Query(value = """
            SELECT c.*
            FROM checkins c
            JOIN group_participants gp ON gp.group_id = c.group_id
            WHERE gp.user_id = CAST(:userId AS UUID)
            AND c.deleted_at IS NULL
            ORDER BY c.created_at DESC
            LIMIT :limit OFFSET :offset
            """, nativeQuery = true)
    List<Checkin> findFeedByUserId(@Param("userId") String userId, @Param("limit") int limit, @Param("offset") int offset);
    
    @Query(value = """
            SELECT c.*
            FROM checkins c
            WHERE c.group_id = CAST(:groupId AS UUID)
            AND c.deleted_at IS NULL
            ORDER BY c.created_at DESC
            LIMIT :limit OFFSET :offset
            """, nativeQuery = true)
    List<Checkin> findByGroupIdOrderByCreatedAtDesc(@Param("groupId") String groupId, @Param("limit") int limit, @Param("offset") int offset);
}
