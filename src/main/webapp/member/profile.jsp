<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<%@ page import="dao.ReviewDAO" %>
<%@ page import="dto.Review" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 마이페이지</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/Style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/profile.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        .liked-movies {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-top: 15px;
            padding: 0 5px;
        }

        .liked-movie-item {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s;
            aspect-ratio: 2/3;
            width: 100%;
        }

        .liked-movie-item:hover {
            transform: translateY(-5px);
        }

        .liked-movie-poster {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .liked-movie-info {
            padding: 8px;
            background-color: rgba(0, 0, 0, 0.8);
            color: white;
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            transform: translateY(100%);
            transition: transform 0.3s;
        }
        
        .liked-movie-item:hover .liked-movie-info {
            transform: translateY(0);
        }
        
        .liked-movie-title {
            font-size: 12px;
            font-weight: bold;
            margin: 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .liked-movie-rating {
            display: flex;
            align-items: center;
            font-size: 11px;
            margin-top: 4px;
        }
        
        .liked-movie-rating i {
            color: gold;
            margin-right: 3px;
            font-size: 10px;
        }
        
        .no-liked-movies {
            text-align: center;
            padding: 30px 0;
            grid-column: 1 / -1;
        }
        
        .no-liked-movies i {
            font-size: 48px;
            color: #ddd;
            margin-bottom: 15px;
        }
        
        .no-liked-movies p {
            color: #666;
            margin: 5px 0;
        }
        
        .profile-section {
            margin-bottom: 25px;
        }
        
        @media (max-width: 768px) {
            .liked-movies {
                grid-template-columns: repeat(2, 1fr);
                gap: 10px;
            }
        }
        .user-reviews {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-top: 15px;
        }

        .review-card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            padding: 15px;
            transition: transform 0.3s;
        }

        .review-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        .review-movie {
            display: flex;
            gap: 12px;
            margin-bottom: 10px;
        }

        .review-movie-poster {
            width: 60px;
            height: 90px;
            border-radius: 4px;
            overflow: hidden;
            flex-shrink: 0;
        }

        .review-movie-poster img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .review-movie-info {
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .review-movie-title {
            font-size: 16px;
            font-weight: bold;
            margin: 0 0 5px 0;
        }

        .review-movie-title a {
            color: #333;
            text-decoration: none;
        }

        .review-movie-title a:hover {
            color: #e74c3c;
        }

        .review-rating {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .review-rating .fa-star {
            color: #ddd;
            font-size: 14px;
        }

        .review-rating .fa-star.filled {
            color: gold;
        }

        .review-date {
            font-size: 12px;
            color: #777;
            margin-left: 8px;
        }

        .review-content {
            font-size: 14px;
            color: #555;
            line-height: 1.5;
            margin: 10px 0;
        }

        .review-actions {
            display: flex;
            justify-content: flex-end;
        }

        .review-link {
            font-size: 13px;
            color: #3498db;
            text-decoration: none;
        }

        .review-link:hover {
            text-decoration: underline;
        }
        
        /* 예매 내역 스타일 - 어두운 테마로 변경 */
        .booking-item {
            background-color: #2c2c2c;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
            padding: 15px;
            margin-bottom: 15px;
            transition: transform 0.3s;
            display: flex;
            gap: 15px;
            border: 1px solid #404040;
        }

        .booking-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
            background-color: #333333;
        }

        .booking-poster {
            width: 80px;
            height: 120px;
            border-radius: 4px;
            overflow: hidden;
            flex-shrink: 0;
        }

        .booking-poster img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .booking-info {
            flex: 1;
        }

        .booking-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .booking-title {
            font-size: 16px;
            font-weight: bold;
            margin: 0;
            color: #e0e0e0;
        }

        .booking-status {
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }

        .booking-status.future {
            background-color: #27ae60;
            color: #fff;
        }

        .booking-status.past {
            background-color: #3498db;
            color: #fff;
        }

        .booking-details {
            font-size: 14px;
            color: #b0b0b0;
            margin-bottom: 10px;
        }

        .booking-details p {
            margin: 5px 0;
            color: #b0b0b0;
        }

        .booking-details strong {
            color: #e0e0e0;
        }

        .booking-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .booking-link {
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 13px;
            text-decoration: none;
            color: #fff;
            background-color: #3498db;
            transition: background-color 0.3s;
        }

        .booking-link:hover {
            background-color: #2980b9;
            color: #fff;
        }
    </style>
</head>
<body class="main-page">
    <%
        // 세션에서 사용자 정보 가져오기
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");
        
        // 로그인 상태가 아니면 로그인 페이지로 리다이렉트
        if (username == null || userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 사용자 정보 조회
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String name = "";
        String nickname = "";
        String address = "";
        String birthdate = "";
        String profileImage = request.getContextPath() + "/image/default-profile.png"; // 절대 경로로 변경
        
        // 좋아요한 영화 수
        int likedMoviesCount = 0;
        // 작성한 리뷰 수
        int reviewCount = 0;
        // 예매 내역 수
        int bookingCount = 0;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM user WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                name = rs.getString("name");
                nickname = rs.getString("nickname");
                address = rs.getString("address") != null ? rs.getString("address") : "등록된 주소가 없습니다";
                birthdate = rs.getDate("birthdate") != null ? rs.getDate("birthdate").toString() : "등록된 생년월일이 없습니다";
                
                // 프로필 이미지 경로 처리 개선
                String dbProfileImage = rs.getString("profile_image");
                if (dbProfileImage != null && !dbProfileImage.isEmpty()) {
                    // 이미 절대 경로인 경우 (http로 시작하는 경우)
                    if (dbProfileImage.startsWith("http")) {
                        profileImage = dbProfileImage;
                    } 
                    // 상대 경로인 경우 컨텍스트 경로 추가
                    else {
                        profileImage = request.getContextPath() + "/" + dbProfileImage;
                    }
                }
                
                // 디버깅 출력
                System.out.println("프로필 이미지 경로: " + profileImage);
            }
            
            // 좋아요한 영화 수 조회
            String countSql = "SELECT COUNT(*) AS count FROM movie_likes WHERE user_id = ?";
            pstmt = conn.prepareStatement(countSql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                likedMoviesCount = rs.getInt("count");
            }

            // 작성한 리뷰 수 조회
            String reviewCountSql = "SELECT COUNT(*) AS count FROM review WHERE user_id = ?";
            pstmt = conn.prepareStatement(reviewCountSql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                reviewCount = rs.getInt("count");
            }
            
            // 예매 내역 수 조회
            String bookingCountSql = "SELECT COUNT(*) AS count FROM booking WHERE user_id = ?";
            pstmt = conn.prepareStatement(bookingCountSql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                bookingCount = rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
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

    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../header.jsp" />
        
        <main class="main-content">
            <div class="profile-container">
                <div class="profile-content">
                    <div class="profile-sidebar">
                        <div class="profile-image-container">
                            <img src="<%= profileImage %>" alt="프로필 이미지" class="profile-image" onerror="this.src='<%= request.getContextPath() %>/image/default-profile.png'">
                            <div class="profile-image-overlay">
                                <a href="<%= request.getContextPath() %>/member/edit-profile.jsp" class="edit-profile-btn">
                                    <i class="fas fa-camera"></i>
                                </a>
                            </div>
                        </div>
                        <h2 class="profile-nickname"><%= nickname %></h2>
                        <p class="profile-username">@<%= username %></p>
                        <div class="profile-stats">
                            <div class="stat">
                                <span class="stat-value"><%= bookingCount %></span>
                                <span class="stat-label">예매</span>
                            </div>
                            <div class="stat">
                                <span class="stat-value"><%= reviewCount %></span>
                                <span class="stat-label">리뷰</span>
                            </div>
                            <div class="stat">
                                <span class="stat-value"><%= likedMoviesCount %></span>
                                <span class="stat-label">좋아요</span>
                            </div>
                        </div>
                        <a href="<%= request.getContextPath() %>/member/edit-profile.jsp" class="edit-profile-link">프로필 수정</a>
                    </div>
                    
                    <div class="profile-main">
                        <div class="profile-section">
                            <div class="section-header">
                                <h3>회원 정보</h3>
                                <div class="section-actions">
                                    <a href="<%= request.getContextPath() %>/member/edit-profile.jsp" class="action-link">
                                        <i class="fas fa-pencil-alt"></i> 수정
                                    </a>
                                </div>
                            </div>
                            <div class="info-card">
                                <div class="info-row">
                                    <div class="info-label">이름</div>
                                    <div class="info-value"><%= name %></div>
                                </div>
                                <div class="info-row">
                                    <div class="info-label">닉네임</div>
                                    <div class="info-value"><%= nickname %></div>
                                </div>
                                <div class="info-row">
                                    <div class="info-label">아이디</div>
                                    <div class="info-value"><%= username %></div>
                                </div>
                                <div class="info-row">
                                    <div class="info-label">주소</div>
                                    <div class="info-value"><%= address %></div>
                                </div>
                                <div class="info-row">
                                    <div class="info-label">생년월일</div>
                                    <div class="info-value"><%= birthdate %></div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="profile-section">
                            <div class="section-header">
                                <h3>좋아요한 영화</h3>
                                <div class="section-actions">
                                    <a href="<%= request.getContextPath() %>/liked-movies.jsp" class="action-link">
                                        전체보기 <i class="fas fa-chevron-right"></i>
                                    </a>
                                </div>
                            </div>
                            
                            <%
                                // 좋아요한 영화 목록 조회
                                conn = null;
                                pstmt = null;
                                rs = null;
                                
                                try {
                                    conn = DBConnection.getConnection();
                                    String likedMoviesSql = 
                                        "SELECT m.*, ml.created_at AS liked_at " +
                                        "FROM movie_likes ml " +
                                        "JOIN movie m ON ml.movie_id = m.movie_id " +
                                        "WHERE ml.user_id = ? " +
                                        "ORDER BY ml.created_at DESC " +
                                        "LIMIT 4";
                                    
                                    pstmt = conn.prepareStatement(likedMoviesSql);
                                    pstmt.setInt(1, userId);
                                    rs = pstmt.executeQuery();
                                    
                                    boolean hasLikedMovies = false;
                            %>
                            
                            <div class="liked-movies">
                                <%
                                    while (rs.next()) {
                                        hasLikedMovies = true;
                                        String movieId = rs.getString("movie_id");
                                        String title = rs.getString("title");
                                        String posterUrl = rs.getString("poster_url");
                                        double rating = rs.getDouble("rating");
                                        
                                        // 포스터 URL 처리 개선
                                        if (posterUrl == null || posterUrl.isEmpty()) {
                                            posterUrl = request.getContextPath() + "/image/default-movie.jpg";
                                        } else if (posterUrl.startsWith("http")) {
                                            // 이미 절대 경로인 경우 그대로 사용
                                        } else {
                                            // 상대 경로인 경우 컨텍스트 경로 추가
                                            posterUrl = request.getContextPath() + "/" + posterUrl;
                                        }
                                %>
                                <a href="<%= request.getContextPath() %>/movie-detail.jsp?id=<%= movieId %>" class="liked-movie-item">
                                    <img src="<%= posterUrl %>" alt="<%= title %> 포스터" class="liked-movie-poster" onerror="this.src='<%= request.getContextPath() %>/image/default-movie.jpg'">
                                    <div class="liked-movie-info">
                                        <h4 class="liked-movie-title"><%= title %></h4>
                                        <div class="liked-movie-rating">
                                            <i class="fas fa-star"></i>
                                            <span><%= String.format("%.1f", rating) %></span>
                                        </div>
                                    </div>
                                </a>
                                <%
                                    }
                                    
                                    if (!hasLikedMovies) {
                                %>
                                <div class="no-liked-movies">
                                    <i class="fas fa-heart"></i>
                                    <p>좋아요한 영화가 없습니다.</p>
                                    <p>영화 상세 페이지에서 좋아요를 눌러보세요!</p>
                                    <a href="<%= request.getContextPath() %>/movies.jsp" class="cta-button">영화 보러가기</a>
                                </div>
                                <%
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
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
                        </div>
                        
                        <div class="profile-section">
                            <div class="section-header">
                                <h3>최근 예매 내역</h3>
                                <div class="section-actions">
                                    <a href="<%= request.getContextPath() %>/member/my-bookings.jsp" class="action-link">
                                        전체보기 <i class="fas fa-chevron-right"></i>
                                    </a>
                                </div>
                            </div>
                            
                            <%
                                // 최근 예매 내역 조회
                                conn = null;
                                pstmt = null;
                                rs = null;
                                
                                try {
                                    conn = DBConnection.getConnection();
                                    
                                    // 새로운 테이블 구조에 맞게 SQL 쿼리 수정
                                    String bookingSql = "SELECT b.id, b.booking_code, b.adult_count, b.youth_count, " +
                                                      "DATE_FORMAT(b.booking_date, '%Y-%m-%d %H:%i') AS formatted_booking_date, " +
                                                      "b.movie_title, b.theater_name, b.screening_date, b.screening_time, " +
                                                      "CASE WHEN STR_TO_DATE(CONCAT(b.screening_date, ' ', b.screening_time), '%Y-%m-%d %H:%i') > NOW() " +
                                                      "THEN TRUE ELSE FALSE END AS is_future, " +
                                                      "m.poster_url " +
                                                      "FROM booking b " +
                                                      "LEFT JOIN movie m ON b.movie_title = m.title " +
                                                      "WHERE b.user_id = ? " +
                                                      "ORDER BY b.booking_date DESC " +
                                                      "LIMIT 2";
                                    
                                    pstmt = conn.prepareStatement(bookingSql);
                                    pstmt.setInt(1, userId);
                                    rs = pstmt.executeQuery();
                                    
                                    boolean hasBookings = false;
                                    
                                    while (rs.next()) {
                                        hasBookings = true;
                                        int bookingId = rs.getInt("id");
                                        String bookingCode = rs.getString("booking_code");
                                        String movieTitle = rs.getString("movie_title");
                                        String theaterName = rs.getString("theater_name");
                                        String screeningDate = rs.getString("screening_date");
                                        String screeningTime = rs.getString("screening_time");
                                        int adultCount = rs.getInt("adult_count");
                                        int youthCount = rs.getInt("youth_count");
                                        String bookingDate = rs.getString("formatted_booking_date");
                                        boolean isFuture = rs.getBoolean("is_future");
                                        
                                        // 포스터 URL 처리
                                        String posterUrl = rs.getString("poster_url");
                                        if (posterUrl == null || posterUrl.isEmpty()) {
                                            posterUrl = request.getContextPath() + "/image/default-movie.jpg";
                                        } else if (!posterUrl.startsWith("http")) {
                                            // 상대 경로인 경우 컨텍스트 경로 추가
                                            posterUrl = request.getContextPath() + "/" + posterUrl;
                                        }
                            %>
                            <div class="booking-item">
                                <div class="booking-poster">
                                    <img src="<%= posterUrl %>" alt="<%= movieTitle %> 포스터" onerror="this.src='<%= request.getContextPath() %>/image/default-movie.jpg'">
                                </div>
                                <div class="booking-info">
                                    <div class="booking-header">
                                        <h4 class="booking-title"><%= movieTitle %></h4>
                                        <span class="booking-status <%= isFuture ? "future" : "past" %>">
                                            <%= isFuture ? "상영 예정" : "예매 완료" %>
                                        </span>
                                    </div>
                                    <div class="booking-details">
                                        <p><strong>예매번호:</strong> <%= bookingCode %></p>
                                        <p><strong>극장:</strong> <%= theaterName %></p>
                                        <p><strong>상영일시:</strong> <%= screeningDate %> <%= screeningTime %></p>
                                        <p><strong>인원:</strong> 일반 <%= adultCount %>명, 청소년 <%= youthCount %>명</p>
                                    </div>
                                    <div class="booking-actions">
                                        <a href="<%= request.getContextPath() %>/booking/booking-detail.jsp?id=<%= bookingId %>" class="booking-link">상세보기</a>
                                    </div>
                                </div>
                            </div>
                            <%
                                    }
                                    
                                    if (!hasBookings) {
                            %>
                            <div class="empty-state">
                                <i class="fas fa-ticket-alt empty-icon"></i>
                                <p>최근 예매 내역이 없습니다</p>
                                <a href="<%= request.getContextPath() %>/movies.jsp" class="cta-button">영화 예매하기</a>
                            </div>
                            <%
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                            %>
                            <div class="error-container">
                                <p>예매 내역을 불러오는 중 오류가 발생했습니다: <%= e.getMessage() %></p>
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
                        
                        <div class="profile-section">
                            <div class="section-header">
                                <h3>내가 작성한 리뷰</h3>
                                <div class="section-actions">
                                    <a href="<%= request.getContextPath() %>/member/my-reviews.jsp" class="action-link">
                                        전체보기 <i class="fas fa-chevron-right"></i>
                                    </a>
                                </div>
                            </div>
                            
                            <%
                                // 사용자가 작성한 리뷰 목록 조회
                                conn = null;
                                pstmt = null;
                                rs = null;
                                
                                try {
                                    conn = DBConnection.getConnection();
                                    String reviewsSql = 
                                        "SELECT r.*, m.title, m.poster_url FROM review r " +
                                        "JOIN movie m ON r.movie_id = m.movie_id " +
                                        "WHERE r.user_id = ? " +
                                        "ORDER BY r.created_at DESC " +
                                        "LIMIT 3";
                                    
                                    pstmt = conn.prepareStatement(reviewsSql);
                                    pstmt.setInt(1, userId);
                                    rs = pstmt.executeQuery();
                                    
                                    boolean hasReviews = false;
                            %>
                            
                            <div class="user-reviews">
                                <%
                                    while (rs.next()) {
                                        hasReviews = true;
                                        int reviewId = rs.getInt("id");
                                        String movieId = rs.getString("movie_id");
                                        String movieTitle = rs.getString("title");
                                        String posterUrl = rs.getString("poster_url");
                                        int rating = rs.getInt("rating");
                                        String content = rs.getString("content");
                                        java.util.Date createdAt = rs.getTimestamp("created_at");
                                        
                                        // 포스터 URL 처리 개선
                                        if (posterUrl == null || posterUrl.isEmpty()) {
                                            posterUrl = request.getContextPath() + "/image/default-movie.jpg";
                                        } else if (posterUrl.startsWith("http")) {
                                            // 이미 절대 경로인 경우 그대로 사용
                                        } else {
                                            // 상대 경로인 경우 컨텍스트 경로 추가
                                            posterUrl = request.getContextPath() + "/" + posterUrl;
                                        }
                                        
                                        // 리뷰 내용이 너무 길면 자르기
                                        String shortContent = content;
                                        if (content.length() > 100) {
                                            shortContent = content.substring(0, 100) + "...";
                                        }
                                %>
                                <div class="review-card">
                                    <div class="review-movie">
                                        <a href="<%= request.getContextPath() %>/movie-detail.jsp?id=<%= movieId %>" class="review-movie-poster">
                                            <img src="<%= posterUrl %>" alt="<%= movieTitle %> 포스터" onerror="this.src='<%= request.getContextPath() %>/image/default-movie.jpg'">
                                        </a>
                                        <div class="review-movie-info">
                                            <h4 class="review-movie-title"><a href="<%= request.getContextPath() %>/movie-detail.jsp?id=<%= movieId %>"><%= movieTitle %></a></h4>
                                            <div class="review-rating">
                                                <% for (int i = 1; i <= 5; i++) { %>
                                                    <i class="fas fa-star <%= i <= rating ? "filled" : "" %>"></i>
                                                <% } %>
                                                <span class="review-date"><%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(createdAt) %></span>
                                            </div>
                                        </div>
                                    </div>
                                    <p class="review-content"><%= shortContent %></p>
                                    <div class="review-actions">
                                        <a href="<%= request.getContextPath() %>/movie-detail.jsp?id=<%= movieId %>#review-<%= reviewId %>" class="review-link">리뷰 보기</a>
                                    </div>
                                </div>
                                <%
                                    }
                                    
                                    if (!hasReviews) {
                                %>
                                <div class="empty-state">
                                    <i class="fas fa-star empty-icon"></i>
                                    <p>작성한 리뷰가 없습니다</p>
                                    <a href="<%= request.getContextPath() %>/movies.jsp" class="cta-button">리뷰 작성하기</a>
                                </div>
                                <%
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
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
                        </div>
                    </div>
                </div>
            </div>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../footer.jsp" />
    </div>
    
    <script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>
