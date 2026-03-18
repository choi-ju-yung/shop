package com.example.demo.productregist.service;

import java.util.List;
import java.util.Locale.Category;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.product.vo.Product;
import com.example.demo.product.vo.ProductFile;
import com.example.demo.productregist.dao.ProductRegistDao;

@Service
public class ProductRegistService {

    private final ProductRegistDao productRegistDao;

    @Autowired
    public ProductRegistService(ProductRegistDao productRegistDao) {
        this.productRegistDao = productRegistDao;
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
        return 1;
    }

    /** 메인 페이지용 최신 상품 목록 */
    public List<Product> selectMainProducts() {
        return productRegistDao.selectMainProducts();
    }

    /** 상품 상세 조회 (이미지 포함) */
    public Product selectProductDetail(String productId) {
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
}
