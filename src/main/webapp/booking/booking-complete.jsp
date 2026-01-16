<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 예매 완료</title>
    <link rel="stylesheet" href="../css/Style.css">
    <link rel="stylesheet" href="../css/main.css">
    <link rel="stylesheet" href="../css/booking.css">
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <style>
        .booking-complete-section {
            padding: 40px 0;
        }
        
        .complete-container {
            background-color: #1a1a1a;
            border-radius: 5px;
            padding: 30px;
            max-width: 800px;
            margin: 0 auto;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }
        
        .complete-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .complete-header i {
            font-size: 60px;
            color: #3498db;
            margin-bottom: 20px;
        }
        
        .complete-header h2 {
            font-size: 24px;
            color: #e0e0e0;
            margin-bottom: 10px;
        }
        
        .complete-header p {
            color: #aaa;
            font-size: 16px;
        }
        
        .booking-details {
            background-color: #222;
            border-radius: 5px;
            padding: 20px;
            margin-bottom: 30px;
        }
        
        .detail-item {
            display: flex;
            margin-bottom: 15px;
        }
        
        .detail-label {
            width: 120px;
            color: #aaa;
            font-size: 14px;
        }
        
        .detail-value {
            flex: 1;
            color: #e0e0e0;
            font-weight: bold;
        }
        
        .booking-code {
            background-color: #2a2a2a;
            border-radius: 5px;
            padding: 15px;
            text-align: center;
            margin-bottom: 30px;
        }
        
        .booking-code p {
            color: #aaa;
            margin-bottom: 10px;
            font-size: 14px;
        }
        
        .code-value {
            font-size: 24px;
            font-weight: bold;
            color: #3498db;
            letter-spacing: 2px;
        }
        
        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 20px;
        }
        
        .action-btn {
            padding: 12px 25px;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-block;
        }
        
        .home-btn {
            background-color: #444;
            color: #e0e0e0;
        }
        
        .home-btn:hover {
            background-color: #555;
        }
        
        .my-bookings-btn {
            background-color: #3498db;
            color: #fff;
        }
        
        .my-bookings-btn:hover {
            background-color: #2980b9;
        }
    </style>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../header.jsp" />
        
        <main class="main-content">
            <section class="booking-complete-section">
                <%
                    String bookingId = request.getParameter("bookingId");
                    String bookingCode = request.getParameter("bookingCode");
                    
                    if (bookingId == null || bookingId.isEmpty()) {
                        // 예매 정보가 없으면 메인 페이지로 리다이렉트
                        response.sendRedirect("index.jsp");
                        return;
                    }
                    
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    
                    try {
                        conn = DBConnection.getConnection();
                        // total_price 필드 제거
                        String sql = "SELECT b.*, DATE_FORMAT(b.booking_date, '%Y년 %m월 %d일 %H:%i') AS formatted_booking_date " +
                                    "FROM booking b WHERE b.id = ?";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, bookingId);
                        rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                            String movieTitle = rs.getString("movie_title");
                            String theaterName = rs.getString("theater_name");
                            String screeningDate = rs.getString("screening_date");
                            String screeningTime = rs.getString("screening_time");
                            int adultCount = rs.getInt("adult_count");
                            int youthCount = rs.getInt("youth_count");
                            String formattedBookingDate = rs.getString("formatted_booking_date");
                            String retrievedBookingCode = rs.getString("booking_code");
                %>
                
                <div class="complete-container">
                    <div class="complete-header">
                        <i class="fas fa-check-circle"></i>
                        <h2>예매가 완료되었습니다!</h2>
                        <p>예매 내역은 마이페이지에서 확인하실 수 있습니다.</p>
                    </div>
                    
                    <div class="booking-details">
                        <div class="detail-item">
                            <div class="detail-label">영화</div>
                            <div class="detail-value"><%= movieTitle %></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">극장</div>
                            <div class="detail-value"><%= theaterName %></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">상영 일시</div>
                            <div class="detail-value"><%= screeningDate %> <%= screeningTime %></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">인원</div>
                            <div class="detail-value">일반 <%= adultCount %>명, 청소년 <%= youthCount %>명</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">좌석</div>
                            <div class="detail-value">
                                <%
                                    // 예매한 좌석 정보 가져오기
                                    PreparedStatement seatPstmt = null;
                                    ResultSet seatRs = null;
                                    
                                    try {
                                        String seatSql = "SELECT seat_row, seat_col FROM booking_seat WHERE booking_id = ? ORDER BY seat_row, seat_col";
                                        seatPstmt = conn.prepareStatement(seatSql);
                                        seatPstmt.setString(1, bookingId);
                                        seatRs = seatPstmt.executeQuery();
                                        
                                        List<String> seats = new ArrayList<>();
                                        while (seatRs.next()) {
                                            String row = seatRs.getString("seat_row");
                                            int col = seatRs.getInt("seat_col");
                                            seats.add(row + col);
                                        }
                                        
                                        out.print(String.join(", ", seats));
                                    } finally {
                                        if (seatRs != null) seatRs.close();
                                        if (seatPstmt != null) seatPstmt.close();
                                    }
                                %>
                            </div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">예매일시</div>
                            <div class="detail-value"><%= formattedBookingDate %></div>
                        </div>
                    </div>
                    
                    <div class="booking-code">
                        <p>예매 번호</p>
                        <div class="code-value"><%= retrievedBookingCode %></div>
                    </div>
                    
                    <div class="action-buttons">
                        <a href="../index.jsp" class="action-btn home-btn">홈으로</a>
                        <a href="../member/my-bookings.jsp" class="action-btn my-bookings-btn">예매 내역</a>
                    </div>
                </div>
                
                <%
                        } else {
                %>
                <div class="complete-container">
                    <div class="complete-header">
                        <i class="fas fa-exclamation-circle"></i>
                        <h2>예매 정보를 찾을 수 없습니다.</h2>
                        <p>요청하신 예매 정보를 찾을 수 없습니다.</p>
                    </div>
                    <div class="action-buttons">
                        <a href="../index.jsp" class="action-btn home-btn">홈으로 돌아가기</a>
                    </div>
                </div>
                <%
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                %>
                <div class="complete-container">
                    <div class="complete-header">
                        <i class="fas fa-exclamation-circle"></i>
                        <h2>데이터베이스 오류</h2>
                        <p>예매 정보를 불러오는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.</p>
                        <p>오류 메시지: <%= e.getMessage() %></p>
                    </div>
                    <div class="action-buttons">
                        <a href="../index.jsp" class="action-btn home-btn">홈으로 돌아가기</a>
                    </div>
                </div>
                <%
                    } finally {
                        try {
                            if (rs != null) rs.close();
                            if (pstmt != null) pstmt.close();
                            if (conn != null) conn.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                %>
            </section>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../footer.jsp" />
    </div>
</body>
</html>
