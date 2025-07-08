package com.example.demo.user.dao;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.demo.user.vo.UserVO;

@Repository
public class UserDao {
	
	private final SqlSession sqlSession;
	
	@Autowired
    public UserDao(SqlSession sqlSession) {
        this.sqlSession = sqlSession;
    }
	
	public UserVO findByKakaoId(String kakaoId) {
		return sqlSession.selectOne("UserMapper.findByKakaoId",kakaoId);
	}
	
	public UserVO findByUserId(String loginId) {
		return sqlSession.selectOne("UserMapper.findByUserId",loginId);
	}
	
	public UserVO findByUserNo(Long userNo) {
		return sqlSession.selectOne("UserMapper.findByUserNo",userNo);
	}
	
	public UserVO getUserByUsername(String username) {
		return sqlSession.selectOne("UserMapper.getUserByUsername",username);
	}
	
	public int emailDupCheck(String memberEmail) {
		return sqlSession.selectOne("UserMapper.emailDupCheck",memberEmail);
	}
	
	public int registKakaoUser(UserVO userVO) {
		return sqlSession.insert("UserMapper.registKakaoUser",userVO);
	}
	
	public int duplicateId(String loginId) {
		return sqlSession.selectOne("UserMapper.duplicateId",loginId);
	}
	
	public String findPwdById(String loginId) {
		return sqlSession.selectOne("UserMapper.findPwdById",loginId);
	}
}
