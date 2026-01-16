<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%@ page import="java.net.URLEncoder" %>
<%
    // URL 파라미터에서 리뷰 ID 가져오기 및 유효성 검사
    String reviewIdParam = request.getParameter("id");
    if (reviewIdParam == null || reviewIdParam.trim().isEmpty()) {
        response.sendRedirect("manage-reviews.jsp?error=delete&message=" + URLEncoder.encode("리뷰 ID가 유효하지 않습니다.", "UTF-8"));
        return;
    }
    
    int reviewId;
    try {
        reviewId = Integer.parseInt(reviewIdParam.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("manage-reviews.jsp?error=delete&message=" + URLEncoder.encode("리뷰 ID가 유효하지 않습니다.", "UTF-8"));
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // 먼저 영화 ID와 사용자 ID 가져오기 (영화 평점 업데이트용)
        String selectSql = "SELECT movie_id, user_id FROM review WHERE id = ?";
        pstmt = conn.prepareStatement(selectSql);
        pstmt.setInt(1, reviewId);
        rs = pstmt.executeQuery();
        
        String movieId = null;
        int userId = 0;
        
        if (rs.next()) {
            movieId = rs.getString("movie_id");
            userId = rs.getInt("user_id");
        } else {
            response.sendRedirect("manage-reviews.jsp?error=delete&message=" + URLEncoder.encode("리뷰를 찾을 수 없습니다.", "UTF-8"));
            return;
        }
        
        // 리뷰 좋아요 먼저 삭제 (외래 키 제약조건 때문)
        String deleteLikesSql = "DELETE FROM review_likes WHERE review_id = ?";
        pstmt = conn.prepareStatement(deleteLikesSql);
        pstmt.setInt(1, reviewId);
        pstmt.executeUpdate();
        
        // 리뷰 삭제
        String deleteSql = "DELETE FROM review WHERE id = ?";
        pstmt = conn.prepareStatement(deleteSql);
        pstmt.setInt(1, reviewId);
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            // 영화 평점 업데이트
            if (movieId != null) {
                String avgSql = "SELECT AVG(rating) as avg_rating FROM review WHERE movie_id = ?";
                pstmt = conn.prepareStatement(avgSql);
                pstmt.setString(1, movieId);
                rs = pstmt.executeQuery();
                
                double avgRating = 0.0;
                if (rs.next()) {
                    avgRating = rs.getDouble("avg_rating");
                }
                
                String updateSql = "UPDATE movie SET rating = ? WHERE movie_id = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setDouble(1, avgRating);
                pstmt.setString(2, movieId);
                pstmt.executeUpdate();
            }
            
            response.sendRedirect("manage-reviews.jsp?success=true&message=" + URLEncoder.encode("리뷰가 성공적으로 삭제되었습니다.", "UTF-8"));
        } else {
            response.sendRedirect("manage-reviews.jsp?error=delete&message=" + URLEncoder.encode("리뷰 삭제에 실패했습니다.", "UTF-8"));
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("manage-reviews.jsp?error=delete&message=" + URLEncoder.encode("오류가 발생했습니다: " + e.getMessage(), "UTF-8"));
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
