<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 리뷰 관리</title>
    <link rel="stylesheet" href="../../css/Style.css">
    <link rel="stylesheet" href="../../css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        .admin-container {
            max-width: 1200px;
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
            font-size: 32px;
            color: #fff;
            margin-bottom: 10px;
        }
        
        .admin-title p {
            color: #bbb;
            font-size: 16px;
        }
        
        .search-container {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .search-box {
            display: flex;
            flex: 1;
            min-width: 300px;
        }
        
        .search-box input {
            flex: 1;
            padding: 10px;
            border: none;
            border-radius: 5px 0 0 5px;
            background-color: rgba(255, 255, 255, 0.1);
            color: #fff;
        }
        
        .search-box button {
            padding: 10px 15px;
            border: none;
            background-color: #e50914;
            color: white;
            border-radius: 0 5px 5px 0;
            cursor: pointer;
        }
        
        .filter-container {
            display: flex;
            gap: 10px;
        }
        
        .filter-container select {
            padding: 10px;
            border: none;
            border-radius: 5px;
            background-color: rgba(255, 255, 255, 0.1);
            color: #fff;
        }
        
        .reviews-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            color: #fff;
        }
        
        .reviews-table th, .reviews-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .reviews-table th {
            background-color: rgba(229, 9, 20, 0.2);
            color: #fff;
            font-weight: 600;
        }
        
        .reviews-table tr:hover {
            background-color: rgba(255, 255, 255, 0.05);
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
        }
        
        .action-button {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .delete-button {
            background-color: #e50914;
            color: white;
        }
        
        .warning-button {
            background-color: #f39c12;
            color: white;
        }
        
        .action-button:hover {
            opacity: 0.8;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 30px;
            gap: 10px;
        }
        
        .pagination a {
            display: inline-block;
            padding: 8px 12px;
            background-color: rgba(255, 255, 255, 0.1);
            color: #fff;
            border-radius: 4px;
            text-decoration: none;
            transition: background-color 0.3s ease;
        }
        
        .pagination a:hover, .pagination a.active {
            background-color: #e50914;
        }
        
        .back-link {
            display: block;
            text-align: center;
            margin-top: 30px;
            color: #bbb;
            text-decoration: none;
            transition: color 0.3s ease;
        }
        
        .back-link:hover {
            color: #e50914;
        }
        
        .warning-count {
            display: inline-block;
            padding: 2px 6px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .warning-low {
            background-color: #2ecc71;
            color: white;
        }
        
        .warning-medium {
            background-color: #f39c12;
            color: white;
        }
        
        .warning-high {
            background-color: #e74c3c;
            color: white;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.7);
        }
        
        .modal-content {
            background-color: #242424;
            margin: 10% auto;
            padding: 20px;
            border-radius: 10px;
            width: 50%;
            max-width: 500px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .modal-header h2 {
            color: #fff;
            margin: 0;
        }
        
        .close-button {
            color: #aaa;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        
        .close-button:hover {
            color: #e50914;
        }
        
        .modal-body {
            margin-bottom: 20px;
        }
        
        .modal-body textarea {
            width: 100%;
            padding: 10px;
            border-radius: 5px;
            border: 1px solid #444;
            background-color: #333;
            color: #fff;
            min-height: 100px;
            resize: vertical;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        .modal-button {
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .cancel-button {
            background-color: #555;
            color: white;
        }
        
        .submit-button {
            background-color: #e50914;
            color: white;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        
        .alert-success {
            background-color: rgba(46, 204, 113, 0.2);
            border: 1px solid #2ecc71;
            color: #2ecc71;
        }
        
        .alert-error {
            background-color: rgba(231, 76, 60, 0.2);
            border: 1px solid #e74c3c;
            color: #e74c3c;
        }
        
        .truncate {
            max-width: 200px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
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
                    <h1>리뷰 관리</h1>
                    <p>사용자의 영화 리뷰를 관리하고 부적절한 내용을 삭제하거나 경고할 수 있습니다.</p>
                </div>
                
                <% 
                // 성공 또는 오류 메시지 표시
                String successMessage = request.getParameter("message");
                String errorMessage = request.getParameter("message");
                boolean isSuccess = "true".equals(request.getParameter("success"));
                boolean isError = request.getParameter("error") != null;
                
                if (successMessage != null && isSuccess) {
                %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
                <% } else if (errorMessage != null && isError) { %>
                <div class="alert alert-error">
                    <%= errorMessage %>
                </div>
                <% } %>
                
                <div class="search-container">
                    <form class="search-box" action="manage-reviews.jsp" method="get">
                        <input type="text" name="search" placeholder="사용자명, 영화 제목 또는 리뷰 내용으로 검색..." 
                               value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                        <button type="submit"><i class="fas fa-search"></i></button>
                    </form>
                    
                    <div class="filter-container">
                        <select name="sort" onchange="this.form.submit()">
                            <option value="newest" <%= "newest".equals(request.getParameter("sort")) ? "selected" : "" %>>최신순</option>
                            <option value="oldest" <%= "oldest".equals(request.getParameter("sort")) ? "selected" : "" %>>오래된순</option>
                            <option value="rating_high" <%= "rating_high".equals(request.getParameter("sort")) ? "selected" : "" %>>평점 높은순</option>
                            <option value="rating_low" <%= "rating_low".equals(request.getParameter("sort")) ? "selected" : "" %>>평점 낮은순</option>
                        </select>
                        
                        <select name="warning" onchange="this.form.submit()">
                            <option value="all" <%= "all".equals(request.getParameter("warning")) || request.getParameter("warning") == null ? "selected" : "" %>>모든 경고</option>
                            <option value="0" <%= "0".equals(request.getParameter("warning")) ? "selected" : "" %>>경고 없음</option>
                            <option value="1" <%= "1".equals(request.getParameter("warning")) ? "selected" : "" %>>경고 1회</option>
                            <option value="2" <%= "2".equals(request.getParameter("warning")) ? "selected" : "" %>>경고 2회</option>
                            <option value="3+" <%= "3+".equals(request.getParameter("warning")) ? "selected" : "" %>>경고 3회 이상</option>
                        </select>
                    </div>
                </div>
                
                <table class="reviews-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>사용자</th>
                            <th>영화</th>
                            <th>평점</th>
                            <th>리뷰 내용</th>
                            <th>작성일</th>
                            <th>경고 횟수</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        
                        try {
                            conn = DBConnection.getConnection();
                            
                            // 페이지네이션 설정
                            int currentPage = 1;
                            if (request.getParameter("page") != null) {
                                currentPage = Integer.parseInt(request.getParameter("page"));
                            }
                            int recordsPerPage = 10;
                            int start = (currentPage - 1) * recordsPerPage;
                            
                            // 검색 및 정렬 조건
                            String search = request.getParameter("search");
                            String sort = request.getParameter("sort");
                            String warning = request.getParameter("warning");
                            
                            StringBuilder sqlBuilder = new StringBuilder();
                            sqlBuilder.append("SELECT r.id, r.user_id, r.movie_id, r.rating, r.content, r.created_at, ");
                            sqlBuilder.append("u.username, u.warning_count, m.title ");
                            sqlBuilder.append("FROM review r ");
                            sqlBuilder.append("JOIN user u ON r.user_id = u.id ");
                            sqlBuilder.append("JOIN movie m ON r.movie_id = m.movie_id ");
                            
                            // 검색 조건
                            if (search != null && !search.trim().isEmpty()) {
                                sqlBuilder.append("WHERE u.username LIKE ? OR m.title LIKE ? OR r.content LIKE ? ");
                            }
                            
                            // 경고 필터
                            if (warning != null && !warning.equals("all")) {
                                if (search != null && !search.trim().isEmpty()) {
                                    sqlBuilder.append("AND ");
                                } else {
                                    sqlBuilder.append("WHERE ");
                                }
                                
                                if (warning.equals("0")) {
                                    sqlBuilder.append("u.warning_count = 0 ");
                                } else if (warning.equals("1")) {
                                    sqlBuilder.append("u.warning_count = 1 ");
                                } else if (warning.equals("2")) {
                                    sqlBuilder.append("u.warning_count = 2 ");
                                } else if (warning.equals("3+")) {
                                    sqlBuilder.append("u.warning_count >= 3 ");
                                }
                            }
                            
                            // 정렬 조건
                            if (sort != null) {
                                if (sort.equals("newest")) {
                                    sqlBuilder.append("ORDER BY r.created_at DESC ");
                                } else if (sort.equals("oldest")) {
                                    sqlBuilder.append("ORDER BY r.created_at ASC ");
                                } else if (sort.equals("rating_high")) {
                                    sqlBuilder.append("ORDER BY r.rating DESC ");
                                } else if (sort.equals("rating_low")) {
                                    sqlBuilder.append("ORDER BY r.rating ASC ");
                                }
                            } else {
                                sqlBuilder.append("ORDER BY r.created_at DESC ");
                            }
                            
                            // 페이지네이션 제한
                            sqlBuilder.append("LIMIT ?, ?");
                            
                            pstmt = conn.prepareStatement(sqlBuilder.toString());
                            
                            // 파라미터 설정
                            int paramIndex = 1;
                            if (search != null && !search.trim().isEmpty()) {
                                String searchPattern = "%" + search + "%";
                                pstmt.setString(paramIndex++, searchPattern);
                                pstmt.setString(paramIndex++, searchPattern);
                                pstmt.setString(paramIndex++, searchPattern);
                            }
                            
                            pstmt.setInt(paramIndex++, start);
                            pstmt.setInt(paramIndex, recordsPerPage);
                            
                            rs = pstmt.executeQuery();
                            
                            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                            
                            while (rs.next()) {
                                int reviewId = rs.getInt("id");
                                int userId = rs.getInt("user_id");
                                String username = rs.getString("username");
                                String movieTitle = rs.getString("title");
                                int rating = rs.getInt("rating");
                                String content = rs.getString("content");
                                Timestamp createdAt = rs.getTimestamp("created_at");
                                int warningCount = rs.getInt("warning_count");
                                
                                String warningClass = "";
                                if (warningCount == 0) {
                                    warningClass = "warning-low";
                                } else if (warningCount == 1) {
                                    warningClass = "warning-medium";
                                } else {
                                    warningClass = "warning-high";
                                }
                        %>
                        <tr>
                            <td><%= reviewId %></td>
                            <td><%= username %></td>
                            <td><%= movieTitle %></td>
                            <td><%= rating %>/5</td>
                            <td class="truncate"><%= content %></td>
                            <td><%= sdf.format(createdAt) %></td>
                            <td><span class="warning-count <%= warningClass %>"><%= warningCount %></span></td>
                            <td class="action-buttons">
                                <button class="action-button delete-button" onclick="confirmDelete(<%= reviewId %>)">삭제</button>
                                <button class="action-button warning-button" onclick="openWarningModal(<%= userId %>, <%= reviewId %>, '<%= username %>')">경고</button>
                            </td>
                        </tr>
                        <%
                            }
                            
                            // 전체 레코드 수 계산
                            String countSql = "SELECT COUNT(*) FROM review r JOIN user u ON r.user_id = u.id JOIN movie m ON r.movie_id = m.movie_id";
                            if (search != null && !search.trim().isEmpty()) {
                                countSql += " WHERE u.username LIKE ? OR m.title LIKE ? OR r.content LIKE ?";
                            }
                            
                            PreparedStatement countStmt = conn.prepareStatement(countSql);
                            if (search != null && !search.trim().isEmpty()) {
                                String searchPattern = "%" + search + "%";
                                countStmt.setString(1, searchPattern);
                                countStmt.setString(2, searchPattern);
                                countStmt.setString(3, searchPattern);
                            }
                            
                            ResultSet countRs = countStmt.executeQuery();
                            countRs.next();
                            int totalRecords = countRs.getInt(1);
                            int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
                            
                            countRs.close();
                            countStmt.close();
                        %>
                    </tbody>
                </table>
                
                <!-- 페이지네이션 -->
                <div class="pagination">
                    <% if (currentPage > 1) { %>
                        <a href="?page=1">&laquo; 처음</a>
                        <a href="?page=<%= currentPage - 1 %>">&lt; 이전</a>
                    <% } %>
                    
                    <% 
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage = Math.min(totalPages, currentPage + 2);
                    
                    for (int i = startPage; i <= endPage; i++) {
                        if (i == currentPage) {
                    %>
                        <a href="?page=<%= i %>" class="active"><%= i %></a>
                    <% } else { %>
                        <a href="?page=<%= i %>"><%= i %></a>
                    <% } 
                    } %>
                    
                    <% if (currentPage < totalPages) { %>
                        <a href="?page=<%= currentPage + 1 %>">다음 &gt;</a>
                        <a href="?page=<%= totalPages %>">마지막 &raquo;</a>
                    <% } %>
                </div>
                
                <a href="../index.jsp" class="back-link">관리자 메인으로 돌아가기</a>
            </div>
        </main>
        
        <!-- 경고 모달 -->
        <div id="warningModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2>사용자 경고</h2>
                    <span class="close-button" onclick="closeWarningModal()">&times;</span>
                </div>
                <form action="send_warning.jsp" method="post">
                    <input type="hidden" id="userId" name="userId" value="">
                    <input type="hidden" id="reviewId" name="reviewId" value="">
                    <div class="modal-body">
                        <p id="warningText">다음 사용자에게 경고를 보냅니다:</p>
                        <textarea name="warningMessage" placeholder="경고 메시지를 입력하세요..." required></textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="modal-button cancel-button" onclick="closeWarningModal()">취소</button>
                        <button type="submit" class="modal-button submit-button">경고 보내기</button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../../footer.jsp" />
    </div>
    
    <script>
        // 삭제 확인
        function confirmDelete(reviewId) {
            if (confirm("정말로 이 리뷰를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.")) {
                window.location.href = "delete_review.jsp?id=" + reviewId;
            }
        }
        
        // 경고 모달
        function openWarningModal(userId, reviewId, username) {
            document.getElementById("userId").value = userId;
            document.getElementById("reviewId").value = reviewId;
            document.getElementById("warningText").innerText = username + "님에게 경고를 보냅니다:";
            document.getElementById("warningModal").style.display = "block";
        }
        
        function closeWarningModal() {
            document.getElementById("warningModal").style.display = "none";
        }
        
        // 모달 외부 클릭 시 닫기
        window.onclick = function(event) {
            var modal = document.getElementById("warningModal");
            if (event.target == modal) {
                closeWarningModal();
            }
        }
    </script>
    
    <%
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    %>
</body>
</html>
