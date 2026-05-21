package com.example.demo.admin.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.product.dao.ProductEsDao;
import com.example.demo.product.dao.TagDao;
import com.example.demo.product.dao.TagEsDao;
import com.example.demo.product.document.ProductDocument;
import com.example.demo.product.document.TagDocument;
import com.example.demo.product.vo.Product;
import com.example.demo.product.vo.TagVO;
import com.example.demo.productregist.dao.ProductRegistDao;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class AdminService {

    private final ProductRegistDao productRegistDao;
    private final ProductEsDao productEsDao;
    private final TagDao tagDao;
    private final TagEsDao tagEsDao;

    @Autowired
    public AdminService(ProductRegistDao productRegistDao, ProductEsDao productEsDao,
                        TagDao tagDao, TagEsDao tagEsDao) {
        this.productRegistDao = productRegistDao;
        this.productEsDao = productEsDao;
        this.tagDao = tagDao;
        this.tagEsDao = tagEsDao;
    }

    /** DB → ES 전체 재동기화 (상품 + 태그) */
    public Map<String, Integer> syncEs() {
        List<Product> products = productRegistDao.selectAllForEs();
        List<ProductDocument> productDocs = products.stream()
                .map(p -> ProductDocument.builder()
                        .productId(p.getProductId())
                        .title(p.getTitle())
                        .tags(p.getTag())
                        .tradeStatus(p.getTradeStatus() != null ? p.getTradeStatus() : "SALE")
                        .mainFilePath(p.getMainFilePath())
                        .price(p.getPrice())
                        .place(p.getPlace())
                        .state(p.getState())
                        .userNo(p.getUserNo())
                        .build())
                .toList();
        int syncedProducts = productEsDao.bulkIndex(productDocs);
        log.info("관리자 ES 상품 재동기화: {}건", syncedProducts);

        List<TagVO> tags = tagDao.selectAllTags();
        List<TagDocument> tagDocs = tags.stream()
                .map(t -> TagDocument.builder()
                        .id(t.getTagId())
                        .tagName(t.getTagName())
                        .useCount(t.getUseCount())
                        .build())
                .toList();
        int syncedTags = tagEsDao.bulkIndex(tagDocs);
        log.info("관리자 ES 태그 재동기화: {}건", syncedTags);

        return Map.of("products", syncedProducts, "tags", syncedTags);
    }
}
