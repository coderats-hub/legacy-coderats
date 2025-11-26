package dev.coderats.backend.web.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import dev.coderats.backend.domain.User;
import dev.coderats.backend.infra.repository.UserRepository;
import dev.coderats.backend.web.dto.mapper.UserMapper;
import dev.coderats.backend.web.dto.response.UserDTO;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/users")
@CrossOrigin(origins = "*")
public class UserController {

  @Autowired
  private UserRepository userRepository;

  /**
   * GET /users - Lista todos os usuários
   */
  @GetMapping
  public ResponseEntity<List<User>> getAllUsers() {
    List<User> users = userRepository.findAll();
    return ResponseEntity.ok(users);
  }

  /**
   * GET /users/{id} - Busca usuário por ID
   */
  @GetMapping("/{id}")
  public ResponseEntity<User> getUserById(@PathVariable UUID id) {
    Optional<User> user = userRepository.findById(id);
    return user.map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
  }

  /**
   * GET /users/me - Busca dados do usuário autenticado via JWT
   */
  @GetMapping("/me")
  public ResponseEntity<UserDTO> getCurrentUser() {
    UUID userId = getCurrentUserId();
    User user = userRepository.findById(userId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));
    return ResponseEntity.ok(UserMapper.toDTO(user));
  }

  /**
   * PUT /users/me - Atualiza dados do usuário autenticado via JWT
   */
  @PutMapping("/me")
  public ResponseEntity<UserDTO> updateCurrentUser(@RequestBody User userUpdate) {
    UUID userId = getCurrentUserId();
    User currentUser = userRepository.findById(userId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));

    // Atualiza apenas campos não nulos
    if (userUpdate.getName() != null) {
      currentUser.setName(userUpdate.getName());
    }
    if (userUpdate.getEmail() != null) {
      currentUser.setEmail(userUpdate.getEmail());
    }
    if (userUpdate.getImage() != null) {
      currentUser.setImage(userUpdate.getImage());
    }

    User savedUser = userRepository.save(currentUser);
    return ResponseEntity.ok(UserMapper.toDTO(savedUser));
  }

  /**
   * POST /users - Cria novo usuário (se necessário)
   */
  @PostMapping
  public ResponseEntity<User> createUser(@RequestBody User user) {
    User savedUser = userRepository.save(user);
    return ResponseEntity.ok(savedUser);
  }

  /**
   * DELETE /users/{id} - Remove usuário por ID
   */
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteUser(@PathVariable UUID id) {
    if (userRepository.existsById(id)) {
      userRepository.deleteById(id);
      return ResponseEntity.noContent().build();
    }
    return ResponseEntity.notFound().build();
  }

  /**
   * Método auxiliar para extrair o ID do usuário autenticado do contexto de segurança
   */
  private UUID getCurrentUserId() {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    Object principal = authentication.getPrincipal();

    if (principal == null || "anonymousUser".equals(principal.toString())) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuário não autenticado");
    }

    String userIdString = principal.toString();
    try {
      return UUID.fromString(userIdString);
    } catch (IllegalArgumentException e) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Formato de ID de usuário inválido: " + userIdString, e);
    }
  }
}