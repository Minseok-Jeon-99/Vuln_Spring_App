<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>공지사항 - Reflected XSS</title>
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #f4f6f9; }
    .header { background: #003366; color: #fff; padding: 12px 30px; }
    .header a { color: #aad4ff; text-decoration: none; margin-right: 10px; }
    .container { max-width: 800px; margin: 24px auto; padding: 0 20px; }
    .card { background: #fff; border: 1px solid #ddd; border-radius: 6px; padding: 24px; margin-bottom: 16px; }
    h2 { color: #003366; margin-top: 0; }
    .msg-box { background: #f0f4ff; border: 1px solid #c8d8ff; border-radius: 4px; padding: 16px; font-size: 15px; margin: 16px 0; }
    .hint { background: #fff8e1; border-left: 3px solid #ffc107; padding: 10px 14px; font-size: 12px; margin-bottom: 12px; }
    code { background: #f0f0f0; padding: 1px 4px; border-radius: 3px; font-size: 11px; }
    .input-row { display: flex; gap: 10px; }
    .input-row input { flex: 1; padding: 10px; border: 1px solid #bbb; border-radius: 4px; }
    .input-row button { padding: 10px 20px; background: #003366; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
  </style>
</head>
<body>
<div class="header">
  <a href="/nas/main/main.do">← 홈</a>
  <strong>공지사항</strong>
  <span style="background:#ffe0ff;color:#800;padding:2px 8px;border-radius:3px;font-size:11px;font-weight:bold;margin-left:10px;">XSS-3: Reflected XSS</span>
</div>

<div class="container">
  <div class="card">
    <h2>📢 시스템 공지사항</h2>

    <div class="hint">
      💡 <strong>Reflected XSS 테스트 (URL의 msg 파라미터):</strong><br>
      기본: <code>?msg=&lt;script&gt;alert(document.cookie)&lt;/script&gt;</code><br>
      IMG: <code>?msg=&lt;img src=x onerror=alert(1)&gt;</code><br>
      SVG: <code>?msg=&lt;svg/onload=alert(1)&gt;</code><br>
      피싱: <code>?msg=&lt;b style="color:red"&gt;비밀번호를 재설정하세요&lt;/b&gt;&lt;a href="http://attacker.com"&gt;클릭&lt;/a&gt;</code>
    </div>

    <form method="GET" action="/nas/board/notice.do">
      <div class="input-row">
        <input type="text" name="msg" value="<%= request.getParameter("msg") != null ? request.getParameter("msg") : "" %>" placeholder="공지 메시지 (취약 파라미터)">
        <button type="submit">적용</button>
      </div>
    </form>

    <% if (request.getAttribute("msg") != null && !((String)request.getAttribute("msg")).isEmpty()) { %>
    <div class="msg-box">
      📌 공지: <%-- ★ 취약: 이스케이프 없이 그대로 출력 --%>
      <%= request.getAttribute("msg") %>
    </div>
    <% } %>
  </div>
</div>
</body>
</html>
