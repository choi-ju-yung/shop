package com.example.demo.coupon;

import com.example.demo.coupon.dao.CouponDao;
import com.example.demo.coupon.kafka.CouponIssuedEvent;
import com.example.demo.coupon.service.CouponService;
import com.example.demo.coupon.vo.CouponVO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.SetOperations;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.kafka.core.KafkaTemplate;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CouponServiceTest {

    @Mock
    RedisTemplate<String, String> redisTemplate;

    @Mock
    KafkaTemplate<String, CouponIssuedEvent> kafkaTemplate;

    @Mock
    CouponDao couponDao;

    @InjectMocks
    CouponService couponService;

    @Mock
    ValueOperations<String, String> valueOps;

    @Mock
    SetOperations<String, String> setOps;

    @BeforeEach
    void setUp() {
        when(redisTemplate.opsForValue()).thenReturn(valueOps);
        when(redisTemplate.opsForSet()).thenReturn(setOps);
    }

    // ───────────────────────────────────────────
    // issueCoupon
    // ───────────────────────────────────────────

    @Test
    @DisplayName("쿠폰 정상 발급 - Kafka 이벤트 발행, true 반환")
    void issueCoupon_success() {
        when(setOps.add("coupon:users:1", "100")).thenReturn(1L);
        when(valueOps.decrement("coupon:count:1")).thenReturn(4L);

        boolean result = couponService.issueCoupon(1L, 100L);

        assertThat(result).isTrue();
        verify(kafkaTemplate).send(eq(CouponService.COUPON_TOPIC), any(CouponIssuedEvent.class));
    }

    @Test
    @DisplayName("중복 발급 - Redis Set에 이미 존재하면 false 반환, Kafka 미발행")
    void issueCoupon_duplicate() {
        when(setOps.add("coupon:users:1", "100")).thenReturn(0L);

        boolean result = couponService.issueCoupon(1L, 100L);

        assertThat(result).isFalse();
        verify(kafkaTemplate, never()).send(any(), any(CouponIssuedEvent.class));
    }

    @Test
    @DisplayName("재고 소진 - 차감 후 음수면 롤백하고 false 반환")
    void issueCoupon_outOfStock() {
        when(setOps.add(any(), any())).thenReturn(1L);
        when(valueOps.decrement("coupon:count:1")).thenReturn(-1L);

        boolean result = couponService.issueCoupon(1L, 100L);

        assertThat(result).isFalse();
        verify(valueOps).increment("coupon:count:1");
        verify(setOps).remove("coupon:users:1", "100");
        verify(kafkaTemplate, never()).send(any(), any(CouponIssuedEvent.class));
    }

    // ───────────────────────────────────────────
    // getRemainingCounts
    // ───────────────────────────────────────────

    @Test
    @DisplayName("Redis에 값이 있으면 Redis 기준으로 잔여수량 반환")
    void getRemainingCounts_fromRedis() {
        CouponVO coupon = new CouponVO();
        coupon.setCouponId(1L);
        coupon.setRemainingCount(10);

        when(valueOps.get("coupon:count:1")).thenReturn("7");

        Map<Long, Integer> result = couponService.getRemainingCounts(List.of(coupon));

        assertThat(result.get(1L)).isEqualTo(7);
    }

    @Test
    @DisplayName("Redis에 값이 없으면 DB 잔여수량으로 폴백")
    void getRemainingCounts_fallbackToDb() {
        CouponVO coupon = new CouponVO();
        coupon.setCouponId(1L);
        coupon.setRemainingCount(5);

        when(valueOps.get("coupon:count:1")).thenReturn(null);

        Map<Long, Integer> result = couponService.getRemainingCounts(List.of(coupon));

        assertThat(result.get(1L)).isEqualTo(5);
    }

    // ───────────────────────────────────────────
    // createCoupon
    // ───────────────────────────────────────────

    @Test
    @DisplayName("쿠폰 생성 - DB insert 후 Redis에 초기 수량 저장")
    void createCoupon_savesToDbAndRedis() {
        CouponVO coupon = new CouponVO();
        coupon.setCouponId(2L);
        coupon.setTotalCount(100);

        couponService.createCoupon(coupon);

        verify(couponDao).insertCoupon(coupon);
        verify(valueOps).set("coupon:count:2", "100");
    }
}
