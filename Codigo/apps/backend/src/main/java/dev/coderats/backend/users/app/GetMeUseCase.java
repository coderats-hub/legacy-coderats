package dev.coderats.backend.users.app;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.users.app.port.UserRepository;
import dev.coderats.backend.users.domain.User;
import dev.coderats.backend.users.domain.UserId;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class GetMeUseCase {
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public User execute(UserId userId) {
        return userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("Usuário não encontrado: " + userId)); 
    }
}