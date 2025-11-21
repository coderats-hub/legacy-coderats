package dev.coderats.backend.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param; // Importe o ID
import org.springframework.stereotype.Repository;

import dev.coderats.backend.domain.GroupParticipant;
import dev.coderats.backend.domain.GroupParticipantId;

@Repository
public interface GroupParticipantRepository extends JpaRepository<GroupParticipant, GroupParticipantId> {
    
    List<GroupParticipant> findByIdGroupId(UUID groupId);
    
    List<GroupParticipant> findByIdUserId(UUID userId);
    
    Optional<GroupParticipant> findByIdUserIdAndIdGroupId(UUID userId, UUID groupId);
    
    void deleteByIdUserIdAndIdGroupId(UUID userId, UUID groupId);
    
    void deleteByIdUserIdInAndIdGroupId(List<UUID> userIds, UUID groupId);
    
    @Query("SELECT COUNT(gp) > 0 FROM GroupParticipant gp WHERE gp.id.userId = :userId AND gp.id.groupId = :groupId")
    boolean existsByUserIdAndGroupId(@Param("userId") UUID userId, @Param("groupId") UUID groupId);
}