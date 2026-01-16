<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 게시판 관리</title>
    <link rel="stylesheet" href="../../css/Style.css">
    <link rel="stylesheet" href="../../css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
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
            margin-bottom: 40px;
        }
        
        .admin-title h1 {
            font-size: 32px;
            color: #fff;
            margin-bottom: 10px;
            position: relative;
            display: inline-block;
        }
        
        .admin-title h1:after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 3px;
            background-color: #e50914;
        }
        
        .admin-title p {
            color: #bbb;
            font-size: 16px;
            margin-top: 20px;
        }
        
        .tabs {
            display: flex;
            margin-bottom: 30px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            overflow-x: auto;
            scrollbar-width: thin;
            scrollbar-color: #e50914 #333;
        }
        
        .tabs::-webkit-scrollbar {
            height: 6px;
        }
        
        .tabs::-webkit-scrollbar-track {
            background: #333;
            border-radius: 10px;
        }
        
        .tabs::-webkit-scrollbar-thumb {
            background-color: #e50914;
            border-radius: 10px;
        }
        
        .tab {
            padding: 15px 25px;
            cursor: pointer;
            color: #aaa;
            font-weight: 500;
            transition: all 0.3s;
            white-space: nowrap;
            position: relative;
        }
        
        .tab.active {
            color: #fff;
        }
        
        .tab.active:after {
            content: '';
            position: absolute;
            bottom: -1px;
            left: 0;
            width: 100%;
            height: 3px;
            background-color: #e50914;
            animation: slideIn 0.3s ease-out;
        }
        
        @keyframes slideIn {
            from { transform: scaleX(0); }
            to { transform: scaleX(1); }
        }
        
        .tab:hover {
            color: #fff;
            background-color: rgba(255, 255, 255, 0.05);
        }
        
        .tab-content {
            display: none;
            animation: fadeIn 0.5s ease-out;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .tab-content.active {
            display: block;
        }
        
        .table-wrapper {
            overflow-x: auto;
            margin-top: 20px;
            border-radius: 8px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .table-wrapper::-webkit-scrollbar {
            height: 8px;
        }

        .table-wrapper::-webkit-scrollbar-track {
            background: #333;
            border-radius: 10px;
        }

        .table-wrapper::-webkit-scrollbar-thumb {
            background-color: #e50914;
            border-radius: 10px;
        }

        .board-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            color: #fff;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            border-radius: 8px;
            table-layout: fixed; /* 테이블 레이아웃 고정 */
        }
        
        .board-table th, .board-table td {
            padding: 12px 8px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            white-space: nowrap;
            vertical-align: middle;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .board-table th:nth-child(1), .board-table td:nth-child(1) { width: 8%; } /* ID */
        .board-table th:nth-child(2), .board-table td:nth-child(2) { width: 12%; } /* 카테고리 */
        .board-table th:nth-child(3), .board-table td:nth-child(3) { 
            width: 35%; 
            white-space: normal;
            word-break: break-word;
            max-width: 0;
        } /* 제목 */
        .board-table th:nth-child(4), .board-table td:nth-child(4) { width: 15%; } /* 작성자 */
        .board-table th:nth-child(5), .board-table td:nth-child(5) { width: 8%; text-align: center; } /* 조회수 */
        .board-table th:nth-child(6), .board-table td:nth-child(6) { width: 12%; } /* 작성일 */
        .board-table th:nth-child(7), .board-table td:nth-child(7) { width: 10%; text-align: center; } /* 작업 */
        
        .board-table th {
            background-color: rgba(229, 9, 20, 0.8);
            color: white;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 14px;
            letter-spacing: 1px;
            min-width: 80px;
        }

        .board-table td {
            min-height: 50px;
        }
        
        .board-table tr:hover {
            background-color: rgba(255, 255, 255, 0.05);
            transition: all 0.3s ease;
        }
        
        .board-table tr:last-child td {
            border-bottom: none;
        }
        
        .board-table td a {
            color: #fff;
            text-decoration: none;
            transition: all 0.3s;
        }
        
        .board-table td a:hover {
            color: #e50914;
            text-decoration: underline;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
            align-items: center;
            min-width: 80px;
        }
        
        .action-btn {
            padding: 8px 14px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
            font-size: 13px;
            white-space: nowrap;
            min-width: 60px;
            text-align: center;
        }
        
        .edit-btn {
            background-color: #4CAF50;
            color: white;
        }
        
        .delete-btn {
            background-color: #e50914;
            color: white;
        }
        
        .action-btn:hover {
            opacity: 0.8;
            transform: translateY(-2px);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }
        
        .search-filter {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
            background-color: rgba(255, 255, 255, 0.05);
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        
        .search-box {
            display: flex;
            gap: 10px;
            flex: 1;
            max-width: 500px;
        }
        
        .search-box input {
            padding: 12px 15px;
            border: none;
            border-radius: 4px;
            background-color: #333;
            color: #fff;
            flex: 1;
            font-size: 14px;
            box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.2);
        }
        
        .search-box button {
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            background-color: #e50914;
            color: white;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }
        
        .search-box button:hover {
            background-color: #c70812;
            transform: translateY(-2px);
        }
        
        .filter-box select {
            padding: 12px 15px;
            border: none;
            border-radius: 4px;
            background-color: #333;
            color: #fff;
            font-size: 14px;
            cursor: pointer;
            min-width: 150px;
            appearance: none;
            background-image: url('data:image/svg+xml;utf8,<svg fill="white" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/><path d="M0 0h24v24H0z" fill="none"/></svg>');
            background-repeat: no-repeat;
            background-position: right 10px center;
            padding-right: 30px;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 30px;
        }
        
        .pagination a {
            color: #fff;
            padding: 10px 16px;
            text-decoration: none;
            transition: all 0.3s;
            border: 1px solid #333;
            margin: 0 4px;
            border-radius: 4px;
        }
        
        .pagination a.active {
            background-color: #e50914;
            color: white;
            border: 1px solid #e50914;
        }
        
        .pagination a:hover:not(.active) {
            background-color: #333;
            transform: translateY(-2px);
        }
        
        .back-link {
            display: inline-block;
            text-align: center;
            margin-top: 40px;
            color: #bbb;
            text-decoration: none;
            transition: all 0.3s ease;
            padding: 10px 20px;
            border: 1px solid #444;
            border-radius: 4px;
            background-color: rgba(255, 255, 255, 0.05);
        }
        
        .back-link:hover {
            color: #e50914;
            background-color: rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
        }
        
        .add-category-btn {
            padding: 12px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-bottom: 20px;
            font-weight: 500;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .add-category-btn:hover {
            background-color: #3e8e41;
            transform: translateY(-2px);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }
        
        .category-form {
            background-color: rgba(255, 255, 255, 0.05);
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
            display: none;
            animation: slideDown 0.3s ease-out;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #ddd;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #333;
            border-radius: 4px;
            background-color: #333;
            color: #fff;
            font-size: 14px;
            transition: all 0.3s;
        }
        
        .form-group input:focus {
            border-color: #e50914;
            outline: none;
            box-shadow: 0 0 0 2px rgba(229, 9, 20, 0.2);
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 20px;
        }
        
        .form-actions button {
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }
        
        .save-btn {
            background-color: #4CAF50;
            color: white;
        }
        
        .save-btn:hover {
            background-color: #3e8e41;
            transform: translateY(-2px);
        }
        
        .cancel-btn {
            background-color: #555;
            color: white;
        }
        
        .cancel-btn:hover {
            background-color: #444;
            transform: translateY(-2px);
        }
        
        .no-data {
            text-align: center;
            padding: 40px;
            color: #aaa;
            font-style: italic;
            background-color: rgba(255, 255, 255, 0.02);
            border-radius: 8px;
            margin-top: 20px;
        }
        
        /* 반응형 디자인 */
        @media (max-width: 992px) {
            .search-filter {
                flex-direction: column;
                gap: 15px;
            }
            
            .search-box {
                max-width: 100%;
            }
        }
        
        @media (max-width: 768px) {
            .board-table {
                font-size: 12px;
            }
            
            .board-table th:nth-child(5),
            .board-table td:nth-child(5),
            .board-table th:nth-child(6),
            .board-table td:nth-child(6) {
                display: none;
            }
            
            .tab {
                padding: 12px 15px;
                font-size: 14px;
            }
        }
        
        @media (max-width: 576px) {
            .board-table th:nth-child(4),
            .board-table td:nth-child(4) {
                display: none;
            }
            
            .action-buttons {
                flex-direction: column;
                gap: 5px;
                min-width: 60px;
            }
            
            .action-btn {
                width: 100%;
                text-align: center;
                min-width: 50px;
            }
        }
    </style>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../../header.jsp" />
        
        <main class="main-content">
            <%
String successMsg = request.getParameter("success");
String errorMsg = request.getParameter("error");
%>

<div class="admin-container">
    <div class="admin-title">
        <h1>게시판 관리</h1>
        <p>게시판의 게시글, 댓글 및 카테고리를 관리합니다</p>
        
        <!-- 성공/오류 메시지 표시 -->
        <% if (successMsg != null) { %>
            <div class="alert alert-success" style="background-color: #4CAF50; color: white; padding: 10px; border-radius: 4px; margin: 10px 0;">
                <% if ("post_deleted".equals(successMsg)) { %>
                    게시글이 성공적으로 삭제되었습니다.
                <% } else if ("comment_deleted".equals(successMsg)) { %>
                    댓글이 성공적으로 삭제되었습니다.
                <% } else if ("category_deleted".equals(successMsg)) { %>
                    카테고리가 성공적으로 삭제되었습니다.
                <% } %>
            </div>
        <% } %>
        
        <% if (errorMsg != null) { %>
            <div class="alert alert-error" style="background-color: #e50914; color: white; padding: 10px; border-radius: 4px; margin: 10px 0;">
                <% if ("invalid_id".equals(errorMsg)) { %>
                    잘못된 ID입니다.
                <% } else if ("post_not_found".equals(errorMsg)) { %>
                    게시글을 찾을 수 없습니다.
                <% } else if ("comment_not_found".equals(errorMsg)) { %>
                    댓글을 찾을 수 없습니다.
                <% } else if ("category_not_found".equals(errorMsg)) { %>
                    카테고리를 찾을 수 없습니다.
                <% } else if ("category_has_posts".equals(errorMsg)) { %>
                    이 카테고리에는 게시글이 있어 삭제할 수 없습니다.
                <% } else if ("database_error".equals(errorMsg)) { %>
                    데이터베이스 오류가 발생했습니다.
                <% } else { %>
                    예상치 못한 오류가 발생했습니다.
                <% } %>
            </div>
        <% } %>
    </div>
                
                <div class="tabs">
                    <div class="tab active" onclick="openTab('posts')"><i class="fas fa-clipboard-list"></i> 게시글 관리</div>
                    <div class="tab" onclick="openTab('comments')"><i class="fas fa-comments"></i> 댓글 관리</div>
                    <div class="tab" onclick="openTab('categories')"><i class="fas fa-tags"></i> 카테고리 관리</div>
                </div>
                
                <!-- 게시글 관리 탭 -->
                <div id="posts" class="tab-content active">
                    <div class="search-filter">
                        <div class="search-box">
                            <input type="text" id="postSearchInput" placeholder="게시글 제목 또는 작성자로 검색...">
                            <button onclick="searchPosts()"><i class="fas fa-search"></i> 검색</button>
                        </div>
                        <div class="filter-box">
                            <select id="categoryFilter" onchange="filterPosts()">
                                <option value="0">모든 카테고리</option>
                                <%
                                Connection conn = null;
                                PreparedStatement pstmt = null;
                                ResultSet rs = null;
                                
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT * FROM board_category ORDER BY id";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    while(rs.next()) {
                                        int id = rs.getInt("id");
                                        String name = rs.getString("name");
                                %>
                                <option value="<%= id %>"><%= name %></option>
                                <%
                                    }
                                } catch(Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if(rs != null) try { rs.close(); } catch(Exception e) {}
                                    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                                    if(conn != null) try { conn.close(); } catch(Exception e) {}
                                }
                                %>
                            </select>
                        </div>
                    </div>
                    
                    <div class="table-wrapper">
                        <table class="board-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>카테고리</th>
                                    <th>제목</th>
                                    <th>작성자</th>
                                    <th>조회수</th>
                                    <th>작성일</th>
                                    <th>작업</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                conn = null;
                                pstmt = null;
                                rs = null;
                                boolean hasPostData = false;
                                
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT b.*, bc.name as category_name, u.username, u.nickname FROM board b " +
                                                 "JOIN board_category bc ON b.category_id = bc.id " +
                                                 "JOIN user u ON b.user_id = u.id " +
                                                 "ORDER BY b.created_at DESC";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    while(rs.next()) {
                                        hasPostData = true;
                                        int id = rs.getInt("id");
                                        int categoryId = rs.getInt("category_id");
                                        String categoryName = rs.getString("category_name");
                                        String title = rs.getString("title");
                                        String username = rs.getString("username");
                                        String nickname = rs.getString("nickname");
                                        int views = rs.getInt("views");
                                        Timestamp createdAt = rs.getTimestamp("created_at");
                                %>
                                <tr data-category="<%= categoryId %>">
                                    <td><%= id %></td>
                                    <td><%= categoryName %></td>
                                    <td><a href="../../board/view.jsp?id=<%= id %>" target="_blank"><%= title %></a></td>
                                    <td><%= nickname %> (<%= username %>)</td>
                                    <td><%= views %></td>
                                    <td><%= createdAt %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <button class="action-btn delete-btn" onclick="confirmDeletePost(<%= id %>)"><i class="fas fa-trash-alt"></i> 삭제</button>
                                        </div>
                                    </td>
                                </tr>
                                <%
                                    }
                                } catch(Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if(rs != null) try { rs.close(); } catch(Exception e) {}
                                    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                                    if(conn != null) try { conn.close(); } catch(Exception e) {}
                                }
                                
                                if (!hasPostData) {
                                %>
                                <tr>
                                    <td colspan="7" class="no-data">등록된 게시글이 없습니다.</td>
                                </tr>
                                <%
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                    
                    <div class="pagination">
                        <a href="#" class="active">1</a>
                        <a href="#">2</a>
                        <a href="#">3</a>
                        <a href="#">4</a>
                        <a href="#">5</a>
                    </div>
                </div>
                
                <!-- 댓글 관리 탭 -->
                <div id="comments" class="tab-content">
                    <div class="search-filter">
                        <div class="search-box">
                            <input type="text" id="commentSearchInput" placeholder="댓글 내용 또는 작성자로 검색...">
                            <button onclick="searchComments()"><i class="fas fa-search"></i> 검색</button>
                        </div>
                    </div>
                    
                    <div class="table-wrapper">
                        <table class="board-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>게시글</th>
                                    <th>내용</th>
                                    <th>작성자</th>
                                    <th>작성일</th>
                                    <th>작업</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                conn = null;
                                pstmt = null;
                                rs = null;
                                boolean hasCommentData = false;
                                
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT bc.*, b.title as post_title, u.username, u.nickname FROM board_comment bc " +
                                                 "JOIN board b ON bc.board_id = b.id " +
                                                 "JOIN user u ON bc.user_id = u.id " +
                                                 "ORDER BY bc.created_at DESC";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    while(rs.next()) {
                                        hasCommentData = true;
                                        int id = rs.getInt("id");
                                        int boardId = rs.getInt("board_id");
                                        String postTitle = rs.getString("post_title");
                                        String content = rs.getString("content");
                                        if(content.length() > 50) content = content.substring(0, 50) + "...";
                                        String username = rs.getString("username");
                                        String nickname = rs.getString("nickname");
                                        Timestamp createdAt = rs.getTimestamp("created_at");
                                %>
                                <tr>
                                    <td><%= id %></td>
                                    <td><a href="../../board/view.jsp?id=<%= boardId %>" target="_blank"><%= postTitle %></a></td>
                                    <td><%= content %></td>
                                    <td><%= nickname %> (<%= username %>)</td>
                                    <td><%= createdAt %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <button class="action-btn delete-btn" onclick="confirmDeleteComment(<%= id %>)"><i class="fas fa-trash-alt"></i> 삭제</button>
                                        </div>
                                    </td>
                                </tr>
                                <%
                                    }
                                } catch(Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if(rs != null) try { rs.close(); } catch(Exception e) {}
                                    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                                    if(conn != null) try { conn.close(); } catch(Exception e) {}
                                }
                                
                                if (!hasCommentData) {
                                %>
                                <tr>
                                    <td colspan="6" class="no-data">등록된 댓글이 없습니다.</td>
                                </tr>
                                <%
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                    
                    <div class="pagination">
                        <a href="#" class="active">1</a>
                        <a href="#">2</a>
                        <a href="#">3</a>
                        <a href="#">4</a>
                        <a href="#">5</a>
                    </div>
                </div>
                
                <!-- 카테고리 관리 탭 -->
                <div id="categories" class="tab-content">
                    <button class="add-category-btn" onclick="toggleCategoryForm()"><i class="fas fa-plus"></i> 새 카테고리 추가</button>
                    
                    <div id="categoryForm" class="category-form">
                        <form action="add_category.jsp" method="post">
                            <div class="form-group">
                                <label for="categoryName">카테고리 이름</label>
                                <input type="text" id="categoryName" name="categoryName" required>
                            </div>
                            <div class="form-group">
                                <label for="categoryDescription">설명</label>
                                <input type="text" id="categoryDescription" name="categoryDescription">
                            </div>
                            <div class="form-actions">
                                <button type="button" class="cancel-btn" onclick="toggleCategoryForm()"><i class="fas fa-times"></i> 취소</button>
                                <button type="submit" class="save-btn"><i class="fas fa-save"></i> 저장</button>
                            </div>
                        </form>
                    </div>
                    
                    <div class="table-wrapper">
                        <table class="board-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>카테고리 이름</th>
                                    <th>설명</th>
                                    <th>게시글 수</th>
                                    <th>작업</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                conn = null;
                                pstmt = null;
                                rs = null;
                                boolean hasCategoryData = false;
                                
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT bc.*, COUNT(b.id) as post_count FROM board_category bc " +
                                                 "LEFT JOIN board b ON bc.id = b.category_id " +
                                                 "GROUP BY bc.id " +
                                                 "ORDER BY bc.id";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    while(rs.next()) {
                                        hasCategoryData = true;
                                        int id = rs.getInt("id");
                                        String name = rs.getString("name");
                                        String description = rs.getString("description") != null ? rs.getString("description") : "";
                                        int postCount = rs.getInt("post_count");
                                %>
                                <tr>
                                    <td><%= id %></td>
                                    <td><%= name %></td>
                                    <td><%= description %></td>
                                    <td><%= postCount %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <button class="action-btn edit-btn" onclick="editCategory(<%= id %>, '<%= name %>', '<%= description %>')"><i class="fas fa-edit"></i> 수정</button>
                                            <button class="action-btn delete-btn" onclick="confirmDeleteCategory(<%= id %>, <%= postCount %>)"><i class="fas fa-trash-alt"></i> 삭제</button>
                                        </div>
                                    </td>
                                </tr>
                                <%
                                    }
                                } catch(Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if(rs != null) try { rs.close(); } catch(Exception e) {}
                                    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                                    if(conn != null) try { conn.close(); } catch(Exception e) {}
                                }
                                
                                if (!hasCategoryData) {
                                %>
                                <tr>
                                    <td colspan="4" class="no-data">등록된 카테고리가 없습니다.</td>
                                </tr>
                                <%
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <a href="../index.jsp" class="back-link"><i class="fas fa-arrow-left"></i> 관리자 메인으로 돌아가기</a>
            </div>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../../footer.jsp" />
    </div>
    
    <script>
        // 탭 전환 함수
        function openTab(tabName) {
            const tabs = document.getElementsByClassName('tab');
            const tabContents = document.getElementsByClassName('tab-content');
            
            for (let i = 0; i < tabs.length; i++) {
                tabs[i].classList.remove('active');
            }
            
            for (let i = 0; i < tabContents.length; i++) {
                tabContents[i].classList.remove('active');
            }
            
            document.getElementById(tabName).classList.add('active');
            document.querySelector('.tab[onclick="openTab(\'' + tabName + '\')"]').classList.add('active');
        }
        
        // 게시글 검색 함수
        function searchPosts() {
            const input = document.getElementById('postSearchInput').value.toLowerCase();
            const rows = document.querySelectorAll('#posts .board-table tbody tr');
            
            rows.forEach(row => {
                if (row.querySelector('.no-data')) return;
                
                const title = row.cells[2].textContent.toLowerCase();
                const author = row.cells[3].textContent.toLowerCase();
                
                if (title.includes(input) || author.includes(input)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }
        
        // 카테고리별 게시글 필터링 함수
        function filterPosts() {
            const filter = document.getElementById('categoryFilter').value;
            const rows = document.querySelectorAll('#posts .board-table tbody tr');
            
            rows.forEach(row => {
                if (row.querySelector('.no-data')) return;
                
                if (filter === '0' || row.getAttribute('data-category') === filter) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }
        
        // 댓글 검색 함수
        function searchComments() {
            const input = document.getElementById('commentSearchInput').value.toLowerCase();
            const rows = document.querySelectorAll('#comments .board-table tbody tr');
            
            rows.forEach(row => {
                if (row.querySelector('.no-data')) return;
                
                const content = row.cells[2].textContent.toLowerCase();
                const author = row.cells[3].textContent.toLowerCase();
                
                if (content.includes(input) || author.includes(input)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }
        
        // 카테고리 폼 토글 함수
        function toggleCategoryForm() {
            const form = document.getElementById('categoryForm');
            if (form.style.display === 'block') {
                form.style.display = 'none';
            } else {
                form.style.display = 'block';
                document.getElementById('categoryName').focus();
            }
        }
        
        // 카테고리 수정 함수
        function editCategory(id, name, description) {
            document.getElementById('categoryForm').style.display = 'block';
            document.getElementById('categoryName').value = name;
            document.getElementById('categoryDescription').value = description || '';
            
            const form = document.querySelector('#categoryForm form');
            form.action = 'update_category.jsp?id=' + id;
            
            // 폼 제목 변경
            const formTitle = document.createElement('h3');
            formTitle.textContent = '카테고리 수정';
            form.prepend(formTitle);
            
            document.getElementById('categoryName').focus();
        }
        
        // 게시글 삭제 확인
        function confirmDeletePost(id) {
            console.log('삭제할 게시글 ID:', id); // 디버깅용
            if (confirm('정말로 이 게시글을 삭제하시겠습니까?\n관련된 모든 댓글도 함께 삭제됩니다.')) {
                // 로딩 표시
                const button = event.target.closest('button');
                button.disabled = true;
                button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 삭제 중...';

                // ID 검증
                if (!id || isNaN(id) || id <= 0) {
                    alert('유효하지 않은 게시글 ID입니다.');
                    button.disabled = false;
                    button.innerHTML = '<i class="fas fa-trash-alt"></i> 삭제';
                    return;
                }

                window.location.href = 'delete_post.jsp?id=' + encodeURIComponent(id);
            }
        }

        // 댓글 삭제 확인
        function confirmDeleteComment(id) {
            console.log('삭제할 댓글 ID:', id); // 디버깅용
            if (confirm('정말로 이 댓글을 삭제하시겠습니까?')) {
                // 로딩 표시
                const button = event.target.closest('button');
                button.disabled = true;
                button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 삭제 중...';

                // ID 검증
                if (!id || isNaN(id) || id <= 0) {
                    alert('유효하지 않은 댓글 ID입니다.');
                    button.disabled = false;
                    button.innerHTML = '<i class="fas fa-trash-alt"></i> 삭제';
                    return;
                }

                window.location.href = 'delete_comment.jsp?id=' + encodeURIComponent(id);
            }
        }

        // 카테고리 삭제 확인
        function confirmDeleteCategory(id, postCount) {
            console.log('삭제할 카테고리 ID:', id, '게시글 수:', postCount); // 디버깅용
            
            // ID 검증
            if (!id || isNaN(id) || id <= 0) {
                alert('유효하지 않은 카테고리 ID입니다.');
                return;
            }
            
            if (postCount > 0) {
                alert('이 카테고리에는 ' + postCount + '개의 게시글이 있어 삭제할 수 없습니다.\n먼저 게시글을 다른 카테고리로 이동하거나 삭제해주세요.');
                return;
            }
            
            if (confirm('정말로 이 카테고리를 삭제하시겠습니까?')) {
                // 로딩 표시
                const button = event.target.closest('button');
                button.disabled = true;
                button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 삭제 중...';

                window.location.href = 'delete_category.jsp?id=' + encodeURIComponent(id);
            }
        }
        
        // 페이지 로드 시 실행
        document.addEventListener('DOMContentLoaded', function() {
            // 페이지네이션 이벤트
            const paginationLinks = document.querySelectorAll('.pagination a');
            paginationLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    const parentTab = this.closest('.tab-content');
                    const paginationLinks = parentTab.querySelectorAll('.pagination a');
                    paginationLinks.forEach(l => l.classList.remove('active'));
                    this.classList.add('active');
                });
            });
        });
    </script>
</body>
</html>
