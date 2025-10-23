// Arquivo: badges/infra/BadgeJpaRepository.java
package dev.coderats.backend.badges.infra;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
public interface BadgeJpaRepository extends JpaRepository<BadgeEntity, UUID> {}
