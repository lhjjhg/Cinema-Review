<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%
    // 디버깅을 위한 로그
    String idParam = request.getParameter("id");
    System.out.println("받은 댓글 ID 파라미터: " + idParam);
    
    // ID 파라미터 검증
    if (idParam == null || idParam.trim().isEmpty()) {
        System.out.println("댓글 ID 파라미터가 null이거나 비어있음");
        response.sendRedirect("manage-boards.jsp?tab=comments&error=missing_id");
        return;
    }
    
    int commentId = 0;
    try {
        commentId = Integer.parseInt(idParam.trim());
        System.out.println("파싱된 댓글 ID: " + commentId);
        
        if (commentId <= 0) {
            System.out.println("댓글 ID가 0 이하임: " + commentId);
            response.sendRedirect("manage-boards.jsp?tab=comments&error=invalid_id_range");
            return;
        }
    } catch (NumberFormatException e) {
        System.out.println("댓글 ID 파싱 실패: " + e.getMessage());
        response.sendRedirect("manage-boards.jsp?tab=comments&error=invalid_id_format&param=" + idParam);
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // 먼저 댓글이 존재하는지 확인
        String checkSql = "SELECT id FROM board_comment WHERE id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, commentId);
        rs = pstmt.executeQuery();
        
        if (!rs.next()) {
            System.out.println("댓글을 찾을 수 없음: " + commentId);
            response.sendRedirect("manage-boards.jsp?tab=comments&error=comment_not_exists&id=" + commentId);
            return;
        }
        rs.close();
        pstmt.close();
        
        // 댓글 삭제
        String sql = "DELETE FROM board_comment WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, commentId);
        
        int result = pstmt.executeUpdate();
        System.out.println("삭제된 댓글 수: " + result);
        
        if (result > 0) {
            System.out.println("댓글 삭제 성공: " + commentId);
            response.sendRedirect("manage-boards.jsp?tab=comments&success=comment_deleted");
        } else {
            System.out.println("댓글 삭제 실패: " + commentId);
            response.sendRedirect("manage-boards.jsp?tab=comments&error=delete_failed");
        }
        
    } catch (SQLException e) {
        System.out.println("SQL 오류: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("manage-boards.jsp?tab=comments&error=database_error&msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    } catch (Exception e) {
        System.out.println("예상치 못한 오류: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("manage-boards.jsp?tab=comments&error=unexpected_error");
    } finally {
        if (rs != null) {
            try { 
                rs.close(); 
            } catch (SQLException e) { 
                e.printStackTrace(); 
            }
        }
        if (pstmt != null) {
            try { 
                pstmt.close(); 
            } catch (SQLException e) { 
                e.printStackTrace(); 
            }
        }
        if (conn != null) {
            try { 
                conn.close(); 
            } catch (SQLException e) { 
                e.printStackTrace(); 
            }
        }
    }
%>
