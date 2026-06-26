package com.example.demo.product.controller;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
public class AddressController {

    @Value("${juso.api.key:}")
    private String jusoApiKey;

    @GetMapping("/api/address/search")
    public Map<String, Object> search(@RequestParam String keyword) {
        try {
            String encodedKeyword = URLEncoder.encode(keyword, StandardCharsets.UTF_8);
            String urlStr = "https://www.juso.go.kr/addrlink/addrLinkApi.do"
                    + "?confmKey=" + jusoApiKey
                    + "&currentPage=1&countPerPage=10"
                    + "&keyword=" + encodedKeyword
                    + "&resultType=json";

            @SuppressWarnings("unchecked")
            Map<String, Object> raw = new RestTemplate().getForObject(URI.create(urlStr), Map.class);

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
