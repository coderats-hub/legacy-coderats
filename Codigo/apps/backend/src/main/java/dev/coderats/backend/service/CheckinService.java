package dev.coderats.backend.service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import dev.coderats.backend.domain.Checkin;
import dev.coderats.backend.domain.CheckinSummary;
import dev.coderats.backend.domain.UserSummary;
import dev.coderats.backend.infra.repository.CheckinRepository;
import dev.coderats.backend.infra.repository.GroupParticipantRepository;
import dev.coderats.backend.infra.repository.UserRepository;
import dev.coderats.backend.web.dto.request.CheckinCreateRequest;
import dev.coderats.backend.web.dto.request.CommitSelectionRequest;
import dev.coderats.backend.web.dto.response.CheckinResponse;
import dev.coderats.backend.service.CommitEvaluationService;

@Service
public class CheckinService {

    private final CheckinRepository checkinRepository;
    private final GroupParticipantRepository participantRepository;
    private final UserRepository userRepository;
    private final CommitEvaluationService commitEvaluationService;

    public CheckinService(
        CheckinRepository checkinRepository,
        GroupParticipantRepository participantRepository,
        UserRepository userRepository,
        CommitEvaluationService commitEvaluationService
    ) {
        this.checkinRepository = checkinRepository;
        this.participantRepository = participantRepository;
        this.userRepository = userRepository;
        this.commitEvaluationService = commitEvaluationService;
    }
    
    public CommitEvaluationService.EvaluationResult previewCheckin(UUID userId, List<CommitSelectionRequest> commits) {
        return commitEvaluationService.evaluate(userId, commits);
    }

    public CheckinResponse createCheckin(UUID userId, UUID groupId, CheckinCreateRequest request) {
        var membership = participantRepository.findByIdUserIdAndIdGroupId(userId, groupId);
        if (membership.isEmpty()) {
            throw new IllegalStateException("User is not a member of this group");
        }

        String description = request.description();
        String summaryAi = request.summary_ai();
        int points = 0;

        if (request.commits() != null && !request.commits().isEmpty()) {
            var evaluation = commitEvaluationService.evaluate(userId, request.commits());
            summaryAi = evaluation.summary();
            points = evaluation.points();
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
            points
        );

        var saved = checkinRepository.save(checkin);
        return toResponse(saved);
    }

    public List<CheckinResponse> getFeed(UUID userId, int limit, int offset) {
        return checkinRepository.findFeedByUserId(userId.toString(), limit, offset)
            .stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }

    public List<CheckinResponse> getGroupCheckins(UUID groupId, int limit, int offset) {
        return checkinRepository.findByGroupIdOrderByCreatedAtDesc(groupId.toString(), limit, offset)
            .stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }

    public List<CheckinSummary> getRecentSummaries(UUID groupId, int limit) {
        return checkinRepository.findRecentByGroupId(groupId.toString(), limit)
            .stream()
            .map(this::toSummary)
            .collect(Collectors.toList());
    }

    private CheckinResponse toResponse(Checkin checkin) {
        var author = userRepository.findById(checkin.getUserId())
            .map(u -> new UserSummary(u.getId(), u.getName(), u.getImage()))
            .orElse(null);

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
        var author = userRepository.findById(checkin.getUserId())
            .map(u -> new UserSummary(u.getId(), u.getName(), u.getImage()))
            .orElse(null);
        return new CheckinSummary(
            checkin.getId(),
            checkin.getTitle(),
            checkin.getCreatedAt(),
            author
        );
    }
}
