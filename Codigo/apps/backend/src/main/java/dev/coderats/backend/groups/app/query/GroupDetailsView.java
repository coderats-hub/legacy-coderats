package dev.coderats.backend.groups.app.query;

import java.util.List;

import dev.coderats.backend.groups.domain.Group;

// Retorna uma visão detalhada de um grupo, incluindo participantes e check-ins recentes.
public record GroupDetailsView(
        Group group, // Inclui a própria entidade de domínio (ou campos específicos dela)
        List<ParticipantView> participants,
        List<CheckinSummaryView> recentCheckins
) {}