package com.example.demo.regist.dao;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.demo.authnumber.vo.AuthNumber;

@Repository
public class EmailDao {
	
	private final SqlSession sqlSession;
	
	@Autowired
	public EmailDao(SqlSession sqlSession) {
		this.sqlSession = sqlSession;
	}
	
	public int createAuthNumber(AuthNumber authNumber) {
		return sqlSession.insert("EmailMapper.createAuthNumber",authNumber);
	}
	
	public int compareAuthNumber(AuthNumber authNumber) {
		return sqlSession.selectOne("EmailMapper.compareAuthNumber",authNumber);
	}

	public int markVerified(String email) {
		return sqlSession.update("EmailMapper.markVerified", email);
	}

	public boolean isEmailVerified(String email) {
		Integer result = sqlSession.selectOne("EmailMapper.isEmailVerified", email);
		return result != null && result > 0;
	}
}
