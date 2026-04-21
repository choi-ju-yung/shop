package com.example.demo.user.dao;

import java.sql.Timestamp;
import java.util.Map;

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

	/** 탈퇴 후 30일 내 재가입 이력 조회 (있으면 탈퇴 시각, 없으면 null) */
	public Timestamp findWithdrawRestriction(String email, String loginId) {
		return sqlSession.selectOne("UserMapper.findWithdrawRestriction",
				Map.of("email", email != null ? email : "", "loginId", loginId != null ? loginId : ""));
	}

	/** 아이디 찾기: 이름 + 이메일 */
	public String findLoginIdByNameAndEmail(String name, String email) {
		return sqlSession.selectOne("UserMapper.findLoginIdByNameAndEmail",
				Map.of("name", name, "email", email));
	}

	/** 비밀번호 찾기: 로그인 아이디 + 이메일로 사용자 확인 */
	public UserVO findUserByLoginIdAndEmail(String loginId, String email) {
		return sqlSession.selectOne("UserMapper.findUserByLoginIdAndEmail",
				Map.of("loginId", loginId, "email", email));
	}

	/** 비밀번호 업데이트 */
	public int updatePassword(String loginId, String encodedPwd) {
		return sqlSession.update("UserMapper.updatePassword",
				Map.of("loginId", loginId, "encodedPwd", encodedPwd));
	}

	public void archiveWithdrawnUser(long userNo) {
		sqlSession.insert("UserMapper.archiveWithdrawnUser", userNo);
	}

	public int withdrawUser(long userNo) {
		return sqlSession.update("UserMapper.withdrawUser", userNo);
	}
}
