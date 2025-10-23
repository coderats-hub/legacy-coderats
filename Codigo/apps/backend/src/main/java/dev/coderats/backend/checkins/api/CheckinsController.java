package dev.coderats.backend.checkins.api;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import dev.coderats.backend.checkins.api.dto.CommentCreateDTO;
import dev.coderats.backend.checkins.api.dto.CommentResponseDTO;
import dev.coderats.backend.checkins.api.dto.LikeResponseDTO;
import dev.coderats.backend.checkins.app.CreateCommentUseCase;
import dev.coderats.backend.checkins.app.DeleteCommentUseCase;
import dev.coderats.backend.checkins.app.LikeCheckinUseCase;
import dev.coderats.backend.checkins.app.ListLikesUseCase;
import dev.coderats.backend.checkins.app.UnlikeCheckinUseCase;
import dev.coderats.backend.checkins.app.command.DeleteCommentCommand;
import dev.coderats.backend.checkins.app.command.LikeCheckinCommand;
import dev.coderats.backend.checkins.app.command.UnlikeCheckinCommand;
import dev.coderats.backend.checkins.app.port.UserQueryPort;
import dev.coderats.backend.checkins.app.query.AuthorView;
import dev.coderats.backend.checkins.domain.CheckinId;
import dev.coderats.backend.checkins.domain.Comment;
import dev.coderats.backend.checkins.domain.CommentId;
import dev.coderats.backend.checkins.domain.Like;
import dev.coderats.backend.shared.infra.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/checkins")
@RequiredArgsConstructor
public class CheckinsController {
    
    private final LikeCheckinUseCase likeCheckinUseCase;
    private final UnlikeCheckinUseCase unlikeCheckinUseCase;
    private final ListLikesUseCase listLikesUseCase;
    private final CreateCommentUseCase createCommentUseCase;
    private final DeleteCommentUseCase deleteCommentUseCase;
    private final UserQueryPort userQueryPort;
    private final CheckinApiMapper mapper;

    @PostMapping("/{checkinId}/like")
    public ResponseEntity<LikeResponseDTO> like(
        @PathVariable String checkinId,
        @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        var command = new LikeCheckinCommand(CheckinId.of(checkinId), currentUser.getUserId());
        Like like = likeCheckinUseCase.execute(command);
        
        AuthorView author = userQueryPort.getAuthorById(currentUser.getUserId());
        var view = new dev.coderats.backend.checkins.app.query.LikeView(like.id().toString(), author);
        
        return ResponseEntity.status(201).body(mapper.toResponseDTO(view));
    }
    
    @DeleteMapping("/{checkinId}/like")
    public ResponseEntity<Void> unlike(
        @PathVariable String checkinId,
        @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        var command = new UnlikeCheckinCommand(CheckinId.of(checkinId), currentUser.getUserId());
        unlikeCheckinUseCase.execute(command);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/{checkinId}/likes")
    public ResponseEntity<List<LikeResponseDTO>> getLikes(
        @PathVariable String checkinId
    ) {
        var views = listLikesUseCase.execute(CheckinId.of(checkinId));
        List<LikeResponseDTO> response = views.stream()
            .map(mapper::toResponseDTO)
            .collect(Collectors.toList());
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/{checkinId}/comments")
    public ResponseEntity<CommentResponseDTO> createComment(
        @PathVariable String checkinId,
        @Valid @RequestBody CommentCreateDTO createDTO,
        @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        var command = mapper.toCommand(createDTO, CheckinId.of(checkinId), currentUser.getUserId());
        Comment comment = createCommentUseCase.execute(command);
        
        AuthorView author = userQueryPort.getAuthorById(currentUser.getUserId());
        CommentResponseDTO responseDTO = mapper.toResponseDTO(comment, author);
        
        return ResponseEntity.status(201).body(responseDTO);
    }
    
    @DeleteMapping("/{checkinId}/comments/{commentId}")
    public ResponseEntity<Void> deleteComment(
        @PathVariable String checkinId, 
        @PathVariable String commentId,
        @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        var command = new DeleteCommentCommand(CommentId.of(commentId), currentUser.getUserId());
        deleteCommentUseCase.execute(command);
        return ResponseEntity.noContent().build();
    }
}