package com.example.demo.regist.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.ui.Model;
import com.example.demo.mypage.dao.MyPageDao;
import com.example.demo.regist.service.RegistService;
import com.example.demo.user.service.UserService;
import com.example.demo.user.vo.UserVO;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/regist")
public class RegistController {

	private final RegistService registService;
	private final UserService userService;
	private final MyPageDao myPageDao;

	@Autowired
	public RegistController(RegistService registService, UserService userService, MyPageDao myPageDao) {
		this.registService = registService;
		this.userService = userService;
		this.myPageDao = myPageDao;
	}

	@PostMapping("/nomalInsert")
	public String nomalInsert(@ModelAttribute UserVO userVO, RedirectAttributes redirectAttributes) {
		try {
			// 탈퇴 후 30일 재가입 제한 체크 (이메일 + 아이디 모두 확인)
			userService.checkWithdrawRestriction(userVO.getEmail(), userVO.getLoginId());
			registService.nomalInsert(userVO);
			redirectAttributes.addFlashAttribute("msg", "회원가입이 완료되었습니다.");
			return "redirect:/login";
		} catch (RuntimeException e) {
			redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
			return "redirect:/regist/nomalregist";
		}
	}

	/** 닉네임 중복 확인 */
	@GetMapping("/duplicateNickname")
	@ResponseBody
	public String duplicateNickname(@RequestParam String nickname) {
		return String.valueOf(myPageDao.checkNicknameForRegist(nickname));
	}

	/** 이메일 기반 탈퇴 제한 확인 (인증 전송 전 호출) */
	@GetMapping("/checkWithdraw")
	@ResponseBody
	public Map<String, Object> checkWithdraw(@RequestParam String email) {
		Map<String, Object> result = new HashMap<>();
		try {
			userService.checkWithdrawRestriction(email, null);
			result.put("restricted", false);
		} catch (RuntimeException e) {
			result.put("restricted", true);
			result.put("message", e.getMessage());
		}
		return result;
	}

	@GetMapping("/kakao")
	public String kakaoRegistForm(HttpSession session, Model model) {
		String oauthId = (String) session.getAttribute("kakaoOauthId");
		if (oauthId == null) {
			return "redirect:/login";
		}
		model.addAttribute("nickname", session.getAttribute("kakaoNickname"));
		model.addAttribute("oauthId", oauthId);
		model.addAttribute("email", session.getAttribute("kakaoEmail"));
		return "regist/kakaoregist";
	}

}
