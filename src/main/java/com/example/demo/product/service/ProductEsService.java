package com.example.demo.product.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.product.dao.ProductEsDao;
import com.example.demo.product.document.ProductDocument;
import com.example.demo.product.vo.Product;

@Service
public class ProductEsService {

    private final ProductEsDao productEsDao;

    @Autowired
    public ProductEsService(ProductEsDao productEsDao) {
        this.productEsDao = productEsDao;
    }

    /** 상품 등록 시 ES 인덱싱 */
    public void indexProduct(Product product) {
        productEsDao.index(toDocument(product));
    }

    /** 상품 삭제 또는 거래완료 시 ES에서 제거 */
    public void removeProduct(Long productId) {
        productEsDao.delete(productId);
    }

    /** 상품명 + 태그 검색 → Product 리스트 반환 */
    public List<Product> search(String keyword) {
        return productEsDao.search(keyword).stream()
                .map(this::toProduct)
                .collect(Collectors.toList());
    }

    /** 전체 상품 bulk 인덱싱 */
    public void bulkIndex(List<Product> products) {
        List<ProductDocument> docs = products.stream()
                .map(this::toDocument)
                .collect(Collectors.toList());
        productEsDao.bulkIndex(docs);
    }

    public long count() {
        return productEsDao.count();
    }

    // ── 변환 ──────────────────────────────────────────

    private ProductDocument toDocument(Product p) {
        return ProductDocument.builder()
                .productId(p.getProductId())
                .title(p.getTitle())
                .tags(p.getTag())
                .tradeStatus(p.getTradeStatus() != null ? p.getTradeStatus() : "SALE")
                .mainFilePath(p.getMainFilePath())
                .price(p.getPrice())
                .place(p.getPlace())
                .state(p.getState())
                .userNo(p.getUserNo())
                .build();
    }

    private Product toProduct(ProductDocument doc) {
        return Product.builder()
                .productId(doc.getProductId())
                .title(doc.getTitle())
                .tag(doc.getTags())
                .tradeStatus(doc.getTradeStatus())
                .mainFilePath(doc.getMainFilePath())
                .price(doc.getPrice())
                .place(doc.getPlace())
                .state(doc.getState())
                .userNo(doc.getUserNo())
                .build();
    }
}
