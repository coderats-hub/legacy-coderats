package dev.coderats.backend.checkins.app;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.checkins.app.port.LikeRepository;
import dev.coderats.backend.checkins.app.port.UserQueryPort;
import dev.coderats.backend.checkins.app.query.AuthorView;
import dev.coderats.backend.checkins.app.query.LikeView;
import dev.coderats.backend.checkins.domain.CheckinId;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ListLikesUseCase {
    private final LikeRepository likeRepository;
    private final UserQueryPort userQueryPort;
    
    @Transactional(readOnly = true)
    public List<LikeView> execute(CheckinId checkinId) {
        return likeRepository.findByCheckinId(checkinId)
            .stream()
            .map(like -> {
                AuthorView author = userQueryPort.getAuthorById(like.userId());
                return new LikeView(like.id().toString(), author);
            })
            .collect(Collectors.toList());
    }
}