package com.example.demo.product.dao;

import java.io.InputStream;
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

    /** tags 인덱스 재생성 (서버 시작 시 항상 최신 settings/mappings 적용) */
    public void setupIndex() {
        try {
            boolean exists = client.indices().exists(e -> e.index("tags")).value();
            if (exists) {
                client.indices().delete(d -> d.index("tags"));
            }

            InputStream productTagSettings = getClass().getResourceAsStream("/elasticsearch/tag-settings.json");
            InputStream productTagMappings = getClass().getResourceAsStream("/elasticsearch/tag-mappings.json");

            client.indices().create(c -> c
                    .index("tags")
                    .settings(s -> s.withJson(productTagSettings))
                    .mappings(m -> m.withJson(productTagMappings))
            );
            log.info("tags 인덱스 재생성 완료");
        } catch (Exception e) {
            log.error("tags 인덱스 생성 실패: {}", e.getMessage());
        }
    }

    /** 키워드로 태그 검색 */
    public List<String> searchByKeyword(String keyword) {
        try {
            List<String> result = client.search(s -> s
                    .index("tags")
                    .query(q -> q  // 쿼리 종류 설정 (match? term? range?)
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
            log.info("태그 검색 keyword={} 결과={}건", keyword, result.size());
            return result;
        } catch (Exception e) {
            log.error("태그 ES 검색 실패 keyword={}", keyword, e);
            return List.of();
        }
    }

    /** ES에 태그 단건 저장 (DB 동기화용) */
    public void index(TagDocument tag) {
        try {
            client.index(IndexRequest.of(i -> i   // 없으면 생성 있으면 덮어쓰기
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
            List<BulkOperation> operations = tags.stream()
                    .map(tag -> BulkOperation.of(op -> op
                            .index(i -> i
                                    .index("tags")
                                    .id(String.valueOf(tag.getId()))
                                    .document(tag)
                            )
                    ))
                    .toList();

            BulkResponse response = client.bulk(BulkRequest.of(b -> b
                    .operations(operations)
            ));

            if (response.errors()) {
                response.items().stream()
                        .filter(item -> item.error() != null)
                        .forEach(item -> log.error("bulk 인덱싱 실패 id={} reason={}",
                                item.id(), item.error().reason()));
            } else {
                log.info("ES 태그 bulk 동기화 완료: {}건", tags.size());
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
