package dev.coderats.backend.users.app.port;

import java.util.Optional;

import dev.coderats.backend.users.domain.User;
import dev.coderats.backend.users.domain.UserId;

public interface UserRepository {
    void save(User user);
    Optional<User> findById(UserId userId);
    Optional<User> findByEmail(String email);
    
    /**
     * O módulo 'auth' precisará de um método para salvar o usuário 
     * E a senha de forma transacional.
     */
    void saveNewUserWithPassword(User user, String hashedPassword);
}