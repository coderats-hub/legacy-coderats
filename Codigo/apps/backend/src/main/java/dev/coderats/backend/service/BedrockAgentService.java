package dev.coderats.backend.service;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import dev.coderats.backend.service.dto.BedrockAgentResult;
import software.amazon.awssdk.core.exception.SdkClientException;
import software.amazon.awssdk.services.bedrockagentruntime.BedrockAgentRuntimeAsyncClient;
import software.amazon.awssdk.services.bedrockagentruntime.model.InvokeAgentRequest;
import software.amazon.awssdk.services.bedrockagentruntime.model.InvokeAgentResponseHandler;
import software.amazon.awssdk.services.bedrockagentruntime.model.PayloadPart;
import software.amazon.awssdk.services.bedrockagentruntime.model.ResponseStream;

@Service
public class BedrockAgentService {

    private static final Logger log = LoggerFactory.getLogger(BedrockAgentService.class);

    private static final String AGENT_ID = "AAQOIDRFC4";

    private final BedrockAgentRuntimeAsyncClient client;
    private final ObjectMapper mapper;

    public BedrockAgentService(
            BedrockAgentRuntimeAsyncClient client,
            ObjectMapper mapper) {
        this.client = client;
        this.mapper = mapper;
    }

    public BedrockAgentResult evaluate(String payload) {
        var buffer = new StringBuilder();
        var latch = new CountDownLatch(1);
        var errorRef = new AtomicReference<Throwable>();

        InvokeAgentResponseHandler handler = InvokeAgentResponseHandler.builder()
                .onResponse(response -> log.debug("InvokeAgent sessionId={} contentType={}", response.sessionId(), response.contentType()))
                .onError(throwable -> {
                    errorRef.set(throwable);
                    latch.countDown();
                })
                .onComplete(latch::countDown)
                .subscriber(event -> handleEvent(event, buffer))
                .build();

        InvokeAgentRequest request = InvokeAgentRequest.builder()
                .agentId(AGENT_ID)
                .inputText(payload)
                .build();

        try {
            client.invokeAgent(request, handler).join();
            boolean completed = latch.await(60, TimeUnit.SECONDS);
            if (!completed) {
                throw new IllegalStateException("Tempo excedido aguardando resposta do Bedrock Agent.");
            }
        } catch (SdkClientException ex) {
            throw new IllegalStateException("Falha ao chamar o Bedrock Agent.", ex);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Thread interrompida ao aguardar resposta do Bedrock.", ex);
        } catch (RuntimeException ex) {
            throw new IllegalStateException("Erro ao executar o Bedrock Agent.", ex);
        }

        if (errorRef.get() != null) {
            throw new IllegalStateException("Erro retornado pelo Bedrock Agent.", errorRef.get());
        }

        String responseText = buffer.toString().trim();
        if (!StringUtils.hasText(responseText)) {
            throw new IllegalStateException("Resposta vazia do Bedrock Agent.");
        }
        return parseResult(responseText);
    }

    private void handleEvent(ResponseStream event, StringBuilder buffer) {
        if (event instanceof PayloadPart payload && payload.bytes() != null) {
            buffer.append(payload.bytes().asUtf8String());
        }
    }

    private BedrockAgentResult parseResult(String json) {
        try {
            JsonNode node = mapper.readTree(json);
            int points = node.path("points").asInt(0);
            String summary = node.path("summary_ai").asText(null);
            if (!StringUtils.hasText(summary)) {
                summary = node.path("summary").asText("");
            }
            return new BedrockAgentResult(points, summary, json);
        } catch (Exception ex) {
            throw new IllegalStateException("Resposta inválida do Bedrock Agent: " + json, ex);
        }
    }
}
