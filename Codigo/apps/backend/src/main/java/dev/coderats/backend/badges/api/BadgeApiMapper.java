package dev.coderats.backend.badges.api;

import java.util.UUID;

import org.springframework.stereotype.Component;

import dev.coderats.backend.badges.api.dto.BadgeDTO;
import dev.coderats.backend.users.app.query.BadgeView;

@Component
public class BadgeApiMapper {

    public BadgeDTO toDTO(BadgeView view) {
        return new BadgeDTO(
            UUID.fromString(view.id()),
            view.name(),
            view.image(),
            view.description(),
            view.points()
        );
    }
}