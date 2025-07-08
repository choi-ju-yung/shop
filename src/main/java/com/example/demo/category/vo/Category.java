package com.example.demo.category.vo;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Category {
	private String categoryId;
	private String categoryName;
	private List<SubCategory> subCategories; // 1:N 관
}
