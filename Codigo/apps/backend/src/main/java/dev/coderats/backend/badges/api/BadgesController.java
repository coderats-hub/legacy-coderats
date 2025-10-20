// Arquivo: badges/api/BadgesController.java
package dev.coderats.backend.badges.api;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import dev.coderats.backend.badges.api.dto.BadgeDTO;
import dev.coderats.backend.badges.app.ListAllBadgesUseCase;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/badges")
@RequiredArgsConstructor
public class BadgesController {
    
    private final ListAllBadgesUseCase listAllBadgesUseCase;
    private final BadgeApiMapper mapper;

    @GetMapping
    public ResponseEntity<List<BadgeDTO>> listAll() {
        var badgeViews = listAllBadgesUseCase.execute();
        
        List<BadgeDTO> response = badgeViews.stream()
            .map(mapper::toDTO)
            .collect(Collectors.toList());
            
        return ResponseEntity.ok(response);
    }
}