package com.example.demo.productregist.dao;

import java.util.List;
import java.util.Locale.Category;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.demo.product.vo.Product;
import com.example.demo.product.vo.ProductFile;

@Repository
public class ProductRegistDao {

    private final SqlSession sqlSession;

    @Autowired
    public ProductRegistDao(SqlSession sqlSession) {
        this.sqlSession = sqlSession;
    }

    public List<String> selectSubCate(String categoryName) {
        return sqlSession.selectList("ProductRegistMapper.selectSubCate", categoryName);
    }

    public List<Category> selectAll() {
        return sqlSession.selectList("ProductRegistMapper.selectAll");
    }

    public int insertProduct(Product product) {
        return sqlSession.insert("ProductRegistMapper.insertProduct", product);
    }

    public int insertProductFile(ProductFile productFile) {
        return sqlSession.insert("ProductRegistMapper.insertProductFile", productFile);
    }

    /** 메인 페이지용 최신 상품 목록 */
    public List<Product> selectMainProducts() {
        return sqlSession.selectList("ProductRegistMapper.selectMainProducts");
    }

    /** 상품 상세 조회 */
    public Product selectProductById(Long productId) {
        return sqlSession.selectOne("ProductRegistMapper.selectProductById", productId);
    }

    /** 상품 이미지 파일 목록 */
    public List<ProductFile> selectProductFilesById(Long productId) {
        return sqlSession.selectList("ProductRegistMapper.selectProductFilesById", productId);
    }

    /** 키워드 검색 */
    public List<Product> searchProducts(String keyword) {
        return sqlSession.selectList("ProductRegistMapper.searchProducts", keyword);
    }

    /** 카테고리별 상품 목록 */
    public List<Product> selectProductsByCategory(String category) {
        return sqlSession.selectList("ProductRegistMapper.selectProductsByCategory", category);
    }

    /** 헤더 카테고리 메뉴 전체 조회 */
    public List<Map<String, Object>> selectAllCategories() {
        return sqlSession.selectList("ProductRegistMapper.selectAllCategories");
    }
    
    public Long selectSellerNoByProductId(Long productId) {
        return sqlSession.selectOne("ProductRegistMapper.selectSellerNoByProductId", productId);
    }

    public int softDeleteProduct(Long productId) {
        return sqlSession.update("ProductRegistMapper.softDeleteProduct", productId);
    }

    public void deleteWishlistByProductId(Long productId) {
        sqlSession.delete("ProductRegistMapper.deleteWishlistByProductId", productId);
    }

    public void softDeleteProductsByUserNo(long userNo) {
        sqlSession.update("ProductRegistMapper.softDeleteProductsByUserNo", userNo);
    }

    public void deleteWishlistByUserProducts(long userNo) {
        sqlSession.delete("ProductRegistMapper.deleteWishlistByUserProducts", userNo);
    }

    public int updateTradeStatus(Map map) {
        return sqlSession.update("ProductRegistMapper.updateTradeStatus", map);
    }

    public int insertTrade(Map map) {
        return sqlSession.update("ProductRegistMapper.insertTrade", map);
    }

    public List<Product> selectMySellingProducts(Map map) {
        return sqlSession.selectList("ProductRegistMapper.selectMySellingProducts", map);
    }

    public List<Product> selectMyPurchasedProducts(long userNo) {
        return sqlSession.selectList("ProductRegistMapper.selectMyPurchasedProducts", userNo);
    }

    public List<Product> selectRelatedProducts(Map<String, Object> map) {
        return sqlSession.selectList("ProductRegistMapper.selectRelatedProducts", map);
    }

    public List<Product> selectAllForEs() {
        return sqlSession.selectList("ProductRegistMapper.selectAllForEs");
    }

    public List<Product> selectSellerProducts(Map<String, Object> map) {
        return sqlSession.selectList("ProductRegistMapper.selectSellerProducts", map);
    }
}
