package com.example.demo.review.vo;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class ReviewVO {
    private long reviewId;
    private Long productId;
    private long reviewerNo;
    private long revieweeNo;
    private int rating;
    private String content;
    private Timestamp regDate;

    // JOIN 필드
    private String reviewerName;
    private String productTitle;
}
