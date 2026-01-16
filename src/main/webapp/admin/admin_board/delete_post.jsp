<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%
    // 디버깅을 위한 로그
    String idParam = request.getParameter("id");
    System.out.println("받은 ID 파라미터: " + idParam);
    
    // ID 파라미터 검증
    if (idParam == null || idParam.trim().isEmpty()) {
        System.out.println("ID 파라미터가 null이거나 비어있음");
        response.sendRedirect("manage-boards.jsp?tab=posts&error=missing_id");
        return;
    }
    
    int postId = 0;
    try {
        postId = Integer.parseInt(idParam.trim());
        System.out.println("파싱된 ID: " + postId);
        
        if (postId <= 0) {
            System.out.println("ID가 0 이하임: " + postId);
            response.sendRedirect("manage-boards.jsp?tab=posts&error=invalid_id_range");
            return;
        }
    } catch (NumberFormatException e) {
        System.out.println("ID 파싱 실패: " + e.getMessage());
        response.sendRedirect("manage-boards.jsp?tab=posts&error=invalid_id_format&param=" + idParam);
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // 먼저 게시글이 존재하는지 확인
        String checkSql = "SELECT id FROM board WHERE id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        
        if (!rs.next()) {
            System.out.println("게시글을 찾을 수 없음: " + postId);
            response.sendRedirect("manage-boards.jsp?tab=posts&error=post_not_exists&id=" + postId);
            return;
        }
        rs.close();
        pstmt.close();
        
        conn.setAutoCommit(false); // 트랜잭션 시작
        
        // 1. 먼저 게시글 댓글 삭제
        String deleteComments = "DELETE FROM board_comment WHERE board_id = ?";
        pstmt = conn.prepareStatement(deleteComments);
        pstmt.setInt(1, postId);
        int commentResult = pstmt.executeUpdate();
        System.out.println("삭제된 댓글 수: " + commentResult);
        pstmt.close();
        
        // 2. 게시글 삭제
        String deletePost = "DELETE FROM board WHERE id = ?";
        pstmt = conn.prepareStatement(deletePost);
        pstmt.setInt(1, postId);
        int postResult = pstmt.executeUpdate();
        System.out.println("삭제된 게시글 수: " + postResult);
        
        if (postResult > 0) {
            conn.commit(); // 트랜잭션 커밋
            System.out.println("게시글 삭제 성공: " + postId);
            response.sendRedirect("manage-boards.jsp?tab=posts&success=post_deleted&comments=" + commentResult);
        } else {
            conn.rollback(); // 트랜잭션 롤백
            System.out.println("게시글 삭제 실패: " + postId);
            response.sendRedirect("manage-boards.jsp?tab=posts&error=delete_failed");
        }
        
    } catch (SQLException e) {
        if (conn != null) {
            try {
                conn.rollback(); // 트랜잭션 롤백
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        System.out.println("SQL 오류: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("manage-boards.jsp?tab=posts&error=database_error&msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    } catch (Exception e) {
        if (conn != null) {
            try {
                conn.rollback(); // 트랜잭션 롤백
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        System.out.println("예상치 못한 오류: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("manage-boards.jsp?tab=posts&error=unexpected_error");
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
                conn.setAutoCommit(true); // 자동 커밋 복원
                conn.close(); 
            } catch (SQLException e) { 
                e.printStackTrace(); 
            }
        }
    }
%>
