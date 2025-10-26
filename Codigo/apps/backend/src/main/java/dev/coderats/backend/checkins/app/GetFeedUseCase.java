package dev.coderats.backend.checkins.app;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.checkins.app.port.CheckinRepository;
import dev.coderats.backend.checkins.app.port.GroupMembershipQueryPort;
import dev.coderats.backend.checkins.app.query.FeedCheckinView;
import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.users.domain.UserId;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class GetFeedUseCase {
    private final CheckinRepository checkinRepository;
    private final GroupMembershipQueryPort groupMembershipQueryPort;
    
    @Transactional(readOnly = true)
    public List<FeedCheckinView> execute(UserId authenticatedUserId, int limit, int offset) {
        // 1. Buscar os grupos que o usuário participa
        List<GroupId> groupIds = groupMembershipQueryPort.findGroupIdsByUserId(authenticatedUserId);
        
        if (groupIds.isEmpty()) {
            return List.of(); // Usuário não está em grupos, feed vazio.
        }
        
        // 2. Delegar a consulta complexa do Feed para o repositório
        return checkinRepository.findFeed(groupIds, authenticatedUserId, limit, offset);
    }
}