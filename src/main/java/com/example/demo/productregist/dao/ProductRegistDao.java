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
    public Product selectProductById(String productId) {
        return sqlSession.selectOne("ProductRegistMapper.selectProductById", productId);
    }

    /** 상품 이미지 파일 목록 */
    public List<ProductFile> selectProductFilesById(String productId) {
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
}
