package com.example.demo.category.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubCategory {
	private String subcategoryId;
	private String subcategoryName;
	private String parentCategoryId; // 외래 키로 부모 카테고리 ID 참조
	
}
