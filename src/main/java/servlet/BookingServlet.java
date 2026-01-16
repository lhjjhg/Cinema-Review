package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.simple.JSONObject;

import DB.DBConnection;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        // 로그인 상태가 아니면 로그인 페이지로 리다이렉트
        if (userId == null) {
            response.sendRedirect("member/login.jsp?redirect=booking/seat-selection.jsp");
            return;
        }
        
        // 폼에서 전송된 데이터 받기
        String screeningId = request.getParameter("screeningId");
        String movieId = request.getParameter("movieId");
        String movieTitle = request.getParameter("movieTitle");
        String theaterName = request.getParameter("theaterName");
        String screeningDate = request.getParameter("screeningDate");
        String screeningTime = request.getParameter("screeningTime");
        int adultCount = Integer.parseInt(request.getParameter("adultCount"));
        int youthCount = Integer.parseInt(request.getParameter("youthCount"));
        String selectedSeats = request.getParameter("selectedSeats");
        
        // 좌석 배열로 변환
        String[] seatArray = selectedSeats.split(",");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // 트랜잭션 시작
            
            // 예매 코드 생성
            String bookingCode = generateBookingCode();
            
            // booking 테이블에 예매 정보 저장 (total_price 필드 제거)
            String insertBookingSql = "INSERT INTO booking (user_id, booking_code, adult_count, youth_count, " +
                                     "movie_title, theater_name, screening_date, screening_time, booking_date) " +
                                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(insertBookingSql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, userId);
            pstmt.setString(2, bookingCode);
            pstmt.setInt(3, adultCount);
            pstmt.setInt(4, youthCount);
            pstmt.setString(5, movieTitle);
            pstmt.setString(6, theaterName);
            pstmt.setString(7, screeningDate);
            pstmt.setString(8, screeningTime);
            pstmt.executeUpdate();
            
            // 생성된 예매 ID 가져오기
            rs = pstmt.getGeneratedKeys();
            int bookingId = 0;
            if (rs.next()) {
                bookingId = rs.getInt(1);
            } else {
                throw new SQLException("예매 ID를 가져오는데 실패했습니다.");
            }
            
            // booking_seat 테이블에 좌석 정보 저장
            String insertSeatSql = "INSERT INTO booking_seat (booking_id, seat_row, seat_col) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(insertSeatSql);
            
            for (String seat : seatArray) {
                if (seat.trim().isEmpty()) continue;
                
                String row = seat.substring(0, 1);
                int col = Integer.parseInt(seat.substring(1));
                
                pstmt.setInt(1, bookingId);
                pstmt.setString(2, row);
                pstmt.setInt(3, col);
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            
            // 기존의 screening 테이블 업데이트 코드 제거
            
            conn.commit(); // 트랜잭션 커밋
            
            // 예매 완료 페이지로 리다이렉트
            response.sendRedirect("booking/booking-complete.jsp?bookingId=" + bookingId + "&bookingCode=" + bookingCode);
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback(); // 오류 발생 시 롤백
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
            e.printStackTrace();
            JSONObject resultObj = new JSONObject();
            resultObj.put("success", false);
            resultObj.put("message", "예매 처리 중 오류가 발생했습니다: " + e.getMessage());
            out.print(resultObj.toJSONString());
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
    }
    
    // 예매 코드 생성 메소드
    private String generateBookingCode() {
        String uuid = UUID.randomUUID().toString().toUpperCase().replace("-", "");
        return "CW-" + uuid.substring(0, 4) + "-" + uuid.substring(4, 8);
    }
}
