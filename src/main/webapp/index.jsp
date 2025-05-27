<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="DB.DBConnection" %>
<%@ page import="dto.Movie" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 영화의 모든 것</title>
    <link rel="stylesheet" href="css/Style.css">
    <link rel="stylesheet" href="css/main.css">
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.css" />
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="header.jsp" />
        
        <main class="main-content">
            <!-- 메인 배너 섹션 -->
            <section class="hero-banner">
                <div class="hero-content">
                    <h1>최고의 영화, 최고의 경험</h1>
                    <p>CinemaWorld에서 다양한 영화를 만나보세요</p>
                    <a href="movies.jsp" class="cta-button">영화 보러가기</a>
                </div>
            </section>
            
            <!-- 박스오피스 섹션 -->
            <section class="section boxoffice-section">
                <div class="section-header">
                    <h2>박스오피스 순위</h2>
                    <a href="movies.jsp" class="view-all">전체보기 <i class="fas fa-chevron-right"></i></a>
                </div>
                
                <div class="swiper boxoffice-slider">
                    <div class="swiper-wrapper">
                        <%
                            Connection conn = null;
                            PreparedStatement pstmt = null;
                            ResultSet rs = null;
                            
                            try {
                                conn = DBConnection.getConnection();
                                String sql = "SELECT * FROM movie WHERE status = 'current' ORDER BY movie_rank, rating DESC LIMIT 10";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                boolean hasMovies = false;
                                int count = 0;
                                
                                while (rs.next()) {
                                    hasMovies = true;
                                    count++;
                                    
                                    String movieId = rs.getString("movie_id");
                                    String title = rs.getString("title");
                                    String posterUrl = rs.getString("poster_url");
                                    double rating = rs.getDouble("rating");
                                    String link = "movie-detail.jsp?id=" + movieId;
                                    
                                    // 포스터 URL이 없는 경우 기본 이미지 사용
                                    if (posterUrl == null || posterUrl.isEmpty()) {
                                        posterUrl = "image/default-movie.jpg";
                                    }
                        %>
                        <div class="swiper-slide">
                            <div class="movie-card">
                                <div class="rank-badge"><%= count %></div>
                                <div class="movie-poster">
                                    <img src="<%= posterUrl %>" alt="<%= title %> 포스터" onerror="this.src='image/default-movie.jpg';">
                                    <div class="movie-overlay">
                                        <a href="<%= link %>" class="detail-btn">상세보기</a>
                                        <a href="booking.jsp?movie=<%= movieId %>" class="booking-btn">예매하기</a>
                                    </div>
                                </div>
                                <div class="movie-info">
                                    <h3 class="movie-title"><%= title %></h3>
                                    <div class="movie-rating">
                                        <i class="fas fa-star"></i>
                                        <span><%= String.format("%.1f", rating) %></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                                }
                                
                                // 영화가 없는 경우 또는 데이터베이스에 영화가 없는 경우 더미 데이터 표시
                                if (!hasMovies) {
                                    String[] movieTitles = {
                                        "아바타: 물의 길", "듄: 파트 2", "데드풀 & 울버린", "인사이드 아웃 2", 
                                        "미션 임파서블: 데드 레코닝", "오펜하이머", "스파이더맨: 어크로스 더 유니버스", 
                                        "분노의 질주: 라이드 오어 다이", "가디언즈 오브 갤럭시 Vol. 3", "존 윅 4"
                                    };
                                    
                                    String[] ratings = {"9.2", "8.9", "9.0", "8.7", "8.5", "9.1", "8.8", "8.3", "8.6", "8.4"};
                                    
                                    for (int i = 0; i < movieTitles.length; i++) {
                                        String title = movieTitles[i];
                                        String rating = ratings[i];
                                        String posterUrl = "image/default-movie.jpg"; // 기본 이미지 사용
                                        String link = "movie-detail.jsp?title=" + java.net.URLEncoder.encode(title, "UTF-8");
                        %>
                        <div class="swiper-slide">
                            <div class="movie-card">
                                <div class="rank-badge"><%= i + 1 %></div>
                                <div class="movie-poster">
                                    <img src="<%= posterUrl %>" alt="<%= title %> 포스터">
                                    <div class="movie-overlay">
                                        <a href="<%= link %>" class="detail-btn">상세보기</a>
                                        <a href="booking.jsp?movie=<%= i %>" class="booking-btn">예매하기</a>
                                    </div>
                                </div>
                                <div class="movie-info">
                                    <h3 class="movie-title"><%= title %></h3>
                                    <div class="movie-rating">
                                        <i class="fas fa-star"></i>
                                        <span><%= rating %></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                                    }
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                                // 예외 발생 시 더미 데이터 표시
                                String[] movieTitles = {
                                    "아바타: 물의 길", "듄: 파트 2", "데드풀 & 울버린", "인사이드 아웃 2", 
                                    "미션 임파서블: 데드 레코닝", "오펜하이머", "스파이더맨: 어크로스 더 유니버스", 
                                    "분노의 질주: 라이드 오어 다이", "가디언즈 오브 갤럭시 Vol. 3", "존 윅 4"
                                };
                                
                                String[] ratings = {"9.2", "8.9", "9.0", "8.7", "8.5", "9.1", "8.8", "8.3", "8.6", "8.4"};
                                
                                for (int i = 0; i < movieTitles.length; i++) {
                                    String title = movieTitles[i];
                                    String rating = ratings[i];
                                    String posterUrl = "image/default-movie.jpg"; // 기본 이미지 사용
                                    String link = "movie-detail.jsp?title=" + java.net.URLEncoder.encode(title, "UTF-8");
                        %>
                        <div class="swiper-slide">
                            <div class="movie-card">
                                <div class="rank-badge"><%= i + 1 %></div>
                                <div class="movie-poster">
                                    <img src="<%= posterUrl %>" alt="<%= title %> 포스터">
                                    <div class="movie-overlay">
                                        <a href="<%= link %>" class="detail-btn">상세보기</a>
                                        <a href="booking.jsp?movie=<%= i %>" class="booking-btn">예매하기</a>
                                    </div>
                                </div>
                                <div class="movie-info">
                                    <h3 class="movie-title"><%= title %></h3>
                                    <div class="movie-rating">
                                        <i class="fas fa-star"></i>
                                        <span><%= rating %></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                                }
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
                    <div class="swiper-button-next"></div>
                    <div class="swiper-button-prev"></div>
                    <div class="swiper-pagination"></div>
                </div>
            </section>
            
            <!-- 인기 리뷰 섹션 -->
            <section class="section popular-reviews-section">
                <div class="section-header">
                    <h2>인기 리뷰 TOP 5</h2>
                    <a href="reviews.jsp" class="view-all">전체보기 <i class="fas fa-chevron-right"></i></a>
                </div>
                
                <div class="reviews-container">
                    <%
                        conn = null;
                        pstmt = null;
                        rs = null;
                        
                        try {
                            conn = DBConnection.getConnection();
                            String sql = "SELECT r.*, u.nickname, u.profile_image, m.title AS movie_title " +
                                       "FROM review r " +
                                       "JOIN user u ON r.user_id = u.id " +
                                       "JOIN movie m ON r.movie_id = m.movie_id " +
                                       "ORDER BY r.likes DESC LIMIT 5";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            
                            boolean hasReviews = false;
                            while (rs.next()) {
                                hasReviews = true;
                                String reviewId = rs.getString("id");
                                String movieId = rs.getString("movie_id");
                                String movieTitle = rs.getString("movie_title");
                                String content = rs.getString("content");
                                int rating = rs.getInt("rating");
                                int likes = rs.getInt("likes");
                                String nickname = rs.getString("nickname");
                                String profileImage = rs.getString("profile_image");
                                
                                // 내용이 너무 길면 자르기
                                if (content.length() > 150) {
                                    content = content.substring(0, 147) + "...";
                                }
                    %>
                    <div class="review-card">
                        <div class="review-header">
                            <div class="reviewer-info">
                                <img src="<%= profileImage %>" alt="<%= nickname %> 프로필" class="reviewer-image" onerror="this.src='image/default-profile.png';">
                                <span class="reviewer-name"><%= nickname %></span>
                            </div>
                            <div class="movie-info">
                                <span class="movie-title"><%= movieTitle %></span>
                                <div class="rating">
                                    <% for (int i = 1; i <= 5; i++) { %>
                                        <i class="fas fa-star <%= i <= rating ? "filled" : "" %>"></i>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <div class="review-content">
                            <p><%= content %></p>
                        </div>
                        <div class="review-footer">
                            <div class="likes">
                                <i class="fas fa-heart"></i>
                                <span><%= likes %></span>
                            </div>
                            <a href="movie-detail.jsp?id=<%= movieId %>#review-<%= reviewId %>" class="read-more">리뷰 보기</a>
                        </div>
                    </div>
                    <%
                            }
                            
                            // 리뷰가 없는 경우 메시지 표시
                            if (!hasReviews) {
                    %>
                    <div class="no-reviews">
                        <i class="fas fa-comment-slash"></i>
                        <p>아직 작성된 리뷰가 없습니다.</p>
                        <p>첫 번째 리뷰를 작성해보세요!</p>
                    </div>
                    <%
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                    %>
                    <div class="error-message">
                        <i class="fas fa-exclamation-circle"></i>
                        <p>리뷰를 불러오는 중 오류가 발생했습니다.</p>
                        <p>잠시 후 다시 시도해주세요.</p>
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
        <jsp:include page="footer.jsp" />
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.js"></script>
    <script src="js/main.js"></script>
    
    -- 커밋 주석 추가
</body>
</html>
