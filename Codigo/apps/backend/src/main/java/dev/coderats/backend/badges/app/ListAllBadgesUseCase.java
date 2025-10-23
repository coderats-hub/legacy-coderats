package dev.coderats.backend.badges.app;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.badges.app.port.BadgeRepository;
import dev.coderats.backend.badges.domain.Badge;
import dev.coderats.backend.users.app.query.BadgeView; 
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ListAllBadgesUseCase {
    
    private final BadgeRepository badgeRepository;

    @Transactional(readOnly = true)
    public List<BadgeView> execute() {
        List<Badge> badges = badgeRepository.findAll();
        
        return badges.stream()
            .map(this::toBadgeView)
            .collect(Collectors.toList());
    }
    
    private BadgeView toBadgeView(Badge badge) {
        return new BadgeView(
            badge.id().toString(),
            badge.name(),
            badge.image(),
            badge.description().orElse(null),
            badge.points()
        );
    }
}