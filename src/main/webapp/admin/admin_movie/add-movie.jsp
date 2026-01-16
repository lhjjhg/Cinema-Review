<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>영화 직접 추가 - 관리자</title>
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
            margin-bottom: 10px;
        }
        
        .admin-title p {
            color: #bbb;
            font-size: 16px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            color: #ddd;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 12px;
            background-color: #333;
            border: 1px solid #444;
            border-radius: 4px;
            color: #fff;
            font-size: 16px;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #e50914;
        }
        
        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }
        
        .form-row {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .form-row .form-group {
            flex: 1;
            margin-bottom: 0;
        }
        
        .btn-container {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 30px;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .btn-primary {
            background-color: #e50914;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #f40612;
            transform: translateY(-2px);
        }
        
        .btn-secondary {
            background-color: #333;
            color: #fff;
        }
        
        .btn-secondary:hover {
            background-color: #444;
            transform: translateY(-2px);
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .alert-success {
            background-color: rgba(76, 175, 80, 0.2);
            color: #4CAF50;
            border: 1px solid #4CAF50;
        }
        
        .alert-danger {
            background-color: rgba(244, 67, 54, 0.2);
            color: #f44336;
            border: 1px solid #f44336;
        }
        
        .back-link {
            display: block;
            text-align: center;
            margin-top: 30px;
            color: #bbb;
            text-decoration: none;
        }
        
        .back-link:hover {
            color: #e50914;
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
                    <h1>영화 직접 추가</h1>
                    <p>영화 정보를 수동으로 추가합니다</p>
                </div>
                
                <%
                    String message = "";
                    String messageType = "";
                    
                    // 폼 제출 처리
                    if ("POST".equalsIgnoreCase(request.getMethod())) {
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        
                        try {
                            // 폼 데이터 가져오기
                            request.setCharacterEncoding("UTF-8");
                            String title = request.getParameter("title");
                            String director = request.getParameter("director");
                            String actors = request.getParameter("actors");
                            String genre = request.getParameter("genre");
                            String releaseDate = request.getParameter("releaseDate");
                            String runtime = request.getParameter("runtime");
                            String rating = request.getParameter("rating");
                            String posterUrl = request.getParameter("posterUrl");
                            String description = request.getParameter("description");
                            String status = request.getParameter("status");
                            String movieRank = request.getParameter("movieRank");
                            
                            conn = DBConnection.getConnection();
                            
                            // 영화 ID 생성 (UUID 형식)
                            String movieId = java.util.UUID.randomUUID().toString();
                            
                            // 영화 정보 삽입
                            String sql = "INSERT INTO movie (movie_id, title, director, actors, genre, release_date, runtime, rating, poster_url, description, status, movie_rank, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
                            pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, movieId);
                            pstmt.setString(2, title);
                            pstmt.setString(3, director);
                            pstmt.setString(4, actors);
                            pstmt.setString(5, genre);
                            pstmt.setString(6, releaseDate);
                            pstmt.setInt(7, Integer.parseInt(runtime));
                            pstmt.setDouble(8, Double.parseDouble(rating));
                            pstmt.setString(9, posterUrl);
                            pstmt.setString(10, description);
                            pstmt.setString(11, status);
                            pstmt.setInt(12, Integer.parseInt(movieRank));
                            
                            int result = pstmt.executeUpdate();
                            
                            if (result > 0) {
                                message = "영화가 성공적으로 추가되었습니다.";
                                messageType = "success";
                            } else {
                                message = "영화 추가에 실패했습니다.";
                                messageType = "danger";
                            }
                            
                        } catch (Exception e) {
                            message = "오류 발생: " + e.getMessage();
                            messageType = "danger";
                            e.printStackTrace();
                        } finally {
                            try {
                                if (pstmt != null) pstmt.close();
                                if (conn != null) conn.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                    }
                %>
                
                <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>">
                    <%= message %>
                </div>
                <% } %>
                
                <form method="post" action="add-movie.jsp">
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">영화 제목</label>
                            <input type="text" name="title" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">감독</label>
                            <input type="text" name="director" class="form-control" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">출연 배우</label>
                        <input type="text" name="actors" class="form-control" placeholder="배우 이름을 쉼표로 구분하여 입력" required>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">장르</label>
                            <input type="text" name="genre" class="form-control" placeholder="장르를 쉼표로 구분하여 입력" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">개봉일</label>
                            <input type="date" name="releaseDate" class="form-control" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">상영 시간 (분)</label>
                            <input type="number" name="runtime" class="form-control" min="1" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">평점</label>
                            <input type="number" name="rating" class="form-control" min="0" max="10" step="0.1" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">순위</label>
                            <input type="number" name="movieRank" class="form-control" min="0" value="0">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">포스터 URL</label>
                        <input type="url" name="posterUrl" class="form-control" placeholder="포스터 이미지 URL">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">영화 설명</label>
                        <textarea name="description" class="form-control" required></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">상태</label>
                        <select name="status" class="form-control" required>
                            <option value="current">현재 상영작</option>
                            <option value="coming">상영 예정작</option>
                        </select>
                    </div>
                    
                    <div class="btn-container">
                        <button type="submit" class="btn btn-primary">영화 추가</button>
                        <button type="reset" class="btn btn-secondary">초기화</button>
                    </div>
                </form>
                
                <a href="../index.jsp" class="back-link">관리자 메인으로 돌아가기</a>
            </div>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../../footer.jsp" />
    </div>
</body>
</html>
