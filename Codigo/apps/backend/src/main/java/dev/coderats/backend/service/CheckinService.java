package dev.coderats.backend.service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import dev.coderats.backend.domain.Checkin;
import dev.coderats.backend.domain.CheckinSummary;
import dev.coderats.backend.domain.UserSummary;
import dev.coderats.backend.infra.repository.CheckinRepository;
import dev.coderats.backend.infra.repository.GroupParticipantRepository;
import dev.coderats.backend.infra.repository.GroupRepository;
import dev.coderats.backend.infra.repository.UserRepository;
import dev.coderats.backend.web.dto.request.CheckinCreateRequest;
import dev.coderats.backend.web.dto.request.CommitSelectionRequest;
import dev.coderats.backend.web.dto.response.CheckinResponse;
import dev.coderats.backend.web.dto.response.GitHubCommitResponse;
import jakarta.transaction.Transactional;

@Service
public class CheckinService {

    private final CheckinRepository checkinRepository;
    private final GroupParticipantRepository participantRepository;
    private final GroupRepository groupRepository;
    private final UserRepository userRepository;
    private final CommitEvaluationService commitEvaluationService;
    private final GitHubCommitService gitHubCommitService;

    public CheckinService(
            CheckinRepository checkinRepository,
            GroupParticipantRepository participantRepository,
            GroupRepository groupRepository,
            UserRepository userRepository,
            CommitEvaluationService commitEvaluationService,
            GitHubCommitService gitHubCommitService
    ) {
        this.checkinRepository = checkinRepository;
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
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<CheckinResponse> getGroupCheckins(UUID groupId, int limit, int offset) {
        return checkinRepository.findByGroupIdOrderByPointsDesc(groupId, limit, offset)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
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

    private CheckinResponse toResponse(Checkin checkin) {
        var author = toUserSummary(checkin);

        return new CheckinResponse(
                checkin.getId(),
                checkin.getTitle(),
                checkin.getDescription(),
                checkin.getImage(),
                checkin.getSummaryAi(),
                checkin.getPoints(),
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
