// Arquivo: badges/infra/BadgeQueryPortImpl.java
package dev.coderats.backend.badges.infra;

import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import dev.coderats.backend.badges.app.port.BadgeRepository;
import dev.coderats.backend.badges.app.port.UserBadgeRepository;
import dev.coderats.backend.badges.domain.Badge;
import dev.coderats.backend.badges.domain.UserBadge;
import dev.coderats.backend.users.app.port.BadgeQueryPort;
import dev.coderats.backend.users.app.query.BadgeView;
import dev.coderats.backend.users.domain.UserId;
import lombok.RequiredArgsConstructor;

/**
 * Implementação da PORTA do módulo 'users'.
 * Permite que 'users' consulte as badges que um usuário possui.
 */
@Component
@RequiredArgsConstructor
public class BadgeQueryPortImpl implements BadgeQueryPort {

    private final UserBadgeRepository userBadgeRepository;
    private final BadgeRepository badgeRepository; // Para buscar os detalhes

    @Override
    public List<BadgeView> findBadgesByUserId(UserId userId) {
        // 1. Encontra todos os registros de conquista (UserBadge)
        List<UserBadge> achievements = userBadgeRepository.findByUserId(userId);
        
        // 2. Para cada conquista, busca os detalhes da Badge
        return achievements.stream()
            .map(achievement -> {
                // 3. Busca a definição da badge
                Optional<Badge> badgeOpt = badgeRepository.findById(achievement.badgeId());
                if (badgeOpt.isEmpty()) {
                    return null; // Badge foi deletada, mas o usuário ainda a tem
                }
                Badge badge = badgeOpt.get();
                
                // 4. Constrói o DTO 'BadgeView' (definido pelo 'users')
                return new BadgeView(
                    badge.id().toString(),
                    badge.name(),
                    badge.image(),
                    badge.description().orElse(null),
                    achievement.points() // Usa os pontos do *momento da conquista*
                );
            })
            .filter(Objects::nonNull)
            .collect(Collectors.toList());
    }
}