package dev.coderats.backend.infra.cache;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Component;

@Component
public class EphemeralStore {
  private static final class Entry {
    final String value;
    final Instant exp;
    Entry(String value, Instant exp) { this.value = value; this.exp = exp; }
    boolean expired() { return Instant.now().isAfter(exp); }
  }

  private final Map<String, Entry> stateStore = new ConcurrentHashMap<>();
  private final Map<String, Entry> codeStore  = new ConcurrentHashMap<>();

  // STATE (para CSRF + metadata do cliente)
  public String saveState(String json, long ttlSeconds) {
    String state = UUID.randomUUID().toString();
    stateStore.put(state, new Entry(json, Instant.now().plusSeconds(ttlSeconds)));
    return state;
  }
  public String consumeState(String state) {
    Entry e = stateStore.remove(state);
    if (e == null || e.expired()) return null;
    return e.value;
  }

  // LOGIN_CODE (one-time)
  public String saveLoginCode(String payloadJson, long ttlSeconds) {
    String code = UUID.randomUUID().toString();
    codeStore.put(code, new Entry(payloadJson, Instant.now().plusSeconds(ttlSeconds)));
    return code;
  }
  public String consumeLoginCode(String code) {
    Entry e = codeStore.remove(code);
    if (e == null || e.expired()) return null;
    return e.value;
  }
}
