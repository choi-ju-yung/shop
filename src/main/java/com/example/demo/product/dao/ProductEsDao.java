package com.example.demo.product.dao;

import java.io.InputStream;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.demo.product.document.ProductDocument;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.query_dsl.TextQueryType;
import co.elastic.clients.elasticsearch.core.BulkRequest;
import co.elastic.clients.elasticsearch.core.BulkResponse;
import co.elastic.clients.elasticsearch.core.IndexRequest;
import co.elastic.clients.elasticsearch.core.bulk.BulkOperation;
import co.elastic.clients.elasticsearch.core.search.Hit;
import lombok.extern.slf4j.Slf4j;

@Repository
@Slf4j
public class ProductEsDao {

    private static final String INDEX = "products";

    private final ElasticsearchClient client;

    @Autowired
    public ProductEsDao(ElasticsearchClient client) {
        this.client = client;
    }

    /** 인덱스가 없을 때만 생성 (기존 데이터 유지) */
    public void ensureIndex() {
        try {
            boolean exists = client.indices().exists(e -> e.index(INDEX)).value();
            if (exists) return;

            InputStream settings = getClass().getResourceAsStream("/elasticsearch/product-settings.json");
            InputStream mappings = getClass().getResourceAsStream("/elasticsearch/product-mappings.json");

            client.indices().create(c -> c
                    .index(INDEX)
                    .settings(s -> s.withJson(settings))
                    .mappings(m -> m.withJson(mappings))
            );
            log.info("products 인덱스 생성 완료");
        } catch (Exception e) {
            log.error("products 인덱스 생성 실패: {}", e.getMessage(), e);
        }
    }

    /** 상품명 + 태그 기준 검색 (SOLD 제외) */
    public List<ProductDocument> search(String keyword) {
        try {
            var response = client.search(s -> s
                    .index(INDEX)
                    .query(q -> q
                            .multiMatch(mm -> mm
                                    .query(keyword)
                                    .fields("title^2", "tags")
                                    .type(TextQueryType.BestFields)
                            )
                    )
                    .size(50),
                    ProductDocument.class
            );
            long totalHits = response.hits().total() != null ? response.hits().total().value() : 0;
            log.info("ES 상품 검색 keyword={} 총{}건 반환", keyword, totalHits);
            return response.hits().hits().stream()
                    .map(Hit::source)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            log.error("상품 ES 검색 실패 keyword={}: {}", keyword, e.getMessage(), e);
            return List.of();
        }
    }

    /** 상품 단건 인덱싱 */
    public void index(ProductDocument doc) {
        try {
            client.index(IndexRequest.of(i -> i
                    .index(INDEX)
                    .id(String.valueOf(doc.getProductId()))
                    .document(doc)
            ));
        } catch (Exception e) {
            log.error("상품 ES 인덱싱 실패 productId={}: {}", doc.getProductId(), e.getMessage());
        }
    }

    /** 전체 상품 bulk 인덱싱 (관리자 수동 재동기화용) */
    public int bulkIndex(List<ProductDocument> docs) {
        if (docs.isEmpty()) return 0;
        try {
            List<BulkOperation> ops = docs.stream()
                    .map(doc -> BulkOperation.of(op -> op
                            .index(i -> i
                                    .index(INDEX)
                                    .id(String.valueOf(doc.getProductId()))
                                    .document(doc)
                            )
                    ))
                    .toList();
            BulkResponse response = client.bulk(BulkRequest.of(b -> b.operations(ops)));
            if (response.errors()) {
                response.items().stream()
                        .filter(item -> item.error() != null)
                        .forEach(item -> log.error("bulk 실패 id={} reason={}", item.id(), item.error().reason()));
            }
            return docs.size();
        } catch (Exception e) {
            log.error("상품 ES bulk 인덱싱 실패: {}", e.getMessage());
            return 0;
        }
    }

    /** 상품 tradeStatus 업데이트 (RESERVED / SOLD 등) */
    public void updateTradeStatus(Long productId, String tradeStatus) {
        try {
            client.update(u -> u
                    .index(INDEX)
                    .id(String.valueOf(productId))
                    .doc(java.util.Map.of("tradeStatus", tradeStatus)),
                    ProductDocument.class
            );
        } catch (Exception e) {
            log.error("상품 ES tradeStatus 업데이트 실패 productId={}: {}", productId, e.getMessage());
        }
    }

    /** 상품 ES에서 제거 (삭제 시) */
    public void delete(Long productId) {
        try {
            client.delete(d -> d.index(INDEX).id(String.valueOf(productId)));
        } catch (Exception e) {
            log.error("상품 ES 삭제 실패 productId={}: {}", productId, e.getMessage());
        }
    }
}
