package com.example.demo.product.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.product.dao.TagDao;
import com.example.demo.product.dao.TagEsDao;
import com.example.demo.product.document.TagDocument;
import com.example.demo.product.vo.TagVO;

@Service
public class TagService {

    private final TagDao tagDao;
    private final TagEsDao tagEsDao;

    @Autowired
    public TagService(TagDao tagDao, TagEsDao tagEsDao) {
        this.tagDao = tagDao;
        this.tagEsDao = tagEsDao;
    }

    /** 태그 검색 - ES에서 조회 */
    public List<String> searchTags(String keyword) {
        return tagEsDao.searchByKeyword(keyword);
    }

    /**
     * 태그 저장 - DB 저장 후 ES 동기화
     * 이미 존재하면 useCount +1, 없으면 신규 등록
     */
    public void saveTag(String tagName) {
        TagVO existing = tagDao.selectByTagName(tagName);

        if (existing != null) {
            tagDao.incrementUseCount(existing.getTagId());
            tagEsDao.updateUseCount(existing.getTagId(), existing.getUseCount() + 1);
        } else {
            TagVO newTag = TagVO.builder().tagName(tagName).build();
            tagDao.insertTag(newTag);
            TagVO saved = tagDao.selectByTagName(tagName);
            tagEsDao.index(TagDocument.builder()
                    .id(saved.getTagId())
                    .tagName(saved.getTagName())
                    .useCount(1)
                    .build());
        }
    }
}
