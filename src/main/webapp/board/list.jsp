<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="DB.DBConnection" %>
<%@ page import="dto.Board" %>
<%@ page import="dto.BoardCategory" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시판 - CinemaWorld</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/board.css">
</head>
<body>
    <jsp:include page="../header.jsp" />
    
    <div class="container">
        <h1>게시판</h1>
        
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DBConnection.getConnection();
                
                // 카테고리 목록 가져오기
                String categorySql = "SELECT * FROM board_category ORDER BY id";
                pstmt = conn.prepareStatement(categorySql);
                rs = pstmt.executeQuery();
                
                List<BoardCategory> categories = new ArrayList<>();
                while (rs.next()) {
                    BoardCategory category = new BoardCategory();
                    category.setId(rs.getInt("id"));
                    category.setName(rs.getString("name"));
                    category.setDescription(rs.getString("description"));
                    category.setCreatedAt(rs.getTimestamp("created_at"));
                    categories.add(category);
                }
                
                rs.close();
                pstmt.close();
                
                // 현재 페이지 및 카테고리 파라미터 처리
                int currentPage = 1;
                String pageParam = request.getParameter("page");
                if (pageParam != null && !pageParam.isEmpty()) {
                    try {
                        currentPage = Integer.parseInt(pageParam);
                        if (currentPage < 1) currentPage = 1;
                    } catch (NumberFormatException e) {
                        // 무시
                    }
                }
                
                int categoryId = 0;
                String categoryParam = request.getParameter("category");
                if (categoryParam != null && !categoryParam.isEmpty()) {
                    try {
                        categoryId = Integer.parseInt(categoryParam);
                    } catch (NumberFormatException e) {
                        // 무시
                    }
                }
                
                // 검색 파라미터 처리
                String searchType = request.getParameter("searchType");
                String searchKeyword = request.getParameter("searchKeyword");
                
                // 페이지네이션 설정
                int recordsPerPage = 10;
                int start = (currentPage - 1) * recordsPerPage;
                
                // 게시글 총 개수 구하기
                StringBuilder countSql = new StringBuilder();
                countSql.append("SELECT COUNT(*) AS total FROM board b ");
                countSql.append("LEFT JOIN user u ON b.user_id = u.id ");
                
                List<Object> countParams = new ArrayList<>();
                
                if (categoryId > 0) {
                    countSql.append("WHERE b.category_id = ? ");
                    countParams.add(categoryId);
                }
                
                if (searchKeyword != null && !searchKeyword.isEmpty()) {
                    if (countParams.isEmpty()) {
                        countSql.append("WHERE ");
                    } else {
                        countSql.append("AND ");
                    }
                    
                    if ("title".equals(searchType)) {
                        countSql.append("b.title LIKE ? ");
                        countParams.add("%" + searchKeyword + "%");
                    } else if ("content".equals(searchType)) {
                        countSql.append("b.content LIKE ? ");
                        countParams.add("%" + searchKeyword + "%");
                    } else if ("writer".equals(searchType)) {
                        countSql.append("(u.username LIKE ? OR u.nickname LIKE ?) ");
                        countParams.add("%" + searchKeyword + "%");
                        countParams.add("%" + searchKeyword + "%");
                    } else {
                        countSql.append("(b.title LIKE ? OR b.content LIKE ?) ");
                        countParams.add("%" + searchKeyword + "%");
                        countParams.add("%" + searchKeyword + "%");
                    }
                }
                
                pstmt = conn.prepareStatement(countSql.toString());
                for (int i = 0; i < countParams.size(); i++) {
                    pstmt.setObject(i + 1, countParams.get(i));
                }
                
                rs = pstmt.executeQuery();
                int totalRecords = 0;
                if (rs.next()) {
                    totalRecords = rs.getInt("total");
                }
                
                int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
                
                rs.close();
                pstmt.close();
                
                // 게시글 목록 가져오기
                StringBuilder sql = new StringBuilder();
                sql.append("SELECT b.*, u.username, u.nickname, ");
                sql.append("(SELECT COUNT(*) FROM board_comment WHERE board_id = b.id) AS comment_count, ");
                sql.append("c.name AS category_name ");
                sql.append("FROM board b ");
                sql.append("LEFT JOIN user u ON b.user_id = u.id ");
                sql.append("LEFT JOIN board_category c ON b.category_id = c.id ");
                
                List<Object> params = new ArrayList<>();
                
                if (categoryId > 0) {
                    sql.append("WHERE b.category_id = ? ");
                    params.add(categoryId);
                }
                
                if (searchKeyword != null && !searchKeyword.isEmpty()) {
                    if (params.isEmpty()) {
                        sql.append("WHERE ");
                    } else {
                        sql.append("AND ");
                    }
                    
                    if ("title".equals(searchType)) {
                        sql.append("b.title LIKE ? ");
                        params.add("%" + searchKeyword + "%");
                    } else if ("content".equals(searchType)) {
                        sql.append("b.content LIKE ? ");
                        params.add("%" + searchKeyword + "%");
                    } else if ("writer".equals(searchType)) {
                        sql.append("(u.username LIKE ? OR u.nickname LIKE ?) ");
                        params.add("%" + searchKeyword + "%");
                        params.add("%" + searchKeyword + "%");
                    } else {
                        sql.append("(b.title LIKE ? OR b.content LIKE ?) ");
                        params.add("%" + searchKeyword + "%");
                        params.add("%" + searchKeyword + "%");
                    }
                }
                
                sql.append("ORDER BY b.is_notice DESC, b.id DESC ");
                sql.append("LIMIT ?, ?");
                params.add(start);
                params.add(recordsPerPage);
                
                pstmt = conn.prepareStatement(sql.toString());
                for (int i = 0; i < params.size(); i++) {
                    pstmt.setObject(i + 1, params.get(i));
                }
                
                rs = pstmt.executeQuery();
                
                List<Board> boardList = new ArrayList<>();
                while (rs.next()) {
                    Board board = new Board();
                    board.setId(rs.getInt("id"));
                    board.setCategoryId(rs.getInt("category_id"));
                    board.setUserId(rs.getInt("user_id"));
                    board.setTitle(rs.getString("title"));
                    board.setContent(rs.getString("content"));
                    board.setViews(rs.getInt("views"));
                    board.setNotice(rs.getBoolean("is_notice"));
                    board.setCreatedAt(rs.getTimestamp("created_at"));
                    board.setUpdatedAt(rs.getTimestamp("updated_at"));
                    
                    // 사용자 정보
                    String username = rs.getString("username");
                    String nickname = rs.getString("nickname");
                    board.setUsername(username);
                    board.setNickname(nickname);
                    
                    // 카테고리 이름
                    board.setCategoryName(rs.getString("category_name"));
                    
                    // 댓글 수
                    board.setCommentCount(rs.getInt("comment_count"));
                    
                    boardList.add(board);
                }
        %>
        
        <!-- 카테고리 탭 -->
        <div class="category-tabs">
            <a href="list.jsp" class="<%= categoryId == 0 ? "active" : "" %>">전체</a>
            <% for (BoardCategory category : categories) { %>
                <a href="list.jsp?category=<%= category.getId() %>" class="<%= categoryId == category.getId() ? "active" : "" %>">
                    <%= category.getName() %>
                </a>
            <% } %>
        </div>
        
        <!-- 검색 폼 -->
        <div class="search-form">
            <form action="list.jsp" method="get">
                <% if (categoryId > 0) { %>
                    <input type="hidden" name="category" value="<%= categoryId %>">
                <% } %>
                <select name="searchType">
                    <option value="all" <%= "all".equals(searchType) ? "selected" : "" %>>전체</option>
                    <option value="title" <%= "title".equals(searchType) ? "selected" : "" %>>제목</option>
                    <option value="content" <%= "content".equals(searchType) ? "selected" : "" %>>내용</option>
                    <option value="writer" <%= "writer".equals(searchType) ? "selected" : "" %>>작성자</option>
                </select>
                <input type="text" name="searchKeyword" value="<%= searchKeyword != null ? searchKeyword : "" %>" placeholder="검색어를 입력하세요">
                <button type="submit">검색</button>
            </form>
        </div>
        
        <!-- 게시글 목록 -->
        <table class="board-table">
            <thead>
                <tr>
                    <th width="10%">번호</th>
                    <th width="15%">카테고리</th>
                    <th width="40%">제목</th>
                    <th width="15%">작성자</th>
                    <th width="10%">조회수</th>
                    <th width="10%">작성일</th>
                </tr>
            </thead>
            <tbody>
                <% if (boardList.isEmpty()) { %>
                    <tr>
                        <td colspan="6" class="no-data">게시글이 없습니다.</td>
                    </tr>
                <% } else { %>
                    <% for (Board board : boardList) { %>
                        <tr class="<%= board.isNotice() ? "notice" : "" %>">
                            <td><%= board.isNotice() ? "공지" : board.getId() %></td>
                            <td><%= board.getCategoryName() %></td>
                            <td class="title">
                                <a href="view.jsp?id=<%= board.getId() %>">
                                    <%= board.getTitle() %>
                                    <% if (board.getCommentCount() > 0) { %>
                                        <span class="comment-count">[<%= board.getCommentCount() %>]</span>
                                    <% } %>
                                </a>
                            </td>
                            <td>
                                <% if (board.getNickname() != null && !board.getNickname().isEmpty()) { %>
                                    <%= board.getNickname() %>
                                <% } else { %>
                                    <%= board.getUsername() %>
                                <% } %>
                            </td>
                            <td><%= board.getViews() %></td>
                            <td><%= new SimpleDateFormat("yyyy-MM-dd").format(board.getCreatedAt()) %></td>
                        </tr>
                    <% } %>
                <% } %>
            </tbody>
        </table>
        
        <!-- 페이지네이션 -->
        <div class="pagination">
            <% if (currentPage > 1) { %>
                <a href="list.jsp?page=1<%= categoryId > 0 ? "&category=" + categoryId : "" %><%= searchKeyword != null && !searchKeyword.isEmpty() ? "&searchType=" + searchType + "&searchKeyword=" + searchKeyword : "" %>">&laquo;</a>
                <a href="list.jsp?page=<%= currentPage - 1 %><%= categoryId > 0 ? "&category=" + categoryId : "" %><%= searchKeyword != null && !searchKeyword.isEmpty() ? "&searchType=" + searchType + "&searchKeyword=" + searchKeyword : "" %>">&lt;</a>
            <% } %>
            
            <% 
                int startPage = Math.max(1, currentPage - 4);
                int endPage = Math.min(totalPages, startPage + 9);
                
                for (int i = startPage; i <= endPage; i++) { 
            %>
                <a href="list.jsp?page=<%= i %><%= categoryId > 0 ? "&category=" + categoryId : "" %><%= searchKeyword != null && !searchKeyword.isEmpty() ? "&searchType=" + searchType + "&searchKeyword=" + searchKeyword : "" %>" 
                   class="<%= i == currentPage ? "active" : "" %>"><%= i %></a>
            <% } %>
            
            <% if (currentPage < totalPages) { %>
                <a href="list.jsp?page=<%= currentPage + 1 %><%= categoryId > 0 ? "&category=" + categoryId : "" %><%= searchKeyword != null && !searchKeyword.isEmpty() ? "&searchType=" + searchType + "&searchKeyword=" + searchKeyword : "" %>">&gt;</a>
                <a href="list.jsp?page=<%= totalPages %><%= categoryId > 0 ? "&category=" + categoryId : "" %><%= searchKeyword != null && !searchKeyword.isEmpty() ? "&searchType=" + searchType + "&searchKeyword=" + searchKeyword : "" %>">&raquo;</a>
            <% } %>
        </div>
        
        <!-- 글쓰기 버튼 -->
        <div class="button-container">
            <% if (session.getAttribute("userId") != null) { %>
                <% 
                    // 공지사항 카테고리 체크
                    boolean isNoticeCategory = false;
                    String userRole = (String) session.getAttribute("userRole");
                    boolean isAdmin = (userRole != null && userRole.equals("ADMIN"));
                    
                    // 현재 카테고리가 공지사항인지 확인
                    if (categoryId > 0) {
                        for (BoardCategory category : categories) {
                            if (category.getId() == categoryId && "공지사항".equals(category.getName())) {
                                isNoticeCategory = true;
                                break;
                            }
                        }
                    }
                    
                    // 공지사항 카테고리가 아니거나, 공지사항 카테고리이지만 관리자인 경우에만 글쓰기 버튼 표시
                    if (!isNoticeCategory || isAdmin) {
                %>
                    <a href="write.jsp<%= categoryId > 0 ? "?category=" + categoryId : "" %>" class="write-button">글쓰기</a>
                <% } %>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/member/login.jsp" class="write-button">로그인 후 글쓰기</a>
            <% } %>
        </div>
        
        <%
            } catch (Exception e) {
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
    </div>
    
    <jsp:include page="../footer.jsp" />
    <script src="${pageContext.request.contextPath}/js/board.js"></script>
</body>
</html>
