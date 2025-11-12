package dev.coderats.backend.web.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import dev.coderats.backend.domain.User;
import dev.coderats.backend.infra.repository.UserRepository;

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
   * GET /users/me - Busca dados do usuário atual (mockado por enquanto)
   * TODO: Implementar autenticação JWT para pegar usuário do token
   */
  @GetMapping("/me")
  public ResponseEntity<User> getCurrentUser() {
    // Por enquanto, retorna o primeiro usuário encontrado
    // TODO: Implementar lógica para pegar usuário do JWT token
    List<User> users = userRepository.findAll();
    if (users.isEmpty()) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(users.get(0));
  }

  /**
   * PUT /users/me - Atualiza dados do usuário atual
   * TODO: Implementar autenticação JWT para pegar usuário do token
   */
  @PutMapping("/me")
  public ResponseEntity<User> updateCurrentUser(@RequestBody User userUpdate) {
    // Por enquanto, atualiza o primeiro usuário encontrado
    // TODO: Implementar lógica para pegar usuário do JWT token e atualizar
    List<User> users = userRepository.findAll();
    if (users.isEmpty()) {
      return ResponseEntity.notFound().build();
    }

    User currentUser = users.get(0);

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
    return ResponseEntity.ok(savedUser);
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
}