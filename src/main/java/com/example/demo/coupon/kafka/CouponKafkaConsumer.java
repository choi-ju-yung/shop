package com.example.demo.coupon.kafka;

import com.example.demo.coupon.dao.CouponDao;
import com.example.demo.coupon.service.CouponService;
import com.example.demo.coupon.vo.UserCouponVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class CouponKafkaConsumer {

    private final CouponDao couponDao;

    @KafkaListener(topics = CouponService.COUPON_TOPIC, groupId = "coupon-group")
    public void consume(CouponIssuedEvent event) {
        try {
            if (couponDao.existsUserCoupon(event.getUserId(), event.getCouponId())) {
                return; // DB 중복 방어
            }
            UserCouponVO userCoupon = new UserCouponVO();
            userCoupon.setUserId(event.getUserId());
            userCoupon.setCouponId(event.getCouponId());
            couponDao.insertUserCoupon(userCoupon);
            couponDao.decrementRemainingCount(event.getCouponId());
        } catch (Exception e) {
            log.error("쿠폰 DB 저장 실패 - couponId={}, userId={}", event.getCouponId(), event.getUserId(), e);
        }
    }
}
