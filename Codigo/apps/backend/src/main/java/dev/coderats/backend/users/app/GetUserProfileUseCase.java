package dev.coderats.backend.users.app;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.users.app.port.GroupQueryPort;
import dev.coderats.backend.users.app.port.UserPointsQueryPort;
import dev.coderats.backend.users.app.port.UserRepository;
import dev.coderats.backend.users.app.query.GroupSummaryView;
import dev.coderats.backend.users.app.query.PublicProfileView;
import dev.coderats.backend.users.app.query.PublicProfileWithGroupsView;
import dev.coderats.backend.users.domain.User;
import dev.coderats.backend.users.domain.UserId;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class GetUserProfileUseCase {
    
    private final UserRepository userRepository;
    private final GroupQueryPort groupQueryPort;
    private final UserPointsQueryPort userPointsQueryPort;

    @Transactional(readOnly = true)
    public PublicProfileWithGroupsView execute(UserId targetUserId, UserId authenticatedUserId) {
        User user = userRepository.findById(targetUserId)
            .orElseThrow(() -> new RuntimeException("Usuário não encontrado")); 
        
        int points = userPointsQueryPort.getTotalPointsForUser(targetUserId);
        
        PublicProfileView profileView = new PublicProfileView(
            user.id().toString(),
            user.name(),
            user.image().orElse(null),
            user.githubUser().orElse(null),
            points
        );
        
        List<GroupSummaryView> commonGroups = groupQueryPort.findCommonGroups(targetUserId, authenticatedUserId);
        
        return new PublicProfileWithGroupsView(profileView, commonGroups);
    }
}