<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 나의 예매내역</title>
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
        
        .bookings-section {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .section-title {
            font-size: 28px;
            margin-bottom: 30px;
            color: #e0e0e0;
            text-align: center;
        }
        
        .booking-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
        }
        
        .booking-card {
            background-color: #1e1e1e;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            transition: transform 0.3s ease;
        }
        
        .booking-card:hover {
            transform: translateY(-5px);
        }
        
        .booking-poster {
            height: 200px;
            overflow: hidden;
            position: relative;
        }
        
        .booking-poster img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .booking-status {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            background-color: #2ecc71;
            color: white;
        }
        
        .booking-info {
            padding: 15px;
        }
        
        .booking-title {
            font-size: 18px;
            margin: 0 0 10px 0;
            color: #e0e0e0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .booking-details {
            font-size: 14px;
            color: #aaa;
            margin-bottom: 5px;
        }
        
        .booking-details strong {
            color: #e0e0e0;
        }
        
        .booking-actions {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
            gap: 10px;
        }
        
        .booking-btn {
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
            text-decoration: none;
            border: none;
            flex: 1;
        }
        
        .detail-btn {
            background-color: #3498db;
            color: white;
        }
        
        .detail-btn:hover {
            background-color: #2980b9;
        }
        
        .cancel-btn {
            background-color: #e74c3c;
            color: white;
        }
        
        .cancel-btn:hover {
            background-color: #c0392b;
        }
        
        .no-bookings {
            text-align: center;
            padding: 40px 20px;
            background-color: #1e1e1e;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            grid-column: 1 / -1;
        }
        
        .no-bookings i {
            font-size: 48px;
            color: #7f8c8d;
            margin-bottom: 20px;
        }
        
        .no-bookings h2 {
            font-size: 24px;
            margin-bottom: 15px;
            color: #e0e0e0;
        }
        
        .no-bookings p {
            color: #aaa;
            margin-bottom: 25px;
        }
        
        .booking-btn.primary {
            display: inline-block;
            padding: 10px 20px;
            background-color: #e50914;
            color: white;
            border-radius: 4px;
            text-decoration: none;
            transition: background-color 0.3s;
        }
        
        .booking-btn.primary:hover {
            background-color: #b2070f;
        }
        
        .error-container {
            text-align: center;
            padding: 40px 20px;
            background-color: #1e1e1e;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            grid-column: 1 / -1;
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
        
        .success-message, .error-message {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
            text-align: center;
        }
        
        .success-message {
            background-color: #2ecc71;
            color: white;
        }
        
        .error-message {
            background-color: #e74c3c;
            color: white;
        }
        
        @media (max-width: 768px) {
            .booking-list {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../header.jsp" />
        
        <main class="main-content">
            <section class="bookings-section">
                <h1 class="section-title">나의 예매내역</h1>
                
                <%
                    // 성공/오류 메시지 표시
                    String successMessage = (String) session.getAttribute("successMessage");
                    String errorMessage = (String) session.getAttribute("errorMessage");
                    
                    if (successMessage != null) {
                        session.removeAttribute("successMessage");
                %>
                <div class="success-message">
                    <i class="fas fa-check-circle"></i> <%= successMessage %>
                </div>
                <%
                    }
                    
                    if (errorMessage != null) {
                        session.removeAttribute("errorMessage");
                %>
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i> <%= errorMessage %>
                </div>
                <%
                    }
                %>
                
                <%
                    // 로그인 상태 확인
                    Integer userId = (Integer) session.getAttribute("userId");
                    if (userId == null) {
                        // 로그인되지 않은 경우 로그인 페이지로 리다이렉트
                        response.sendRedirect("login.jsp?redirect=member/my-bookings.jsp");
                        return;
                    }
                    
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    
                    try {
                        conn = DBConnection.getConnection();
                        
                        // 예매 내역 조회 (영화 정보와 조인하여 포스터 URL 가져오기)
                        String sql = "SELECT b.*, " +
                                    "DATE_FORMAT(b.booking_date, '%Y-%m-%d %H:%i') AS formatted_booking_date, " +
                                    "m.poster_url, m.title as actual_movie_title " +
                                    "FROM booking b " +
                                    "LEFT JOIN movie m ON b.movie_title = m.title " +
                                    "WHERE b.user_id = ? " +
                                    "ORDER BY b.booking_date DESC";
                        
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, userId);
                        rs = pstmt.executeQuery();
                        
                        boolean hasBookings = false;
                %>
                
                <div class="booking-list">
                    <%
                        while (rs.next()) {
                            hasBookings = true;
                            String bookingId = rs.getString("id");
                            String bookingCode = rs.getString("booking_code");
                            String bookingDate = rs.getString("formatted_booking_date");
                            String movieTitle = rs.getString("movie_title");
                            String theaterName = rs.getString("theater_name");
                            String screeningDate = rs.getString("screening_date");
                            String screeningTime = rs.getString("screening_time");
                            int adultCount = rs.getInt("adult_count");
                            int youthCount = rs.getInt("youth_count");
                            
                            // 포스터 URL 설정 (실제 영화 데이터에서 가져오기)
                            String posterUrl = rs.getString("poster_url");
                            if (posterUrl == null || posterUrl.isEmpty()) {
                                posterUrl = "image/default-movie.jpg";
                            }
                    %>
                    <div class="booking-card">
                        <div class="booking-poster">
                            <img src="<%= posterUrl %>" alt="<%= movieTitle %> 포스터" onerror="this.src='image/default-movie.jpg';">
                            <span class="booking-status">예매 완료</span>
                        </div>
                        <div class="booking-info">
                            <h3 class="booking-title"><%= movieTitle %></h3>
                            <p class="booking-details"><strong>예매번호:</strong> <%= bookingCode %></p>
                            <p class="booking-details"><strong>극장:</strong> <%= theaterName %></p>
                            <p class="booking-details"><strong>상영일:</strong> <%= screeningDate %></p>
                            <p class="booking-details"><strong>상영시간:</strong> <%= screeningTime %></p>
                            <p class="booking-details"><strong>인원:</strong> 일반 <%= adultCount %>명, 청소년 <%= youthCount %>명</p>
                            <p class="booking-details"><strong>예매일:</strong> <%= bookingDate %></p>
                            <div class="booking-actions">
                                <a href="../booking/booking-detail.jsp?id=<%= bookingId %>" class="booking-btn detail-btn">상세보기</a>
                                <button class="booking-btn cancel-btn" onclick="cancelBooking('<%= bookingId %>')">예매취소</button>
                            </div>
                        </div>
                    </div>
                    <%
                        }
                        
                        if (!hasBookings) {
                    %>
                    <div class="no-bookings">
                        <i class="fas fa-ticket-alt"></i>
                        <h2>예매 내역이 없습니다</h2>
                        <p>아직 예매한 영화가 없습니다. 지금 영화를 예매해보세요!</p>
                        <a href="../movies.jsp" class="booking-btn primary">영화 예매하기</a>
                    </div>
                    <%
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    %>
                    <div class="error-container">
                        <i class="fas fa-exclamation-circle"></i>
                        <h2>데이터베이스 오류</h2>
                        <p>예매 내역을 불러오는 중 오류가 발생했습니다: <%= e.getMessage() %></p>
                        <a href="../index.jsp" class="booking-btn primary">홈으로 돌아가기</a>
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
                </div>
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
