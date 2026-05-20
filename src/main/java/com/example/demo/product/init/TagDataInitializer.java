package com.example.demo.product.init;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import com.example.demo.product.dao.TagEsDao;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class TagDataInitializer implements ApplicationRunner {

    private final TagEsDao tagEsDao;

    @Autowired
    public TagDataInitializer(TagEsDao tagEsDao) {
        this.tagEsDao = tagEsDao;
    }

    @Override
    public void run(ApplicationArguments args) {
        tagEsDao.ensureIndex();
    }
}
