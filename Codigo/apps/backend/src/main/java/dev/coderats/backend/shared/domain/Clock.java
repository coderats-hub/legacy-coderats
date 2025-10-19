package dev.coderats.backend.shared.domain;

import java.time.Instant;

public interface Clock {
    Instant now();
}
