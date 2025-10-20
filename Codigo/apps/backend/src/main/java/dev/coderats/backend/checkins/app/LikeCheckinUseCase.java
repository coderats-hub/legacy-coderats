package dev.coderats.backend.checkins.app;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.checkins.app.command.LikeCheckinCommand;
import dev.coderats.backend.checkins.app.port.LikeRepository;
import dev.coderats.backend.checkins.domain.Like;
import dev.coderats.backend.shared.domain.Clock;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class LikeCheckinUseCase {
    private final LikeRepository likeRepository;
    private final Clock clock;
    
    @Transactional
    public Like execute(LikeCheckinCommand command) {
        // Regra de Negócio: Não pode curtir duas vezes (Conflito 409)
        if (likeRepository.existsByCheckinIdAndUserId(command.checkinId(), command.userId())) {
            throw new RuntimeException("Usuário já curtiu este check-in."); // TODO: Exceção 409
        }
        
        Like like = Like.create(command.checkinId(), command.userId(), clock);
        likeRepository.save(like);
        return like;
    }
}