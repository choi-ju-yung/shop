package com.example.demo.mypage.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.mypage.dao.MyPageDao;
import com.example.demo.mypage.vo.MyPage;
import com.example.demo.mypage.vo.ProfileUpdateDto;
import com.example.demo.user.dao.UserDao;

@Service
public class MyPageService {

    private final MyPageDao myPageDao;
    private final UserDao userDao;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public MyPageService(MyPageDao myPageDao, UserDao userDao, PasswordEncoder passwordEncoder) {
        this.myPageDao = myPageDao;
        this.userDao = userDao;
        this.passwordEncoder = passwordEncoder;
    }

    public MyPage findByMyPage(long userNo) {
        return myPageDao.findByMyPage(userNo);
    }

    /** 닉네임 중복 확인 (0: 사용가능, 1: 중복) */
    public int checkNicknameDup(long userNo, String nickname) {
        return myPageDao.checkNicknameDup(Map.of("userNo", userNo, "nickname", nickname));
    }

    /** 프로필 통합 저장 (닉네임 + 소개글 + 이미지 선택적) — DB 쿼리 1회 */
    @Transactional
    public void updateProfile(long userNo, String nickname, String introduce, String savedFileName) {
        String nick = (nickname == null) ? "" : nickname.trim();
        if (nick.isEmpty()) throw new RuntimeException("닉네임을 입력해주세요.");
        if (nick.length() < 2 || nick.length() > 12) throw new RuntimeException("닉네임은 2~12자로 입력해주세요.");
        if (checkNicknameDup(userNo, nick) > 0) throw new RuntimeException("이미 사용 중인 닉네임입니다.");

        String intro = (introduce == null) ? "" : introduce.trim();
        myPageDao.updateProfile(new ProfileUpdateDto(userNo, nick, intro, savedFileName));
    }

    /** 비밀번호 변경 (현재 비밀번호 확인 후 변경) */
    @Transactional
    public void changePassword(long userNo, String currentPwd, String newPwd) {
        var user = userDao.findByUserNo(userNo);
        if (user == null) throw new RuntimeException("회원 정보를 찾을 수 없습니다.");
        if (user.getPassword() == null) throw new RuntimeException("소셜 로그인 계정은 비밀번호를 변경할 수 없습니다.");
        if (!passwordEncoder.matches(currentPwd, user.getPassword())) throw new RuntimeException("현재 비밀번호가 올바르지 않습니다.");
        String encoded = passwordEncoder.encode(newPwd);
        userDao.updatePassword(user.getLoginId(), encoded);
    }

    /** 마이페이지 통계 */
    public Map<String, Object> getStats(long userNo) {
        return myPageDao.getStats(userNo);
    }

    /** 최근 등록 상품 (최대 3개) */
    public List<Map<String, Object>> getRecentProducts(long userNo) {
        return myPageDao.getRecentProducts(userNo);
    }

    /** 닉네임 설정 여부 확인 */
    public boolean hasNickname(long userNo) {
        return myPageDao.hasNickname(userNo) == 1;
    }
}
