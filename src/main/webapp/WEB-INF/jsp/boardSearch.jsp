<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>게시판 검색 - Reflected XSS</title>
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #f4f6f9; }
    .header { background: #003366; color: #fff; padding: 12px 30px; }
    .header a { color: #aad4ff; text-decoration: none; }
    .container { max-width: 900px; margin: 24px auto; padding: 0 20px; }
    .card { background: #fff; border: 1px solid #ddd; border-radius: 6px; padding: 20px; }
    .search-row { display: flex; gap: 10px; margin-bottom: 16px; }
    .search-row input { flex: 1; padding: 10px; border: 1px solid #bbb; border-radius: 4px; }
    .search-row button { padding: 10px 20px; background: #003366; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
    .result-info { font-size: 13px; color: #555; margin-bottom: 12px; }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th { background: #003366; color: #fff; padding: 10px; text-align: left; }
    td { padding: 10px; border-bottom: 1px solid #eee; }
  </style>
</head>
<body>
<div class="header">
  <a href="/nas/main/main.do">← 홈</a>
  <strong>게시판 검색</strong>
  <span style="background:#ffe0ff;color:#800;padding:2px 8px;border-radius:3px;font-size:11px;font-weight:bold;margin-left:10px;">XSS-4: Reflected XSS</span>
</div>
<div class="container">
  <div class="card">
    <form method="GET" action="/nas/board/boardSearch.do">
      <div class="search-row">
        <input type="text" name="q" value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>" placeholder="검색어 입력">
        <button>검색</button>
      </div>
    </form>

    <% if (request.getAttribute("q") != null && !((String)request.getAttribute("q")).isEmpty()) { %>
    <div class="result-info">
      <%-- ★ 취약: 검색어를 이스케이프 없이 출력 --%>
      "<%= request.getAttribute("q") %>" 검색 결과: ${posts.size()}건
    </div>
    <% } %>

    <table>
      <thead><tr><th>No</th><th>작성자</th><th>제목</th><th>내용</th></tr></thead>
      <tbody>
        <c:forEach var="post" items="${posts}">
          <tr>
            <td>${post.ID}</td>
            <td>${post.AUTHOR}</td>
            <td>${post.TITLE}</td>
            <td>${post.CONTENT}</td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</div>
</body>
</html>
