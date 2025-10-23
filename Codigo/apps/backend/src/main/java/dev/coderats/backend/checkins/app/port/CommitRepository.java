package dev.coderats.backend.checkins.app.port;
import java.util.Optional;

import dev.coderats.backend.checkins.domain.Commit;
public interface CommitRepository {
    void save(Commit commit);
    Optional<Commit> findByHash(String hash);
}