package dev.coderats.backend.service;

import java.util.Locale;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.domain.Checkin;
import dev.coderats.backend.domain.Group;
import dev.coderats.backend.domain.GroupParticipant;
import dev.coderats.backend.domain.User;
import dev.coderats.backend.infra.repository.CheckinRepository;
import dev.coderats.backend.infra.repository.GroupParticipantRepository;
import dev.coderats.backend.infra.repository.GroupRepository;
import dev.coderats.backend.infra.repository.UserRepository;

@Service
public class ImageReferenceService {

    private final UserRepository userRepository;
    private final GroupRepository groupRepository;
    private final CheckinRepository checkinRepository;
    private final GroupParticipantRepository participantRepository;

    public ImageReferenceService(
            UserRepository userRepository,
            GroupRepository groupRepository,
            CheckinRepository checkinRepository,
            GroupParticipantRepository participantRepository) {
        this.userRepository = userRepository;
        this.groupRepository = groupRepository;
        this.checkinRepository = checkinRepository;
        this.participantRepository = participantRepository;
    }

    @Transactional
    public ImageAssignmentResult assign(String target, UUID entityId, String imageUrl, UUID actorId) {
        TargetType targetType = TargetType.from(target);
        if (actorId == null) {
            throw new IllegalStateException("Usuário não autenticado.");
        }
        return switch (targetType) {
            case USER -> assignToUser(entityId, imageUrl, actorId);
            case GROUP -> assignToGroup(entityId, imageUrl, actorId);
            case CHECKIN -> assignToCheckin(entityId, imageUrl, actorId);
        };
    }

    private ImageAssignmentResult assignToUser(UUID userId, String imageUrl, UUID actorId) {
        if (actorId == null || !actorId.equals(userId)) {
            throw new IllegalStateException("Usuário não autorizado a alterar esta imagem.");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado."));

        user.setImage(imageUrl);
        userRepository.save(user);
        return new ImageAssignmentResult(TargetType.USER, user.getId(), imageUrl);
    }

    private ImageAssignmentResult assignToGroup(UUID groupId, String imageUrl, UUID actorId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Grupo não encontrado."));

        GroupParticipant participant = participantRepository.findByIdUserIdAndIdGroupId(actorId, groupId)
                .orElseThrow(() -> new IllegalStateException("Usuário não participa deste grupo."));

        if (!"admin".equalsIgnoreCase(participant.getRole())) {
            throw new IllegalStateException("Apenas administradores podem atualizar a imagem do grupo.");
        }

        group.setImage(imageUrl);
        groupRepository.save(group);
        return new ImageAssignmentResult(TargetType.GROUP, group.getId(), imageUrl);
    }

    private ImageAssignmentResult assignToCheckin(UUID checkinId, String imageUrl, UUID actorId) {
        Checkin checkin = checkinRepository.findById(checkinId)
                .orElseThrow(() -> new IllegalArgumentException("Check-in não encontrado."));

        if (!checkin.getUserId().equals(actorId)) {
            throw new IllegalStateException("Apenas o autor do check-in pode atualizar a imagem.");
        }

        checkin.setImage(imageUrl);
        checkinRepository.save(checkin);
        return new ImageAssignmentResult(TargetType.CHECKIN, checkin.getId(), imageUrl);
    }

    public enum TargetType {
        USER,
        GROUP,
        CHECKIN;

        public static TargetType from(String value) {
            try {
                return TargetType.valueOf(value.toUpperCase(Locale.ROOT));
            } catch (Exception ex) {
                throw new IllegalArgumentException("Tipo de destino inválido para imagem.");
            }
        }
    }

    public record ImageAssignmentResult(TargetType targetType, UUID entityId, String imageUrl) {}
}
