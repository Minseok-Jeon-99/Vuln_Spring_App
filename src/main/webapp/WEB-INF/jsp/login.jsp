<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>로그인 - 국가기록원</title>
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #003366; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
    .login-box { background: #fff; border-radius: 8px; padding: 40px; width: 360px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); }
    h2 { color: #003366; text-align: center; margin-bottom: 24px; }
    input { width: 100%; padding: 12px; border: 1px solid #bbb; border-radius: 4px; margin-bottom: 14px; box-sizing: border-box; font-family: inherit; font-size: 14px; }
    button { width: 100%; padding: 12px; background: #003366; color: #fff; border: none; border-radius: 4px; font-size: 15px; cursor: pointer; }
    .error { color: #c00; font-size: 13px; text-align: center; margin-bottom: 12px; }
    .hint { font-size: 12px; color: #888; text-align: center; margin-top: 16px; }
  </style>
</head>
<body>
<div class="login-box">
  <h2>🗄️ 국가기록원<br>문서관리시스템</h2>
  <% if ("1".equals(request.getParameter("error"))) { %>
  <div class="error">아이디 또는 비밀번호가 틀렸습니다.</div>
  <% } %>
  <form method="GET" action="/nas/login/loginProc.do">
    <input type="text" name="username" placeholder="아이디" value="admin">
    <input type="password" name="password" placeholder="비밀번호" value="admin1234">
    <button type="submit">로그인</button>
  </form>
  <div class="hint">테스트 계정: admin / admin1234</div>
</div>
</body>
</html>
