<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%
    // 응답 타입을 JSON으로 설정
    response.setContentType("application/json");
    
    String userIdParam = request.getParameter("id");
    if (userIdParam == null || userIdParam.trim().isEmpty()) {
        out.print("{\"error\": \"사용자 ID가 제공되지 않았습니다.\"}");
        return;
    }
    
    int userId;
    try {
        userId = Integer.parseInt(userIdParam);
    } catch (NumberFormatException e) {
        out.print("{\"error\": \"잘못된 사용자 ID 형식입니다.\"}");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT * FROM user WHERE id=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        
        if(rs.next()) {
            String username = rs.getString("username") != null ? rs.getString("username") : "";
            String nickname = rs.getString("nickname") != null ? rs.getString("nickname") : "";
            String name = rs.getString("name") != null ? rs.getString("name") : "";
            String address = rs.getString("address") != null ? rs.getString("address") : "";
            String birthdate = rs.getString("birthdate") != null ? rs.getString("birthdate") : "";
            
            // JSON 문자열 수동 생성
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"id\": ").append(userId).append(",");
            json.append("\"username\": \"").append(username.replace("\"", "\\\"")).append("\",");
            json.append("\"nickname\": \"").append(nickname.replace("\"", "\\\"")).append("\",");
            json.append("\"name\": \"").append(name.replace("\"", "\\\"")).append("\",");
            json.append("\"address\": \"").append(address.replace("\"", "\\\"")).append("\",");
            json.append("\"birthdate\": \"").append(birthdate.replace("\"", "\\\"")).append("\"");
            json.append("}");
            
            out.print(json.toString());
        } else {
            out.print("{\"error\": \"사용자를 찾을 수 없습니다.\"}");
        }
        
    } catch(Exception e) {
        e.printStackTrace();
        out.print("{\"error\": \"데이터베이스 오류가 발생했습니다.\"}");
    } finally {
        if(rs != null) try { rs.close(); } catch(Exception e) {}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>
