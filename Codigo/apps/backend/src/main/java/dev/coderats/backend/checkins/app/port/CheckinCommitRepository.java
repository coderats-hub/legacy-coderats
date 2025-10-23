package dev.coderats.backend.checkins.app.port;
import dev.coderats.backend.checkins.domain.CheckinCommit;
public interface CheckinCommitRepository {
    void save(CheckinCommit checkinCommit);
}