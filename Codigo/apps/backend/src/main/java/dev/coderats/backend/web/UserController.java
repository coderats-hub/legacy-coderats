package dev.coderats.backend.web;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import dev.coderats.backend.service.UserService;
import dev.coderats.backend.web.dto.MyProfileResponse;
import dev.coderats.backend.web.dto.PublicProfileResponse;
import dev.coderats.backend.web.dto.UserUpdateRequest;

@RestController
@RequestMapping("/users") // Define o prefixo "/users" para todos os métodos
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * GET /users/me
     * Obtém o perfil detalhado do usuário autenticado (privado).
     */
    @GetMapping("/me")
    public ResponseEntity<MyProfileResponse> getMyProfile() {
        try {
            UUID userId = getCurrentUserId();
            MyProfileResponse profile = userService.getUserProfile(userId);
            return ResponseEntity.ok(profile);
            
        } catch (RuntimeException e) {
             // Se o usuário do token não for encontrado no banco (ex: deletado)
            if (e.getMessage().contains("não encontrado")) {
                return ResponseEntity.notFound().build();
            }
            // Captura o "User not authenticated" do getCurrentUserId
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    /**
     * PATCH /users/me
     * Atualiza o perfil do usuário autenticado.
     */
    @PatchMapping("/me")
    public ResponseEntity<MyProfileResponse> updateMyProfile(@RequestBody UserUpdateRequest request) {
        try {
            UUID userId = getCurrentUserId();
            MyProfileResponse updatedProfile = userService.updateUserProfile(userId, request);
            return ResponseEntity.ok(updatedProfile);
            
        } catch (RuntimeException e) {
            if (e.getMessage().contains("não encontrado")) {
                return ResponseEntity.notFound().build();
            }
             // Captura o "User not authenticated" do getCurrentUserId
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    /**
     * GET /users/{userId}
     * Obtém o perfil público de um usuário específico e seus grupos em comum com o usuário autenticado.
     */
    @GetMapping("/{userId}")
    public ResponseEntity<PublicProfileResponse> getPublicProfile(@PathVariable String userId) {
        try {
            UUID targetUserId = UUID.fromString(userId);
            
            // Tenta obter o ID do usuário logado (pode ser nulo se for um visitante)
            UUID viewerId = getOptionalCurrentUserId();

            PublicProfileResponse profile = userService.getPublicProfile(targetUserId, viewerId);
            
            if (profile == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(profile);

        } catch (IllegalArgumentException e) {
            // Se o {userId} da URL for um UUID inválido
            return ResponseEntity.badRequest().build(); 
        } catch (RuntimeException e) {
             // Se o usuário com {userId} não for encontrado
            if (e.getMessage().contains("não encontrado")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.internalServerError().build();
        }
    }


    // --- MÉTODOS UTILITÁRIOS ---

    /**
     * Obtém o ID do usuário autenticado. 
     * Lança uma exceção se o usuário não estiver autenticado.
     * (Copiado do seu GroupController)
     */
    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication.getPrincipal();
        
        if (principal == null || "anonymousUser".equals(principal.toString())) {
            throw new RuntimeException("User not authenticated");
        }
        
        String userIdString = principal.toString();
        try {
            return UUID.fromString(userIdString);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid user ID format: " + userIdString);
        }
    }

    /**
     * Obtém o ID do usuário autenticado, mas retorna null se não estiver logado.
     * Útil para endpoints públicos que mudam se o usuário está logado (ex: "grupos em comum").
     */
    private UUID getOptionalCurrentUserId() {
        try {
            return getCurrentUserId();
        } catch (RuntimeException e) {
            return null; // Usuário não está logado ou é anônimo
        }
    }
}