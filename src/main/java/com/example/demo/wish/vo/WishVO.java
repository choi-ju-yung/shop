package com.example.demo.wish.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class WishVO {
    private long wishId;
    private long userNo;
    private Long productId;
    private String createdAt;

    // 목록 조회 시 JOIN 결과
    private String productTitle;
    private int productPrice;
    private String productState;
    private String productPlace;
    private String mainFilePath;
    private String sellerName;
}
