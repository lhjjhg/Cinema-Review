<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%@ page import="java.net.URLEncoder" %>
<%
    // URL 파라미터에서 사용자 ID 가져오기 및 유효성 검사
    String userIdParam = request.getParameter("id");
    if (userIdParam == null || userIdParam.trim().isEmpty()) {
        response.sendRedirect("manage-users.jsp?error=invalid_id");
        return;
    }
    
    int userId;
    try {
        userId = Integer.parseInt(userIdParam.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("manage-users.jsp?error=invalid_id");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false); // 트랜잭션 시작
        
        // 사용자 삭제 전에 관련 데이터 삭제 (외래 키 제약조건 때문)
        // 리뷰 삭제
        String deleteReviews = "DELETE FROM review WHERE user_id=?";
        pstmt = conn.prepareStatement(deleteReviews);
        pstmt.setInt(1, userId);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 영화 좋아요 삭제
        String deleteMovieLikes = "DELETE FROM movie_likes WHERE user_id=?";
        pstmt = conn.prepareStatement(deleteMovieLikes);
        pstmt.setInt(1, userId);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 리뷰 좋아요 삭제
        String deleteReviewLikes = "DELETE FROM review_likes WHERE user_id=?";
        pstmt = conn.prepareStatement(deleteReviewLikes);
        pstmt.setInt(1, userId);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 게시글 댓글 삭제
        String deleteBoardComments = "DELETE FROM board_comment WHERE user_id=?";
        pstmt = conn.prepareStatement(deleteBoardComments);
        pstmt.setInt(1, userId);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 게시글 삭제
        String deleteBoards = "DELETE FROM board WHERE user_id=?";
        pstmt = conn.prepareStatement(deleteBoards);
        pstmt.setInt(1, userId);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 예약 정보 삭제 (있는 경우)
        try {
            String deleteBookings = "DELETE FROM booking WHERE user_id=?";
            pstmt = conn.prepareStatement(deleteBookings);
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
            pstmt.close();
        } catch (SQLException e) {
            // 테이블이 없거나 다른 오류 발생 시 무시하고 계속 진행
        }
        
        // 사용자 삭제
        String deleteUser = "DELETE FROM user WHERE id=?";
        pstmt = conn.prepareStatement(deleteUser);
        pstmt.setInt(1, userId);
        
        int result = pstmt.executeUpdate();
        
        if(result > 0) {
            // 삭제 성공, 트랜잭션 커밋
            conn.commit();
            // 세션에 성공 메시지 저장
            session.setAttribute("deleteSuccess", "true");
            session.setAttribute("deleteMessage", "사용자가 성공적으로 삭제되었습니다.");
            response.sendRedirect("manage-users.jsp");
        } else {
            // 삭제 실패, 트랜잭션 롤백
            conn.rollback();
            // 세션에 오류 메시지 저장
            session.setAttribute("deleteError", "true");
            session.setAttribute("deleteMessage", "사용자를 찾을 수 없습니다.");
            response.sendRedirect("manage-users.jsp");
        }
    } catch(Exception e) {
        // 오류 발생, 트랜잭션 롤백
        if(conn != null) {
            try {
                conn.rollback();
            } catch(SQLException ex) {
                ex.printStackTrace();
            }
        }
        e.printStackTrace();
        // 세션에 오류 메시지 저장
        session.setAttribute("deleteError", "true");
        session.setAttribute("deleteMessage", "데이터베이스 오류가 발생했습니다: " + e.getMessage());
        response.sendRedirect("manage-users.jsp");
    } finally {
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(conn != null) {
            try {
                conn.setAutoCommit(true); // 트랜잭션 설정 복원
                conn.close();
            } catch(Exception e) {}
        }
    }
%>
