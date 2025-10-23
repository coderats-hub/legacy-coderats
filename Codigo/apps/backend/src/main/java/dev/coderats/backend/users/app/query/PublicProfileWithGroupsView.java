package dev.coderats.backend.users.app.query;

import java.util.List;

public record PublicProfileWithGroupsView(
    PublicProfileView profile,
    List<GroupSummaryView> commonGroups
) {}