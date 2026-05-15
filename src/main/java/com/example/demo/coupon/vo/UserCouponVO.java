package com.example.demo.coupon.vo;

import java.sql.Date;
import lombok.Data;

@Data
public class UserCouponVO {
    private long userCouponId;
    private long userId;
    private long couponId;
    private Date issuedAt;
}
