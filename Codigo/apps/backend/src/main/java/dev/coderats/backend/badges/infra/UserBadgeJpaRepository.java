package dev.coderats.backend.badges.infra;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
public interface UserBadgeJpaRepository extends JpaRepository<UserBadgeEntity, UserBadgeEntityId> {
    List<UserBadgeEntity> findById_UserId(UUID userId);
}