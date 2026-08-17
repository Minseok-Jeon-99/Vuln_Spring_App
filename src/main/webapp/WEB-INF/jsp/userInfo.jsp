<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>사용자 조회 - Blind SQLi</title>
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #f4f6f9; }
    .header { background: #003366; color: #fff; padding: 12px 30px; }
    .header a { color: #aad4ff; text-decoration: none; margin-right: 10px; font-size: 13px; }
    .container { max-width: 800px; margin: 24px auto; padding: 0 20px; }
    .card { background: #fff; border: 1px solid #ddd; border-radius: 6px; padding: 20px; margin-bottom: 16px; }
    h2 { color: #003366; margin-top: 0; }
    .input-row { display: flex; gap: 10px; margin-bottom: 16px; }
    .input-row input { flex: 1; padding: 10px; border: 1px solid #bbb; border-radius: 4px; }
    .input-row button { padding: 10px 20px; background: #003366; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
    .query-box { background: #1e1e1e; color: #4ec9b0; padding: 12px; border-radius: 4px; font-family: monospace; font-size: 12px; margin-bottom: 12px; }
    .error-box { background: #fff0f0; border: 1px solid #f00; color: #c00; padding: 12px; border-radius: 4px; font-family: monospace; font-size: 12px; }
    .result-true  { background: #d4edda; border: 1px solid #28a745; color: #155724; padding: 16px; border-radius: 4px; font-size: 15px; font-weight: bold; }
    .result-false { background: #f8d7da; border: 1px solid #dc3545; color: #721c24; padding: 16px; border-radius: 4px; font-size: 15px; font-weight: bold; }
    .hint { background: #fff8e1; border-left: 3px solid #ffc107; padding: 10px 14px; font-size: 12px; margin-bottom: 12px; }
    code { background: #f0f0f0; padding: 1px 5px; border-radius: 3px; font-size: 11px; }
  </style>
</head>
<body>
<div class="header">
  <a href="/nas/main/main.do">← 홈</a>
  <strong>사용자 조회</strong>
  <span style="background:#ffe0e0;color:#c00;padding:2px 8px;border-radius:3px;font-size:11px;font-weight:bold;margin-left:10px;">SQLi-3: Blind SQLi</span>
</div>

<div class="container">
  <div class="card">
    <h2>시스템 사용자 확인</h2>
    <form method="GET" action="/nas/user/userInfo.do">
      <div class="input-row">
        <input type="text" name="userId" value="<%= request.getParameter("userId") != null ? request.getParameter("userId") : "" %>" placeholder="사용자 ID (취약 파라미터)">
        <button type="submit">조회</button>
      </div>
    </form>

    <div class="hint">
      💡 <strong>Blind SQLi 테스트 (True/False 응답 차이 관찰):</strong><br>
      TRUE: <code>admin' AND '1'='1</code> → 사용자 존재 메시지<br>
      FALSE: <code>admin' AND '1'='2</code> → 사용자 없음 메시지<br>
      비밀번호 첫 글자: <code>admin' AND SUBSTRING(password,1,1)='a</code><br>
      비밀번호 두 번째: <code>admin' AND SUBSTRING(password,2,1)='d</code>
    </div>

    <% if (request.getAttribute("executedQuery") != null) { %>
    <div class="query-box">🔍 실행 쿼리: <%= request.getAttribute("executedQuery") %></div>
    <% } %>

    <% if (request.getAttribute("errorMsg") != null) { %>
    <div class="error-box">⚠️ <%= request.getAttribute("errorMsg") %></div>
    <% } %>

    <% if (request.getAttribute("exists") != null) {
         boolean exists = (Boolean) request.getAttribute("exists"); %>
      <div class="<%= exists ? "result-true" : "result-false" %>">
        <% if (exists) { %>✅ 사용자가 존재합니다 (EXISTS)
        <% } else { %>❌ 사용자가 존재하지 않습니다 (MISSING)<% } %>
      </div>
    <% } %>
  </div>
</div>
</body>
</html>
