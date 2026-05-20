package com.example.demo.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;

import java.net.URI;

@Configuration
public class OciStorageConfig {

    @Value("${oci.storage.endpoint:}")
    private String endpoint;

    @Value("${oci.storage.region:ap-melbourne-1}")
    private String region;

    @Value("${oci.storage.access-key:}")
    private String accessKey;

    @Value("${oci.storage.secret-key:}")
    private String secretKey;

    @Bean
    @ConditionalOnExpression("!'${oci.storage.endpoint:}'.isEmpty()")
    public S3Client s3Client() {
        return S3Client.builder()
                .endpointOverride(URI.create(endpoint))
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(accessKey, secretKey)
                ))
                .forcePathStyle(true)
                .build();
    }
}
