package dev.coderats.backend.groups.app;

import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.groups.app.command.CreateGroupCommand;
import dev.coderats.backend.groups.app.port.GroupRepository;
import dev.coderats.backend.groups.app.port.MembershipRepository;
import dev.coderats.backend.groups.domain.Group;
import dev.coderats.backend.groups.domain.GroupRole;
import dev.coderats.backend.groups.domain.Membership;
import dev.coderats.backend.shared.domain.Clock;

// Especifica um caso de uso para criar um novo grupo
// Toda e qualquer lógica de criação de grupo é encapsulada aqui
// Não deve haver lógica de criação de grupo em nenhum outro lugar
@Service
public class CreateGroupUseCase {

    private final GroupRepository groupRepository;
    private final MembershipRepository membershipRepository;
    private final Clock clock;

    public CreateGroupUseCase(GroupRepository groupRepository, MembershipRepository membershipRepository, Clock clock) {
        this.groupRepository = groupRepository;
        this.membershipRepository = membershipRepository;
        this.clock = clock;
    }

    @Transactional
    public Group execute(CreateGroupCommand command) {
        String groupCode = command.code() != null ? command.code() : UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        
        if (groupRepository.existsByCode(groupCode)) {
            throw new RuntimeException("Group code already exists");
        }

        Group group = Group.create(
                command.name(),
                command.image(),
                groupCode,
                command.method(),
                command.status(),
                command.description(),
                command.repository(),
                command.startDate(),
                command.endDate(),
                clock
        );

        Membership adminMembership = Membership.create(
                group.id(),
                command.creatorId(),
                GroupRole.ADMIN,
                clock
        );

        groupRepository.save(group);
        membershipRepository.save(adminMembership);

        return group;
    }
}