package dev.coderats.backend.checkins.api;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import dev.coderats.backend.checkins.api.dto.CheckinCreateDTO;
import dev.coderats.backend.checkins.api.dto.CheckinResponseDTO;
import dev.coderats.backend.checkins.api.dto.CommentCreateDTO;
import dev.coderats.backend.checkins.api.dto.CommentResponseDTO;
import dev.coderats.backend.checkins.api.dto.CommitDTO;
import dev.coderats.backend.checkins.api.dto.LikeResponseDTO;
import dev.coderats.backend.checkins.api.dto.UserSummaryDTO;
import dev.coderats.backend.checkins.app.command.CommitData;
import dev.coderats.backend.checkins.app.command.CreateCheckinCommand;
import dev.coderats.backend.checkins.app.command.CreateCommentCommand;
import dev.coderats.backend.checkins.app.query.AuthorView;
import dev.coderats.backend.checkins.app.query.CommentView;
import dev.coderats.backend.checkins.app.query.CommitView;
import dev.coderats.backend.checkins.app.query.FeedCheckinView;
import dev.coderats.backend.checkins.app.query.LikeView;
import dev.coderats.backend.checkins.domain.Checkin;
import dev.coderats.backend.checkins.domain.CheckinId;
import dev.coderats.backend.checkins.domain.Comment;
import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.users.domain.UserId;

@Component
public class CheckinApiMapper {

    
    public CreateCheckinCommand toCommand(CheckinCreateDTO dto, GroupId groupId, UserId authorId) {
        List<CommitData> commitData = List.of();
        if (dto.commits() != null) {
            commitData = dto.commits().stream()
                .map(c -> new CommitData(c.link(), c.title(), c.hash()))
                .collect(Collectors.toList());
        }
        return new CreateCheckinCommand(
            authorId,
            groupId,
            dto.title(),
            dto.description(),
            dto.image(),
            dto.summaryAi(),
            commitData
        );
    }
    
    public CreateCommentCommand toCommand(CommentCreateDTO dto, CheckinId checkinId, UserId authorId) {
        return new CreateCommentCommand(checkinId, authorId, dto.content());
    }

    public CheckinResponseDTO toResponseDTO(Checkin checkin, AuthorView author) {
        return new CheckinResponseDTO(
            checkin.id().asUuid(),
            checkin.title(),
            checkin.description().orElse(null),
            checkin.image().orElse(null),
            checkin.summaryAi().orElse(null),
            checkin.points(),
            checkin.createdAt(),
            toAuthorDTO(author),
            List.of(), 
            0,     
            false, 
            List.of() 
        );
    }
    
    public CheckinResponseDTO toResponseDTO(FeedCheckinView view) {
        return new CheckinResponseDTO(
            UUID.fromString(view.id()),
            view.title(),
            view.description(),
            view.image(),
            view.summaryAi(),
            view.points(),
            view.createdAt(),
            toAuthorDTO(view.author()),
            view.commits().stream().map(this::toCommitDTO).collect(Collectors.toList()), 
            view.likesCount(),
            view.likedByMe(),
            view.comments().stream().map(this::toCommentDTO).collect(Collectors.toList())
        );
    }
    
    public LikeResponseDTO toResponseDTO(LikeView view) {
        return new LikeResponseDTO(UUID.fromString(view.id()), toAuthorDTO(view.author()));
    }
    
    public CommentResponseDTO toResponseDTO(Comment comment, AuthorView author) {
        return new CommentResponseDTO(
            comment.id().asUuid(),
            comment.content(),
            toAuthorDTO(author)
        );
    }

    public UserSummaryDTO toAuthorDTO(AuthorView author) {
        return new UserSummaryDTO(UUID.fromString(author.id()), author.name(), author.image());
    }
    
    public CommentResponseDTO toCommentDTO(CommentView comment) {
        return new CommentResponseDTO(UUID.fromString(comment.id()), comment.content(), toAuthorDTO(comment.author()));
    }
    
    public CommitDTO toCommitDTO(CommitView commit) {
        return new CommitDTO(
            UUID.fromString(commit.id()),
            commit.link(),
            commit.title(),
            commit.hash()
        );
    }
}