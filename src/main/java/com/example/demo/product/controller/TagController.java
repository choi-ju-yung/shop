package com.example.demo.product.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TagController {

    private final com.example.demo.product.service.TagService tagService;

    @Autowired
    public TagController(com.example.demo.product.service.TagService tagService) {
        this.tagService = tagService;
    }

    @GetMapping("/product/tags")
    public List<String> searchTags(@RequestParam String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return List.of();
        }
        return tagService.searchTags(keyword.trim());
    }
}
