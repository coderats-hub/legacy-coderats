package dev.coderats.backend.infra.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Pageable;
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
            WHERE gp.user_id = :userId
            AND c.deleted_at IS NULL
            ORDER BY c.created_at DESC
            LIMIT :limit OFFSET :offset
            """, nativeQuery = true)
    List<Checkin> findFeedByUserId(@Param("userId") UUID userId, @Param("limit") int limit, @Param("offset") int offset);

    @Query(value = """
            SELECT c.*
            FROM checkins c
            WHERE c.group_id = :groupId
            AND c.deleted_at IS NULL
            ORDER BY c.points DESC
            LIMIT :limit OFFSET :offset
            """, nativeQuery = true)
    List<Checkin> findByGroupIdOrderByPointsDesc(@Param("groupId") UUID groupId, @Param("limit") int limit, @Param("offset") int offset);

    @Query("""
            SELECT c FROM Checkin c
            WHERE c.groupId = :groupId
            AND c.deletedAt IS NULL
            ORDER BY c.createdAt DESC
            """)
    List<Checkin> findRecentByGroupId(@Param("groupId") UUID groupId, Pageable pageable);
}
