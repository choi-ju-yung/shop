package com.example.demo.product.dao;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.demo.product.vo.TagVO;

@Repository
public class TagDao {

    private final SqlSession sqlSession;

    @Autowired
    public TagDao(SqlSession sqlSession) {
        this.sqlSession = sqlSession;
    }

    public List<TagVO> selectAllTags() {
        return sqlSession.selectList("TagMapper.selectAllTags");
    }

    public TagVO selectByTagName(String tagName) {
        return sqlSession.selectOne("TagMapper.selectByTagName", tagName);
    }

    public void insertTag(TagVO tagVO) {
        sqlSession.insert("TagMapper.insertTag", tagVO);
    }

    public void incrementUseCount(Long tagId) {
        sqlSession.update("TagMapper.incrementUseCount", tagId);
    }
}
