<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 예매 상세 정보</title>
    <link rel="stylesheet" href="../css/Style.css">
    <link rel="stylesheet" href="../css/main.css">
    <link rel="stylesheet" href="../css/booking.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        .main-content {
            background-color: #121212;
            color: #e0e0e0;
            min-height: 100vh;
            padding: 20px;
        }
        
        .booking-detail-section {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .section-title {
            font-size: 28px;
            margin-bottom: 30px;
            color: #e0e0e0;
            text-align: center;
        }
        
        .booking-detail-container {
            background-color: #1e1e1e;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }
        
        .booking-header {
            display: flex;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid #333;
        }
        
        .booking-poster {
            width: 120px;
            height: 180px;
            border-radius: 4px;
            overflow: hidden;
            margin-right: 20px;
        }
        
        .booking-poster img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .booking-title-info {
            flex: 1;
        }
        
        .booking-title {
            font-size: 24px;
            margin: 0 0 10px 0;
            color: #e0e0e0;
        }
        
        .booking-code {
            font-size: 14px;
            color: #aaa;
            margin-bottom: 5px;
        }
        
        .booking-status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: bold;
            margin-top: 10px;
            background-color: #2ecc71;
            color: #fff;
        }
        
        .booking-info-section {
            padding: 20px;
        }
        
        .info-group {
            margin-bottom: 20px;
        }
        
        .info-group-title {
            font-size: 18px;
            margin-bottom: 10px;
            color: #e0e0e0;
            border-bottom: 1px solid #333;
            padding-bottom: 5px;
        }
        
        .info-row {
            display: flex;
            margin-bottom: 10px;
        }
        
        .info-label {
            width: 120px;
            color: #aaa;
            font-size: 14px;
        }
        
        .info-value {
            flex: 1;
            color: #e0e0e0;
            font-size: 14px;
        }
        
        .seat-layout {
            background-color: #2a2a2a;
            padding: 20px;
            border-radius: 4px;
            margin-top: 10px;
            text-align: center;
        }
        
        .screen {
            background-color: #444;
            color: #ddd;
            padding: 5px;
            border-radius: 2px;
            margin-bottom: 20px;
            font-size: 12px;
            text-align: center;
        }
        
        .seat-grid {
            display: grid;
            grid-template-columns: repeat(15, 1fr);
            gap: 5px;
            margin: 0 auto;
            max-width: 750px;
        }
        
        .seat {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 4px;
            font-size: 14px;
            background-color: #333;
            color: #ddd;
        }
        
        .seat.selected {
            background-color: #3498db;
            color: white;
        }
        
        .booking-actions {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 30px;
            padding: 0 20px 20px;
        }
        
        .action-btn {
            padding: 10px 20px;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
            text-decoration: none;
            border: none;
        }
        
        .cancel-btn {
            background-color: #e74c3c;
            color: white;
        }
        
        .cancel-btn:hover {
            background-color: #c0392b;
        }
        
        .cancel-btn:disabled {
            background-color: #7f8c8d;
            cursor: not-allowed;
        }
        
        .back-btn {
            background-color: #7f8c8d;
            color: white;
        }
        
        .back-btn:hover {
            background-color: #6c7a7d;
        }
        
        .error-container {
            text-align: center;
            padding: 40px 20px;
            background-color: #1e1e1e;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }
        
        .error-container i {
            font-size: 48px;
            color: #e74c3c;
            margin-bottom: 20px;
        }
        
        .error-container h2 {
            font-size: 24px;
            margin-bottom: 15px;
            color: #e0e0e0;
        }
        
        .error-container p {
            color: #aaa;
            margin-bottom: 25px;
        }
        
        .error-container .back-btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #7f8c8d;
            color: white;
            border-radius: 4px;
            text-decoration: none;
            transition: background-color 0.3s;
        }
        
        .error-container .back-btn:hover {
            background-color: #6c7a7d;
        }
        
        @media (max-width: 768px) {
            .booking-header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .booking-poster {
                margin-bottom: 15px;
                margin-right: 0;
            }
            
            .info-row {
                flex-direction: column;
                margin-bottom: 15px;
            }
            
            .info-label {
                width: 100%;
                margin-bottom: 5px;
            }
            
            .seat-grid {
                grid-template-columns: repeat(5, 1fr);
            }
            
            .seat {
                width: 35px;
                height: 35px;
                font-size: 12px;
            }
        }
    </style>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../header.jsp" />
        
        <main class="main-content">
            <section class="booking-detail-section">
                <h1 class="section-title">예매 상세 정보</h1>
                
                <%
                    // 로그인 상태 확인
                    Integer userId = (Integer) session.getAttribute("userId");
                    if (userId == null) {
                        // 로그인되지 않은 경우 로그인 페이지로 리다이렉트
                        response.sendRedirect("../member/login.jsp?redirect=booking/my-bookings.jsp");
                        return;
                    }
                    
                    String bookingId = request.getParameter("id");
                    if (bookingId == null || bookingId.isEmpty()) {
                        response.sendRedirect("../member/my-bookings.jsp");
                        return;
                    }
                    
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    
                    try {
                        conn = DBConnection.getConnection();
                        
                        // 예매 정보 조회 (영화 정보와 조인하여 포스터 URL 가져오기)
                        String sql = "SELECT b.*, " +
                                    "DATE_FORMAT(b.booking_date, '%Y-%m-%d %H:%i') AS formatted_booking_date, " +
                                    "m.poster_url " +
                                    "FROM booking b " +
                                    "LEFT JOIN movie m ON b.movie_title = m.title " +
                                    "WHERE b.id = ? AND b.user_id = ?";
                        
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, bookingId);
                        pstmt.setInt(2, userId);
                        rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                            String bookingCode = rs.getString("booking_code");
                            int adultCount = rs.getInt("adult_count");
                            int youthCount = rs.getInt("youth_count");
                            String bookingDate = rs.getString("formatted_booking_date");
                            String movieTitle = rs.getString("movie_title");
                            String theaterName = rs.getString("theater_name");
                            String screeningDate = rs.getString("screening_date");
                            String screeningTime = rs.getString("screening_time");
                            
                            // 포스터 URL 설정 (실제 영화 데이터에서 가져오기)
                            String posterUrl = rs.getString("poster_url");
                            if (posterUrl == null || posterUrl.isEmpty()) {
                                posterUrl = "image/default-movie.jpg";
                            }
                %>
                
                <div class="booking-detail-container">
                    <div class="booking-header">
                        <div class="booking-poster">
                            <img src="<%= posterUrl %>" alt="<%= movieTitle %> 포스터" onerror="this.src='image/default-movie.jpg';">
                        </div>
                        <div class="booking-title-info">
                            <h2 class="booking-title"><%= movieTitle %></h2>
                            <p class="booking-code">예매번호: <strong><%= bookingCode %></strong></p>
                            <p class="booking-code">예매일시: <%= bookingDate %></p>
                            <span class="booking-status">예매 완료</span>
                        </div>
                    </div>
                    
                    <div class="booking-info-section">
                        <div class="info-group">
                            <h3 class="info-group-title">상영 정보</h3>
                            <div class="info-row">
                                <div class="info-label">극장</div>
                                <div class="info-value"><%= theaterName %></div>
                            </div>
                            <div class="info-row">
                                <div class="info-label">상영일</div>
                                <div class="info-value"><%= screeningDate %></div>
                            </div>
                            <div class="info-row">
                                <div class="info-label">상영시간</div>
                                <div class="info-value"><%= screeningTime %></div>
                            </div>
                        </div>
                        
                        <div class="info-group">
                            <h3 class="info-group-title">예매 정보</h3>
                            <div class="info-row">
                                <div class="info-label">인원</div>
                                <div class="info-value">일반 <%= adultCount %>명, 청소년 <%= youthCount %>명</div>
                            </div>
                            <div class="info-row">
                                <div class="info-label">좌석</div>
                                <div class="info-value">
                                    <%
                                        // 예매한 좌석 정보 가져오기
                                        PreparedStatement seatPstmt = null;
                                        ResultSet seatRs = null;
                                        List<String> seats = new ArrayList<>();
                                        Map<String, Integer> seatMap = new HashMap<>();
                                        
                                        try {
                                            String seatSql = "SELECT seat_row, seat_col FROM booking_seat WHERE booking_id = ? ORDER BY seat_row, seat_col";
                                            seatPstmt = conn.prepareStatement(seatSql);
                                            seatPstmt.setString(1, bookingId);
                                            seatRs = seatPstmt.executeQuery();
                                            
                                            while (seatRs.next()) {
                                                String row = seatRs.getString("seat_row");
                                                int col = seatRs.getInt("seat_col");
                                                seats.add(row + col);
                                                seatMap.put(row + col, 1);
                                            }
                                            
                                            out.print(String.join(", ", seats));
                                        } finally {
                                            if (seatRs != null) seatRs.close();
                                            if (seatPstmt != null) seatPstmt.close();
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="info-group">
                            <h3 class="info-group-title">좌석 배치도</h3>
                            <div class="seat-layout">
                                <div class="screen">SCREEN</div>
                                <div class="seat-grid" style="grid-template-columns: repeat(15, 1fr); max-width: 750px;">
                                    <%
                                        // 좌석 배치도 생성 - 항상 A1부터 J15까지 표시
                                        String[] rowLabels = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J"};
                                        int totalRows = 10; // 10행
                                        int seatsPerRow = 15; // 15열
                                        
                                        for (int row = 0; row < totalRows; row++) {
                                            for (int col = 1; col <= seatsPerRow; col++) {
                                                String rowLabel = rowLabels[row];
                                                String seatId = rowLabel + col;
                                                boolean isSelected = seatMap.containsKey(seatId);
                                    %>
                                    <div class="seat <%= isSelected ? "selected" : "" %>"><%= seatId %></div>
                                    <%
                                            }
                                        }
                                    %>
                                </div>
                                <div style="margin-top: 15px; text-align: center; color: #aaa; font-size: 12px;">
                                    <span style="color: #3498db;">■</span> 선택한 좌석 &nbsp;&nbsp;
                                    <span style="color: #333;">■</span> 일반 좌석 &nbsp;&nbsp;
                                    <span style="color: #888;">총 <%= totalRows * seatsPerRow %>석</span>
                                </div>
                            </div>
                        </div>
                        
                        
                        <div class="booking-actions">
                            <a href="../member/my-bookings.jsp" class="action-btn back-btn">목록으로</a>
                            <button class="action-btn cancel-btn" onclick="cancelBooking('<%= bookingId %>')">예매취소</button>
                        </div>
                    </div>
                </div>
                
                <%
                        } else {
                %>
                <div class="error-container">
                    <i class="fas fa-exclamation-circle"></i>
                    <h2>예매 정보를 찾을 수 없습니다</h2>
                    <p>요청하신 예매 정보가 존재하지 않거나 접근 권한이 없습니다.</p>
                    <a href="../member/my-bookings.jsp" class="back-btn">예매 목록으로</a>
                </div>
                <%
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                %>
                <div class="error-container">
                    <i class="fas fa-exclamation-circle"></i>
                    <h2>데이터베이스 오류</h2>
                    <p>예매 정보를 불러오는 중 오류가 발생했습니다: <%= e.getMessage() %></p>
                    <a href="../member/my-bookings.jsp" class="back-btn">예매 목록으로</a>
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
    
    <script>
        function cancelBooking(bookingId) {
            if (confirm('예매를 취소하시겠습니까?\n취소 후에는 복구할 수 없습니다.')) {
                // 로딩 표시
                const button = event.target;
                const originalText = button.textContent;
                button.textContent = '취소 중...';
                button.disabled = true;
                
                // 예매 취소 요청
                window.location.href = '../BookingCancelServlet?id=' + bookingId;
            }
        }
    </script>
</body>
</html>
