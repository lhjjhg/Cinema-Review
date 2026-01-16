<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%
    // 로그인 확인
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/member/login.jsp");
        return;
    }
    
    // 관리자 권한 확인 (기존 방식 사용)
    Boolean isAdminObj = (Boolean) session.getAttribute("isAdmin");
    boolean isAdmin = isAdminObj != null && isAdminObj.booleanValue();
    
    // 파라미터 받기
    String idStr = request.getParameter("id");
    String categoryIdStr = request.getParameter("categoryId");
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String isNoticeStr = request.getParameter("isNotice");
    
    if (idStr == null || categoryIdStr == null || title == null || content == null) {
        response.sendRedirect("list.jsp?error=missing_fields");
        return;
    }
    
    int boardId, categoryId;
    try {
        boardId = Integer.parseInt(idStr);
        categoryId = Integer.parseInt(categoryIdStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("list.jsp?error=invalid_parameters");
        return;
    }
    
    // 공지사항 설정 - 관리자만 가능
    boolean isNotice = false;
    if (isAdmin && "true".equals(isNoticeStr)) {
        isNotice = true;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // 게시글 작성자 확인
        String checkSql = "SELECT user_id FROM board WHERE id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, boardId);
        rs = pstmt.executeQuery();
        
        if (!rs.next()) {
            response.sendRedirect("list.jsp?error=post_not_found");
            return;
        }
        
        int postUserId = rs.getInt("user_id");
        
        // 작성자 본인이거나 관리자만 수정 가능
        if (userId != postUserId && !isAdmin) {
            response.sendRedirect("view.jsp?id=" + boardId + "&error=no_permission");
            return;
        }
        
        rs.close();
        pstmt.close();
        
        // 게시글 업데이트
        String updateSql = "UPDATE board SET category_id = ?, title = ?, content = ?, is_notice = ?, updated_at = NOW() WHERE id = ?";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setInt(1, categoryId);
        pstmt.setString(2, title);
        pstmt.setString(3, content);
        pstmt.setBoolean(4, isNotice);
        pstmt.setInt(5, boardId);
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            response.sendRedirect("view.jsp?id=" + boardId + "&success=edit");
        } else {
            response.sendRedirect("edit.jsp?id=" + boardId + "&error=edit_failed");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("edit.jsp?id=" + boardId + "&error=database_error");
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
