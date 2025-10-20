package dev.coderats.backend.checkins.app.command;
import java.util.List;

import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.users.domain.UserId;

public record CreateCheckinCommand(
    UserId authorId,
    GroupId groupId,
    String title,
    String description,
    String image,
    String summaryAi,
    List<CommitData> commits
) {}
