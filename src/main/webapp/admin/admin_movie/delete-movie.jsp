<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%
    String movieId = request.getParameter("id");
    
    if (movieId != null && !movieId.isEmpty()) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // 영화 스틸컷 삭제
            pstmt = conn.prepareStatement("DELETE FROM movie_stillcut WHERE movie_id = ?");
            pstmt.setString(1, movieId);
            pstmt.executeUpdate();
            
            // 영화 상세 정보 삭제
            pstmt = conn.prepareStatement("DELETE FROM movie_detail WHERE movie_id = ?");
            pstmt.setString(1, movieId);
            pstmt.executeUpdate();
            
            // 영화 정보 삭제
            pstmt = conn.prepareStatement("DELETE FROM movie WHERE movie_id = ?");
            pstmt.setString(1, movieId);
            pstmt.executeUpdate();
            
            // 관리 페이지로 리다이렉트
            response.sendRedirect("manage-movies.jsp?deleted=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage-movies.jsp?error=" + e.getMessage());
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        response.sendRedirect("manage-movies.jsp?error=Invalid movie ID");
    }
%>
