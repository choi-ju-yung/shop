package com.example.demo.coupon.controller;

import com.example.demo.coupon.service.CouponService;
import com.example.demo.coupon.vo.CouponVO;
import com.example.demo.user.vo.CustomUserDetails;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/coupon")
public class CouponController {

    private final CouponService couponService;

    @GetMapping("/list")
    public String list(Model model) {
        model.addAttribute("coupons", couponService.getAllCoupons());
        return "coupon/list";
    }

    /** 관리자용 쿠폰 생성 */
    @PostMapping("/create")
    @ResponseBody
    public ResponseEntity<?> create(@RequestBody CouponVO coupon) {
        couponService.createCoupon(coupon);
        return ResponseEntity.ok(Map.of("message", "쿠폰이 생성되었습니다."));
    }

    /** 쿠폰 발급 API - k6 부하테스트 대상 */
    @PostMapping("/{couponId}/issue")
    @ResponseBody
    public ResponseEntity<?> issue(@PathVariable long couponId,
                                   @AuthenticationPrincipal CustomUserDetails user) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }
        boolean issued = couponService.issueCoupon(couponId, user.getUser().getUserNo());
        if (issued) {
            return ResponseEntity.ok(Map.of("message", "쿠폰이 발급되었습니다."));
        } else {
            return ResponseEntity.badRequest().body(Map.of("message", "쿠폰이 소진되었거나 이미 발급받으셨습니다."));
        }
    }
}
