package com.vulnapp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.nio.file.*;
import java.util.Arrays;
import java.util.List;

/**
 * ══════════════════════════════════════════════════════
 *  [취약점 3] 파일 업로드 / Path Traversal 테스트 컨트롤러
 *
 *  URL:
 *    GET  /nas/file/upload.do          — 업로드 폼
 *    POST /nas/file/uploadProc.do      — 파일 업로드 처리
 *    GET  /nas/file/download.do?path=  — 파일 다운로드 (Path Traversal)
 *    GET  /nas/file/view.do?fileName=  — 파일 보기 (Path Traversal)
 *
 *  취약 포인트:
 *    - 파일 확장자 검증 없음 (WebShell 업로드 가능)
 *    - Path Traversal: ../../../etc/passwd
 *    - Content-Type 검증 없음
 * ══════════════════════════════════════════════════════
 */
@Controller
public class FileController {

    // 업로드 디렉토리 (프로젝트 루트 기준)
    private static final String UPLOAD_DIR =
        System.getProperty("user.dir") + "/uploads/";

    // ──────────────────────────────────────────────────────────────
    // 업로드 폼
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/file/upload.do")
    public String uploadForm(Model model) {
        // 업로드된 파일 목록 표시
        File dir = new File(UPLOAD_DIR);
        dir.mkdirs();
        String[] files = dir.list();
        model.addAttribute("files", files != null ? Arrays.asList(files) : List.of());
        model.addAttribute("uploadDir", UPLOAD_DIR);
        return "upload";
    }

    // ──────────────────────────────────────────────────────────────
    // [FileUpload-1] 파일 업로드 — 확장자 검증 없음
    // ★ 취약: .jsp .html .sh .php 등 모든 파일 업로드 허용
    // 테스트: webshell.jsp 업로드 → RCE 가능 시나리오
    // ──────────────────────────────────────────────────────────────
    @PostMapping("/file/uploadProc.do")
    public String uploadProc(
            @RequestParam("file") MultipartFile file,
            Model model) throws IOException {

        if (file.isEmpty()) {
            model.addAttribute("error", "파일을 선택하세요.");
            return "upload";
        }

        // ★ 취약 코드: 원본 파일명 그대로 저장 (경로 조작 포함)
        String originalName = file.getOriginalFilename();
        // ★ 취약: 파일명에서 경로 분리 안 함, 확장자 검증 안 함
        Path savePath = Paths.get(UPLOAD_DIR + originalName);
        file.transferTo(savePath.toFile());

        model.addAttribute("success", "업로드 완료: " + originalName);
        model.addAttribute("savedPath", savePath.toString());
        model.addAttribute("originalName", originalName);
        model.addAttribute("fileSize", file.getSize());
        model.addAttribute("contentType", file.getContentType());
        return "upload";
    }

    // ──────────────────────────────────────────────────────────────
    // [FileUpload-2] Path Traversal — 파일 다운로드
    // ★ 취약: path 파라미터를 그대로 파일 경로로 사용
    // 테스트: path=../../../etc/passwd
    //         path=../../../etc/hosts
    //         path=../src/main/resources/application.properties
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/file/download.do")
    public void download(
            @RequestParam String path,
            HttpServletResponse response) throws IOException {

        // ★ 취약 코드: path 검증 없음
        File file = new File(UPLOAD_DIR + path);

        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"" + file.getName() + "\"");

        try (FileInputStream fis = new FileInputStream(file);
             OutputStream os = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int len;
            while ((len = fis.read(buffer)) != -1) {
                os.write(buffer, 0, len);
            }
        } catch (FileNotFoundException e) {
            response.setContentType("text/plain;charset=UTF-8");
            response.getWriter().write("파일 없음: " + file.getAbsolutePath());
        }
    }

    // ──────────────────────────────────────────────────────────────
    // [FileUpload-3] Path Traversal — 파일 내용 뷰어
    // ★ 취약: fileName으로 서버 파일 직접 읽기
    // 테스트: fileName=../../../etc/passwd
    //         fileName=../../../proc/version  (Linux)
    //         fileName=../../src/main/resources/application.properties
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/file/view.do")
    public String viewFile(
            @RequestParam(required = false, defaultValue = "") String fileName,
            Model model) {

        String content = "";
        String resolvedPath = "";

        if (!fileName.isEmpty()) {
            // ★ 취약 코드: 경로 정규화 없이 직접 읽기
            File file = new File(UPLOAD_DIR + fileName);
            resolvedPath = file.getAbsolutePath();

            try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line).append("\n");
                }
                content = sb.toString();
            } catch (Exception e) {
                content = "[오류] " + e.getMessage() + "\n실제 경로: " + resolvedPath;
            }
        }

        model.addAttribute("fileName", fileName);
        model.addAttribute("content", content);
        model.addAttribute("resolvedPath", resolvedPath);
        model.addAttribute("uploadDir", UPLOAD_DIR);
        return "fileView";
    }
}
