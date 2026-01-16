<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 영화 목록</title>
    <link rel="stylesheet" href="css/Style.css">
    <link rel="stylesheet" href="css/main.css">
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="header.jsp" />
        
        <main class="main-content">
            <section class="section movies-section">
                <div class="section-header">
                    <h2>현재 상영작</h2>
                </div>
                
                <div class="movies-grid">
                    <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        
                        try {
                            conn = DBConnection.getConnection();
                            String sql = "SELECT m.*, md.genre, md.running_time FROM movie m " +
                                        "LEFT JOIN movie_detail md ON m.movie_id = md.movie_id " +
                                        "WHERE m.status = 'current' " +
                                        "ORDER BY m.movie_rank, m.rating DESC";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            
                            boolean hasMovies = false;
                            
                            while (rs.next()) {
                                hasMovies = true;
                                String movieId = rs.getString("movie_id");
                                String title = rs.getString("title");
                                String posterUrl = rs.getString("poster_url");
                                double rating = rs.getDouble("rating");
                                String genre = rs.getString("genre");
                                String runtime = rs.getString("running_time");
                                
                                if (genre == null) genre = "정보 없음";
                                if (runtime == null) runtime = "정보 없음";
                                
                                // 포스터 URL이 없는 경우 기본 이미지 사용
                                if (posterUrl == null || posterUrl.isEmpty()) {
                                    posterUrl = "image/default-movie.jpg";
                                }
                    %>
                    <div class="movie-card">
                        <div class="movie-poster">
                            <img src="<%= posterUrl %>" alt="<%= title %> 포스터" onerror="this.src='image/default-movie.jpg';">
                            <div class="movie-overlay">
                                <a href="movie-detail.jsp?id=<%= movieId %>" class="detail-btn">상세보기</a>
                                <a href="booking/booking.jsp?id=<%= movieId %>" class="booking-btn">예매하기</a>
                            </div>
                        </div>
                        <div class="movie-info">
                            <h3 class="movie-title"><%= title %></h3>
                            <div class="movie-meta">
                                <span class="genre"><%= genre %></span>
                                <span class="runtime"><%= runtime %></span>
                            </div>
                            <div class="movie-rating">
                                <i class="fas fa-star"></i>
                                <span><%= String.format("%.1f", rating) %></span>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                            
                            // 영화가 없는 경우 메시지 표시
                            if (!hasMovies) {
                    %>
                    <div class="no-movies">
                        <i class="fas fa-film"></i>
                        <p>현재 상영 중인 영화가 없습니다.</p>
                    </div>
                    <%
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                    %>
                    <div class="error-message">
                        <i class="fas fa-exclamation-circle"></i>
                        <p>영화 정보를 불러오는 중 오류가 발생했습니다.</p>
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
                
                <div class="section-header" style="margin-top: 50px;">
                    <h2>상영 예정작</h2>
                </div>
                
                <div class="movies-grid">
                    <%
                        conn = null;
                        pstmt = null;
                        rs = null;
                        
                        try {
                            conn = DBConnection.getConnection();
                            String sql = "SELECT m.*, md.genre, md.running_time FROM movie m " +
                                        "LEFT JOIN movie_detail md ON m.movie_id = md.movie_id " +
                                        "WHERE m.status = 'coming' " +
                                        "ORDER BY m.release_date ASC";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            
                            boolean hasMovies = false;
                            
                            while (rs.next()) {
                                hasMovies = true;
                                String movieId = rs.getString("movie_id");
                                String title = rs.getString("title");
                                String posterUrl = rs.getString("poster_url");
                                String releaseDate = rs.getString("release_date");
                                String genre = rs.getString("genre");
                                String runtime = rs.getString("running_time");
                                
                                if (genre == null) genre = "정보 없음";
                                if (runtime == null) runtime = "정보 없음";
                                
                                // 포스터 URL이 없는 경우 기본 이미지 사용
                                if (posterUrl == null || posterUrl.isEmpty()) {
                                    posterUrl = "image/default-movie.jpg";
                                }
                    %>
                    <div class="movie-card coming-soon">
                        <div class="movie-poster">
                            <img src="<%= posterUrl %>" alt="<%= title %> 포스터" onerror="this.src='image/default-movie.jpg';">
                            <div class="movie-overlay">
                                <a href="movie-detail.jsp?id=<%= movieId %>" class="detail-btn">상세보기</a>
                            </div>
                            <div class="release-date-badge">
                                <%= releaseDate != null ? releaseDate : "개봉일 미정" %>
                            </div>
                        </div>
                        <div class="movie-info">
                            <h3 class="movie-title"><%= title %></h3>
                            <div class="movie-meta">
                                <span class="genre"><%= genre %></span>
                                <span class="runtime"><%= runtime %></span>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                            
                            // 영화가 없는 경우 메시지 표시
                            if (!hasMovies) {
                    %>
                    <div class="no-movies">
                        <i class="fas fa-film"></i>
                        <p>상영 예정인 영화가 없습니다.</p>
                    </div>
                    <%
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                    %>
                    <div class="error-message">
                        <i class="fas fa-exclamation-circle"></i>
                        <p>영화 정보를 불러오는 중 오류가 발생했습니다.</p>
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
    
    <script src="js/main.js"></script>
</body>
</html>
