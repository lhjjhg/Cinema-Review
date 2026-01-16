<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/member/login.jsp");
        return;
    }
    
    String userRole = (String) session.getAttribute("userRole");
    boolean isAdmin = "ADMIN".equals(userRole);
    
    String categoryIdStr = request.getParameter("category");
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String noticeStr = request.getParameter("notice");
    
    // 공지사항 설정 - 관리자만 가능
    boolean isNotice = false;
    if (isAdmin && "1".equals(noticeStr)) {
        isNotice = true;
    }
    
    if (categoryIdStr == null || title == null || content == null || 
        categoryIdStr.trim().isEmpty() || title.trim().isEmpty() || content.trim().isEmpty()) {
        response.sendRedirect("write.jsp?error=missing_fields");
        return;
    }
    
    int categoryId;
    try {
        categoryId = Integer.parseInt(categoryIdStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("write.jsp?error=invalid_category");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // 일반 사용자가 공지사항 카테고리에 글을 작성하려고 하는지 확인
        if (!isAdmin) {
            String checkCategorySql = "SELECT name FROM board_category WHERE id = ?";
            PreparedStatement checkPstmt = conn.prepareStatement(checkCategorySql);
            checkPstmt.setInt(1, categoryId);
            ResultSet checkRs = checkPstmt.executeQuery();
            
            if (checkRs.next() && "공지사항".equals(checkRs.getString("name"))) {
                // 일반 사용자가 공지사항 카테고리에 글을 작성하려고 하면 차단
                response.sendRedirect("write.jsp?error=no_permission");
                return;
            }
            checkRs.close();
            checkPstmt.close();
        }
        
        String sql = "INSERT INTO board (category_id, user_id, title, content, is_notice, created_at) VALUES (?, ?, ?, ?, ?, NOW())";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, categoryId);
        pstmt.setInt(2, userId);
        pstmt.setString(3, title);
        pstmt.setString(4, content);
        pstmt.setBoolean(5, isNotice);
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            response.sendRedirect("list.jsp?category=" + categoryId + "&success=write");
        } else {
            response.sendRedirect("write.jsp?error=write_failed");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("write.jsp?error=database_error");
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
