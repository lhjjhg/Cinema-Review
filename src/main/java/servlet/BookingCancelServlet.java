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

import DB.DBConnection;

@WebServlet("/BookingCancelServlet")
public class BookingCancelServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        // 로그인 상태가 아니면 로그인 페이지로 리다이렉트
        if (userId == null) {
            response.sendRedirect("member/login.jsp?redirect=my-bookings.jsp");
            return;
        }
        
        String bookingId = request.getParameter("id");
        if (bookingId == null || bookingId.isEmpty()) {
            session.setAttribute("errorMessage", "잘못된 예매 정보입니다.");
            response.sendRedirect("my-bookings.jsp");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // 트랜잭션 시작
        
            // 예매 정보 확인 (본인 예매인지 확인)
            String checkSql = "SELECT b.id, b.user_id, b.booking_code " +
                             "FROM booking b " +
                             "WHERE b.id = ? AND b.user_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, Integer.parseInt(bookingId));
            pstmt.setInt(2, userId);
            rs = pstmt.executeQuery();
        
            if (rs.next()) {
                String bookingCode = rs.getString("booking_code");
                rs.close();
                pstmt.close();
            
                // 좌석 예매 정보 삭제
                String deleteSeatsSql = "DELETE FROM booking_seat WHERE booking_id = ?";
                pstmt = conn.prepareStatement(deleteSeatsSql);
                pstmt.setInt(1, Integer.parseInt(bookingId));
                int seatDeleteResult = pstmt.executeUpdate();
                pstmt.close();
            
                // 예매 정보 삭제
                String deleteBookingSql = "DELETE FROM booking WHERE id = ? AND user_id = ?";
                pstmt = conn.prepareStatement(deleteBookingSql);
                pstmt.setInt(1, Integer.parseInt(bookingId));
                pstmt.setInt(2, userId);
                int bookingDeleteResult = pstmt.executeUpdate();
            
                if (bookingDeleteResult > 0) {
                    conn.commit(); // 트랜잭션 커밋
                
                    // 성공 메시지 설정
                    session.setAttribute("successMessage", 
                        "예매번호 " + bookingCode + "의 예매가 성공적으로 취소되었습니다.");
                } else {
                    conn.rollback(); // 롤백
                    session.setAttribute("errorMessage", "예매 취소에 실패했습니다.");
                }
            } else {
                session.setAttribute("errorMessage", "예매 정보를 찾을 수 없습니다.");
            }
        
    } catch (SQLException e) {
        try {
            if (conn != null) {
                conn.rollback(); // 오류 발생 시 롤백
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        
        e.printStackTrace();
        session.setAttribute("errorMessage", "예매 취소 중 오류가 발생했습니다: " + e.getMessage());
    } catch (NumberFormatException e) {
        session.setAttribute("errorMessage", "잘못된 예매 ID입니다.");
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) {
                conn.setAutoCommit(true); // 자동 커밋 복원
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // 예매 내역 페이지로 리다이렉트
    response.sendRedirect("member/my-bookings.jsp");
}
}
