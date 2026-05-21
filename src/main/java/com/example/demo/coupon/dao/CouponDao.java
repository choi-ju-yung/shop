package com.example.demo.coupon.dao;

import com.example.demo.coupon.vo.CouponVO;
import com.example.demo.coupon.vo.UserCouponVO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface CouponDao {
    List<CouponVO> selectAllCoupons();
    CouponVO selectCouponById(long couponId);
    void insertCoupon(CouponVO coupon);
    void insertUserCoupon(UserCouponVO userCoupon);
    boolean existsUserCoupon(long userId, long couponId);
    List<Long> selectIssuedCouponIds(long userId);
    int countIssuedByCouponId(long couponId);
    void decrementRemainingCount(long couponId);
}
