package com.vulnapp.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * ══════════════════════════════════════════════════════
 *  [취약점 1] SQL Injection 테스트 컨트롤러
 *
 *  URL 구조 (실제 사이트 유사):
 *    GET /nas/search/search.do?extendedParam=sitdId=nas&keyword=<PAYLOAD>
 *    GET /nas/doc/docDetail.do?docId=<PAYLOAD>
 *    GET /nas/user/userInfo.do?userId=<PAYLOAD>
 *
 *  취약 포인트:
 *    - 문자열 직접 연결 쿼리 (Prepared Statement 미사용)
 *    - 오류 메시지 그대로 노출
 *    - UNION 기반, Error 기반, Blind 기반 모두 가능
 * ══════════════════════════════════════════════════════
 */
@Controller
public class SearchController {

    @Autowired
    private JdbcTemplate jdbc;

    // ──────────────────────────────────────────────────────────────
    // [SQLi-1] 키워드 검색 — 문자열 직접 연결
    // 취약 쿼리: SELECT * FROM documents WHERE title LIKE '%keyword%'
    // 테스트: keyword=' OR '1'='1
    //         keyword=' UNION SELECT username,password,role,email,id FROM users--
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/search/search.do")
    public String search(
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) String extendedParam,
            Model model) {

        List<Map<String, Object>> results = new ArrayList<>();
        String errorMsg = null;
        String executedQuery = null;

        // ★ 취약 코드: 입력값을 직접 쿼리에 삽입
        String query = "SELECT id, title, content, author, category " +
                       "FROM documents WHERE title LIKE '%" + keyword + "%'";
        executedQuery = query;

        try {
            results = jdbc.queryForList(query);
        } catch (Exception e) {
            // ★ 취약: 오류 메시지 그대로 노출 (DB 구조 파악 가능)
            errorMsg = e.getMessage();
        }

        model.addAttribute("keyword", keyword);
        model.addAttribute("results", results);
        model.addAttribute("errorMsg", errorMsg);
        model.addAttribute("executedQuery", executedQuery);
        model.addAttribute("extendedParam", extendedParam);
        return "search";
    }

    // ──────────────────────────────────────────────────────────────
    // [SQLi-2] 문서 상세 조회 — 숫자형 파라미터 인젝션
    // 취약 쿼리: SELECT * FROM documents WHERE id = docId
    // 테스트: docId=1 OR 1=1
    //         docId=1 UNION SELECT id,username,password,role,email FROM users
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/doc/docDetail.do")
    public String docDetail(
            @RequestParam(defaultValue = "1") String docId,
            Model model) {

        List<Map<String, Object>> results = new ArrayList<>();
        String errorMsg = null;
        String executedQuery = null;

        // ★ 취약 코드: 숫자형 파라미터도 직접 삽입
        String query = "SELECT id, title, content, author, category, created " +
                       "FROM documents WHERE id = " + docId;
        executedQuery = query;

        try {
            results = jdbc.queryForList(query);
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        model.addAttribute("docId", docId);
        model.addAttribute("results", results);
        model.addAttribute("errorMsg", errorMsg);
        model.addAttribute("executedQuery", executedQuery);
        return "docDetail";
    }

    // ──────────────────────────────────────────────────────────────
    // [SQLi-3] 사용자 조회 — Blind SQLi 테스트용
    // 취약 쿼리: SELECT * FROM users WHERE username = 'userId'
    // 테스트: userId=admin' AND '1'='1   (참 → 결과 있음)
    //         userId=admin' AND '1'='2   (거짓 → 결과 없음)
    //         userId=admin' AND SUBSTRING(password,1,1)='a'--
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/user/userInfo.do")
    public String userInfo(
            @RequestParam(defaultValue = "") String userId,
            Model model) {

        boolean exists = false;
        String errorMsg = null;
        String executedQuery = null;

        // ★ 취약 코드
        String query = "SELECT COUNT(*) FROM users WHERE username = '" + userId + "'";
        executedQuery = query;

        try {
            Integer count = jdbc.queryForObject(query, Integer.class);
            exists = (count != null && count > 0);
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        model.addAttribute("userId", userId);
        model.addAttribute("exists", exists);
        model.addAttribute("errorMsg", errorMsg);
        model.addAttribute("executedQuery", executedQuery);
        return "userInfo";
    }
}
