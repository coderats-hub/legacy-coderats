package dev.coderats.backend.users.infra;

import org.springframework.stereotype.Component;

import dev.coderats.backend.users.app.port.UserQueryPort;
import dev.coderats.backend.users.app.query.UserSummaryView;
import dev.coderats.backend.users.domain.UserId;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class UserQueryPortImpl implements UserQueryPort {

    private final UserJpaRepository jpaRepository;

    @Override
    public UserSummaryView getUserSummary(UserId userId) {
        return jpaRepository.findById(userId.asUuid())
            .map(entity -> new UserSummaryView( 
                entity.getId().toString(),
                entity.getName(),
                entity.getImage()
            ))
            .orElse(new UserSummaryView(userId.toString(), "Usuário Excluído", null)); 
    }
}