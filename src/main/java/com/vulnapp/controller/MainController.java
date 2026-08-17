package com.vulnapp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;

/**
 * 메인 페이지 컨트롤러
 * URL: /nas/main/main.do  (실제 사이트와 동일한 .do 구조)
 */
@Controller
public class MainController {

    // ── 메인 페이지 ─────────────────────────────────────────────────
    // 실제 사이트 구조: GET /nas/main/main.do?extendedParam=sitdId=nas
    @GetMapping({"/", "/main/main.do"})
    public String main(
            @RequestParam(required = false) String extendedParam,
            HttpSession session,
            Model model) {
        model.addAttribute("extendedParam", extendedParam);
        model.addAttribute("user", session.getAttribute("loginUser"));
        return "main";
    }

    // ── 로그인 페이지 ───────────────────────────────────────────────
    @GetMapping("/login/login.do")
    public String loginForm() {
        return "login";
    }

    // ── 로그인 처리 (취약: 세션 고정 공격 가능) ─────────────────────
    @GetMapping("/login/loginProc.do")
    public String loginProc(
            @RequestParam String username,
            @RequestParam String password,
            HttpSession session) {
        // 취약: 비밀번호 평문 비교, 세션 재생성 없음
        if ("admin".equals(username) && "admin1234".equals(password)) {
            session.setAttribute("loginUser", username);
            session.setAttribute("role", "ADMIN");
            return "redirect:/main/main.do";
        }
        return "redirect:/login/login.do?error=1";
    }

    @GetMapping("/login/logout.do")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/main/main.do";
    }
}
