package dev.coderats.backend.checkins.app;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.checkins.app.command.CreateCheckinCommand;
import dev.coderats.backend.checkins.app.port.CheckinCommitRepository;
import dev.coderats.backend.checkins.app.port.CheckinRepository;
import dev.coderats.backend.checkins.app.port.CommitRepository;
import dev.coderats.backend.checkins.app.port.GroupMembershipQueryPort;
import dev.coderats.backend.checkins.domain.Checkin;
import dev.coderats.backend.checkins.domain.CheckinCommit;
import dev.coderats.backend.checkins.domain.Commit;
import dev.coderats.backend.shared.domain.Clock;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CreateCheckinUseCase {
    private final CheckinRepository checkinRepository;
    private final CommitRepository commitRepository;
    private final CheckinCommitRepository checkinCommitRepository;
    private final GroupMembershipQueryPort groupMembershipQueryPort;
    private final Clock clock;
    
    @Transactional
    public Checkin execute(CreateCheckinCommand command) {
        if (!groupMembershipQueryPort.isUserMemberOfGroup(command.authorId(), command.groupId())) {
            throw new RuntimeException("Acesso negado: Usuário não é membro do grupo."); 
        }

        Checkin checkin = Checkin.create(
            command.authorId(),
            command.groupId(),
            command.title(),
            command.description(),
            command.image(),
            command.summaryAi(),
            100, 
            clock
        );
        checkinRepository.save(checkin);
        
        if (command.commits() != null && !command.commits().isEmpty()) {
            for (var commitData : command.commits()) {
                Commit commit = commitRepository.findByHash(commitData.hash())
                    .orElseGet(() -> {
                        Commit newCommit = Commit.create(commitData.link(), commitData.title(), commitData.hash(), clock);
                        commitRepository.save(newCommit);
                        return newCommit;
                    });
                
                CheckinCommit association = CheckinCommit.create(checkin.id(), commit.id(), clock);
                checkinCommitRepository.save(association);
            }
        }
        return checkin;
    }
}