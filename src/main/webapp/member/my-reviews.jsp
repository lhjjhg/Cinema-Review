<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%@ page import="dao.ReviewDAO" %>
<%@ page import="dto.Review" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 내가 작성한 리뷰</title>
    <link rel="stylesheet" href="../css/Style.css">
    <link rel="stylesheet" href="../css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .page-title {
            font-size: 24px;
            font-weight: bold;
            margin: 0;
        }
        
        .reviews-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        
        .review-card {
            display: flex;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .review-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
        .movie-poster-container {
            width: 120px;
            flex-shrink: 0;
        }
        
        .movie-poster {
            width: 100%;
            height: 180px;
            object-fit: cover;
        }
        
        .review-content-container {
            flex: 1;
            padding: 15px;
            display: flex;
            flex-direction: column;
        }
        
        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 10px;
        }
        
        .movie-title {
            font-size: 18px;
            font-weight: bold;
            margin: 0;
            color: #333;
        }
        
        .movie-title a {
            color: #333;
            text-decoration: none;
        }
        
        .movie-title a:hover {
            color: #e74c3c;
        }
        
        .review-rating {
            display: flex;
            align-items: center;
            margin: 5px 0;
        }
        
        .review-rating .fa-star {
            color: #ddd;
            font-size: 14px;
        }
        
        .review-rating .fa-star.filled {
            color: gold;
        }
        
        .review-meta {
            display: flex;
            align-items: center;
            font-size: 13px;
            color: #777;
            margin-bottom: 10px;
        }
        
        .review-date {
            margin-right: 15px;
        }
        
        .review-likes {
            display: flex;
            align-items: center;
        }
        
        .review-likes i {
            margin-right: 5px;
            color: #e74c3c;
        }
        
        .review-text {
            font-size: 15px;
            line-height: 1.5;
            color: #333;
            margin-bottom: 15px;
            flex: 1;
        }
        
        .review-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: auto;
        }
        
        .btn {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 14px;
            text-decoration: none;
            cursor: pointer;
            transition: background-color 0.3s;
            border: none;
        }
        
        .btn-primary {
            background-color: #4285f4;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #3367d6;
        }
        
        .btn-secondary {
            background-color: #f8f9fa;
            color: #333;
            border: 1px solid #ddd;
        }
        
        .btn-secondary:hover {
            background-color: #e9ecef;
        }
        
        .btn-danger {
            background-color: #dc3545;
            color: white;
        }
        
        .btn-danger:hover {
            background-color: #c82333;
        }
        
        .empty-state {
            text-align: center;
            padding: 50px 0;
        }
        
        .empty-state i {
            font-size: 48px;
            color: #ddd;
            margin-bottom: 15px;
        }
        
        .empty-state p {
            color: #666;
            margin: 5px 0;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 30px;
        }
        
        .pagination a {
            color: #333;
            padding: 8px 12px;
            text-decoration: none;
            border: 1px solid #ddd;
            margin: 0 4px;
            border-radius: 4px;
        }
        
        .pagination a.active {
            background-color: #4285f4;
            color: white;
            border-color: #4285f4;
        }
        
        .pagination a:hover:not(.active) {
            background-color: #f5f5f5;
        }
        
        /* 모달 스타일 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
        }
        
        .modal-content {
            background-color: #fff;
            margin: 10% auto;
            padding: 20px;
            border-radius: 8px;
            width: 80%;
            max-width: 600px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        
        .modal-title {
            font-size: 20px;
            font-weight: bold;
            margin: 0;
        }
        
        .close {
            font-size: 24px;
            font-weight: bold;
            cursor: pointer;
            color: #777;
        }
        
        .close:hover {
            color: #333;
        }
        
        .modal-body {
            margin-bottom: 20px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        
        .form-control {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        
        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }
        
        .star-rating {
            display: flex;
            flex-direction: row-reverse;
            justify-content: flex-end;
        }
        
        .star-rating input {
            display: none;
        }
        
        .star-rating label {
            cursor: pointer;
            font-size: 25px;
            color: #ddd;
            margin-right: 5px;
        }
        
        .star-rating label:hover,
        .star-rating label:hover ~ label,
        .star-rating input:checked ~ label {
            color: gold;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        @media (max-width: 768px) {
            .review-card {
                flex-direction: column;
            }
            
            .movie-poster-container {
                width: 100%;
                height: 200px;
            }
            
            .movie-poster {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
            
            .modal-content {
                width: 95%;
                margin: 5% auto;
            }
        }
    </style>
</head>
<body class="main-page">
    <%
        // 세션에서 사용자 정보 가져오기
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");
        
        // 로그인 상태가 아니면 로그인 페이지로 리다이렉트
        if (username == null || userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 페이지네이션 처리
        int currentPage = 1;
        int reviewsPerPage = 10;
        int totalReviews = 0;
        int totalPages = 0;
        
        if (request.getParameter("page") != null) {
            try {
                currentPage = Integer.parseInt(request.getParameter("page"));
                if (currentPage < 1) currentPage = 1;
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // 전체 리뷰 수 조회
            String countSql = "SELECT COUNT(*) AS count FROM review WHERE user_id = ?";
            pstmt = conn.prepareStatement(countSql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                totalReviews = rs.getInt("count");
                totalPages = (int) Math.ceil((double) totalReviews / reviewsPerPage);
            }
            
            if (currentPage > totalPages && totalPages > 0) {
                currentPage = totalPages;
            }
            
            // 현재 페이지에 해당하는 리뷰 목록 조회
            int offset = (currentPage - 1) * reviewsPerPage;
    %>

    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../header.jsp" />
        
        <main class="main-content">
            <div class="container">
                <div class="page-header">
                    <h1 class="page-title">내가 작성한 리뷰</h1>
                    <a href="../movies.jsp" class="btn btn-primary">영화 목록으로</a>
                </div>
                
                <% if (totalReviews > 0) { %>
                <div class="reviews-list">
                    <% 
                        String reviewsSql = 
                            "SELECT r.*, m.title, m.poster_url FROM review r " +
                            "JOIN movie m ON r.movie_id = m.movie_id " +
                            "WHERE r.user_id = ? " +
                            "ORDER BY r.created_at DESC " +
                            "LIMIT ? OFFSET ?";
                        
                        pstmt = conn.prepareStatement(reviewsSql);
                        pstmt.setInt(1, userId);
                        pstmt.setInt(2, reviewsPerPage);
                        pstmt.setInt(3, offset);
                        rs = pstmt.executeQuery();
                        
                        while (rs.next()) {
                            int reviewId = rs.getInt("id");
                            String movieId = rs.getString("movie_id");
                            String movieTitle = rs.getString("title");
                            String posterUrl = rs.getString("poster_url");
                            int rating = rs.getInt("rating");
                            String content = rs.getString("content");
                            int likes = rs.getInt("likes");
                            java.util.Date createdAt = rs.getTimestamp("created_at");
                            
                            // 포스터 URL이 없는 경우 기본 이미지 사용
                            if (posterUrl == null || posterUrl.isEmpty()) {
                                posterUrl = "../image/default-movie.jpg";
                            }
                    %>
                    <div class="review-card" id="review-<%= reviewId %>">
                        <div class="movie-poster-container">
                            <a href="../movie-detail.jsp?id=<%= movieId %>">
                                <img src="<%= posterUrl %>" alt="<%= movieTitle %> 포스터" class="movie-poster" onerror="this.src='../image/default-movie.jpg';">
                            </a>
                        </div>
                        <div class="review-content-container">
                            <div class="review-header">
                                <div>
                                    <h3 class="movie-title"><a href="../movie-detail.jsp?id=<%= movieId %>"><%= movieTitle %></a></h3>
                                    <div class="review-rating">
                                        <% for (int i = 1; i <= 5; i++) { %>
                                            <i class="fas fa-star <%= i <= rating ? "filled" : "" %>"></i>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            <div class="review-meta">
                                <span class="review-date"><i class="far fa-calendar-alt"></i> <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(createdAt) %></span>
                                <% if (likes > 0) { %>
                                    <span class="review-likes"><i class="far fa-heart"></i> <%= likes %></span>
                                <% } %>
                            </div>
                            <div class="review-text"><%= content %></div>
                            <div class="review-actions">
                                <a href="../movie-detail.jsp?id=<%= movieId %>#review-<%= reviewId %>" class="btn btn-secondary">
                                    <i class="fas fa-external-link-alt"></i> 영화 페이지에서 보기
                                </a>
                                <button class="btn btn-primary edit-review-btn" data-id="<%= reviewId %>" data-movie-id="<%= movieId %>" data-rating="<%= rating %>" data-content="<%= content.replace("\"", "&quot;").replace("\n", "\\n") %>">
                                    <i class="fas fa-edit"></i> 수정
                                </button>
                                <button class="btn btn-danger delete-review-btn" data-id="<%= reviewId %>" data-movie-id="<%= movieId %>">
                                    <i class="fas fa-trash-alt"></i> 삭제
                                </button>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                
                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <% if (currentPage > 1) { %>
                        <a href="?page=1">&laquo;</a>
                        <a href="?page=<%= currentPage - 1 %>">&lt;</a>
                    <% } %>
                    
                    <% 
                        int startPage = Math.max(1, currentPage - 2);
                        int endPage = Math.min(totalPages, currentPage + 2);
                        
                        for (int i = startPage; i <= endPage; i++) {
                    %>
                        <a href="?page=<%= i %>" <%= i == currentPage ? "class='active'" : "" %>><%= i %></a>
                    <% } %>
                    
                    <% if (currentPage < totalPages) { %>
                        <a href="?page=<%= currentPage + 1 %>">&gt;</a>
                        <a href="?page=<%= totalPages %>">&raquo;</a>
                    <% } %>
                </div>
                <% } %>
                
                <% } else { %>
                <div class="empty-state">
                    <i class="fas fa-star"></i>
                    <p>작성한 리뷰가 없습니다.</p>
                    <p>영화 상세 페이지에서 리뷰를 작성해보세요!</p>
                    <a href="../movies.jsp" class="btn btn-primary">영화 보러가기</a>
                </div>
                <% } %>
            </div>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../footer.jsp" />
    </div>
    
    <!-- 리뷰 수정 모달 -->
    <div id="editReviewModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">리뷰 수정</h2>
                <span class="close">&times;</span>
            </div>
            <div class="modal-body">
                <form id="editReviewForm" action="../ReviewServlet" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="editReviewId">
                    <input type="hidden" name="movieId" id="editMovieId">
                    
                    <div class="form-group">
                        <label class="form-label">별점</label>
                        <div class="star-rating">
                            <input type="radio" id="star5" name="rating" value="5">
                            <label for="star5" class="fas fa-star"></label>
                            <input type="radio" id="star4" name="rating" value="4">
                            <label for="star4" class="fas fa-star"></label>
                            <input type="radio" id="star3" name="rating" value="3">
                            <label for="star3" class="fas fa-star"></label>
                            <input type="radio" id="star2" name="rating" value="2">
                            <label for="star2" class="fas fa-star"></label>
                            <input type="radio" id="star1" name="rating" value="1">
                            <label for="star1" class="fas fa-star"></label>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="editContent" class="form-label">리뷰 내용</label>
                        <textarea id="editContent" name="content" class="form-control" required></textarea>
                    </div>
                    
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" id="cancelEdit">취소</button>
                        <button type="submit" class="btn btn-primary">저장</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- 리뷰 삭제 확인 모달 -->
    <div id="deleteReviewModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">리뷰 삭제</h2>
                <span class="close">&times;</span>
            </div>
            <div class="modal-body">
                <p>정말로 이 리뷰를 삭제하시겠습니까?</p>
                <p>이 작업은 되돌릴 수 없습니다.</p>
                
                <form id="deleteReviewForm" action="../ReviewServlet" method="post">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteReviewId">
                    <input type="hidden" name="movieId" id="deleteMovieId">
                    
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" id="cancelDelete">취소</button>
                        <button type="submit" class="btn btn-danger">삭제</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="../js/main.js"></script>
    <script>
        // 모달 관련 스크립트
        const editModal = document.getElementById('editReviewModal');
        const deleteModal = document.getElementById('deleteReviewModal');
        const editForm = document.getElementById('editReviewForm');
        const deleteForm = document.getElementById('deleteReviewForm');
        
        // 수정 버튼 클릭 이벤트
        document.querySelectorAll('.edit-review-btn').forEach(button => {
            button.addEventListener('click', function() {
                const reviewId = this.getAttribute('data-id');
                const movieId = this.getAttribute('data-movie-id');
                const rating = this.getAttribute('data-rating');
                const content = this.getAttribute('data-content').replace(/\\n/g, '\n');
                
                document.getElementById('editReviewId').value = reviewId;
                document.getElementById('editMovieId').value = movieId;
                document.getElementById('editContent').value = content;
                
                // 별점 설정
                document.querySelector(`#star${rating}`).checked = true;
                
                editModal.style.display = 'block';
            });
        });
        
        // 삭제 버튼 클릭 이벤트
        document.querySelectorAll('.delete-review-btn').forEach(button => {
            button.addEventListener('click', function() {
                const reviewId = this.getAttribute('data-id');
                const movieId = this.getAttribute('data-movie-id');
                
                document.getElementById('deleteReviewId').value = reviewId;
                document.getElementById('deleteMovieId').value = movieId;
                
                deleteModal.style.display = 'block';
            });
        });
        
        // 모달 닫기 이벤트
        document.querySelectorAll('.close, #cancelEdit, #cancelDelete').forEach(element => {
            element.addEventListener('click', function() {
                editModal.style.display = 'none';
                deleteModal.style.display = 'none';
            });
        });
        
        // 모달 외부 클릭 시 닫기
        window.addEventListener('click', function(event) {
            if (event.target == editModal) {
                editModal.style.display = 'none';
            }
            if (event.target == deleteModal) {
                deleteModal.style.display = 'none';
            }
        });
    </script>
</body>
</html>
<%
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
