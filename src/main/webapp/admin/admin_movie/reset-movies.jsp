<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.MovieDAO" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>영화 데이터 초기화</title>
    <link rel="stylesheet" href="../../css/Style.css">
    <link rel="stylesheet" href="../../css/main.css">
    <style>
        .admin-container {
            max-width: 800px;
            margin: 50px auto;
            padding: 30px;
            background-color: rgba(31, 31, 31, 0.9);
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
        
        .admin-title {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .admin-title h1 {
            font-size: 28px;
            color: #fff;
        }
        
        .admin-title p {
            color: #bbb;
        }
        
        .admin-actions {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 40px;
            flex-wrap: wrap;
        }
        
        .admin-btn {
            background-color: #e50914;
            color: white;
            padding: 12px 25px;
            border-radius: 5px;
            border: none;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .admin-btn:hover {
            background-color: #f40612;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }
        
        .admin-btn.secondary {
            background-color: #333;
        }
        
        .admin-btn.secondary:hover {
            background-color: #444;
        }
        
        .admin-btn.danger {
            background-color: #f44336;
        }
        
        .admin-btn.danger:hover {
            background-color: #d32f2f;
        }
        
        .important-note {
            margin-top: 30px;
            padding: 15px;
            background-color: rgba(229, 9, 20, 0.1);
            border-left: 4px solid #e50914;
            color: #ddd;
        }
        
        .status-card {
            background-color: rgba(255, 255, 255, 0.05);
            padding: 20px;
            border-radius: 5px;
            margin-top: 30px;
        }
        
        .status-card h3 {
            margin-top: 0;
            color: #fff;
        }
        
        .status-info {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-top: 20px;
        }
        
        .status-item {
            flex: 1;
            min-width: 200px;
            background-color: rgba(0, 0, 0, 0.2);
            padding: 15px;
            border-radius: 5px;
            text-align: center;
        }
        
        .status-count {
            font-size: 32px;
            font-weight: bold;
            color: #e50914;
            margin-bottom: 5px;
        }
        
        .status-label {
            color: #bbb;
        }
        
        .result-message {
            margin-top: 20px;
            padding: 15px;
            border-radius: 5px;
            text-align: center;
        }
        
        .success {
            background-color: rgba(76, 175, 80, 0.1);
            color: #4CAF50;
        }
        
        .error {
            background-color: rgba(244, 67, 54, 0.1);
            color: #f44336;
        }

        .container {
            max-width: 800px;
            margin: 50px auto;
            padding: 30px;
            background-color: rgba(31, 31, 31, 0.9);
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            color: #fff;
        }

        h1 {
            text-align: center;
            margin-bottom: 30px;
            color: #fff;
        }

        .warning-box {
            margin-top: 30px;
            padding: 15px;
            background-color: rgba(229, 9, 20, 0.1);
            border-left: 4px solid #e50914;
            color: #ddd;
        }

        .success-message {
            margin-top: 20px;
            padding: 15px;
            background-color: rgba(76, 175, 80, 0.1);
            color: #4CAF50;
            text-align: center;
            border-radius: 5px;
        }

        .error-message {
            margin-top: 20px;
            padding: 15px;
            background-color: rgba(244, 67, 54, 0.1);
            color: #f44336;
            text-align: center;
            border-radius: 5px;
        }

        .danger-button {
            background-color: #f44336;
            color: white;
            padding: 12px 25px;
            border-radius: 5px;
            border: none;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-block;
            margin-top: 20px;
        }

        .danger-button:hover {
            background-color: #d32f2f;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }

        .button-container {
            margin-top: 30px;
            text-align: center;
        }

        .button {
            background-color: #333;
            color: white;
            padding: 12px 25px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
        }

        .button:hover {
            background-color: #444;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }
    </style>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../../header.jsp" />
        
        <main class="main-content">
            <div class="admin-container">
                <div class="admin-title">
                    <h1>영화 데이터 초기화</h1>
                    <p>데이터베이스의 영화 정보를 초기화하고 다시 크롤링할 수 있습니다</p>
                </div>
                
                <%
                    String action = request.getParameter("action");
                    
                    if ("reset".equals(action)) {
                        try {
                            MovieDAO movieDAO = new MovieDAO();
                            movieDAO.resetMovieTables();
                            out.println("<div class='success-message'>영화 테이블이 성공적으로 초기화되었습니다.</div>");
                            out.println("<p>AUTO_INCREMENT 값이 1로 재설정되었습니다.</p>");
                        } catch (Exception e) {
                            out.println("<div class='error-message'>영화 테이블 초기화 중 오류가 발생했습니다: " + e.getMessage() + "</div>");
                            e.printStackTrace();
                        }
                    }
                %>
                
                <div class="important-note">
                    <h2>주의!</h2>
                    <p>이 작업은 모든 영화 데이터를 삭제하고 AUTO_INCREMENT 값을 1로 재설정합니다.</p>
                    <p>이 작업은 되돌릴 수 없습니다.</p>
                </div>
                
                <form method="post" onsubmit="return confirm('정말로 모든 영화 데이터를 초기화하시겠습니까?');">
                    <input type="hidden" name="action" value="reset">
                    <button type="submit" class="admin-btn danger">영화 데이터 초기화</button>
                </form>
                
                <div class="button-container">
                    <a href="../index.jsp" class="admin-btn secondary">관리자 메인으로 돌아가기</a>
                </div>
            </div>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../../footer.jsp" />
    </div>
</body>
</html>
