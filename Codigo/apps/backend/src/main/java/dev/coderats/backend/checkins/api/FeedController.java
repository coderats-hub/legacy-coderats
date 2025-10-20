// Arquivo: checkins/api/FeedController.java
package dev.coderats.backend.checkins.api;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import dev.coderats.backend.checkins.api.dto.CheckinResponseDTO;
import dev.coderats.backend.checkins.app.GetFeedUseCase;
import dev.coderats.backend.shared.infra.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/feed")
@RequiredArgsConstructor
public class FeedController {
    
    private final GetFeedUseCase getFeedUseCase;
    private final CheckinApiMapper mapper;
    
    @GetMapping
    public ResponseEntity<List<CheckinResponseDTO>> getFeed(
        @AuthenticationPrincipal UserPrincipal currentUser,
        @RequestParam(defaultValue = "20") int limit,
        @RequestParam(defaultValue = "0") int offset
    ) {
        var feedViews = getFeedUseCase.execute(currentUser.getUserId(), limit, offset);
        
        List<CheckinResponseDTO> response = feedViews.stream()
            .map(mapper::toResponseDTO)
            .collect(Collectors.toList());
            
        return ResponseEntity.ok(response);
    }
}
