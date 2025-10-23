package dev.coderats.backend.shared.infra;

import java.time.Instant;

import org.springframework.stereotype.Component;

import dev.coderats.backend.shared.domain.Clock;

@Component
public class SystemClock implements Clock {

    @Override
    public Instant now() {
        return Instant.now();
    }
}
