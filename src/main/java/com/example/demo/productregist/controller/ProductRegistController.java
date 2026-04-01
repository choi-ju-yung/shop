package com.example.demo.productregist.controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.Locale.Category;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.product.vo.Product;
import com.example.demo.product.vo.ProductFile;
import com.example.demo.productregist.service.ProductRegistService;
import com.example.demo.user.vo.UserVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
public class ProductRegistController {

    private static final Logger log = LoggerFactory.getLogger(ProductRegistController.class);

    private final ProductRegistService productRegistService;

    @Value("${app.upload.dir:C:/upload}")
    private String uploadDir;

    @Autowired
    public ProductRegistController(ProductRegistService productRegistService) {
        this.productRegistService = productRegistService;
    }

    /** 상품 등록 화면 */
    @GetMapping("/member/sell")
    public String productRegistView(Model model) {
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
        return "1";
    }

    /** 메인 페이지 상품 목록 AJAX (JSON) */
    @GetMapping("/product/list")
    @ResponseBody
    public List<Product> mainProducts() {
        return productRegistService.selectMainProducts();
    }

    /** 상품 상세 페이지 */
    @GetMapping("/product/{productId}")
    public String productDetail(@PathVariable String productId, Model model, HttpSession session) {
        Product product = productRegistService.selectProductDetail(productId);
        if (product == null) {
            return "redirect:/main";
        }
        model.addAttribute("product", product);
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser != null) {
            model.addAttribute("isSeller", loginUser.getUserNo() == product.getUserNo());
        } else {
            model.addAttribute("isSeller", false);
        }
        return "product/productDetail";
    }

    /** 상품 검색 결과 페이지 */
    
    @GetMapping("/product/search")
    public String searchProducts(@RequestParam(required = false) String keyword, Model model) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return "redirect:/main";
        }
        List<Product> products = productRegistService.searchProducts(keyword.trim());
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
}
