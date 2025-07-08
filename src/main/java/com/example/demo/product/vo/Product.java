package com.example.demo.product.vo;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@Data
@NoArgsConstructor
@Builder
public class Product { // Product에 List<ProductFile> 포함하는 것이 관련성 있는 데이터를 다루기에 좋음
	  	private String productId;
	    private Long userNo; // 유저식별번호
	    private String title; // 제목
	    private String subCate; // 서브카테고리
	    private String place; // 거래지역 
	    private String state; // 상품상태
	    private int price; // 가격
	    private String explanation; // 설명
	    private String tag; // 태그
	    private List<ProductFile> productFiles;
}
