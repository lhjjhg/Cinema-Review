<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 로그인</title>
    <link rel="stylesheet" href="../css/Style.css">
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    
    <script>
        // 페이지 로드 시 쿠키에서 아이디 읽어오기
        window.onload = function() {
            var cookies = document.cookie.split(';');
            for(var i = 0; i < cookies.length; i++) {
                var cookie = cookies[i].trim();
                if (cookie.indexOf('savedUsername=') === 0) {
                    var username = cookie.substring('savedUsername='.length, cookie.length);
                    if(username !== '') {
                        document.getElementById('username').value = decodeURIComponent(username);
                        document.getElementById('remember').checked = true;
                    }
                    break;
                }
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <div class="login-container">
            <div class="login-image">
                <img src="../image/movie.jpg" alt="영화 포스터">
                <div class="poster-overlay"></div>
            </div>
            <div class="login-form">
                <div class="logo">
                    <i class="fas fa-film"></i>
                    <h1>CinemaWorld</h1>
                </div>
                <h2>로그인</h2>
                <p class="welcome-text">영화의 세계로 오신 것을 환영합니다</p>
                
                <% if (request.getParameter("registered") != null && request.getParameter("registered").equals("true")) { %>
                    <div class="success-message">
                        회원가입이 완료되었습니다. 로그인해주세요.
                    </div>
                <% } %>
                
                <% 
				String errorParam = request.getParameter("error");
				String errorMessage = null;

				if ("login_failed".equals(errorParam)) {
    				errorMessage = "아이디 또는 비밀번호가 일치하지 않습니다.";
				} else if ("db_error".equals(errorParam)) {
    				errorMessage = "데이터베이스 연결 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
				}

				if (request.getAttribute("errorMessage") != null) {
    				errorMessage = (String) request.getAttribute("errorMessage");
				}
				%>

				<% if (errorMessage != null) { %>
    			<div class="error-message">
        		<%= errorMessage %>
    			</div>
				<% } %>
                
                <form action="../LoginServlet" method="post">
                    <div class="input-group">
                        <label for="username">아이디</label>
                        <input type="text" id="username" name="username" required>
                    </div>
                    <div class="input-group">
                        <label for="password">비밀번호</label>
                        <input type="password" id="password" name="password" required>	
                    </div>
                    <div class="remember-me">
                        <input type="checkbox" id="remember" name="remember">
                        <label for="remember">로그인 상태 유지</label>
                    </div>
                    <button type="submit" class="login-btn">로그인</button>
                </form>
                
                <div class="signup-link">
                    <p>계정이 없으신가요? <a href="register.jsp">회원가입</a></p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
