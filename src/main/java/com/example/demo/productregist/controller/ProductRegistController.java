package com.example.demo.productregist.controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.Locale.Category;
import java.util.stream.Collectors;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.chat.service.ChatService;
import com.example.demo.mypage.service.MyPageService;
import com.example.demo.product.service.ProductEsService;
import com.example.demo.product.service.TagService;
import com.example.demo.product.vo.Product;
import com.example.demo.product.vo.ProductFile;
import com.example.demo.productregist.service.ProductRegistService;
import com.example.demo.user.vo.UserVO;
import com.example.demo.util.UserIdEncoder;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
public class ProductRegistController {

    private static final Logger log = LoggerFactory.getLogger(ProductRegistController.class);

    private final ProductRegistService productRegistService;
    private final ProductEsService productEsService;
    private final TagService tagService;
    private final ChatService chatService;
    private final MyPageService myPageService;

    @Value("${app.upload.dir:C:/upload}")
    private String uploadDir;

    @Autowired
    public ProductRegistController(ProductRegistService productRegistService,
                                   ProductEsService productEsService,
                                   TagService tagService,
                                   ChatService chatService,
                                   MyPageService myPageService) {
        this.productRegistService = productRegistService;
        this.productEsService = productEsService;
        this.tagService = tagService;
        this.chatService = chatService;
        this.myPageService = myPageService;
    }

    /** 상품 등록 화면 — 닉네임 없으면 설정 페이지로 */
    @GetMapping("/member/sell")
    public String productRegistView(Model model, HttpSession session) {
        long userNo = ((UserVO) session.getAttribute("loginUser")).getUserNo();
        if (!myPageService.hasNickname(userNo)) {
            return "redirect:/member/mypage/settings?require=nickname";
        }
        List<Category> categorys = productRegistService.selectAll();
        model.addAttribute("categorys", categorys);
        return "product/productregist";
    }

    /** 서브카테고리 AJAX 조회 */
    @GetMapping("/member/sell/subcategory")
    @ResponseBody
    public String findSubCate(HttpServletRequest request) {
        String categoryName = request.getParameter("categoryName");
        List<String> subCategorys = productRegistService.findSubCate(categoryName);
        return subCategorys.stream().collect(Collectors.joining(","));
    }

    /** 상품 등록 처리 */
    @PostMapping("/member/sell")
    @ResponseBody
    public String productRegistEnd(HttpSession session,
            @RequestParam("title") String title,
            @RequestParam("subCate") String subCate,
            @RequestParam("place") String place,
            @RequestParam("state") String state,
            @RequestParam("price") String price,
            @RequestParam("explanation") String explanation,
            @RequestParam("tag") String tag,
            @RequestParam("mainImageIndex") int mainImageIndex,
            @RequestParam("files") List<MultipartFile> files) {

        long userNo = ((UserVO) session.getAttribute("loginUser")).getUserNo();

        String productUploadDir = uploadDir + "/productRegist";
        File dir = new File(productUploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        List<ProductFile> fileList = new ArrayList<>();
        for (int i = 0; i < files.size(); i++) {
            MultipartFile file = files.get(i);
            if (!file.isEmpty()) {
                // 이미지 파일 검증 (보안)
                String contentType = file.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    log.warn("이미지가 아닌 파일 업로드 시도: {}", contentType);
                    continue;
                }
                try {
                    String originalFilename = file.getOriginalFilename();
                    String ext = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
                    String savedName = UUID.randomUUID().toString() + ext;
                    File dest = new File(productUploadDir, savedName);
                    file.transferTo(dest);
                    fileList.add(ProductFile.builder()
                            .originalName(originalFilename)
                            .savedName(savedName)
                            .filePath("/upload/productRegist/" + savedName)
                            .isMain(i == mainImageIndex)
                            .build());
                } catch (IOException e) {
                    log.error("파일 저장 실패", e);
                }
            }
        }

        int realPrice = Integer.parseInt(price.replace(",", ""));
        Product p = Product.builder()
                .userNo(userNo).title(title).state(state).price(realPrice)
                .explanation(explanation).tag(tag).place(place).subCate(subCate)
                .productFiles(fileList).build();
        productRegistService.insertProduct(p);

        // 입력된 태그들을 ES에 저장 (useCount 증가)
        if (tag != null && !tag.isBlank()) {
            for (String t : tag.split(",")) {
                String trimmed = t.trim();
                if (!trimmed.isEmpty()) {
                    tagService.saveTag(trimmed);
                }
            }
        }

        return "1";
    }
    
    /** 상품 삭제 */
    @DeleteMapping("/member/product/delete/{productId}")
    @ResponseBody
    public ResponseEntity<?> deleteProduct(@PathVariable Long productId, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        try {
            productRegistService.deleteProduct(productId, loginUser.getUserNo());
        } catch (SecurityException e) {
            return ResponseEntity.status(403).body(e.getMessage());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(404).body(e.getMessage());
        }
        return ResponseEntity.ok().build();
    }

    /**
     * 거래 상태 변경 (판매자 본인만)
     * PATCH /member/product/{productId}/status
     * param: tradeStatus (SALE / RESERVED / SOLD), buyerNo (SOLD 시 필수)
     */
    @PatchMapping("/member/product/{productId}/status")
    @ResponseBody
    public ResponseEntity<?> updateTradeStatus(
            @PathVariable Long productId,
            @RequestParam String tradeStatus,
            @RequestParam(required = false) Long buyerNo,
            HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        try {
            productRegistService.updateTradeStatus(productId, loginUser.getUserNo(), tradeStatus, buyerNo);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        } catch (SecurityException e) {
            return ResponseEntity.status(403).body(e.getMessage());
        }
        return ResponseEntity.ok().build();
    }

    /**
     * 거래완료 시 구매자 후보 목록 (해당 상품으로 채팅한 유저)
     * GET /member/product/{productId}/buyers
     */
    @GetMapping("/member/product/{productId}/buyers")
    @ResponseBody
    public ResponseEntity<?> getChatBuyers(@PathVariable Long productId, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        List<Map> buyers = chatService.getChatBuyersByProductId(productId, loginUser.getUserNo());
        return ResponseEntity.ok(buyers);
    }

    /** 내 판매 내역 */
    @GetMapping("/member/mypage/sales")
    public String mySales(@RequestParam(defaultValue = "ALL") String status,
                          @RequestParam(defaultValue = "1") int page,
                          HttpSession session, Model model) {
        long userNo = ((UserVO) session.getAttribute("loginUser")).getUserNo();
        PageHelper.startPage(page, 8);
        List<Product> products = productRegistService.getMySellingProducts(userNo, status);
        PageInfo<Product> pageInfo = new PageInfo<>(products);
        model.addAttribute("products", products);
        model.addAttribute("currentStatus", status);
        model.addAttribute("currentPage", pageInfo.getPageNum());
        model.addAttribute("totalPages", pageInfo.getPages());
        return "mypage/sales";
    }

    /** 내 구매 내역 */
    @GetMapping("/member/mypage/purchases")
    public String myPurchases(@RequestParam(defaultValue = "1") int page,
                              HttpSession session, Model model) {
        long userNo = ((UserVO) session.getAttribute("loginUser")).getUserNo();
        PageHelper.startPage(page, 8);
        List<Product> products = productRegistService.getMyPurchasedProducts(userNo);
        PageInfo<Product> pageInfo = new PageInfo<>(products);
        model.addAttribute("products", products);
        model.addAttribute("currentPage", pageInfo.getPageNum());
        model.addAttribute("totalPages", pageInfo.getPages());
        return "mypage/purchases";
    }
    
    
    /** 메인 페이지 상품 목록 AJAX (JSON) */
    @GetMapping("/product/list")
    @ResponseBody
    public List<Product> mainProducts() {
        return productRegistService.selectMainProducts();
    }

    /** 상품 상세 페이지 */
    @GetMapping("/product/{productId}")
    public String productDetail(@PathVariable Long productId, Model model, HttpSession session) {
        Product product = productRegistService.selectProductDetail(productId);
        if (product == null) {
            return "redirect:/main";
        }
        model.addAttribute("product", product);
        model.addAttribute("encodedSellerNo", UserIdEncoder.encode(product.getUserNo()));
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser != null) {
            model.addAttribute("isSeller", loginUser.getUserNo() == product.getUserNo());
        } else {
            model.addAttribute("isSeller", false);
        }
        // 추천 상품 (같은 카테고리, 최대 4개)
        model.addAttribute("relatedProducts",
            productRegistService.selectRelatedProducts(productId, product.getSubCate()));
        return "product/productDetail";
    }

    /** 상품 검색 결과 페이지 (ES 우선, 실패 시 DB로 조회) */
    @GetMapping("/product/search")
    public String searchProducts(@RequestParam(required = false) String keyword, Model model) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return "redirect:/main";
        }
        String kw = keyword.trim();
        List<Product> products = productEsService.search(kw);
        if (products.isEmpty()) {
            products = productRegistService.searchProducts(kw);
        }
        model.addAttribute("products", products);
        model.addAttribute("keyword", keyword);
        return "product/searchResult";
    }

    /** 카테고리별 상품 목록 페이지 */
    @GetMapping("/product/category")
    public String categoryProducts(@RequestParam(required = false) String name, Model model) {
        List<Product> products;
        if (name == null || name.trim().isEmpty()) {
            products = productRegistService.selectMainProducts();
            model.addAttribute("categoryName", "전체");
        } else {
            products = productRegistService.selectProductsByCategory(name.trim());
            model.addAttribute("categoryName", name.trim());
        }
        model.addAttribute("products", products);
        return "product/searchResult";
    }

    /** 헤더 카테고리 메뉴 AJAX (JSON) */
    @GetMapping("/product/categories")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> headerCategories() {
        List<Map<String, Object>> categories = productRegistService.selectAllCategories();
        return ResponseEntity.ok(categories);
    }

    /** 카테고리별 상품 목록 AJAX (JSON) */
    @GetMapping("/product/category/products")
    @ResponseBody
    public ResponseEntity<List<Product>> categoryProductsJson(@RequestParam(required = false) String name) {
        List<Product> products;
        if (name == null || name.trim().isEmpty()) {
            products = productRegistService.selectMainProducts();
        } else {
            products = productRegistService.selectProductsByCategory(name.trim());
        }
        return ResponseEntity.ok(products);
    }
}
