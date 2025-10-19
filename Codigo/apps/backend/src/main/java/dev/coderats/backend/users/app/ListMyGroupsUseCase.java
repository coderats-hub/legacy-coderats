package dev.coderats.backend.users.app;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.groups.app.query.GroupDetailsView;
import dev.coderats.backend.users.app.port.GroupQueryPort;
import dev.coderats.backend.users.domain.UserId;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ListMyGroupsUseCase {
    
    private final GroupQueryPort groupQueryPort;
    
    @Transactional(readOnly = true)
    public List<GroupDetailsView> execute(UserId userId) {
        // Este caso de uso é um simples "proxy" para a porta do módulo 'groups'
        return groupQueryPort.findGroupsWithDetailsByUserId(userId);
    }
}