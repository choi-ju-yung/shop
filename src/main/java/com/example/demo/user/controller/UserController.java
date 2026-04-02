package com.example.demo.user.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.config.KakaoConfig;
import com.example.demo.user.service.UserService;
import com.example.demo.user.vo.CustomUserDetails;
import com.example.demo.user.vo.UserVO;

import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
public class UserController {

	private final UserService userService;
	
	@Autowired
	public UserController(UserService userService) {
		this.userService = userService;
	}
	
	
	
		
	@GetMapping("/login")
	public String login(Model model, HttpSession session) {

		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

		boolean isAuthenticated = authentication != null &&
                 authentication.isAuthenticated() &&
                 !(authentication.getPrincipal() instanceof String);
		
		// 시큐리티 인증와 세션값으로 인증되있으면 메인페이지로, 안되어있으면 로그인페이지로
		if (isAuthenticated || session.getAttribute("loginUser") != null) {
			return "redirect:/main";
		}

		return "login/loginView"; 
	}
	
	
	/** 
	 * 설명 : 일반 회원가입 페이지로 이동
	 */
	@GetMapping("/regist/nomalregist")
	public String nomalregist(HttpServletRequest request, Model model) {
		String userIp = request.getRemoteAddr();
		model.addAttribute("userIp",userIp);
		return "regist/nomalRegistView";
	}
	
	/**
	 * 설명 : 루트 경로 → /user/main 리다이렉트
	 */
	@GetMapping("/")
	public String root() {
		return "redirect:/main";
	}

	/**
	 * 설명 : 메인화면으로 이동
	 */
	@GetMapping("/main")
	public String mainView(@AuthenticationPrincipal CustomUserDetails userDetails, HttpSession session) {
		if(userDetails != null) {
			session.setAttribute("loginUser",userDetails.getUser());
		}
		return "user/mainView";
	}
	
	

	@GetMapping("/popup/popup1")
	public String popup1() {
		return "popup/popup1"; // /WEB-INF/views/popup/popup1.jsp 렌더링
	}

	@GetMapping("/popup/popup2")
	public String popup2() {
		return "popup/popup2"; // /WEB-INF/views/popup/popup2.jsp 렌더링
	}

	@GetMapping("/popup/popup3")
	public String popup3() {
		return "popup/popup3"; // /WEB-INF/views/popup/popup3.jsp 렌더링
	}

	@GetMapping("/popup/popup4")
	public String popup4() {
		return "popup/popup4"; // /WEB-INF/views/popup/popup4.jsp 렌더링
	}

	@PostMapping("/emailDupCheck")
	@ResponseBody
	public String emailDupCheck(HttpServletRequest request, HttpServletResponse response) throws Exception {

		String memberEmail = request.getParameter("memberEmail");

		int result = userService.emailDupCheck(memberEmail); // 받아온 값 0 / 1

		return String.valueOf(result); // "0" 또는 "1"
		// response.getWriter().print(result);
		// 응답용 스트림을 이용해 result 출력

	}

	@PostMapping("/regist/insert")
	public String registUser(HttpServletRequest request, HttpServletResponse response, UserVO userVO) {
		
		userService.registKakaoUser(userVO);
		
		UserVO savedUser = userService.findByKakaoId(userVO.getOauthId());

		CustomUserDetails userDetails = new CustomUserDetails(savedUser);
		
		UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(userDetails, null,
				userDetails.getAuthorities());
		
		// Spring Security가 현재 인증된 사용자라고 인식하도록 설정
		// 이 설정이 없으면, 리다이렉트 후에도 여전히 "비로그인 상태"로 인식
		SecurityContextHolder.getContext().setAuthentication(authentication); 
		
		
		HttpSession session = request.getSession();
		session.setAttribute("userNo", savedUser.getOauthId());
		session.setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY,
                  SecurityContextHolder.getContext());
		// 카카오 임시 세션 정리
		session.removeAttribute("kakaoOauthId");
		session.removeAttribute("kakaoNickname");
		session.removeAttribute("kakaoEmail");

		return "redirect:/main";
	}
	
	@GetMapping("/regist/duplicateId")
	@ResponseBody
	public String duplicateId(HttpServletRequest request, HttpServletResponse response) {
		String loginId = request.getParameter("loginId");
		int duplicateId = userService.duplicateId(loginId);
		
		return Integer.toString(duplicateId);
	}
	
	
}
