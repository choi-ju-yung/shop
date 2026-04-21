package com.example.demo.review.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.demo.review.vo.ReviewVO;

@Repository
public class ReviewDao {

    private final SqlSession sqlSession;

    @Autowired
    public ReviewDao(SqlSession sqlSession) {
        this.sqlSession = sqlSession;
    }

    public int insertReview(ReviewVO review) {
        return sqlSession.insert("ReviewMapper.insertReview", review);
    }

    public int hasReview(Map<String, Object> map) {
        return sqlSession.selectOne("ReviewMapper.hasReview", map);
    }

    public List<ReviewVO> getReviewsByReviewee(long revieweeNo) {
        return sqlSession.selectList("ReviewMapper.getReviewsByReviewee", revieweeNo);
    }

    public int countReviewsByReviewee(long revieweeNo) {
        return sqlSession.selectOne("ReviewMapper.countReviewsByReviewee", revieweeNo);
    }

    public List<ReviewVO> getReviewsByRevieweePaged(Map<String, Object> map) {
        return sqlSession.selectList("ReviewMapper.getReviewsByRevieweePaged", map);
    }

    public Map<String, Object> getProductForReview(Map<String, Object> map) {
        return sqlSession.selectOne("ReviewMapper.getProductForReview", map);
    }

    public int updateTemperature(long userNo, int rating) {
        Map<String, Object> map = new java.util.HashMap<>();
        map.put("userNo", userNo);
        map.put("rating", rating);
        return sqlSession.update("ReviewMapper.updateTemperature", map);
    }
}
