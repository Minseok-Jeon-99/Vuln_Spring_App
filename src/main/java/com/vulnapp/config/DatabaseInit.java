package com.vulnapp.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import javax.annotation.PostConstruct;

@Component
public class DatabaseInit {

    @Autowired
    private JdbcTemplate jdbc;

    @PostConstruct
    public void init() {
        // ── 사용자 테이블 ──────────────────────────────────────
        jdbc.execute("CREATE TABLE IF NOT EXISTS users (" +
            "id       INT AUTO_INCREMENT PRIMARY KEY," +
            "username VARCHAR(50)  NOT NULL," +
            "password VARCHAR(100) NOT NULL," +
            "role     VARCHAR(20)  DEFAULT 'USER'," +
            "email    VARCHAR(100)" +
        ")");

        jdbc.execute("MERGE INTO users (id,username,password,role,email) KEY(id) VALUES " +
            "(1,'admin','admin1234','ADMIN','admin@nas.go.kr')," +
            "(2,'hong','hong1234','USER','hong@nas.go.kr')," +
            "(3,'kim','kim5678','USER','kim@nas.go.kr')," +
            "(4,'lee','lee9999','USER','lee@nas.go.kr')");

        // ── 문서(기록물) 테이블 ────────────────────────────────
        jdbc.execute("CREATE TABLE IF NOT EXISTS documents (" +
            "id       INT AUTO_INCREMENT PRIMARY KEY," +
            "title    VARCHAR(200) NOT NULL," +
            "content  TEXT," +
            "author   VARCHAR(50)," +
            "category VARCHAR(50)," +
            "created  TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
        ")");

        jdbc.execute("MERGE INTO documents (id,title,content,author,category) KEY(id) VALUES " +
            "(1,'2024년 국가기록원 연간보고서','연간 업무 보고 내용...','admin','보고서')," +
            "(2,'행정절차 처리 매뉴얼','행정절차 세부 지침...','hong','매뉴얼')," +
            "(3,'기밀문서 관리지침','[기밀] 내부 관리 절차...','admin','기밀')," +
            "(4,'공개자료 목록','일반 공개 자료 목록...','kim','공개')");

        // ── 게시판(XSS Stored) ─────────────────────────────────
        jdbc.execute("CREATE TABLE IF NOT EXISTS board (" +
            "id       INT AUTO_INCREMENT PRIMARY KEY," +
            "author   VARCHAR(50)," +
            "title    VARCHAR(200)," +
            "content  TEXT," +
            "created  TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
        ")");

        jdbc.execute("MERGE INTO board (id,author,title,content) KEY(id) VALUES " +
            "(1,'admin','공지사항','시스템 점검 안내입니다.')," +
            "(2,'hong','질문','자료 검색 방법이 궁금합니다.')");

        System.out.println("[DB] 초기 데이터 로드 완료");
    }
}
