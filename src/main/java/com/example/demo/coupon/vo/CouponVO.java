package com.example.demo.coupon.vo;

import java.sql.Date;
import lombok.Data;

@Data
public class CouponVO {
    private long couponId;
    private String name;
    private int totalCount;
    private int remainingCount;
    private Date startDate;
    private Date endDate;
    private Date createdAt;
}
