package com.example.demo.product.init;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import com.example.demo.product.dao.ProductEsDao;

import lombok.extern.slf4j.Slf4j;

@Component
@Order(2)
@Slf4j
public class ProductEsInitializer implements ApplicationRunner {

    private final ProductEsDao productEsDao;

    @Autowired
    public ProductEsInitializer(ProductEsDao productEsDao) {
        this.productEsDao = productEsDao;
    }

    @Override
    public void run(ApplicationArguments args) {
        productEsDao.ensureIndex();
    }
}
