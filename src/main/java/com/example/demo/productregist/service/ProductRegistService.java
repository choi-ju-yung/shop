package com.example.demo.productregist.service;

import java.util.List;
import java.util.Locale.Category;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.product.vo.Product;
import com.example.demo.product.vo.ProductFile;
import com.example.demo.productregist.dao.ProductRegistDao;

import jakarta.annotation.Resource;

@Service
public class ProductRegistService {

	private final ProductRegistDao productRegistDao;

	@Autowired
	public ProductRegistService(ProductRegistDao productRegistDao) {
		this.productRegistDao = productRegistDao;
	}

	public List<String> findSubCate(String categoryName) {
		List<String> subCategorys = productRegistDao.selectSubCate(categoryName);
		return subCategorys;
	}

	// 대표카테고리 찾는 작업
	public List<Category> selectAll() {
		List<Category> categorys = productRegistDao.selectAll();
		return categorys;
	}

	@Transactional // @Transactional은 기본적으로 RuntimeException 이상만 롤백시킴
	public int insertProduct(Product product) {
		try {
			productRegistDao.insertProduct(product); // 1. 상품 정보 저장 후 productId 자동으로 채워짐

			for (ProductFile file : product.getProductFiles()) { 	// 2. 이미지 정보 저장
				file.setProductId(product.getProductId()); // 자동 생성된 productId 할당
				productRegistDao.insertProductFile(file);
			}
		} catch (Exception e) {
			throw new RuntimeException("상품 등록 중 오류 발생",e); // 오류 발생시 롤백 유도
		}
		return 1;
	}
}
