package dev.coderats.backend.users.app.port;

import dev.coderats.backend.users.app.query.UserSummaryView;
import dev.coderats.backend.users.domain.UserId;

public interface UserQueryPort {
    UserSummaryView getUserSummary(UserId userId);
}