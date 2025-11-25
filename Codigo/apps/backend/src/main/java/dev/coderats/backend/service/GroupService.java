package dev.coderats.backend.service;

import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.domain.CheckinSummary;
import dev.coderats.backend.domain.Group;
import dev.coderats.backend.domain.GroupParticipant;
import dev.coderats.backend.domain.User;
import dev.coderats.backend.domain.UserSummary;
import dev.coderats.backend.infra.repository.GroupParticipantRepository;
import dev.coderats.backend.infra.repository.GroupRepository;
import dev.coderats.backend.infra.repository.UserRepository;
import dev.coderats.backend.web.dto.request.GroupCreateRequest;
import dev.coderats.backend.web.dto.request.GroupUpdateRequest;
import dev.coderats.backend.web.dto.response.GroupWithDetailsResponse;

@Service
public class GroupService {

    private final GroupRepository groupRepository;
    private final GroupParticipantRepository participantRepository;
    private final UserRepository userRepository;
    private final SecureRandom secureRandom = new SecureRandom();

    public GroupService(GroupRepository groupRepository, GroupParticipantRepository participantRepository, UserRepository userRepository) {
        this.groupRepository = groupRepository;
        this.participantRepository = participantRepository;
        this.userRepository = userRepository;
    }

    // CORREÇÃO: Removido o .toString()
    public List<Group> getGroupsForUser(UUID userId) {
        return groupRepository.findGroupsByUserId(userId);
    }

    // REMOVIDO: O método findCommonGroups foi movido para o GroupRepository
    @Transactional
    public Group createGroup(GroupCreateRequest request, UUID creatorUserId) {
        // Criar o grupo
        Group group = new Group();
        group.setName(request.name());
        group.setDescription(request.description());
        group.setImage(request.image());
        group.setRepository(request.repository());
        group.setMethod(request.method());
        group.setStartDate(request.start_date() != null ? request.start_date() : OffsetDateTime.now(ZoneOffset.UTC));
        group.setEndDate(request.end_date());
        group.setStatus(true);

        // Gerar código único se não fornecido
        if (request.code() != null && !request.code().trim().isEmpty()) {
            group.setCode(request.code().trim());
        } else {
            group.setCode(generateUniqueCode());
        }

        Group savedGroup = groupRepository.save(group);

        User user = userRepository.findById(creatorUserId)
                .orElseThrow(() -> new RuntimeException("Usuário criador não encontrado"));

        GroupParticipant creator = new GroupParticipant();
        creator.setUser(user);       
        creator.setGroup(savedGroup); 
        creator.setRole("admin");

        participantRepository.save(creator);

        return savedGroup;
    }

    public Optional<Group> getGroupById(UUID groupId) {
        return groupRepository.findById(groupId);
    }

    public GroupWithDetailsResponse getGroupWithDetails(UUID groupId) {
        Optional<Group> groupOpt = groupRepository.findById(groupId);
        if (groupOpt.isEmpty()) {
            return null;
        }

        Group group = groupOpt.get();

        // Buscar participantes
        List<GroupParticipant> participants = participantRepository.findByIdGroupId(groupId);
        List<UserSummary> participantSummaries = participants.stream()
                .map(participant -> {
                    // Use o getter correto dependendo da sua implementação
                    var user = userRepository.findById(participant.getUserId()).orElse(null);
                    if (user == null) {
                        return null;
                    }
                    return new UserSummary(user.getId(), user.getName(), user.getImage());
                })
                .filter(summary -> summary != null)
                .collect(Collectors.toList());

        // Por enquanto, checkins vazios - seria necessário implementar a busca de checkins
        List<CheckinSummary> recentCheckins = List.of();

        return new GroupWithDetailsResponse(
                group.getId(),
                group.getName(),
                group.getDescription(),
                group.getImage(),
                group.getCode(),
                group.getRepository(),
                group.getMethod(),
                group.isStatus(),
                group.getStartDate(),
                group.getEndDate(),
                group.getCreatedAt(),
                group.getUpdatedAt(),
                participantSummaries,
                recentCheckins
        );
    }

    @Transactional
    public Group updateGroup(UUID groupId, GroupUpdateRequest request, UUID userIdFromAuth) {
        Optional<Group> groupOpt = groupRepository.findById(groupId);
        if (groupOpt.isEmpty()) {
            throw new RuntimeException("Grupo não encontrado");
        }

        Group group = groupOpt.get();

        // Verificar se o usuário é admin do grupo
        Optional<GroupParticipant> participation = participantRepository.findByIdUserIdAndIdGroupId(userIdFromAuth, groupId);
        if (participation.isEmpty() || !"admin".equals(participation.get().getRole())) {
            throw new RuntimeException("Apenas administradores podem atualizar o grupo");
        }

        // Atualizar campos se fornecidos
        if (request.name() != null) {
            group.setName(request.name());
        }
        if (request.description() != null) {
            group.setDescription(request.description());
        }
        if (request.image() != null) {
            group.setImage(request.image());
        }
        if (request.repository() != null) {
            group.setRepository(request.repository());
        }
        if (request.method() != null) {
            group.setMethod(request.method());
        }
        if (request.status() != null) {
            group.setStatus(request.status());
        }
        if (request.end_date() != null) {
            group.setEndDate(request.end_date());
        }

        // Remover participantes se especificado
        if (request.remove_participants() != null && !request.remove_participants().isEmpty()) {
            List<UUID> userIdsToRemove = request.remove_participants().stream()
                    .map(UUID::fromString)
                    .collect(Collectors.toList());
            participantRepository.deleteByIdUserIdInAndIdGroupId(userIdsToRemove, groupId);
        }

        return groupRepository.save(group);
    }

    @Transactional
    public void deleteGroup(UUID groupId, UUID userIdFromAuth) {
        Optional<Group> groupOpt = groupRepository.findById(groupId);
        if (groupOpt.isEmpty()) {
            throw new RuntimeException("Grupo não encontrado");
        }

        // Verificar se o usuário é admin do grupo
        Optional<GroupParticipant> participation = participantRepository.findByIdUserIdAndIdGroupId(userIdFromAuth, groupId);
        if (participation.isEmpty() || !"admin".equals(participation.get().getRole())) {
            throw new RuntimeException("Apenas administradores podem excluir o grupo");
        }

        // Marcar como deletado (soft delete)
        Group group = groupOpt.get();
        group.setDeletedAt(OffsetDateTime.now(ZoneOffset.UTC));
        groupRepository.save(group);
    }

    private String generateUniqueCode() {
        String code;
        do {
            code = String.format("%03d", secureRandom.nextInt(1000));
        } while (groupRepository.findByCode(code).isPresent());
        return code;
    }
}
