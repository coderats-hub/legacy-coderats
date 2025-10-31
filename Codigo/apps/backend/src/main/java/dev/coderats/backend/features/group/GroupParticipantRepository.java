package dev.coderats.backend.features.group;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface GroupParticipantRepository extends JpaRepository<GroupParticipant, GroupParticipantId> {
    
    List<GroupParticipant> findByGroupId(UUID groupId);
    
    List<GroupParticipant> findByUserId(UUID userId);
    
    Optional<GroupParticipant> findByUserIdAndGroupId(UUID userId, UUID groupId);
    
    void deleteByUserIdAndGroupId(UUID userId, UUID groupId);
    
    void deleteByUserIdInAndGroupId(List<UUID> userIds, UUID groupId);
    
    @Query("SELECT COUNT(gp) > 0 FROM GroupParticipant gp WHERE gp.userId = :userId AND gp.groupId = :groupId")
    boolean existsByUserIdAndGroupId(@Param("userId") UUID userId, @Param("groupId") UUID groupId);
}
