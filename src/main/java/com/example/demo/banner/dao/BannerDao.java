package com.example.demo.banner.dao;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import com.example.demo.banner.vo.Banner;

@Repository
public class BannerDao {

    private final SqlSession sqlSession;

    public BannerDao(SqlSession sqlSession) {
        this.sqlSession = sqlSession;
    }

    /** 메인페이지용 - 활성화된 배너만 조회 */
    public List<Banner> selectActiveBanners() {
        return sqlSession.selectList("BannerMapper.selectActiveBanners");
    }

    /** 관리자용 - 전체 배너 조회 */
    public List<Banner> selectAllBanners() {
        return sqlSession.selectList("BannerMapper.selectAllBanners");
    }

    /** 배너 등록 */
    public int insertBanner(Banner banner) {
        return sqlSession.insert("BannerMapper.insertBanner", banner);
    }

    /** 활성화/비활성화 토글 */
    public int updateBannerActive(Long bannerId, String isActive) {
        Banner banner = new Banner();
        banner.setBannerId(bannerId);
        banner.setIsActive(isActive);
        return sqlSession.update("BannerMapper.updateBannerActive", banner);
    }

    /** 배너 삭제 */
    public int deleteBanner(Long bannerId) {
        return sqlSession.delete("BannerMapper.deleteBanner", bannerId);
    }
}
