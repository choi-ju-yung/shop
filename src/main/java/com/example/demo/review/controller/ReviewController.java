package com.example.demo.review.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.demo.review.vo.ReviewVO;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import com.example.demo.review.service.ReviewService;
import com.example.demo.user.vo.UserVO;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/member/review")
public class ReviewController {

    private final ReviewService reviewService;

    @Autowired
    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    /** 리뷰 작성 페이지 */
    @GetMapping("/write")
    public String writeReviewView(@RequestParam Long productId,
                                  HttpSession session, Model model) {
        long buyerNo = getLoginUserNo(session);

        // 이미 작성한 경우 → 구매내역으로
        if (reviewService.hasReview(productId, buyerNo)) {
            return "redirect:/member/mypage/purchases?alreadyReviewed=true";
        }

        Map<String, Object> product = reviewService.getProductForReview(productId, buyerNo);
        if (product == null) {
            // 구매자 본인이 아니거나 SOLD가 아닌 경우
            return "redirect:/member/mypage/purchases";
        }

        model.addAttribute("product", product);
        return "mypage/writeReview";
    }

    /** 리뷰 제출 */
    @PostMapping("/write")
    public String submitReview(@RequestParam Long productId,
                               @RequestParam long revieweeNo,
                               @RequestParam int rating,
                               @RequestParam(defaultValue = "") String content,
                               HttpSession session,
                               RedirectAttributes ra) {
        long reviewerNo = getLoginUserNo(session);
        try {
            reviewService.writeReview(productId, reviewerNo, revieweeNo, rating, content);
            ra.addFlashAttribute("reviewSuccess", true);
        } catch (Exception e) {
            ra.addFlashAttribute("reviewError", e.getMessage());
        }
        return "redirect:/member/mypage/purchases";
    }

    /** 받은 후기 목록 */
    @GetMapping("/received")
    public String receivedReviews(@RequestParam(defaultValue = "1") int page,
                                  HttpSession session, Model model) {
        long userNo = getLoginUserNo(session);
        int totalCount = reviewService.countReviewsByReviewee(userNo);
        double avg = reviewService.getReviewsByReviewee(userNo)
                         .stream().mapToInt(ReviewVO::getRating).average().orElse(0);

        PageHelper.startPage(page, 6);
        List<ReviewVO> reviews = reviewService.getReviewsByReviewee(userNo);
        PageInfo<ReviewVO> pageInfo = new PageInfo<>(reviews);

        model.addAttribute("reviews",     reviews);
        model.addAttribute("reviewCount", totalCount);
        model.addAttribute("avgRating",   Math.round(avg * 10.0) / 10.0);
        model.addAttribute("currentPage", pageInfo.getPageNum());
        model.addAttribute("totalPages",  pageInfo.getPages());
        return "mypage/receivedReviews";
    }

    private long getLoginUserNo(HttpSession session) {
        return ((UserVO) session.getAttribute("loginUser")).getUserNo();
    }
}
