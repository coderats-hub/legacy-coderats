package dev.coderats.backend.checkins.api;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import dev.coderats.backend.checkins.api.dto.CheckinCreateDTO;
import dev.coderats.backend.checkins.api.dto.CheckinResponseDTO;
import dev.coderats.backend.checkins.app.CreateCheckinUseCase;
import dev.coderats.backend.checkins.app.port.UserQueryPort;
import dev.coderats.backend.checkins.app.query.AuthorView;
import dev.coderats.backend.checkins.domain.Checkin;
import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.shared.infra.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import jakarta.validation.Valid;
import java.net.URI;

@RestController
@RequestMapping("/groups/{groupId}/checkins")
@RequiredArgsConstructor
public class GroupCheckinsController {
    
    private final CreateCheckinUseCase createCheckinUseCase;
    private final CheckinApiMapper mapper;
    private final UserQueryPort userQueryPort; // Para obter dados do autor para a resposta
    
    @PostMapping
    public ResponseEntity<CheckinResponseDTO> createCheckin(
        @PathVariable String groupId,
        @Valid @RequestBody CheckinCreateDTO createDTO,
        @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        var command = mapper.toCommand(createDTO, GroupId.of(groupId), currentUser.getUserId());
        Checkin newCheckin = createCheckinUseCase.execute(command);
        
        // Precisamos dos dados do autor para a resposta
        AuthorView author = userQueryPort.getAuthorById(currentUser.getUserId());
        CheckinResponseDTO responseDTO = mapper.toResponseDTO(newCheckin, author);
        
        // TODO: Criar URI de localização do novo check-in
        return ResponseEntity.created(URI.create("/checkins/" + newCheckin.id().toString()))
            .body(responseDTO);
    }
}