package com.example.demo.admin.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.admin.service.AdminService;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private final AdminService adminService;

    @Autowired
    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    @RequestMapping("/adminMode")
    public String adminMainView() {
        return "admin/adminMainView";
    }

    @PostMapping("/es/sync")
    @ResponseBody
    public ResponseEntity<Map<String, Integer>> syncEs() {
        Map<String, Integer> result = adminService.syncEs();
        return ResponseEntity.ok(result);
    }
}
