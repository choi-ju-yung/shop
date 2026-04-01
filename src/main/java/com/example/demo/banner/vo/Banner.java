package com.example.demo.banner.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Banner {
    private Long   bannerId;
    private String imageUrl;
    private String linkUrl;
    private int    sortOrder;
    private String isActive;
    private String startDt;
    private String endDt;
    private String regDate;
    
}
