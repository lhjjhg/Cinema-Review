<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%
    // 디버깅을 위한 로그
    String idParam = request.getParameter("id");
    System.out.println("받은 카테고리 ID 파라미터: " + idParam);
    
    // ID 파라미터 검증
    if (idParam == null || idParam.trim().isEmpty()) {
        System.out.println("카테고리 ID 파라미터가 null이거나 비어있음");
        response.sendRedirect("manage-boards.jsp?tab=categories&error=missing_id");
        return;
    }
    
    int categoryId = 0;
    try {
        categoryId = Integer.parseInt(idParam.trim());
        System.out.println("파싱된 카테고리 ID: " + categoryId);
        
        if (categoryId <= 0) {
            System.out.println("카테고리 ID가 0 이하임: " + categoryId);
            response.sendRedirect("manage-boards.jsp?tab=categories&error=invalid_id_range");
            return;
        }
    } catch (NumberFormatException e) {
        System.out.println("카테고리 ID 파싱 실패: " + e.getMessage());
        response.sendRedirect("manage-boards.jsp?tab=categories&error=invalid_id_format&param=" + idParam);
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // 먼저 카테고리가 존재하는지 확인
        String checkCategorySql = "SELECT id FROM board_category WHERE id = ?";
        pstmt = conn.prepareStatement(checkCategorySql);
        pstmt.setInt(1, categoryId);
        rs = pstmt.executeQuery();
        
        if (!rs.next()) {
            System.out.println("카테고리를 찾을 수 없음: " + categoryId);
            response.sendRedirect("manage-boards.jsp?tab=categories&error=category_not_exists&id=" + categoryId);
            return;
        }
        rs.close();
        pstmt.close();
        
        // 해당 카테고리에 게시글이 있는지 확인
        String checkSql = "SELECT COUNT(*) as post_count FROM board WHERE category_id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, categoryId);
        rs = pstmt.executeQuery();
        
        int postCount = 0;
        if (rs.next()) {
            postCount = rs.getInt("post_count");
        }
        System.out.println("카테고리 " + categoryId + "의 게시글 수: " + postCount);
        rs.close();
        pstmt.close();
        
        if (postCount > 0) {
            System.out.println("카테고리에 게시글이 있어 삭제 불가: " + categoryId);
            response.sendRedirect("manage-boards.jsp?tab=categories&error=category_has_posts&count=" + postCount);
            return;
        }
        
        // 카테고리 삭제
        String deleteSql = "DELETE FROM board_category WHERE id = ?";
        pstmt = conn.prepareStatement(deleteSql);
        pstmt.setInt(1, categoryId);
        
        int result = pstmt.executeUpdate();
        System.out.println("삭제된 카테고리 수: " + result);
        
        if (result > 0) {
            System.out.println("카테고리 삭제 성공: " + categoryId);
            response.sendRedirect("manage-boards.jsp?tab=categories&success=category_deleted");
        } else {
            System.out.println("카테고리 삭제 실패: " + categoryId);
            response.sendRedirect("manage-boards.jsp?tab=categories&error=delete_failed");
        }
        
    } catch (SQLException e) {
        System.out.println("SQL 오류: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("manage-boards.jsp?tab=categories&error=database_error&msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    } catch (Exception e) {
        System.out.println("예상치 못한 오류: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("manage-boards.jsp?tab=categories&error=unexpected_error");
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
