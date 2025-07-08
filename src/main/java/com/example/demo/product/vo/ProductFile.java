package com.example.demo.product.vo;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ProductFile {
    private int fileId;
    private String productId;
    private String originalName;  // 사용자가 업로드한 원본 파일명
    private String savedName;     // 서버에 저장된 랜덤 파일명
    private String filePath;      // 웹에서 접근 가능한 경로
    private boolean isMain; // true면 대표 이미지
}
