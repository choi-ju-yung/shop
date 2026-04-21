package com.example.demo.product.init;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import com.example.demo.product.dao.ProductEsDao;
import com.example.demo.product.service.ProductEsService;
import com.example.demo.productregist.dao.ProductRegistDao;
import com.example.demo.product.vo.Product;

import lombok.extern.slf4j.Slf4j;

@Component
@Order(2)
@Slf4j
public class ProductEsInitializer implements ApplicationRunner {

    private final ProductEsDao productEsDao;
    private final ProductEsService productEsService;
    private final ProductRegistDao productRegistDao;

    @Autowired
    public ProductEsInitializer(ProductEsDao productEsDao,
                                ProductEsService productEsService,
                                ProductRegistDao productRegistDao) {
        this.productEsDao = productEsDao;
        this.productEsService = productEsService;
        this.productRegistDao = productRegistDao;
    }

    @Override
    public void run(ApplicationArguments args) {
        productEsDao.setupIndex();

        if (productEsDao.count() == 0) {
            log.info("DB → ES 상품 동기화 시작");
            List<Product> products = productRegistDao.selectAllForEs();
            productEsService.bulkIndex(products);
            log.info("DB → ES 상품 동기화 완료: {}건", products.size());
        }
    }
}
