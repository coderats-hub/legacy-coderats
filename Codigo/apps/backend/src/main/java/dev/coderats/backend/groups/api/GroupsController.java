package dev.coderats.backend.groups.api;

import java.net.URI;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import dev.coderats.backend.groups.api.dto.GroupCreateDTO;
import dev.coderats.backend.groups.api.dto.GroupResponseDTO;
import dev.coderats.backend.groups.app.CreateGroupUseCase;
import dev.coderats.backend.groups.app.command.CreateGroupCommand;
import dev.coderats.backend.groups.domain.Group;
import dev.coderats.backend.shared.infra.security.UserPrincipal; 
import dev.coderats.backend.users.domain.UserId;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/groups")
@RequiredArgsConstructor
public class GroupsController {

    private final CreateGroupUseCase createGroupUseCase;
    private final GroupApiMapper mapper;
    
    // (Você também injetará GetGroupDetailsUseCase, UpdateGroupUseCase, etc. aqui)

    /**
     * Endpoint para POST /groups
     */
    @PostMapping
    public ResponseEntity<GroupResponseDTO> create(
            @Valid @RequestBody GroupCreateDTO createDTO,
            @AuthenticationPrincipal UserPrincipal currentUser 
    ) {
        
        UserId creatorId = currentUser.getUserId(); 

        CreateGroupCommand command = mapper.toCommand(createDTO, creatorId);

        Group newGroup = createGroupUseCase.execute(command);

        GroupResponseDTO responseDTO = mapper.toResponseDTO(newGroup);

        URI location = ServletUriComponentsBuilder
                .fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(responseDTO.id())
                .toUri();

        return ResponseEntity.created(location).body(responseDTO);
    }
    
    // ... Aqui você implementará os outros endpoints ...
    //
    // @GetMapping("/{groupId}")
    // public ResponseEntity<GroupWithDetailsDTO> getDetails(...) {
    //    ...
    // }
    //
    // @PatchMapping("/{groupId}")
    // public ResponseEntity<GroupWithDetailsDTO> update(...) {
    //    ...
    // }
}