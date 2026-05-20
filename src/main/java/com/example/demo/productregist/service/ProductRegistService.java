package com.example.demo.productregist.service;

import java.util.List;
import java.util.Locale.Category;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.product.service.ProductEsService;
import com.example.demo.product.vo.Product;
import com.example.demo.product.vo.ProductFile;
import com.example.demo.productregist.dao.ProductRegistDao;

@Service
public class ProductRegistService {

    private final ProductRegistDao productRegistDao;
    private final ProductEsService productEsService;

    @Autowired
    public ProductRegistService(ProductRegistDao productRegistDao,
                                ProductEsService productEsService) {
        this.productRegistDao = productRegistDao;
        this.productEsService = productEsService;
    }

    public List<String> findSubCate(String categoryName) {
        return productRegistDao.selectSubCate(categoryName);
    }

    public List<Category> selectAll() {
        return productRegistDao.selectAll();
    }

    @Transactional
    public int insertProduct(Product product) {
        try {
            productRegistDao.insertProduct(product);
            for (ProductFile file : product.getProductFiles()) {
                file.setProductId(product.getProductId());
                productRegistDao.insertProductFile(file);
            }
        } catch (Exception e) {
            throw new RuntimeException("상품 등록 중 오류 발생", e);
        }
        product.getProductFiles().stream()
                .filter(ProductFile::isMain)
                .map(ProductFile::getFilePath)
                .findFirst()
                .ifPresent(product::setMainFilePath);
        productEsService.indexProduct(product);
        return 1;
    }

    /** 메인 페이지용 최신 상품 목록 */
    public List<Product> selectMainProducts() {
        return productRegistDao.selectMainProducts();
    }

    /** 상품 상세 조회 (이미지 포함) */
    public Product selectProductDetail(Long productId) {
        Product product = productRegistDao.selectProductById(productId);
        if (product != null) {
            List<ProductFile> files = productRegistDao.selectProductFilesById(productId);
            product.setProductFiles(files);
        }
        return product;
    }

    /** 키워드 검색 */
    public List<Product> searchProducts(String keyword) {
        return productRegistDao.searchProducts(keyword);
    }

    /** 카테고리별 상품 목록 */
    public List<Product> selectProductsByCategory(String category) {
        return productRegistDao.selectProductsByCategory(category);
    }

    /** 헤더 카테고리 메뉴 */
    public List<Map<String, Object>> selectAllCategories() {
        return productRegistDao.selectAllCategories();
    }
    
    @Transactional
    public void deleteProduct(Long productId, long requestUserNo){
        Long sellerNo = productRegistDao.selectSellerNoByProductId(productId);
        if (sellerNo == null) {
            throw new IllegalArgumentException("존재하지 않는 상품입니다.");
        }
        if (sellerNo != requestUserNo) {
            throw new SecurityException("삭제 권한이 없습니다.");
        }
        productRegistDao.deleteWishlistByProductId(productId);
        productRegistDao.softDeleteProduct(productId);
        productEsService.removeProduct(productId);
    }

    /**
     * 거래 상태 변경 (판매자 본인만)
     * tradeStatus: SALE / RESERVED / SOLD
     * SOLD 시 buyerNo 필수
     */
    @Transactional
    public void updateTradeStatus(Long productId, long requestUserNo, String tradeStatus, Long buyerNo) {
        Map<String, Object> map = new java.util.HashMap<>();
        map.put("productId",   productId);
        map.put("userNo",      requestUserNo);
        map.put("tradeStatus", tradeStatus);
        map.put("buyerNo",     buyerNo);
        if ("SOLD".equals(tradeStatus) && buyerNo == null) {
            throw new IllegalArgumentException("거래완료 처리 시 구매자를 선택해야 합니다.");
        }
        int updated = productRegistDao.updateTradeStatus(map);
        if (updated == 0) {
            throw new SecurityException("상태 변경 권한이 없거나 존재하지 않는 상품입니다.");
        }
        if ("SOLD".equals(tradeStatus)) {
            productRegistDao.insertTrade(map);
        }
        productEsService.updateProductStatus(productId, tradeStatus);
    }

    /** 내 판매 목록 (상태 필터: ALL / SALE / RESERVED / SOLD) */
    public List<Product> getMySellingProducts(long userNo, String tradeStatus) {
        Map<String, Object> map = new java.util.HashMap<>();
        map.put("userNo",      userNo);
        map.put("tradeStatus", tradeStatus);
        return productRegistDao.selectMySellingProducts(map);
    }

    /** 내 구매 목록 */
    public List<Product> getMyPurchasedProducts(long userNo) {
        return productRegistDao.selectMyPurchasedProducts(userNo);
    }

    /** 추천 상품 (같은 서브카테고리, 현재 상품 제외) */
    public List<Product> selectRelatedProducts(Long productId, String subCate) {
        Map<String, Object> map = new java.util.HashMap<>();
        map.put("productId", productId);
        map.put("subCate", subCate);
        return productRegistDao.selectRelatedProducts(map);
    }

    /** 특정 판매자 상품 목록 (외부 프로필 조회용) */
    public List<Product> getSellerProducts(long userNo, String tradeStatus) {
        Map<String, Object> map = new java.util.HashMap<>();
        map.put("userNo", userNo);
        map.put("tradeStatus", tradeStatus);
        return productRegistDao.selectSellerProducts(map);
    }
}
