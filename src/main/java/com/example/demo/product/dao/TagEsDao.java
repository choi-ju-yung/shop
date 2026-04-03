package com.example.demo.product.dao;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.demo.product.document.TagDocument;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.SortOrder;
import co.elastic.clients.elasticsearch.core.BulkRequest;
import co.elastic.clients.elasticsearch.core.BulkResponse;
import co.elastic.clients.elasticsearch.core.IndexRequest;
import co.elastic.clients.elasticsearch.core.bulk.BulkOperation;
import co.elastic.clients.elasticsearch.core.search.Hit;
import lombok.extern.slf4j.Slf4j;

@Repository
@Slf4j
public class TagEsDao {

    private final ElasticsearchClient client;

    @Autowired
    public TagEsDao(ElasticsearchClient client) {
        this.client = client;
    }

    /** 키워드로 태그 검색 */
    public List<String> searchByKeyword(String keyword) {
        try {
            return client.search(s -> s
                    .index("tags")
                    .query(q -> q
                            .match(m -> m
                                    .field("tagName")
                                    .query(keyword)
                            )
                    )
                    .sort(sort -> sort
                            .field(f -> f.field("useCount").order(SortOrder.Desc))
                    )
                    .size(10),
                    TagDocument.class
            ).hits().hits().stream()
                    .map(Hit::source)
                    .map(TagDocument::getTagName)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            log.error("태그 ES 검색 실패: {}", e.getMessage());
            return List.of();
        }
    }

    /** ES에 태그 단건 저장 (DB 동기화용) */
    public void index(TagDocument tag) {
        try {
            client.index(IndexRequest.of(i -> i
                    .index("tags")
                    .id(String.valueOf(tag.getId()))
                    .document(tag)
            ));
        } catch (Exception e) {
            log.error("태그 ES 인덱싱 실패: {}", e.getMessage());
        }
    }

    /** useCount 업데이트 */
    public void updateUseCount(Long id, int useCount) {
        try {
            client.update(u -> u
                    .index("tags")
                    .id(String.valueOf(id))
                    .doc(TagDocument.builder()
                            .useCount(useCount)
                            .build()),
                    TagDocument.class
            );
        } catch (Exception e) {
            log.error("태그 ES useCount 업데이트 실패: {}", e.getMessage());
        }
    }

    /** 전체 태그 bulk 인덱싱 (서버 시작 시 DB → ES 동기화) */
    public void bulkIndex(List<TagDocument> tags) {
        try {
            // 태그 목록을 BulkOperation 리스트로 변환
            List<BulkOperation> operations = tags.stream()
                    .map(tag -> BulkOperation.of(op -> op
                            .index(i -> i
                                    .index("tags")
                                    .id(String.valueOf(tag.getId()))
                                    .document(tag)
                            )
                    ))
                    .toList();

            // 한 번의 HTTP 요청으로 전체 전송
            BulkResponse response = client.bulk(BulkRequest.of(b -> b
                    .operations(operations)
            ));

            if (response.errors()) {
                response.items().stream()
                        .filter(item -> item.error() != null)
                        .forEach(item -> log.error("bulk 인덱싱 실패 id={} reason={}",
                                item.id(), item.error().reason()));
            } else {
                log.info("ES 태그 bulk 동기화 완료: {}건 (요청 1회)", tags.size());
            }
        } catch (Exception e) {
            log.error("ES bulk 인덱싱 실패: {}", e.getMessage());
        }
    }

    public long count() {
        try {
            return client.count(c -> c.index("tags")).count();
        } catch (Exception e) {
            return 0;
        }
    }
}
