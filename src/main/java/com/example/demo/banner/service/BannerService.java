package com.example.demo.banner.service;

import java.util.List;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.banner.dao.BannerDao;
import com.example.demo.banner.vo.Banner;

@Service
public class BannerService {

    private final BannerDao bannerDao;

    public BannerService(BannerDao bannerDao) {
        this.bannerDao = bannerDao;
    }

    @Cacheable(value = "banners")
    public List<Banner> getActiveBanners() {
        return bannerDao.selectActiveBanners();
    }

    public List<Banner> getAllBanners() {
        return bannerDao.selectAllBanners();
    }

    @Transactional
    @CacheEvict(value = "banners", allEntries = true)
    public void insertBanner(Banner banner) {
        bannerDao.insertBanner(banner);
    }

    @Transactional
    @CacheEvict(value = "banners", allEntries = true)
    public void toggleActive(Long bannerId, String isActive) {
        bannerDao.updateBannerActive(bannerId, isActive);
    }

    @Transactional
    @CacheEvict(value = "banners", allEntries = true)
    public void deleteBanner(Long bannerId) {
        bannerDao.deleteBanner(bannerId);
    }
}
