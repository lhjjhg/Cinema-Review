package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import DB.DBConnection;

@WebServlet("/GetScreeningInfoServlet")
public class GetScreeningInfoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String movieId = request.getParameter("movieId");
        String theaterId = request.getParameter("theaterId");
        String date = request.getParameter("date");
        
        JSONObject resultObj = new JSONObject();
        JSONArray screeningsArray = new JSONArray();
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // 각 상영시간별 예매된 좌석 수 계산
            Map<String, Integer> bookedSeatsMap = getBookedSeatsCount(conn, movieId, theaterId, date);
            
            // 고정된 상영 시간표와 좌석 정보
            String[][] screeningData = {
                {"101", "10:30", "1관 (일반)", "150"},
                {"102", "13:00", "1관 (일반)", "150"},
                {"103", "15:30", "1관 (일반)", "150"},
                {"104", "18:00", "1관 (일반)", "150"},
                {"105", "20:30", "1관 (일반)", "150"},
                {"201", "11:00", "2관 (일반)", "120"},
                {"202", "13:30", "2관 (일반)", "120"},
                {"203", "16:00", "2관 (일반)", "120"},
                {"204", "18:30", "2관 (일반)", "120"},
                {"205", "21:00", "2관 (일반)", "120"},
                {"301", "09:30", "3관 (IMAX)", "50"},
                {"302", "12:30", "3관 (IMAX)", "50"},
                {"303", "15:30", "3관 (IMAX)", "50"},
                {"304", "18:30", "3관 (IMAX)", "50"},
                {"305", "21:30", "3관 (IMAX)", "50"}
            };
            
            for (String[] screening : screeningData) {
                String screeningId = screening[0];
                String time = screening[1];
                String screenName = screening[2];
                int totalSeats = Integer.parseInt(screening[3]);
                
                // 해당 상영시간에 예매된 좌석 수 가져오기
                int bookedSeats = bookedSeatsMap.getOrDefault(screeningId, 0);
                int availableSeats = Math.max(0, totalSeats - bookedSeats);
                
                JSONObject screeningObj = new JSONObject();
                screeningObj.put("id", screeningId);
                screeningObj.put("time", time);
                screeningObj.put("screenName", screenName);
                screeningObj.put("availableSeats", availableSeats);
                screeningObj.put("totalSeats", totalSeats);
                screeningObj.put("bookedSeats", bookedSeats);
                
                screeningsArray.add(screeningObj);
            }
            
            resultObj.put("success", true);
            resultObj.put("screenings", screeningsArray);
            
        } catch (SQLException e) {
            e.printStackTrace();
            resultObj.put("success", false);
            resultObj.put("message", "데이터베이스 오류가 발생했습니다.");
            
            // 오류 시에도 기본 상영 시간표 제공
            String[][] defaultScreeningData = {
                {"101", "10:30", "1관 (일반)", "150"},
                {"102", "13:00", "1관 (일반)", "150"},
                {"103", "15:30", "1관 (일반)", "150"},
                {"104", "18:00", "1관 (일반)", "150"},
                {"105", "20:30", "1관 (일반)", "150"}
            };
            
            for (String[] screening : defaultScreeningData) {
                JSONObject screeningObj = new JSONObject();
                screeningObj.put("id", screening[0]);
                screeningObj.put("time", screening[1]);
                screeningObj.put("screenName", screening[2]);
                screeningObj.put("availableSeats", Integer.parseInt(screening[3]));
                screeningObj.put("totalSeats", Integer.parseInt(screening[3]));
                screeningObj.put("bookedSeats", 0);
                
                screeningsArray.add(screeningObj);
            }
            
            resultObj.put("screenings", screeningsArray);
            
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        out.print(resultObj.toJSONString());
    }
    
    // 특정 날짜/영화/극장의 각 상영시간별 예매된 좌석 수를 계산하는 메소드
    private Map<String, Integer> getBookedSeatsCount(Connection conn, String movieId, String theaterId, String date) 
            throws SQLException {
        
        Map<String, Integer> bookedSeatsMap = new HashMap<>();
        
        // booking 테이블과 booking_seat 테이블을 조인하여 예매된 좌석 수 계산
        String sql = "SELECT " +
                    "    CASE " +
                    "        WHEN b.screening_time = '10:30' THEN '101' " +
                    "        WHEN b.screening_time = '13:00' THEN '102' " +
                    "        WHEN b.screening_time = '15:30' THEN '103' " +
                    "        WHEN b.screening_time = '18:00' THEN '104' " +
                    "        WHEN b.screening_time = '20:30' THEN '105' " +
                    "        WHEN b.screening_time = '11:00' THEN '201' " +
                    "        WHEN b.screening_time = '13:30' THEN '202' " +
                    "        WHEN b.screening_time = '16:00' THEN '203' " +
                    "        WHEN b.screening_time = '18:30' THEN '204' " +
                    "        WHEN b.screening_time = '21:00' THEN '205' " +
                    "        WHEN b.screening_time = '09:30' THEN '301' " +
                    "        WHEN b.screening_time = '12:30' THEN '302' " +
                    "        WHEN b.screening_time = '15:30' AND b.theater_name LIKE '%IMAX%' THEN '303' " +
                    "        WHEN b.screening_time = '18:30' AND b.theater_name LIKE '%IMAX%' THEN '304' " +
                    "        WHEN b.screening_time = '21:30' THEN '305' " +
                    "        ELSE 'unknown' " +
                    "    END as screening_id, " +
                    "    COUNT(bs.id) as booked_count " +
                    "FROM booking b " +
                    "LEFT JOIN booking_seat bs ON b.id = bs.booking_id " +
                    "WHERE b.screening_date = ? " +
                    "AND b.movie_title IN (SELECT title FROM movie WHERE movie_id = ?) " +
                    "AND b.theater_name LIKE ? " +
                    "GROUP BY screening_id " +
                    "HAVING screening_id != 'unknown'";
        
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, date);
        pstmt.setString(2, movieId);
        pstmt.setString(3, "%" + getTheaterName(theaterId) + "%");
        
        ResultSet rs = pstmt.executeQuery();
        
        while (rs.next()) {
            String screeningId = rs.getString("screening_id");
            int bookedCount = rs.getInt("booked_count");
            bookedSeatsMap.put(screeningId, bookedCount);
        }
        
        rs.close();
        pstmt.close();
        
        return bookedSeatsMap;
    }
    
    // 극장 ID를 극장 이름으로 변환하는 메소드
    private String getTheaterName(String theaterId) {
        switch (theaterId) {
            case "1": return "CGV 강남";
            case "2": return "CGV 홍대";
            case "3": return "CGV 용산 아이파크몰";
            case "4": return "CGV 영등포";
            case "5": return "CGV 왕십리";
            case "6": return "CGV 대학로";
            case "7": return "CGV 건대입구";
            case "8": return "CGV 명동";
            case "9": return "CGV 구로";
            case "10": return "CGV 부천";
            case "11": return "CGV 수원";
            case "12": return "CGV 일산";
            case "13": return "CGV 동탄";
            case "14": return "CGV 광명";
            case "15": return "CGV 의정부";
            case "16": return "CGV 인천";
            case "17": return "CGV 부평";
            case "18": return "CGV 청라";
            case "19": return "CGV 대전";
            case "20": return "CGV 청주";
            case "21": return "CGV 천안";
            case "22": return "CGV 대구 현대";
            case "23": return "CGV 대구 수성";
            case "24": return "CGV 포항";
            case "25": return "CGV 부산 서면";
            case "26": return "CGV 부산 센텀시티";
            case "27": return "CGV 울산";
            case "28": return "CGV 창원";
            case "29": return "CGV 광주 터미널";
            case "30": return "CGV 전주";
            case "31": return "CGV 목포";
            case "32": return "CGV 제주";
            default: return "CGV";
        }
    }
}
