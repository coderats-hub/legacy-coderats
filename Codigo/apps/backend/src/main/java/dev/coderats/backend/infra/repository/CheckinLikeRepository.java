package dev.coderats.backend.infra.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import dev.coderats.backend.domain.CheckinLike;
import dev.coderats.backend.domain.CheckinLikeId;

@Repository
public interface CheckinLikeRepository extends JpaRepository<CheckinLike, CheckinLikeId> {
    
    boolean existsByCheckinIdAndUserId(UUID checkinId, UUID userId);
    
    void deleteByCheckinIdAndUserId(UUID checkinId, UUID userId);
    
    long countByCheckinId(UUID checkinId);
}
