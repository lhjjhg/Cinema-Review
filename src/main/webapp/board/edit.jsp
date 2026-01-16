<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="DB.DBConnection" %>
<%@ page import="dto.BoardCategory" %>
<%@ page import="dto.Board" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시글 수정 - CinemaWorld</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/board.css">
</head>
<body>
    <jsp:include page="../header.jsp" />
    
    <div class="container">
        <h1>게시글 수정</h1>
        
        <%
            // 로그인 확인
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                response.sendRedirect(request.getContextPath() + "/member/login.jsp");
                return;
            }
            
            // 게시글 ID 파라미터
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/board/list.jsp");
                return;
            }
            
            int boardId;
            try {
                boardId = Integer.parseInt(idParam);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/board/list.jsp");
                return;
            }
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DBConnection.getConnection();
                
                // 게시글 정보 가져오기
                String sql = "SELECT * FROM board WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, boardId);
                rs = pstmt.executeQuery();
                
                if (!rs.next()) {
                    response.sendRedirect(request.getContextPath() + "/board/list.jsp");
                    return;
                }
                
                Board board = new Board();
                board.setId(rs.getInt("id"));
                board.setCategoryId(rs.getInt("category_id"));
                board.setUserId(rs.getInt("user_id"));
                board.setTitle(rs.getString("title"));
                board.setContent(rs.getString("content"));
                board.setViews(rs.getInt("views"));
                board.setNotice(rs.getBoolean("is_notice"));
                
                // 작성자만 수정 가능
                if (userId != board.getUserId()) {
                    response.sendRedirect(request.getContextPath() + "/board/view.jsp?id=" + boardId);
                    return;
                }
                
                rs.close();
                pstmt.close();

                // 관리자 여부 확인 (기존 방식 사용)
                Boolean isAdminObj = (Boolean) session.getAttribute("isAdmin");
                boolean isAdmin = isAdminObj != null && isAdminObj.booleanValue();
                
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
                    categories.add(category);
                }
        %>
        
        <form action="edit_process.jsp" method="post" class="board-form">
            <input type="hidden" name="id" value="<%= board.getId() %>">
            
            <div class="form-group">
                <label for="category">카테고리</label>
                <select name="categoryId" id="category" required>
                    <% for (BoardCategory category : categories) { %>
                        <option value="<%= category.getId() %>" <%= category.getId() == board.getCategoryId() ? "selected" : "" %>>
                            <%= category.getName() %>
                        </option>
                    <% } %>
                </select>
            </div>
            
            <div class="form-group">
                <label for="title">제목</label>
                <input type="text" name="title" id="title" value="<%= board.getTitle() %>" required>
            </div>
            
            <div class="form-group">
                <label for="content">내용</label>
                <textarea name="content" id="content" rows="15" required><%= board.getContent() %></textarea>
            </div>
            
            <% if (isAdmin) { %>
                <div class="form-group checkbox-group">
                    <input type="checkbox" name="isNotice" id="isNotice" value="true" <%= board.isNotice() ? "checked" : "" %>>
                    <label for="isNotice">공지사항으로 등록</label>
                </div>
            <% } %>
            
            <div class="form-actions">
                <a href="view.jsp?id=<%= board.getId() %>" class="btn-cancel">취소</a>
                <button type="submit" class="btn-submit">수정</button>
            </div>
        </form>
        
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
