package com.example.demo.wish.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.user.vo.UserVO;
import com.example.demo.wish.service.WishService;
import com.example.demo.wish.vo.WishVO;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class WishController {

    private final WishService wishService;

    /** 찜한 상품 목록 페이지 */
    @GetMapping("/member/wishlist")
    public String wishListPage(@RequestParam(defaultValue = "1") int page,
                               HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        PageHelper.startPage(page, 12);
        List<WishVO> wishList = wishService.getWishList(loginUser.getUserNo());
        PageInfo<WishVO> pageInfo = new PageInfo<>(wishList);
        model.addAttribute("wishList", wishList);
        model.addAttribute("currentPage", pageInfo.getPageNum());
        model.addAttribute("totalPages", pageInfo.getPages());
        return "mypage/wishList";
    }

    /** 찜 토글 AJAX */
    @PostMapping("/member/wish/toggle")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleWish(
            @RequestParam Long productId,
            HttpSession session) {

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        boolean wished = wishService.toggleWish(
                loginUser.getUserNo(), productId, loginUser.getUsername());

        Map<String, Object> result = new HashMap<>();
        result.put("wished", wished);
        return ResponseEntity.ok(result);
    }

    /** 찜한 상품 수 */
    @GetMapping("/member/wish/count")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> wishCount(HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        int count = wishService.getWishList(loginUser.getUserNo()).size();
        Map<String, Object> result = new HashMap<>();
        result.put("count", count);
        return ResponseEntity.ok(result);
    }

    /** 찜 여부 확인 AJAX */
    @GetMapping("/member/wish/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> wishStatus(
            @RequestParam Long productId,
            HttpSession session) {

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        boolean wished = loginUser != null &&
                wishService.isWished(loginUser.getUserNo(), productId);

        Map<String, Object> result = new HashMap<>();
        result.put("wished", wished);
        return ResponseEntity.ok(result);
    }
}
