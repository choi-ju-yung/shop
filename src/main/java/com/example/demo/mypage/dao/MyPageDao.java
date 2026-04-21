package com.example.demo.mypage.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.demo.mypage.vo.MyPage;
import com.example.demo.mypage.vo.ProfileUpdateDto;

@Repository
public class MyPageDao {

    private final SqlSession sqlSession;

    @Autowired
    public MyPageDao(SqlSession sqlSession) {
        this.sqlSession = sqlSession;
    }

    public MyPage findByMyPage(long userNo) {
        return sqlSession.selectOne("MyPageMapper.findByMyPage", userNo);
    }

    public int registUserPage(long userId) {
        return sqlSession.insert("MyPageMapper.registUserPage", userId);
    }

    public int checkNicknameDup(Map<String, Object> map) {
        return sqlSession.selectOne("MyPageMapper.checkNicknameDup", map);
    }

    public int updateProfile(ProfileUpdateDto dto) {
        return sqlSession.update("MyPageMapper.updateProfile", dto);
    }

    public Map<String, Object> getStats(long userNo) {
        return sqlSession.selectOne("MyPageMapper.getStats", userNo);
    }

    public List<Map<String, Object>> getRecentProducts(long userNo) {
        return sqlSession.selectList("MyPageMapper.getRecentProducts", userNo);
    }

    public int hasNickname(long userNo) {
        return sqlSession.selectOne("MyPageMapper.hasNickname", userNo);
    }
}
