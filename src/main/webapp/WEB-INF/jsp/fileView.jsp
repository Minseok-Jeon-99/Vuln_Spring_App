<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>파일 내용 - Path Traversal</title>
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #f4f6f9; }
    .header { background: #003366; color: #fff; padding: 12px 30px; }
    .header a { color: #aad4ff; text-decoration: none; margin-right: 10px; }
    .container { max-width: 960px; margin: 24px auto; padding: 0 20px; }
    .card { background: #fff; border: 1px solid #ddd; border-radius: 6px; padding: 20px; }
    .meta { font-size: 12px; color: #666; margin-bottom: 12px; }
    .content-box {
      background: #1e1e1e; color: #d4d4d4; padding: 16px;
      border-radius: 4px; font-family: monospace; font-size: 12px;
      white-space: pre-wrap; max-height: 600px; overflow-y: auto;
    }
    .input-row { display: flex; gap: 10px; margin-bottom: 16px; }
    .input-row input { flex: 1; padding: 10px; border: 1px solid #bbb; border-radius: 4px; font-family: monospace; }
    .input-row button { padding: 10px 20px; background: #003366; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
  </style>
</head>
<body>
<div class="header">
  <a href="/nas/file/upload.do">← 파일관리</a>
  <strong>파일 내용 뷰어</strong>
  <span style="background:#e0ffe0;color:#060;padding:2px 8px;border-radius:3px;font-size:11px;font-weight:bold;margin-left:10px;">Path Traversal</span>
</div>
<div class="container">
  <div class="card">
    <form method="GET" action="/nas/file/view.do">
      <div class="input-row">
        <input type="text" name="fileName"
          value="<%= request.getAttribute("fileName") != null ? request.getAttribute("fileName") : "" %>"
          placeholder="../../../etc/passwd">
        <button>읽기</button>
      </div>
    </form>

    <% if (request.getAttribute("resolvedPath") != null && !((String)request.getAttribute("resolvedPath")).isEmpty()) { %>
    <div class="meta">
      📂 요청 파일: <strong><%= request.getAttribute("fileName") %></strong><br>
      📍 실제 경로: <code><%= request.getAttribute("resolvedPath") %></code>
    </div>
    <div class="content-box"><%= request.getAttribute("content") %></div>
    <% } %>
  </div>
</div>
</body>
</html>
