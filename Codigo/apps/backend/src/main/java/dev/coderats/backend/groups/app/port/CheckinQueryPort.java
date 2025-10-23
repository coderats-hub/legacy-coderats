package dev.coderats.backend.groups.app.port;

import dev.coderats.backend.groups.app.query.CheckinSummaryView;
import dev.coderats.backend.groups.domain.GroupId;
import java.util.List;

/**
 * Porta para buscar dados de Check-ins (de outro módulo).
 * Permite que o módulo 'groups' consulte check-ins sem depender
 * diretamente da implementação do módulo 'checkins'.
 */
public interface CheckinQueryPort {
    List<CheckinSummaryView> findRecentCheckinsByGroupId(GroupId groupId, int limit);
}