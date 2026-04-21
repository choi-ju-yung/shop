package com.example.demo.user.controller;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.demo.mypage.service.MyPageService;
import com.example.demo.mypage.vo.MyPage;
import com.example.demo.product.vo.Product;
import com.example.demo.productregist.service.ProductRegistService;
import com.example.demo.review.service.ReviewService;
import com.example.demo.review.vo.ReviewVO;
import com.example.demo.user.vo.UserVO;
import com.example.demo.util.UserIdEncoder;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.servlet.http.HttpSession;

@Controller
public class SellerController {

    private final MyPageService myPageService;
    private final ProductRegistService productRegistService;
    private final ReviewService reviewService;

    @Autowired
    public SellerController(MyPageService myPageService,
                            ProductRegistService productRegistService,
                            ReviewService reviewService) {
        this.myPageService = myPageService;
        this.productRegistService = productRegistService;
        this.reviewService = reviewService;
    }

    /** 판매자 프로필 페이지 */
    @GetMapping("/user/profile/{uid}")
    public String sellerProfile(@PathVariable String uid,
                                @RequestParam(defaultValue = "ALL") String status,
                                Model model, HttpSession session) {
        long userNo = UserIdEncoder.decode(uid);
        MyPage seller = myPageService.findByMyPage(userNo);
        if (seller == null) return "redirect:/main";

        Map<String, Object> stats = Collections.emptyMap();
        try { stats = myPageService.getStats(userNo); } catch (Exception ignored) {}

        List<Product> products = productRegistService.getSellerProducts(userNo, status);

        // 리뷰 목록 + 평균 별점
        List<ReviewVO> reviews = reviewService.getReviewsByReviewee(userNo);
        double avgRating = 0;
        if (!reviews.isEmpty()) {
            avgRating = reviews.stream().mapToInt(ReviewVO::getRating).average().orElse(0);
            avgRating = Math.round(avgRating * 10.0) / 10.0;
        }

        model.addAttribute("seller", seller);
        model.addAttribute("sellerNo", userNo);
        model.addAttribute("encodedSellerNo", UserIdEncoder.encode(userNo));
        model.addAttribute("stats", stats);
        model.addAttribute("products", products);
        model.addAttribute("currentStatus", status);
        model.addAttribute("reviews", reviews);
        model.addAttribute("avgRating", avgRating);
        model.addAttribute("reviewCount", reviews.size());

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        model.addAttribute("isOwn", loginUser != null && loginUser.getUserNo() == userNo);

        return "user/sellerProfile";
    }

    /** 판매자 받은 후기 페이지 */
    @GetMapping("/user/profile/{uid}/reviews")
    public String sellerReviews(@PathVariable String uid,
                                @RequestParam(defaultValue = "1") int page,
                                Model model) {
        long userNo = UserIdEncoder.decode(uid);
        MyPage seller = myPageService.findByMyPage(userNo);
        if (seller == null) return "redirect:/main";

        int totalCount = reviewService.countReviewsByReviewee(userNo);
        double avgRating = reviewService.getReviewsByReviewee(userNo)
                               .stream().mapToInt(ReviewVO::getRating).average().orElse(0);
        avgRating = Math.round(avgRating * 10.0) / 10.0;

        PageHelper.startPage(page, 12);
        List<ReviewVO> reviews = reviewService.getReviewsByReviewee(userNo);
        PageInfo<ReviewVO> pageInfo = new PageInfo<>(reviews);

        model.addAttribute("seller", seller);
        model.addAttribute("sellerNo", userNo);
        model.addAttribute("encodedSellerNo", UserIdEncoder.encode(userNo));
        model.addAttribute("reviews", reviews);
        model.addAttribute("avgRating", avgRating);
        model.addAttribute("reviewCount", totalCount);
        model.addAttribute("currentPage", pageInfo.getPageNum());
        model.addAttribute("totalPages",  pageInfo.getPages());

        return "user/sellerReviews";
    }
}
