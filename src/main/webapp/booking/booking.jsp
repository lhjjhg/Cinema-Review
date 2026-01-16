<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 영화 예매</title>
    <link rel="stylesheet" href="../css/Style.css">
    <link rel="stylesheet" href="../css/main.css">
    <link rel="stylesheet" href="../css/booking.css">
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <style>
    </style>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../header.jsp" />
        
        
        <main class="main-content">
            <section class="booking-section">
                <h1 class="section-title">영화 예매</h1>
                
                <div class="booking-container">
                    <!-- 영화 선택 -->
                    <div class="booking-column movie-column">
                        <div class="column-header">
                            <h2>영화</h2>
                        </div>
                        <div class="column-content">
                            <ul class="movie-list">
                                <%
                                    Connection conn = null;
                                    PreparedStatement pstmt = null;
                                    ResultSet rs = null;
                                    
                                    String selectedMovieId = request.getParameter("id");
                                    
                                    try {
                                        conn = DBConnection.getConnection();
                                        String sql = "SELECT * FROM movie WHERE status = 'current' ORDER BY movie_rank, rating DESC";
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        
                                        while (rs.next()) {
                                            String movieId = rs.getString("movie_id");
                                            String title = rs.getString("title");
                                            boolean isSelected = movieId.equals(selectedMovieId);
                                %>
                                <li class="movie-item <%= isSelected ? "selected" : "" %>" data-movie-id="<%= movieId %>">
                                    <%= title %>
                                </li>
                                <%
                                        }
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                        // 데이터베이스 오류 시 임시 영화 목록 표시
                                %>
                                <li class="movie-item selected" data-movie-id="movie1">어벤져스: 엔드게임</li>
                                <li class="movie-item" data-movie-id="movie2">기생충</li>
                                <li class="movie-item" data-movie-id="movie3">미나리</li>
                                <li class="movie-item" data-movie-id="movie4">스파이더맨: 노 웨이 홈</li>
                                <li class="movie-item" data-movie-id="movie5">듄</li>
                                <li class="movie-item" data-movie-id="movie6">007 노 타임 투 다이</li>
                                <li class="movie-item" data-movie-id="movie7">블랙 위도우</li>
                                <li class="movie-item" data-movie-id="movie8">분노의 질주: 더 얼티메이트</li>
                                <li class="movie-item" data-movie-id="movie9">모가디슈</li>
                                <li class="movie-item" data-movie-id="movie10">샹치와 텐 링즈의 전설</li>
                                <li class="movie-item" data-movie-id="movie11">이터널스</li>
                                <li class="movie-item" data-movie-id="movie12">베놈 2: 렛 데어 비 카니지</li>
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
                            </ul>
                        </div>
                    </div>
                    
                    <!-- 극장 선택 -->
                    <div class="booking-column theater-column">
                        <div class="column-header">
                            <h2>극장</h2>
                        </div>
                        <div class="column-content">
                            <div class="region-tabs">
                                <ul class="region-list">
                                    <li class="region-item selected" data-region="all">전체</li>
                                    <li class="region-item" data-region="서울">서울</li>
                                    <li class="region-item" data-region="경기">경기</li>
                                    <li class="region-item" data-region="인천">인천</li>
                                    <li class="region-item" data-region="대전/충청">대전/충청</li>
                                    <li class="region-item" data-region="대구/경북">대구/경북</li>
                                    <li class="region-item" data-region="부산/경상">부산/경상</li>
                                    <li class="region-item" data-region="광주/전라">광주/전라</li>
                                    <li class="region-item" data-region="제주">제주</li>
                                </ul>
                            </div>
                            <ul class="theater-list">
                                <!-- 서울 -->
                                <li class="theater-item" data-theater-id="1" data-region="서울">CGV 강남</li>
                                <li class="theater-item" data-theater-id="2" data-region="서울">CGV 홍대</li>
                                <li class="theater-item" data-theater-id="3" data-region="서울">CGV 용산 아이파크몰</li>
                                <li class="theater-item" data-theater-id="4" data-region="서울">CGV 영등포</li>
                                <li class="theater-item" data-theater-id="5" data-region="서울">CGV 왕십리</li>
                                <li class="theater-item" data-theater-id="6" data-region="서울">CGV 대학로</li>
                                <li class="theater-item" data-theater-id="7" data-region="서울">CGV 건대입구</li>
                                <li class="theater-item" data-theater-id="8" data-region="서울">CGV 명동</li>
                                <li class="theater-item" data-theater-id="9" data-region="서울">CGV 구로</li>
                                
                                <!-- 경기 -->
                                <li class="theater-item" data-theater-id="10" data-region="경기">CGV 부천</li>
                                <li class="theater-item" data-theater-id="11" data-region="경기">CGV 수원</li>
                                <li class="theater-item" data-theater-id="12" data-region="경기">CGV 일산</li>
                                <li class="theater-item" data-theater-id="13" data-region="경기">CGV 동탄</li>
                                <li class="theater-item" data-theater-id="14" data-region="경기">CGV 광명</li>
                                <li class="theater-item" data-theater-id="15" data-region="경기">CGV 의정부</li>
                                
                                <!-- 인천 -->
                                <li class="theater-item" data-theater-id="16" data-region="인천">CGV 인천</li>
                                <li class="theater-item" data-theater-id="17" data-region="인천">CGV 부평</li>
                                <li class="theater-item" data-theater-id="18" data-region="인천">CGV 청라</li>
                                
                                <!-- 대전/충청 -->
                                <li class="theater-item" data-theater-id="19" data-region="대전/충청">CGV 대전</li>
                                <li class="theater-item" data-theater-id="20" data-region="대전/충청">CGV 청주</li>
                                <li class="theater-item" data-theater-id="21" data-region="대전/충청">CGV 천안</li>
                                
                                <!-- 대구/경북 -->
                                <li class="theater-item" data-theater-id="22" data-region="대구/경북">CGV 대구 현대</li>
                                <li class="theater-item" data-theater-id="23" data-region="대구/경북">CGV 대구 수성</li>
                                <li class="theater-item" data-theater-id="24" data-region="대구/경북">CGV 포항</li>
                                
                                <!-- 부산/경상 -->
                                <li class="theater-item" data-theater-id="25" data-region="부산/경상">CGV 부산 서면</li>
                                <li class="theater-item" data-theater-id="26" data-region="부산/경상">CGV 부산 센텀시티</li>
                                <li class="theater-item" data-theater-id="27" data-region="부산/경상">CGV 울산</li>
                                <li class="theater-item" data-theater-id="28" data-region="부산/경상">CGV 창원</li>
                                
                                <!-- 광주/전라 -->
                                <li class="theater-item" data-theater-id="29" data-region="광주/전라">CGV 광주 터미널</li>
                                <li class="theater-item" data-theater-id="30" data-region="광주/전라">CGV 전주</li>
                                <li class="theater-item" data-theater-id="31" data-region="광주/전라">CGV 목포</li>
                                
                                <!-- 제주 -->
                                <li class="theater-item" data-theater-id="32" data-region="제주">CGV 제주</li>
                            </ul>
                        </div>
                    </div>
                    
                    <!-- 날짜 선택 -->
                    <div class="booking-column date-column">
                        <div class="column-header">
                            <h2>날짜</h2>
                        </div>
                        <div class="column-content">
                            <div class="date-year-month">
                                <%
                                    Calendar currentCal = Calendar.getInstance();
                                    SimpleDateFormat yearMonthFormat = new SimpleDateFormat("yyyy년 MM월");
                                    String currentYearMonth = yearMonthFormat.format(currentCal.getTime());
                                %>
                                <div class="year-month-display"><%= currentYearMonth %></div>
                            </div>
                            <ul class="date-list-vertical">
                                <%
                                    // 오늘부터 14일간의 날짜 표시
                                    Calendar cal = Calendar.getInstance();
                                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");
                                    SimpleDateFormat dayFormat = new SimpleDateFormat("E", Locale.KOREAN);
                                    SimpleDateFormat dayNumFormat = new SimpleDateFormat("dd");
                                    
                                    for (int i = 0; i < 14; i++) {
                                        Date date = cal.getTime();
                                        String formattedDate = dateFormat.format(date);
                                        String day = dayFormat.format(date);
                                        String dayNum = dayNumFormat.format(date);
                                        
                                        // 주말 여부에 따라 클래스 추가
                                        String dayClass = "";
                                        if (day.equals("토")) {
                                            dayClass = "saturday";
                                        } else if (day.equals("일")) {
                                            dayClass = "sunday";
                                        }
                                %>
                                <li class="date-item-vertical <%= i == 0 ? "selected" : "" %>" data-date="<%= formattedDate %>">
                                    <span class="day-name <%= dayClass %>"><%= day %></span>
                                    <span class="day-number"><%= dayNum %></span>
                                </li>
                                <%
                                        cal.add(Calendar.DATE, 1);
                                    }
                                %>
                            </ul>
                        </div>
                    </div>
                    
                    <!-- 시간 선택 -->
                    <div class="booking-column time-column">
                        <div class="column-header">
                            <h2>시간</h2>
                        </div>
                        <div class="column-content">
                            <div class="time-list-container">
                                <div class="no-schedule-message">
                                    <i class="fas fa-film"></i>
                                    <p>영화, 극장, 날짜를 선택해주세요.</p>
                                </div>
                                <div class="time-list" style="display: none;">
                                    <!-- 시간표는 JavaScript로 동적 생성 -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../footer.jsp" />
    </div>
    
    <script src="../js/booking.js"></script>
</body>
</html>
