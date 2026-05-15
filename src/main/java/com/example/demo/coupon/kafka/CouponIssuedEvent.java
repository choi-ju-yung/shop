package com.example.demo.coupon.kafka;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CouponIssuedEvent {
    private long couponId;
    private long userId;
}
