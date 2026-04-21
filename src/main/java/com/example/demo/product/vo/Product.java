package com.example.demo.product.vo;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@Data
@NoArgsConstructor
@Builder
public class Product {
    private Long productId;
    private Long userNo;       // 판매자 유저번호
    private String title;      // 제목
    private String subCate;    // 서브카테고리
    private String place;      // 거래지역
    private String state;      // 상품상태
    private int price;         // 가격
    private String explanation; // 설명
    private String tag;        // 태그
    private List<ProductFile> productFiles;

    // 거래 상태
    private String tradeStatus;    // SALE / RESERVED / SOLD
    private Long buyerNo;          // 구매자 유저번호 (SOLD 시 세팅)

    // 상세 조회 시 추가 필드
    private String sellerName;     // 판매자 닉네임 (JOIN)
    private String buyerName;      // 구매자 닉네임 (구매내역 조회 시)
    private String mainFilePath;      // 대표 이미지 경로 (목록용)
    private String regDate;           // 등록일
    private boolean hasReview;        // 구매자가 리뷰를 작성했는지 여부
    private String sellerProfileImg;  // 판매자 프로필 이미지
}
