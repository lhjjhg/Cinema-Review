package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Random;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import DB.DBConnection;

@WebServlet("/admin/init-screenings")
public class InitScreeningsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<title>상영 정보 초기화</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; line-height: 1.6; padding: 20px; background-color: #f4f4f4; }");
        out.println(".container { max-width: 800px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }");
        out.println("h1 { color: #333; }");
        out.println(".log { background: #f0f0f0; padding: 15px; border-radius: 5px; max-height: 400px; overflow-y: auto; margin-top: 20px; }");
        out.println(".success { color: green; }");
        out.println(".error { color: red; }");
        out.println("a { display: inline-block; margin-top: 20px; background: #4CAF50; color: white; padding: 10px 15px; text-decoration: none; border-radius: 5px; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='container'>");
        out.println("<h1>상영 정보 초기화</h1>");
        out.println("<p>기존 프론트엔드 구조와 동일한 상영 정보를 생성합니다.</p>");
        
        out.println("<div class='log'>");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // 트랜잭션 시작
            
            // 기존 상영 정보 삭제
            out.println("기존 상영 정보 삭제 중...<br>");
            String truncateSql = "DELETE FROM screening";
            pstmt = conn.prepareStatement(truncateSql);
            pstmt.executeUpdate();
            out.println("기존 상영 정보 삭제 완료<br>");
            
            // 기존 상영관 정보 삭제
            out.println("기존 상영관 정보 삭제 중...<br>");
            String truncateScreenSql = "DELETE FROM screen";
            pstmt = conn.prepareStatement(truncateScreenSql);
            pstmt.executeUpdate();
            out.println("기존 상영관 정보 삭제 완료<br>");
            
            // 상영관 정보 생성 (프론트엔드와 동일한 구조)
            out.println("상영관 정보 생성 중...<br>");
            String insertScreenSql = "INSERT INTO screen (theater_id, name, seats_total) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(insertScreenSql);
            
            // 극장 ID 1부터 24까지 (booking_tables.sql의 극장 수)
            for (int theaterId = 1; theaterId <= 24; theaterId++) {
                // 1관 (일반) - 150석
                pstmt.setInt(1, theaterId);
                pstmt.setString(2, "1관 (일반)");
                pstmt.setInt(3, 150);
                pstmt.addBatch();
                
                // 2관 (일반) - 120석
                pstmt.setInt(1, theaterId);
                pstmt.setString(2, "2관 (일반)");
                pstmt.setInt(3, 120);
                pstmt.addBatch();
                
                // 3관 (IMAX) - 50석
                pstmt.setInt(1, theaterId);
                pstmt.setString(2, "3관 (IMAX)");
                pstmt.setInt(3, 50);
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            out.println("상영관 정보 생성 완료 (72개 상영관)<br>");
            out.println("- 1관 (일반): 150석<br>");
            out.println("- 2관 (일반): 120석<br>");
            out.println("- 3관 (IMAX): 50석<br>");
            
            // 영화 목록 가져오기
            out.println("영화 목록 가져오는 중...<br>");
            String movieSql = "SELECT movie_id, title FROM movie WHERE status = 'current' LIMIT 10";
            pstmt = conn.prepareStatement(movieSql);
            rs = pstmt.executeQuery();
            
            // 영화 ID 배열 생성
            java.util.List<String> movieIds = new java.util.ArrayList<>();
            while (rs.next()) {
                movieIds.add(rs.getString("movie_id"));
                out.println("- " + rs.getString("title") + "<br>");
            }
            
            if (movieIds.isEmpty()) {
                out.println("<span class='error'>현재 상영 중인 영화가 없습니다. 먼저 영화를 등록해주세요.</span><br>");
                conn.rollback();
                return;
            }
            
            // 상영관 목록 가져오기
            out.println("상영관 목록 가져오는 중...<br>");
            String screenSql = "SELECT id, name, seats_total, theater_id FROM screen ORDER BY theater_id, name";
            pstmt = conn.prepareStatement(screenSql);
            rs = pstmt.executeQuery();
            
            // 상영관 정보를 맵으로 저장
            java.util.Map<String, java.util.List<Integer>> screensByType = new java.util.HashMap<>();
            java.util.Map<Integer, Integer> screenSeats = new java.util.HashMap<>();
            
            while (rs.next()) {
                int screenId = rs.getInt("id");
                String screenName = rs.getString("name");
                int seatsTotal = rs.getInt("seats_total");
                
                screenSeats.put(screenId, seatsTotal);
                
                if (!screensByType.containsKey(screenName)) {
                    screensByType.put(screenName, new java.util.ArrayList<>());
                }
                screensByType.get(screenName).add(screenId);
            }
            
            // 프론트엔드와 동일한 상영 시간 설정
            java.util.Map<String, String[]> screenTimes = new java.util.HashMap<>();
            screenTimes.put("1관 (일반)", new String[]{"10:30", "13:00", "15:30", "18:00", "20:30"});
            screenTimes.put("2관 (일반)", new String[]{"11:00", "13:30", "16:00", "18:30", "21:00"});
            screenTimes.put("3관 (IMAX)", new String[]{"09:30", "12:30", "15:30", "18:30"});
            
            // 오늘부터 14일간의 상영 정보 생성
            out.println("상영 정보 생성 중...<br>");
            
            Random random = new Random();
            Calendar cal = Calendar.getInstance();
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            
            String insertScreeningSql = "INSERT INTO screening (movie_id, screen_id, screening_date, screening_time, available_seats) VALUES (?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertScreeningSql);
            
            int count = 0;
            
            for (int day = 0; day < 14; day++) {
                Date date = cal.getTime();
                String formattedDate = dateFormat.format(date);
                
                // 각 상영관 타입별로 처리
                for (String screenType : screenTimes.keySet()) {
                    String[] times = screenTimes.get(screenType);
                    java.util.List<Integer> screenIds = screensByType.get(screenType);
                    
                    if (screenIds != null) {
                        for (int screenId : screenIds) {
                            // 각 상영관마다 2-3개의 영화 선택
                            int movieCount = random.nextInt(2) + 2; // 2-3개
                            java.util.List<String> selectedMovies = new java.util.ArrayList<>();
                            
                            for (int i = 0; i < movieCount && selectedMovies.size() < movieIds.size(); i++) {
                                String movieId = movieIds.get(random.nextInt(movieIds.size()));
                                if (!selectedMovies.contains(movieId)) {
                                    selectedMovies.add(movieId);
                                }
                            }
                            
                            for (String movieId : selectedMovies) {
                                // 각 영화마다 해당 상영관의 모든 시간대 사용
                                for (String time : times) {
                                    int seatsTotal = screenSeats.get(screenId);
                                    int availableSeats = seatsTotal - random.nextInt(seatsTotal / 4); // 25% 이내 랜덤 예약
                                    
                                    pstmt.setString(1, movieId);
                                    pstmt.setInt(2, screenId);
                                    pstmt.setString(3, formattedDate);
                                    pstmt.setString(4, time);
                                    pstmt.setInt(5, availableSeats);
                                    pstmt.addBatch();
                                    
                                    count++;
                                }
                            }
                        }
                    }
                }
                
                cal.add(Calendar.DATE, 1);
            }
            
            pstmt.executeBatch();
            conn.commit();
            
            out.println("상영 정보 생성 완료. 총 " + count + "개의 상영 정보가 생성되었습니다.<br>");
            out.println("<span class='success'>프론트엔드와 동일한 구조로 모든 작업이 성공적으로 완료되었습니다.</span><br>");
            out.println("<br>생성된 상영 시간표:<br>");
            out.println("- 1관 (일반): 10:30, 13:00, 15:30, 18:00, 20:30<br>");
            out.println("- 2관 (일반): 11:00, 13:30, 16:00, 18:30, 21:00<br>");
            out.println("- 3관 (IMAX): 09:30, 12:30, 15:30, 18:30<br>");
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
            out.println("<span class='error'>오류 발생: " + e.getMessage() + "</span><br>");
            e.printStackTrace(new PrintWriter(out));
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        out.println("</div>");
        
        out.println("<a href='../index.jsp'>관리자 메인 페이지로 이동</a>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
}
