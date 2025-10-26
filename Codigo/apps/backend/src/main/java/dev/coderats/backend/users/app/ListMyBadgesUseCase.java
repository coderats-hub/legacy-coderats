package dev.coderats.backend.users.app;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.users.app.port.BadgeQueryPort;
import dev.coderats.backend.users.app.query.BadgeView;
import dev.coderats.backend.users.domain.UserId;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ListMyBadgesUseCase {
    
    private final BadgeQueryPort badgeQueryPort;
    
    @Transactional(readOnly = true)
    public List<BadgeView> execute(UserId userId) {
        return badgeQueryPort.findBadgesByUserId(userId);
    }
}