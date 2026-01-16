<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%@ page import="java.net.URLEncoder" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 폼에서 전송된 데이터 가져오기
    String userIdParam = request.getParameter("userId");
    String reviewIdParam = request.getParameter("reviewId");
    String warningMessage = request.getParameter("warningMessage");
    
    // 유효성 검사
    if (userIdParam == null || userIdParam.trim().isEmpty() || 
        warningMessage == null || warningMessage.trim().isEmpty()) {
        response.sendRedirect("manage-reviews.jsp?error=warning&message=" + URLEncoder.encode("필수 정보가 누락되었습니다.", "UTF-8"));
        return;
    }
    
    int userId;
    int reviewId = 0;
    
    try {
        userId = Integer.parseInt(userIdParam.trim());
        if (reviewIdParam != null && !reviewIdParam.trim().isEmpty()) {
            reviewId = Integer.parseInt(reviewIdParam.trim());
        }
    } catch (NumberFormatException e) {
        response.sendRedirect("manage-reviews.jsp?error=warning&message=" + URLEncoder.encode("ID 형식이 올바르지 않습니다.", "UTF-8"));
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String username = "";
    
    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false); // 트랜잭션 시작
        
        // 먼저 사용자 이름 가져오기
        String userSql = "SELECT username FROM user WHERE id = ?";
        pstmt = conn.prepareStatement(userSql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            username = rs.getString("username");
        } else {
            conn.rollback();
            response.sendRedirect("manage-reviews.jsp?error=warning&message=" + URLEncoder.encode("사용자를 찾을 수 없습니다.", "UTF-8"));
            return;
        }
        
        // 리소스 정리
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        
        // 사용자 경고 카운트 증가
        String updateSql = "UPDATE user SET warning_count = warning_count + 1 WHERE id = ?";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setInt(1, userId);
        int updateResult = pstmt.executeUpdate();
        
        if (updateResult <= 0) {
            conn.rollback();
            response.sendRedirect("manage-reviews.jsp?error=warning&message=" + URLEncoder.encode("사용자 경고 카운트 업데이트에 실패했습니다.", "UTF-8"));
            return;
        }
        
        // 경고 메시지에 사용자 이름 추가
        String fullWarningMessage = username + "님께, " + warningMessage;
        
        // 트랜잭션 커밋
        conn.commit();
        
        // 성공 메시지와 함께 리다이렉트
        response.sendRedirect("manage-reviews.jsp?success=true&message=" + URLEncoder.encode(username + "님에게 경고가 성공적으로 발송되었습니다.", "UTF-8"));
        
    } catch (Exception e) {
        // 오류 발생 시 롤백
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        e.printStackTrace();
        response.sendRedirect("manage-reviews.jsp?error=warning&message=" + URLEncoder.encode("오류가 발생했습니다: " + e.getMessage(), "UTF-8"));
    } finally {
        // 리소스 정리
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) {
            try {
                conn.setAutoCommit(true); // 트랜잭션 설정 복원
                conn.close();
            } catch (Exception e) {}
        }
    }
%>
