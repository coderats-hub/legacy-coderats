package dev.coderats.backend.groups.app;
// (Imports)
import dev.coderats.backend.groups.app.port.CheckinQueryPort;
import dev.coderats.backend.groups.app.port.GroupRepository;
import dev.coderats.backend.groups.app.port.MembershipRepository;
import dev.coderats.backend.groups.app.query.GroupDetailsView;
import dev.coderats.backend.groups.app.query.ParticipantView;
import dev.coderats.backend.groups.app.query.CheckinSummaryView;
import dev.coderats.backend.groups.domain.Group;
import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.users.app.port.UserQueryPort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class GetGroupDetailsUseCase {
    
    private final GroupRepository groupRepository;
    private final MembershipRepository membershipRepository;
    private final CheckinQueryPort checkinQueryPort;
    private final UserQueryPort userQueryPort;

    public GetGroupDetailsUseCase(
            GroupRepository groupRepository, 
            MembershipRepository membershipRepository, 
            CheckinQueryPort checkinQueryPort,
            UserQueryPort userQueryPort 
    ) {
        this.groupRepository = groupRepository;
        this.membershipRepository = membershipRepository;
        this.checkinQueryPort = checkinQueryPort;
        this.userQueryPort = userQueryPort;
    }

    @Transactional(readOnly = true)
    public GroupDetailsView execute(GroupId groupId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new RuntimeException("Grupo não encontrado")); 

        List<ParticipantView> participants = membershipRepository.findByGroupId(groupId)
                .stream()
                .map(membership -> {
                    var userDetails = userQueryPort.getUserSummary(membership.userId());
                    
                    return new ParticipantView(
                            membership.userId(),
                            userDetails.name(),
                            userDetails.image(),
                            membership.points()
                    );
                })
                .collect(Collectors.toList());

        List<CheckinSummaryView> recentCheckins = checkinQueryPort.findRecentCheckinsByGroupId(groupId, 5);

        return new GroupDetailsView(
                group,
                participants,
                recentCheckins
        );
    }
}