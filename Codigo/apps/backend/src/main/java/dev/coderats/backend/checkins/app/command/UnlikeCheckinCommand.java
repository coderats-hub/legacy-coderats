package dev.coderats.backend.checkins.app.command;
import dev.coderats.backend.checkins.domain.CheckinId;
import dev.coderats.backend.users.domain.UserId;
public record UnlikeCheckinCommand(CheckinId checkinId, UserId userId) {}