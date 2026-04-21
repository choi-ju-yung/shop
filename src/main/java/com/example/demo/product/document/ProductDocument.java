package com.example.demo.product.document;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductDocument {
    private Long   productId;
    private String title;
    private String tags;         // PRODUCT_KEYWORD (쉼표 구분)
    private String tradeStatus;
    private String mainFilePath;
    private int    price;
    private String place;
    private String state;
    private Long   userNo;
}
