package dev.coderats.backend.service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import dev.coderats.backend.domain.Checkin;
import dev.coderats.backend.domain.CheckinLike;
import dev.coderats.backend.domain.CheckinLikeId;
import dev.coderats.backend.domain.CheckinSummary;
import dev.coderats.backend.domain.UserSummary;
import dev.coderats.backend.infra.repository.CheckinLikeRepository;
import dev.coderats.backend.infra.repository.CheckinRepository;
import dev.coderats.backend.infra.repository.GroupParticipantRepository;
import dev.coderats.backend.infra.repository.GroupRepository;
import dev.coderats.backend.infra.repository.UserRepository;
import dev.coderats.backend.web.dto.request.CheckinCreateRequest;
import dev.coderats.backend.web.dto.request.CommitSelectionRequest;
import dev.coderats.backend.web.dto.response.CheckinLikeResponse;
import dev.coderats.backend.web.dto.response.CheckinResponse;
import dev.coderats.backend.web.dto.response.GitHubCommitResponse;
import jakarta.transaction.Transactional;

@Service
public class CheckinService {

    private final CheckinRepository checkinRepository;
    private final CheckinLikeRepository checkinLikeRepository;
    private final GroupParticipantRepository participantRepository;
    private final GroupRepository groupRepository;
    private final UserRepository userRepository;
    private final CommitEvaluationService commitEvaluationService;
    private final GitHubCommitService gitHubCommitService;

    public CheckinService(
            CheckinRepository checkinRepository,
            CheckinLikeRepository checkinLikeRepository,
            GroupParticipantRepository participantRepository,
            GroupRepository groupRepository,
            UserRepository userRepository,
            CommitEvaluationService commitEvaluationService,
            GitHubCommitService gitHubCommitService
    ) {
        this.checkinRepository = checkinRepository;
        this.checkinLikeRepository = checkinLikeRepository;
        this.participantRepository = participantRepository;
        this.groupRepository = groupRepository;
        this.userRepository = userRepository;
        this.commitEvaluationService = commitEvaluationService;
        this.gitHubCommitService = gitHubCommitService;
    }

    public CommitEvaluationService.EvaluationResult previewCheckin(UUID userId, List<CommitSelectionRequest> commits) {
        return commitEvaluationService.evaluate(userId, commits);
    }

    @Transactional
    public CheckinResponse createCheckin(UUID userId, UUID groupId, CheckinCreateRequest request) {

        var participant = participantRepository.findByIdUserIdAndIdGroupId(userId, groupId)
                .orElseThrow(() -> new IllegalStateException("User is not a member of this group"));

        String description = request.description();
        String summaryAi = request.summary_ai();
        int newPoints = 0;

        if (request.commits() != null && !request.commits().isEmpty()) {
            var evaluation = commitEvaluationService.evaluate(userId, request.commits());
            summaryAi = evaluation.summary();
            newPoints = evaluation.points();
            if (description == null || description.isBlank()) {
                description = evaluation.summary();
            }
        }

        var checkin = new Checkin(
                userId,
                groupId,
                request.title(),
                description,
                request.image(),
                summaryAi,
                newPoints
        );

        if (newPoints > 0) {
            participant.addPoints(newPoints);
            participantRepository.save(participant);
        }

        var savedCheckin = checkinRepository.save(checkin);

        return toResponse(savedCheckin);
    }

    public List<CheckinResponse> getFeed(UUID userId, int limit, int offset) {
        return checkinRepository.findFeedByUserId(userId, limit, offset)
                .stream()
                .map(checkin -> toResponse(checkin, userId))
                .collect(Collectors.toList());
    }

    public List<CheckinResponse> getGroupCheckins(UUID userId, UUID groupId, int limit, int offset) {
        return checkinRepository.findByGroupIdOrderByPointsDesc(groupId, limit, offset)
                .stream()
                .map(checkin -> toResponse(checkin, userId))
                .collect(Collectors.toList());
    }

    public List<CheckinResponse> getUserCheckins(UUID requesterId, UUID authorId, int limit, int offset) {
        if (!requesterId.equals(authorId)) {
            throw new IllegalStateException("Nao permitido visualizar check-ins de outro usuario");
        }
        return checkinRepository.findByUserId(authorId, limit, offset)
                .stream()
                .map(checkin -> toResponse(checkin, requesterId))
                .collect(Collectors.toList());
    }

    public dev.coderats.backend.web.dto.response.GroupCheckinsWithRankingResponse getGroupWithCheckins(UUID requesterId, UUID groupId, int limit, int offset) {
        if (!participantRepository.existsByUserIdAndGroupId(requesterId, groupId)) {
            throw new IllegalStateException("Usuário não pertence ao grupo");
        }

        var group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalStateException("Grupo não encontrado"));

        var checkins = getGroupCheckins(requesterId, groupId, limit, offset);

        var participants = participantRepository.findByIdGroupId(groupId);
        var ranking = new java.util.ArrayList<dev.coderats.backend.web.dto.response.GroupCheckinsWithRankingResponse.GroupRankingItem>();

        participants.sort((a, b) -> Integer.compare(b.getPoints(), a.getPoints()));
        for (var p : participants) {
            var user = userRepository.findById(p.getUserId()).orElse(null);
            if (user == null) continue;
            ranking.add(new dev.coderats.backend.web.dto.response.GroupCheckinsWithRankingResponse.GroupRankingItem(
                    user.getId(),
                    user.getName(),
                    user.getImage(),
                    user.getGithubUser(),
                    Double.valueOf(p.getPoints()),
                    p.getRole()
            ));
        }

        return new dev.coderats.backend.web.dto.response.GroupCheckinsWithRankingResponse(
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
                checkins,
                ranking
        );
    }

    /**
     * Retorna os top N usuários pelo somatório de pontos em check-ins (desc).
     */
    public List<UserSummary> getTopUsersByPoints(int limit) {
        int lim = Math.max(1, limit);
        var rows = checkinRepository.findTopUsersByPoints(lim);
        var result = new java.util.ArrayList<UserSummary>();
        for (Object[] row : rows) {
            if (row.length < 5) continue;
            UUID uid = row[0] instanceof UUID ? (UUID) row[0] : UUID.fromString(row[0].toString());
            String name = row[1] != null ? row[1].toString() : "";
            String image = row[2] != null ? row[2].toString() : null;
            String githubUser = row[3] != null ? row[3].toString() : "";
            Double points = ((Number) row[4]).doubleValue();
            result.add(new UserSummary(uid, name, image, githubUser, points, null));
        }
        return result;
    }

    public List<CheckinSummary> getRecentSummaries(UUID groupId, int limit) {
        return checkinRepository.findRecentByGroupId(groupId, PageRequest.of(0, limit))
                .stream()
                .map(this::toSummary)
                .collect(Collectors.toList());
    }

    public List<GitHubCommitResponse> listRecentCommitsForGroup(
            UUID userId,
            UUID groupId,
            int page,
            int size,
            int hours,
            String repoOverride,
            String githubUsername) {
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException("Usuário não encontrado"));
        if (StringUtils.hasText(githubUsername)
                && !githubUsername.equalsIgnoreCase(user.getGithubUser())) {
            throw new IllegalStateException("GitHub informado não corresponde ao usuário autenticado.");
        }
        if (!participantRepository.existsByUserIdAndGroupId(userId, groupId)) {
            throw new IllegalStateException("Usuário não participa deste grupo.");
        }
        var group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalStateException("Grupo não encontrado"));
        String repository = StringUtils.hasText(group.getRepository())
                ? group.getRepository()
                : repoOverride;
        if (!StringUtils.hasText(repository)) {
            throw new IllegalStateException("Grupo não possui repositório associado.");
        }
        int effectiveHours = hours > 0 ? hours : 24;
        return gitHubCommitService.fetchRecentCommitsForRepository(userId, page, size, effectiveHours, repository);
    }

    @Transactional
    public void likeCheckin(UUID checkinId, UUID userId) {
        // Verificar se o checkin existe
        var checkin = checkinRepository.findById(checkinId)
                .orElseThrow(() -> new IllegalStateException("Checkin não encontrado"));

        // Verificar se o usuário faz parte do grupo
        if (!participantRepository.existsByUserIdAndGroupId(userId, checkin.getGroupId())) {
            throw new IllegalStateException("Usuário não pertence ao grupo do checkin");
        }

        // Verificar se já existe like desse usuário para esse checkin
        if (checkinLikeRepository.existsByCheckinIdAndUserId(checkinId, userId)) {
            return; // Já curtiu, não faz nada
        }

        // Criar o like
        var like = new CheckinLike(checkinId, userId);
        checkinLikeRepository.save(like);

        // Incrementar o contador
        checkin.setLikesCount(checkin.getLikesCount() + 1);
        checkinRepository.save(checkin);
    }

    @Transactional
    public void unlikeCheckin(UUID checkinId, UUID userId) {
        // Verificar se o checkin existe
        var checkin = checkinRepository.findById(checkinId)
                .orElseThrow(() -> new IllegalStateException("Checkin não encontrado"));

        // Verificar se existe like desse usuário para esse checkin
        if (!checkinLikeRepository.existsByCheckinIdAndUserId(checkinId, userId)) {
            return; // Não curtiu, não faz nada
        }

        // Remover o like usando deleteById com chave composta
        CheckinLikeId likeId = new CheckinLikeId();
        likeId.setCheckinId(checkinId);
        likeId.setUserId(userId);
        checkinLikeRepository.deleteById(likeId);

        // Decrementar o contador (sem deixar negativo)
        int newCount = Math.max(0, checkin.getLikesCount() - 1);
        checkin.setLikesCount(newCount);
        checkinRepository.save(checkin);
    }

    public boolean userHasLiked(UUID checkinId, UUID userId) {
        return checkinLikeRepository.existsByCheckinIdAndUserId(checkinId, userId);
    }

    public CheckinLikeResponse likeCheckinAndGetResponse(UUID checkinId, UUID userId) {
        likeCheckin(checkinId, userId);
        var checkin = checkinRepository.findById(checkinId).orElseThrow();
        return new CheckinLikeResponse(checkin.getLikesCount(), true);
    }

    public CheckinLikeResponse unlikeCheckinAndGetResponse(UUID checkinId, UUID userId) {
        unlikeCheckin(checkinId, userId);
        var checkin = checkinRepository.findById(checkinId).orElseThrow();
        return new CheckinLikeResponse(checkin.getLikesCount(), false);
    }

    private CheckinResponse toResponse(Checkin checkin) {
        return toResponse(checkin, null);
    }

    private CheckinResponse toResponse(Checkin checkin, UUID currentUserId) {
        var author = toUserSummary(checkin);
        boolean userHasLiked = currentUserId != null
                && checkinLikeRepository.existsByCheckinIdAndUserId(checkin.getId(), currentUserId);

        return new CheckinResponse(
                checkin.getId(),
                checkin.getTitle(),
                checkin.getDescription(),
                checkin.getImage(),
                checkin.getSummaryAi(),
                checkin.getPoints(),
                checkin.getLikesCount(),
                userHasLiked,
                checkin.getCreatedAt(),
                author
        );
    }

    private CheckinSummary toSummary(Checkin checkin) {
        var author = toUserSummary(checkin);
        return new CheckinSummary(
                checkin.getId(),
                checkin.getTitle(),
                checkin.getCreatedAt(),
                author
        );
    }

    private UserSummary toUserSummary(Checkin checkin) {
        var user = userRepository.findById(checkin.getUserId()).orElse(null);
        if (user == null) {
            return null;
        }

        var role = participantRepository.findByIdUserIdAndIdGroupId(checkin.getUserId(), checkin.getGroupId())
                .map(participant -> participant.getRole())
                .orElse(null);

        return new UserSummary(
                user.getId(),
                user.getName(),
                user.getImage(),
                user.getGithubUser(),
                Double.valueOf(checkin.getPoints()),
                role
        );
    }
}
