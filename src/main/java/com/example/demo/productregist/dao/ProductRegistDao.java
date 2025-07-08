package com.example.demo.productregist.dao;

import java.util.List;
import java.util.Locale.Category;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
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
	
	/**
	 * 주카테고리 -> 서브카테고리 찾기
	 * @param cateId
	 * @return
	 */
	public List<String> selectSubCate(String categoryName){
		List<String> subCategorys = sqlSession.selectList("ProductRegistMapper.selectSubCate",categoryName);
		return subCategorys;
	}
	
	public List<Category> selectAll() {
		List<Category> categorys = sqlSession.selectList("ProductRegistMapper.selectAll");
		return categorys;
	}
	
	public int insertProduct(Product product) {
		return sqlSession.insert("ProductRegistMapper.insertProduct",product);
	}
	
	public int insertProductFile(ProductFile productFile) {
		return sqlSession.insert("ProductRegistMapper.insertProductFile",productFile);
	}
}
