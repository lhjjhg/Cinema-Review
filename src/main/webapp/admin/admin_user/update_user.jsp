<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%
    // 폼에서 전송된 데이터 가져오기
    int userId = Integer.parseInt(request.getParameter("userId"));
    String nickname = request.getParameter("nickname");
    String name = request.getParameter("name");
    String address = request.getParameter("address");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        conn = DBConnection.getConnection();
        String sql = "UPDATE user SET nickname=?, name=?, address=? WHERE id=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, nickname);
        pstmt.setString(2, name);
        pstmt.setString(3, address);
        pstmt.setInt(4, userId);
        
        int result = pstmt.executeUpdate();
        
        if(result > 0) {
            // 업데이트 성공
            response.sendRedirect("manage-users.jsp?success=true");
        } else {
            // 업데이트 실패
            response.sendRedirect("manage-users.jsp?error=update");
        }
    } catch(Exception e) {
        e.printStackTrace();
        response.sendRedirect("manage-users.jsp?error=exception&message=" + e.getMessage());
    } finally {
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>
