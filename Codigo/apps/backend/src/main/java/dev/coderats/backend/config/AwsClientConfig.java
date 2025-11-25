package dev.coderats.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.bedrockagentruntime.BedrockAgentRuntimeAsyncClient;

@Configuration
public class AwsClientConfig {

    @Bean
    BedrockAgentRuntimeAsyncClient bedrockAgentRuntimeAsyncClient(
            @Value("${aws.region:us-east-2}") String region) {
        return BedrockAgentRuntimeAsyncClient.builder()
                .region(Region.of(region))
                .build();
    }
}

