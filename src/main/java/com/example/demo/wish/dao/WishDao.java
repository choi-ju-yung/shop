package com.example.demo.wish.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import com.example.demo.wish.vo.WishVO;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class WishDao {

    private final SqlSession session;

    public int insertWish(Map<String, Object> map) {
        return session.insert("WishMapper.insertWish", map);
    }

    public int deleteWish(Map<String, Object> map) {
        return session.delete("WishMapper.deleteWish", map);
    }

    public int isWished(Map<String, Object> map) {
        return session.selectOne("WishMapper.isWished", map);
    }

    public List<WishVO> selectWishList(long userNo) {
        return session.selectList("WishMapper.selectWishList", userNo);
    }

    public long selectSellerNo(Long productId) {
        return session.selectOne("WishMapper.selectSellerNo", productId);
    }

    public void deleteWishlistByUserNo(long userNo) {
        session.delete("WishMapper.deleteWishlistByUserNo", userNo);
    }
}
