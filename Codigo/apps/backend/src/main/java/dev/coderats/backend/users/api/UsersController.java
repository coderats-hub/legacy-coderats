package dev.coderats.backend.users.api;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import dev.coderats.backend.shared.infra.security.UserPrincipal;
import dev.coderats.backend.users.api.dto.PublicUserProfileWithGroupsDTO;
import dev.coderats.backend.users.app.GetUserProfileUseCase;
import dev.coderats.backend.users.app.query.PublicProfileWithGroupsView;
import dev.coderats.backend.users.domain.UserId;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UsersController {

    private final GetUserProfileUseCase getUserProfileUseCase;
    private final UserApiMapper mapper;

    @GetMapping("/{userId}")
    public ResponseEntity<PublicUserProfileWithGroupsDTO> getUserProfile(
            @PathVariable String userId,
            @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        PublicProfileWithGroupsView view = getUserProfileUseCase.execute(
            UserId.of(userId), 
            currentUser.getUserId()
        );
        
        return ResponseEntity.ok(mapper.toPublicProfileWithGroupsDTO(view));
    }
}