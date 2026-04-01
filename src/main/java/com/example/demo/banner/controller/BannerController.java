package com.example.demo.banner.controller;

import java.io.File;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.banner.service.BannerService;
import com.example.demo.banner.vo.Banner;

@Controller
public class BannerController {

    private final BannerService bannerService;

    @Value("${app.upload.dir:C:/upload}")
    private String uploadDir;

    public BannerController(BannerService bannerService) {
        this.bannerService = bannerService;
    }

    /** 메인페이지 AJAX - 활성 배너 목록 JSON 반환 */
    @GetMapping("/banner/list")
    @ResponseBody
    public ResponseEntity<List<Banner>> getActiveBanners() {
        return ResponseEntity.ok(bannerService.getActiveBanners());
    }

    /** 관리자 - 전체 배너 목록 JSON 반환 */
    @GetMapping("/admin/banner/list")
    @ResponseBody
    public ResponseEntity<List<Banner>> getAllBanners() {
        return ResponseEntity.ok(bannerService.getAllBanners());
    }

    /** 관리자 - 배너 이미지 업로드 + 등록 */
    @PostMapping("/admin/banner/insert")
    @ResponseBody
    public ResponseEntity<String> insertBanner(
            @RequestParam("imageFile") MultipartFile imageFile,
            @RequestParam(value = "linkUrl",   required = false) String linkUrl,
            @RequestParam(value = "sortOrder", defaultValue = "1") int sortOrder,
            @RequestParam(value = "startDt",   required = false) String startDt,
            @RequestParam(value = "endDt",     required = false) String endDt) {

        try {
            String contentType = imageFile.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest().body("이미지 파일만 업로드 가능합니다.");
            }

            String bannerDir = uploadDir + "/banner";
            File dir = new File(bannerDir);
            if (!dir.exists()) dir.mkdirs();

            String fileName  = UUID.randomUUID().toString() + "_" + imageFile.getOriginalFilename();
            File   savedFile = new File(bannerDir + "/" + fileName);
            imageFile.transferTo(savedFile);

            Banner banner = Banner.builder()
                    .imageUrl("/upload/banner/" + fileName)
                    .linkUrl(linkUrl)
                    .sortOrder(sortOrder)
                    .isActive("Y")
                    .startDt(startDt)
                    .endDt(endDt)
                    .build();

            bannerService.insertBanner(banner);
            return ResponseEntity.ok("등록 완료");

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("등록 실패: " + e.getMessage());
        }
    }

    /** 관리자 - 배너 활성화/비활성화 */
    @PostMapping("/admin/banner/toggle/{bannerId}")
    @ResponseBody
    public ResponseEntity<String> toggleBanner(
            @PathVariable Long bannerId,
            @RequestParam String isActive) {
        bannerService.toggleActive(bannerId, isActive);
        return ResponseEntity.ok("변경 완료");
    }

    /** 관리자 - 배너 삭제 */
    @DeleteMapping("/admin/banner/delete/{bannerId}")
    @ResponseBody
    public ResponseEntity<String> deleteBanner(@PathVariable Long bannerId) {
        bannerService.deleteBanner(bannerId);
        return ResponseEntity.ok("삭제 완료");
    }
}
