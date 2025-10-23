package dev.coderats.backend.checkins.app;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.checkins.app.command.UnlikeCheckinCommand;
import dev.coderats.backend.checkins.app.port.LikeRepository;
import dev.coderats.backend.checkins.domain.Like;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UnlikeCheckinUseCase {
    private final LikeRepository likeRepository;
    
    @Transactional
    public void execute(UnlikeCheckinCommand command) {
        Like like = likeRepository.findByCheckinIdAndUserId(command.checkinId(), command.userId())
            .orElseThrow(() -> new RuntimeException("Curtida não encontrada.")); // TODO: Exceção 404
        
        likeRepository.delete(like);
    }
}