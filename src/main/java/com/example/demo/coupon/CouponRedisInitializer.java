package com.example.demo.coupon;

import com.example.demo.coupon.service.CouponService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class CouponRedisInitializer {

    private final CouponService couponService;

    /**
     * 서버 완전 기동 후 실행 - DB에 있는 쿠폰 중 Redis 키가 없는 것을 자동 초기화
     * SQL로 직접 INSERT한 쿠폰도 발급이 정상 동작하도록 보장
     */
    @EventListener(ApplicationReadyEvent.class)
    public void initCouponRedis() {
        log.info("쿠폰 Redis 동기화 시작...");
        try {
            couponService.syncAllCouponsToRedis();
        } catch (Exception e) {
            log.warn("쿠폰 Redis 동기화 실패 (Redis 미연결 가능성): {}", e.getMessage());
        }
    }
}
