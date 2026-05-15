package com.example.demo.coupon.service;

import com.example.demo.coupon.dao.CouponDao;
import com.example.demo.coupon.kafka.CouponIssuedEvent;
import com.example.demo.coupon.vo.CouponVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
public class CouponService {

    private static final String COUNT_KEY = "coupon:count:";
    private static final String USERS_KEY = "coupon:users:";
    public  static final String COUPON_TOPIC = "coupon-issued";

    private final RedisTemplate<String, String> redisTemplate;
    private final KafkaTemplate<String, CouponIssuedEvent> kafkaTemplate;
    private final CouponDao couponDao;

    public CouponService(@Qualifier("stringRedisTemplate") RedisTemplate<String, String> redisTemplate,
                         KafkaTemplate<String, CouponIssuedEvent> kafkaTemplate,
                         CouponDao couponDao) {
        this.redisTemplate = redisTemplate;
        this.kafkaTemplate = kafkaTemplate;
        this.couponDao = couponDao;
    }

    public void createCoupon(CouponVO coupon) {
        couponDao.insertCoupon(coupon);
        redisTemplate.opsForValue().set(COUNT_KEY + coupon.getCouponId(),
                String.valueOf(coupon.getTotalCount()));
    }

    public List<CouponVO> getAllCoupons() {
        return couponDao.selectAllCoupons();
    }

    public boolean issueCoupon(long couponId, long userId) {
        // 1. 중복 발급 방지
        Long added = redisTemplate.opsForSet().add(USERS_KEY + couponId, String.valueOf(userId));
        if (added == null || added == 0) {
            return false;
        }

        // 2. 수량 원자적 차감
        Long remaining = redisTemplate.opsForValue().decrement(COUNT_KEY + couponId);
        if (remaining == null || remaining < 0) {
            redisTemplate.opsForValue().increment(COUNT_KEY + couponId);
            redisTemplate.opsForSet().remove(USERS_KEY + couponId, String.valueOf(userId));
            return false;
        }

        // 3. Kafka 비동기 발행 → Consumer가 DB 저장
        kafkaTemplate.send(COUPON_TOPIC, new CouponIssuedEvent(couponId, userId));
        log.info("쿠폰 발급 성공 - couponId={}, userId={}, 남은수량={}", couponId, userId, remaining);
        return true;
    }
}
