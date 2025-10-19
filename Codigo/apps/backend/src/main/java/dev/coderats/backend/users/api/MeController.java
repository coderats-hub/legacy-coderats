package dev.coderats.backend.users.api;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import dev.coderats.backend.shared.infra.security.UserPrincipal; // Assumindo
import dev.coderats.backend.users.api.dto.PrivateUserProfileDTO;
import dev.coderats.backend.users.api.dto.UserUpdateDTO;
import dev.coderats.backend.users.app.GetMeUseCase;
import dev.coderats.backend.users.app.ListMyBadgesUseCase;
import dev.coderats.backend.users.app.ListMyGroupsUseCase;
import dev.coderats.backend.users.app.UpdateMeUseCase;
import dev.coderats.backend.users.app.command.UpdateMeCommand;
import dev.coderats.backend.users.domain.User;
import lombok.RequiredArgsConstructor;
import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/users/me")
@RequiredArgsConstructor
public class MeController {

    private final GetMeUseCase getMeUseCase;
    private final UpdateMeUseCase updateMeUseCase;
    private final ListMyGroupsUseCase listMyGroupsUseCase;
    private final ListMyBadgesUseCase listMyBadgesUseCase;
    private final UserApiMapper mapper;
    
    // (Mappers para Groups e Badges seriam injetados aqui)

    @GetMapping
    public ResponseEntity<PrivateUserProfileDTO> getMe(
            @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        User user = getMeUseCase.execute(currentUser.getUserId());
        return ResponseEntity.ok(mapper.toPrivateProfileDTO(user));
    }

    @PatchMapping
    public ResponseEntity<PrivateUserProfileDTO> updateMe(
            @Valid @RequestBody UserUpdateDTO updateDTO,
            @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        UpdateMeCommand command = mapper.toUpdateMeCommand(updateDTO, currentUser.getUserId());
        User updatedUser = updateMeUseCase.execute(command);
        return ResponseEntity.ok(mapper.toPrivateProfileDTO(updatedUser));
    }

    @GetMapping("/groups")
    public ResponseEntity<List<?>> getMyGroups( // Retorno seria List<GroupWithDetailsDTO>
            @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        var groupViews = listMyGroupsUseCase.execute(currentUser.getUserId());
        // Aqui você usaria um 'GroupApiMapper' para converter as Views em DTOs
        // List<GroupWithDetailsDTO> dtos = groupViews.stream()...
        return ResponseEntity.ok(groupViews); // Retornando as Views por simplicidade
    }
    
    @GetMapping("/badges")
    public ResponseEntity<List<?>> getMyBadges( // Retorno seria List<BadgeDTO>
            @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        var badgeViews = listMyBadgesUseCase.execute(currentUser.getUserId());
        // Aqui você usaria um 'BadgeApiMapper' para converter as Views em DTOs
        return ResponseEntity.ok(badgeViews);
    }
}