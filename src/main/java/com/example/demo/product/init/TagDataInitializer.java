package com.example.demo.product.init;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import com.example.demo.product.dao.TagEsDao;
import com.example.demo.product.service.TagService;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class TagDataInitializer implements ApplicationRunner {

    private final TagService tagService;
    private final TagEsDao tagEsDao;

    @Autowired
    public TagDataInitializer(TagService tagService, TagEsDao tagEsDao) {
        this.tagService = tagService;
        this.tagEsDao = tagEsDao;
    }

    @Override
    public void run(ApplicationArguments args) {
        tagEsDao.setupIndex();
        
        // 인덱스 비어있을 때만 동기화
        if(tagEsDao.count() == 0) {
        	log.info("DB → ES 태그 동기화 시작");
        	tagService.syncAllToEs();
        }
        
    }
}
