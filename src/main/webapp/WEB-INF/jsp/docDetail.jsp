<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>문서 상세 - SQLi 숫자형</title>
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #f4f6f9; }
    .header { background: #003366; color: #fff; padding: 12px 30px; }
    .header a { color: #aad4ff; text-decoration: none; margin-right: 10px; font-size: 13px; }
    .container { max-width: 960px; margin: 24px auto; padding: 0 20px; }
    .card { background: #fff; border: 1px solid #ddd; border-radius: 6px; padding: 20px; margin-bottom: 16px; }
    h2 { color: #003366; margin-top: 0; }
    .id-box { display: flex; gap: 10px; margin-bottom: 16px; }
    .id-box input { width: 200px; padding: 10px; border: 1px solid #bbb; border-radius: 4px; }
    .id-box button { padding: 10px 20px; background: #003366; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
    .query-box { background: #1e1e1e; color: #4ec9b0; padding: 12px; border-radius: 4px; font-family: monospace; font-size: 12px; margin-bottom: 12px; }
    .error-box { background: #fff0f0; border: 1px solid #ffaaaa; color: #cc0000; padding: 12px; border-radius: 4px; font-family: monospace; font-size: 12px; }
    .doc-card { background: #f8fbff; border: 1px solid #c0d8ff; border-radius: 4px; padding: 16px; margin-top: 12px; }
    .hint { background: #fff8e1; border-left: 3px solid #ffc107; padding: 10px 14px; font-size: 12px; margin-bottom: 12px; }
    .tag { display: inline-block; padding: 2px 8px; border-radius: 3px; font-size: 11px; font-weight: bold; }
    .tag-sqli { background: #ffe0e0; color: #c00; }
  </style>
</head>
<body>
<div class="header">
  <a href="/nas/main/main.do">← 홈</a>
  <strong style="font-size:16px;">문서 상세 조회</strong>
  <span class="tag tag-sqli" style="margin-left:10px;">SQLi-2: 숫자형 파라미터 인젝션</span>
</div>

<div class="container">
  <div class="card">
    <h2>기록물 상세 정보</h2>
    <form method="GET" action="/nas/doc/docDetail.do">
      <div class="id-box">
        <input type="text" name="docId" value="${docId}" placeholder="문서 ID (취약 파라미터)">
        <button type="submit">조회</button>
      </div>
    </form>

    <div class="hint">
      💡 <strong>SQLi 테스트 페이로드 (숫자형 — 따옴표 불필요):</strong><br>
      <code>1 OR 1=1</code> — 전체 레코드 조회<br>
      <code>1 UNION SELECT id,username,password,role,email FROM users</code> — 계정 정보 탈취<br>
      <code>0 UNION SELECT id,username,password,role,email FROM users WHERE role='ADMIN'</code> — 관리자만
    </div>

    <% if (request.getAttribute("executedQuery") != null) { %>
    <div class="query-box">🔍 실행 쿼리: <%= request.getAttribute("executedQuery") %></div>
    <% } %>

    <% if (request.getAttribute("errorMsg") != null) { %>
    <div class="error-box">⚠️ DB 오류: <%= request.getAttribute("errorMsg") %></div>
    <% } %>

    <c:forEach var="row" items="${results}">
      <div class="doc-card">
        <table style="width:100%;font-size:13px;border-collapse:collapse;">
          <tr><th style="text-align:left;padding:6px;width:100px;color:#555;">ID</th><td style="padding:6px;">${row.ID}</td></tr>
          <tr><th style="text-align:left;padding:6px;color:#555;">제목</th><td style="padding:6px;">${row.TITLE}</td></tr>
          <tr><th style="text-align:left;padding:6px;color:#555;">내용</th><td style="padding:6px;">${row.CONTENT}</td></tr>
          <tr><th style="text-align:left;padding:6px;color:#555;">작성자</th><td style="padding:6px;">${row.AUTHOR}</td></tr>
          <tr><th style="text-align:left;padding:6px;color:#555;">분류</th><td style="padding:6px;">${row.CATEGORY}</td></tr>
        </table>
      </div>
    </c:forEach>
  </div>
</div>
</body>
</html>
