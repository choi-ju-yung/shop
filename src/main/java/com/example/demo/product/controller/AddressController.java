package com.example.demo.product.controller;

import java.net.URI;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
public class AddressController {

    @Value("${juso.api.key:}")
    private String jusoApiKey;

    @GetMapping("/api/address/search")
    public Map<String, Object> search(@RequestParam String keyword) {
        try {
            URI uri = UriComponentsBuilder
                .fromHttpUrl("https://www.juso.go.kr/addrlink/addrLinkApi.do")
                .queryParam("confmKey",      jusoApiKey)
                .queryParam("currentPage",   1)
                .queryParam("countPerPage",  10)
                .queryParam("keyword",       keyword)
                .queryParam("resultType",    "json")
                .build(true)
                .toUri();

            @SuppressWarnings("unchecked")
            Map<String, Object> raw = new RestTemplate().getForObject(uri, Map.class);

            if (raw == null) return Collections.singletonMap("results", List.of());

            @SuppressWarnings("unchecked")
            Map<String, Object> results = (Map<String, Object>) raw.get("results");
            if (results == null) return Collections.singletonMap("results", List.of());

            Object juso = results.get("juso");
            return Collections.singletonMap("results", juso != null ? juso : List.of());

        } catch (Exception e) {
            log.error("주소 검색 오류", e);
            return Collections.singletonMap("results", List.of());
        }
    }
}
