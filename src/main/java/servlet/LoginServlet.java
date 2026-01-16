package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;

import DB.DBConnection;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM user WHERE username = ? AND password = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password); 
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                // 로그인 성공
                HttpSession session = request.getSession();
                int userId = rs.getInt("id");
                session.setAttribute("username", username);
                session.setAttribute("userId", userId);
                session.setAttribute("nickname", rs.getString("nickname"));
                session.setAttribute("userRole", rs.getString("role")); 
                
                // 경고 알림 확인 
                int warningCount = rs.getInt("warning_count");
                System.out.println("Debug - User ID: " + userId + ", Warning Count: " + warningCount);
                
                // 쿠키에서 마지막으로 확인한 경고 횟수 가져오기
                Cookie[] cookies = request.getCookies();
                int lastCheckedWarningCount = 0;
                String cookieName = "warningChecked_" + userId;
                
                if (cookies != null) {
                    for (Cookie cookie : cookies) {
                        if (cookieName.equals(cookie.getName())) {
                            try {
                                lastCheckedWarningCount = Integer.parseInt(cookie.getValue());
                                System.out.println("Debug - Found cookie: " + cookieName + " = " + lastCheckedWarningCount);
                            } catch (NumberFormatException e) {
                                lastCheckedWarningCount = 0;
                                System.out.println("Debug - Cookie value parse error, setting to 0");
                            }
                            break;
                        }
                    }
                } else {
                    System.out.println("Debug - No cookies found");
                }
                
                System.out.println("Debug - Last checked: " + lastCheckedWarningCount + ", Current: " + warningCount);
                
                // 새로운 경고가 있는 경우 알림 표시
                if (warningCount > lastCheckedWarningCount) {
                    session.setAttribute("showWarningAlert", true);
                    session.setAttribute("warningCount", warningCount);
                    session.setAttribute("newWarningCount", warningCount - lastCheckedWarningCount);
                    System.out.println("Debug - Setting warning alert: true, New warnings: " + (warningCount - lastCheckedWarningCount));
                } else {
                    System.out.println("Debug - No new warnings to show");
                }
                
                // 로그인 상태 유지 처리
                if (remember != null) {
                    session.setMaxInactiveInterval(30 * 24 * 60 * 60);
                    
                    // 아이디 저장을 위한 쿠키 생성
                    Cookie usernameCookie = new Cookie("savedUsername", username);
                    usernameCookie.setMaxAge(30 * 24 * 60 * 60); 
                    usernameCookie.setPath("/");
                    response.addCookie(usernameCookie);
                } else {
                    // 아이디 저장을 해제한 경우 기존 쿠키 삭제
                    Cookie usernameCookie = new Cookie("savedUsername", "");
                    usernameCookie.setMaxAge(0); 
                    usernameCookie.setPath("/");
                    response.addCookie(usernameCookie);
                }
                
                // 메인 페이지로 리다이렉트 (Profile.jsp 대신 index.jsp로 변경)
                response.sendRedirect("index.jsp");
            } else {
                // 로그인 실패 - redirect 사용
                response.sendRedirect("member/login.jsp?error=login_failed");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            // 데이터베이스 오류 - redirect 사용
            response.sendRedirect("member/login.jsp?error=db_error");
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
}
