package dev.coderats.backend.checkins.app.port;
import dev.coderats.backend.checkins.app.query.AuthorView;
import dev.coderats.backend.users.domain.UserId;
import java.util.List;
import java.util.Map;

public interface UserQueryPort {
    AuthorView getAuthorById(UserId userId);
    Map<UserId, AuthorView> getAuthorsByIds(List<UserId> userIds);
}