package dev.coderats.backend.groups.app;

import java.util.Objects;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.groups.app.command.UpdateGroupCommand;
import dev.coderats.backend.groups.app.port.GroupRepository;
import dev.coderats.backend.groups.app.port.MembershipRepository;
import dev.coderats.backend.groups.app.query.GroupDetailsView;
import dev.coderats.backend.groups.domain.Group;
import dev.coderats.backend.groups.domain.GroupRole;
import dev.coderats.backend.groups.domain.Membership;
import dev.coderats.backend.shared.domain.Clock;

@Service
public class UpdateGroupUseCase {

    private final GroupRepository groupRepository;
    private final MembershipRepository membershipRepository;
    private final GetGroupDetailsUseCase getGroupDetailsUseCase; 
    private final Clock clock;

    public UpdateGroupUseCase(GroupRepository groupRepo, MembershipRepository memberRepo, 
                              GetGroupDetailsUseCase getGroupDetailsUseCase, Clock clock) {
        this.groupRepository = groupRepo;
        this.membershipRepository = memberRepo;
        this.getGroupDetailsUseCase = getGroupDetailsUseCase;
        this.clock = clock;
    }

    @Transactional
    public GroupDetailsView execute(UpdateGroupCommand command) {
        Membership updaterMembership = membershipRepository.findById(command.groupId(), command.updaterId())
                .orElseThrow(() -> new RuntimeException("Acesso Negado: Você não é membro")); 
        if (updaterMembership.role() != GroupRole.ADMIN) {
            throw new RuntimeException("Acesso Negado: Apenas admins podem atualizar"); 
        }

        Group group = groupRepository.findById(command.groupId())
                .orElseThrow(() -> new RuntimeException("Grupo não encontrado"));

        group.updateDetails(
                Objects.requireNonNullElse(command.name(), group.name()),
                Objects.requireNonNullElse(command.description(), group.description()),
                Objects.requireNonNullElse(command.repository(), group.repository().orElse(null)),
                clock
        );

        if (command.participantsRemove() != null && !command.participantsRemove().isEmpty()) {
            for (var userIdToRemove : command.participantsRemove()) {
                Membership memberToRemove = membershipRepository.findById(command.groupId(), userIdToRemove)
                        .orElse(null); 

                if (memberToRemove != null) {
                    if (memberToRemove.role() == GroupRole.ADMIN) {
                        if (membershipRepository.countAdmins(command.groupId()) <= 1) {
                            throw new RuntimeException("Não é possível remover o último admin"); 
                        }
                    }
                    membershipRepository.delete(memberToRemove);
                }
            }
        }

        groupRepository.save(group);

        return getGroupDetailsUseCase.execute(command.groupId());
    }
}