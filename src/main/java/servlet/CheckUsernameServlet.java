package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import DB.DBConnection;

@WebServlet("/CheckUsernameServlet")
public class CheckUsernameServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String username = request.getParameter("username");
        PrintWriter out = response.getWriter();
        
        System.out.println("CheckUsernameServlet 호출됨 - username: " + username); // 디버그용
        
        if (username == null || username.trim().isEmpty()) {
            out.print("{\"available\": false, \"message\": \"아이디를 입력해주세요.\"}");
            return;
        }
        
        // 아이디 형식 검사 (영문, 숫자 조합 4-20자)
        if (!username.matches("^[a-zA-Z0-9]{4,20}$")) {
            out.print("{\"available\": false, \"message\": \"아이디는 영문, 숫자 조합 4-20자로 입력해주세요.\"}");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            System.out.println("데이터베이스 연결 성공"); // 디버그용
            
            // 여러 가능한 테이블명과 컬럼명을 시도
            String[] possibleQueries = {
                "SELECT COUNT(*) FROM user WHERE username = ?",
                "SELECT COUNT(*) FROM users WHERE username = ?",
                "SELECT COUNT(*) FROM user WHERE user_id = ?",
                "SELECT COUNT(*) FROM users WHERE user_id = ?"
            };
            
            boolean querySuccess = false;
            int count = 0;
            
            for (String sql : possibleQueries) {
                try {
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, username);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        count = rs.getInt(1);
                        querySuccess = true;
                        System.out.println("쿼리 성공: " + sql + ", 결과: " + count); // 디버그용
                        break;
                    }
                } catch (SQLException e) {
                    System.out.println("쿼리 실패: " + sql + " - " + e.getMessage()); // 디버그용
                    // 다음 쿼리 시도
                    if (pstmt != null) {
                        try { pstmt.close(); } catch (SQLException ex) {}
                    }
                    if (rs != null) {
                        try { rs.close(); } catch (SQLException ex) {}
                    }
                }
            }
            
            if (!querySuccess) {
                throw new SQLException("모든 쿼리 시도 실패");
            }
            
            if (count > 0) {
                out.print("{\"available\": false, \"message\": \"이미 사용 중인 아이디입니다.\"}");
            } else {
                out.print("{\"available\": true, \"message\": \"사용 가능한 아이디입니다.\"}");
            }
            
        } catch (SQLException e) {
            System.out.println("데이터베이스 오류: " + e.getMessage()); // 디버그용
            e.printStackTrace();
            out.print("{\"available\": false, \"message\": \"데이터베이스 연결 오류가 발생했습니다.\"}");
        } catch (Exception e) {
            System.out.println("일반 오류: " + e.getMessage()); // 디버그용
            e.printStackTrace();
            out.print("{\"available\": false, \"message\": \"서버 오류가 발생했습니다.\"}");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // GET 요청도 처리하도록 추가
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
