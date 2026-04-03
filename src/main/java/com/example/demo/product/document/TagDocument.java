package com.example.demo.product.document;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TagDocument {

    private Long id;        // Oracle TAG_ID (ES 도큐먼트 ID로 사용)
    private String tagName;
    private int useCount;
}
