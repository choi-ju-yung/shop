package com.example.demo.coupon.service;

import com.example.demo.coupon.dao.CouponDao;
import com.example.demo.coupon.kafka.CouponIssuedEvent;
import com.example.demo.coupon.vo.CouponVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

    public List<Long> getIssuedCouponIds(long userId) {
        return couponDao.selectIssuedCouponIds(userId);
    }

    public Map<Long, Integer> getRemainingCounts(List<CouponVO> coupons) {
        Map<Long, Integer> map = new HashMap<>();
        for (CouponVO c : coupons) {
            String val = redisTemplate.opsForValue().get(COUNT_KEY + c.getCouponId());
            int remaining = (val != null) ? Math.max(0, Integer.parseInt(val)) : c.getRemainingCount();
            map.put(c.getCouponId(), remaining);
        }
        return map;
    }

    /**
     * 서버 기동 시 DB 쿠폰 → Redis 동기화
     * - Redis 키가 없는 쿠폰만 초기화 (기존 키는 건드리지 않음)
     * - 재시작 복구: DB 발급 수(USER_COUPON) 기준으로 잔여수량 계산
     */
    public void syncAllCouponsToRedis() {
        List<CouponVO> coupons = couponDao.selectAllCoupons();
        int synced = 0;
        for (CouponVO c : coupons) {
            String key = COUNT_KEY + c.getCouponId();
            if (Boolean.FALSE.equals(redisTemplate.hasKey(key))) {
                int issued    = couponDao.countIssuedByCouponId(c.getCouponId());
                int remaining = Math.max(0, c.getTotalCount() - issued);
                redisTemplate.opsForValue().set(key, String.valueOf(remaining));
                log.info("Redis 쿠폰 초기화 - couponId={}, remaining={}/{}", c.getCouponId(), remaining, c.getTotalCount());
                synced++;
            }
        }
        if (synced > 0) log.info("Redis 쿠폰 동기화 완료 - {}개 초기화", synced);
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
