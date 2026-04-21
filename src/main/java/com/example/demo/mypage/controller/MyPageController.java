package com.example.demo.mypage.controller;

import java.io.File;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.mypage.service.MyPageService;
import com.example.demo.mypage.vo.MyPage;
import com.example.demo.user.service.UserService;
import com.example.demo.user.vo.UserVO;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/member")
public class MyPageController {

    private final UserService userService;
    private final MyPageService myPageService;

    @Value("${app.upload.dir:C:/upload}")
    private String uploadDir;

    @Autowired
    public MyPageController(UserService userService, MyPageService myPageService) {
        this.userService = userService;
        this.myPageService = myPageService;
    }

    /** 마이페이지 홈 */
    @GetMapping("/mypage")
    public String myPageView(HttpSession session, Model model) {
        long userNo = getLoginUserNo(session);
        MyPage myPage = myPageService.findByMyPage(userNo);
        model.addAttribute("myPage", myPage);
        return "mypage/myPageMain";
    }

    /** 회원정보 설정 페이지 */
    @GetMapping("/mypage/settings")
    public String settingsView(HttpSession session, Model model) {
        long userNo = getLoginUserNo(session);
        MyPage myPage = myPageService.findByMyPage(userNo);
        model.addAttribute("myPage", myPage);
        return "mypage/settings";
    }

    /** 닉네임 중복 확인 (AJAX) */
    @GetMapping("/mypage/checkNickname")
    @ResponseBody
    public Map<String, Object> checkNickname(@RequestParam String nickname, HttpSession session) {
        long userNo = getLoginUserNo(session);
        Map<String, Object> result = new HashMap<>();
        if (nickname == null || nickname.trim().length() < 2 || nickname.trim().length() > 12) {
            result.put("available", false);
            result.put("message", "닉네임은 2~12자로 입력해주세요.");
        } else if (myPageService.checkNicknameDup(userNo, nickname.trim()) > 0) {
            result.put("available", false);
            result.put("message", "이미 사용 중인 닉네임입니다.");
        } else {
            result.put("available", true);
            result.put("message", "사용 가능한 닉네임입니다.");
        }
        return result;
    }

    /** 프로필 통합 저장 (이미지 + 닉네임 + 소개글) */
    @PostMapping("/mypage/updateProfile")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateProfile(
            @RequestParam(required = false) MultipartFile file,
            @RequestParam String nickname,
            @RequestParam(required = false, defaultValue = "") String introduce,
            HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        try {
            long userNo = getLoginUserNo(session);

            String savedName = null;
            if (file != null && !file.isEmpty()) {
                String contentType = file.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    result.put("success", false);
                    result.put("message", "이미지 파일만 업로드 가능합니다.");
                    return ResponseEntity.badRequest().body(result);
                }
                String orig = file.getOriginalFilename();
                String ext = orig.substring(orig.lastIndexOf(".")).toLowerCase();
                savedName = "profile_" + userNo + "_" + UUID.randomUUID().toString().substring(0, 8) + ext;

                File dir = new File(uploadDir + "/profile");
                if (!dir.exists()) dir.mkdirs();
                file.transferTo(new File(dir, savedName));
            }

            myPageService.updateProfile(userNo, nickname, introduce, savedName);
            result.put("success", true);
        } catch (RuntimeException e) {
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(result);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "저장 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(result);
        }
        return ResponseEntity.ok(result);
    }

    /** 비밀번호 변경 페이지 (일반 회원만) */
    @GetMapping("/mypage/changePassword")
    public String changePasswordView(HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser.getOauthProvider() != null) {
            return "redirect:/member/mypage";
        }
        return "mypage/changePassword";
    }

    /** 비밀번호 변경 (AJAX) */
    @PostMapping("/mypage/changePassword")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> changePassword(
            @RequestParam String currentPwd,
            @RequestParam String newPwd,
            @RequestParam String confirmPwd,
            HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (!newPwd.equals(confirmPwd)) throw new RuntimeException("새 비밀번호가 일치하지 않습니다.");
            if (newPwd.length() < 8) throw new RuntimeException("비밀번호는 8자 이상으로 입력해주세요.");
            long userNo = getLoginUserNo(session);
            myPageService.changePassword(userNo, currentPwd, newPwd);
            result.put("success", true);
        } catch (RuntimeException e) {
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(result);
        }
        return ResponseEntity.ok(result);
    }

    /** 마이페이지 통계 (AJAX) */
    @GetMapping("/mypage/stats")
    @ResponseBody
    public Map<String, Object> myPageStats(HttpSession session) {
        long userNo = getLoginUserNo(session);
        Map<String, Object> stats = new HashMap<>();
        try { stats.putAll(myPageService.getStats(userNo)); } catch (Exception ignored) {}
        return stats;
    }

    /** 최근 등록 상품 (AJAX) */
    @GetMapping("/mypage/recentProducts")
    @ResponseBody
    public List<Map<String, Object>> recentProducts(HttpSession session) {
        long userNo = getLoginUserNo(session);
        try { return myPageService.getRecentProducts(userNo); } catch (Exception ignored) {}
        return Collections.emptyList();
    }

    /** 닉네임 설정 여부 확인 (채팅/상품등록 게이트용 AJAX) */
    @GetMapping("/mypage/requireNickname")
    @ResponseBody
    public Map<String, Object> requireNickname(HttpSession session) {
        long userNo = getLoginUserNo(session);
        Map<String, Object> result = new HashMap<>();
        result.put("hasNickname", myPageService.hasNickname(userNo));
        return result;
    }

    private long getLoginUserNo(HttpSession session) {
        return ((UserVO) session.getAttribute("loginUser")).getUserNo();
    }
}
