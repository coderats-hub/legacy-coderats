package dev.coderats.backend.users.app;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.shared.domain.Clock;
import dev.coderats.backend.users.app.command.UpdateMeCommand;
import dev.coderats.backend.users.app.port.UserRepository;
import dev.coderats.backend.users.domain.User;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UpdateMeUseCase {
    private final UserRepository userRepository;
    private final Clock clock;
    
    @Transactional
    public User execute(UpdateMeCommand command) {
        User user = userRepository.findById(command.userIdToUpdate())
            .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        
        user.updateProfile(
            command.name(),
            command.image(),
            command.githubUser(),
            clock
        );
        
        userRepository.save(user);
        return user;
    }
}