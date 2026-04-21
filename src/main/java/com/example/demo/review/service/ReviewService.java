package com.example.demo.review.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.review.dao.ReviewDao;
import com.example.demo.review.vo.ReviewVO;

@Service
public class ReviewService {

    private final ReviewDao reviewDao;

    @Autowired
    public ReviewService(ReviewDao reviewDao) {
        this.reviewDao = reviewDao;
    }

    /** 리뷰 작성 페이지용 상품 정보 조회 (구매자 본인 + SOLD 검증 포함) */
    public Map<String, Object> getProductForReview(Long productId, long buyerNo) {
        Map<String, Object> map = new java.util.HashMap<>();
        map.put("productId", productId);
        map.put("buyerNo", buyerNo);
        return reviewDao.getProductForReview(map);
    }

    /** 이미 리뷰 작성 여부 */
    public boolean hasReview(Long productId, long reviewerNo) {
        Map<String, Object> map = new java.util.HashMap<>();
        map.put("productId", productId);
        map.put("reviewerNo", reviewerNo);
        return reviewDao.hasReview(map) > 0;
    }

    /**
     * 리뷰 등록 + 매너온도 갱신
     * - 구매자 본인 + SOLD 상품 + 미작성 검증
     */
    @Transactional
    public void writeReview(Long productId, long reviewerNo, long revieweeNo, int rating, String content) {
        if (hasReview(productId, reviewerNo)) {
            throw new IllegalStateException("이미 후기를 작성한 거래입니다.");
        }
        if (rating < 1 || rating > 5) {
            throw new IllegalArgumentException("별점은 1~5점 사이로 입력해주세요.");
        }

        ReviewVO review = new ReviewVO();
        review.setProductId(productId);
        review.setReviewerNo(reviewerNo);
        review.setRevieweeNo(revieweeNo);
        review.setRating(rating);
        review.setContent(content == null ? "" : content.trim());
        reviewDao.insertReview(review);

        // 판매자 매너온도 갱신 (별점별 증감)
        reviewDao.updateTemperature(revieweeNo, rating);
    }

    /** 판매자가 받은 리뷰 목록 (전체) */
    public List<ReviewVO> getReviewsByReviewee(long revieweeNo) {
        return reviewDao.getReviewsByReviewee(revieweeNo);
    }

    /** 판매자가 받은 리뷰 수 */
    public int countReviewsByReviewee(long revieweeNo) {
        return reviewDao.countReviewsByReviewee(revieweeNo);
    }

    /** 판매자가 받은 리뷰 목록 (페이징) */
    public List<ReviewVO> getReviewsByRevieweePaged(long revieweeNo, int page, int pageSize) {
        java.util.Map<String, Object> map = new java.util.HashMap<>();
        map.put("revieweeNo", revieweeNo);
        map.put("startRow", (page - 1) * pageSize);
        map.put("endRow", page * pageSize);
        return reviewDao.getReviewsByRevieweePaged(map);
    }
}
