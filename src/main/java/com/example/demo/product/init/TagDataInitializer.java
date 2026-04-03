package com.example.demo.product.init;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import com.example.demo.product.service.TagService;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class TagDataInitializer implements ApplicationRunner {

    private final TagService tagService;

    @Autowired
    public TagDataInitializer(TagService tagService) {
        this.tagService = tagService;
    }

    @Override
    public void run(ApplicationArguments args) {
        log.info("DB → ES 태그 동기화 시작");
        tagService.syncAllToEs();
    }
}
