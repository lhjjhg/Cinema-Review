<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 좌석 선택</title>
    <link rel="stylesheet" href="../css/Style.css">
    <link rel="stylesheet" href="../css/main.css">
    <link rel="stylesheet" href="../css/booking.css">
    <link rel="stylesheet" href="../css/seat-selection.css">
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../header.jsp" />
        
        <main class="main-content">
            <section class="seat-selection-section">
                <h1 class="section-title">좌석 선택</h1>
                
                <%
                    // URL 파라미터에서 영화 정보 가져오기
                    String screeningId = request.getParameter("screeningId");
                    String movieId = request.getParameter("movieId");
                    String movieTitle = request.getParameter("movieTitle");
                    String theaterName = request.getParameter("theaterName");
                    String selectedDate = request.getParameter("date");
                    String selectedTime = request.getParameter("time");
                    
                    // 기본값 설정
                    if (movieTitle == null || movieTitle.isEmpty()) {
                        movieTitle = "영화 정보 없음";
                    }
                    if (theaterName == null || theaterName.isEmpty()) {
                        theaterName = "극장 정보 없음";
                    }
                    if (selectedDate == null || selectedDate.isEmpty()) {
                        selectedDate = "날짜 정보 없음";
                    }
                    if (selectedTime == null || selectedTime.isEmpty()) {
                        selectedTime = "시간 정보 없음";
                    }
                    
                    // 날짜 형식 변경 (yyyy/MM/dd -> yyyy년 MM월 dd일)
                    String formattedDate = selectedDate;
                    if (selectedDate.contains("/")) {
                        try {
                            String[] dateParts = selectedDate.split("/");
                            if (dateParts.length == 3) {
                                formattedDate = dateParts[0] + "년 " + dateParts[1] + "월 " + dateParts[2] + "일";
                            }
                        } catch (Exception e) {
                            // 날짜 파싱 실패 시 원본 사용
                        }
                    }
                    
                    // 이미 예매된 좌석 정보 가져오기
                    Set<String> occupiedSeats = new HashSet<>();
                    
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    
                    try {
                        conn = DBConnection.getConnection();
                        
                        // 해당 상영에 대한 예매된 좌석 조회
                        String sql = "SELECT bs.seat_row, bs.seat_col " +
                                    "FROM booking b " +
                                    "JOIN booking_seat bs ON b.id = bs.booking_id " +
                                    "WHERE b.movie_title = ? AND b.theater_name = ? " +
                                    "AND b.screening_date = ? AND b.screening_time = ?";
                        
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, movieTitle);
                        pstmt.setString(2, theaterName);
                        pstmt.setString(3, selectedDate);
                        pstmt.setString(4, selectedTime);
                        
                        rs = pstmt.executeQuery();
                        
                        while (rs.next()) {
                            String row = rs.getString("seat_row");
                            int col = rs.getInt("seat_col");
                            occupiedSeats.add(row + col);
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
                
                <div class="movie-info-container">
                    <div class="movie-info">
                        <h2><%= movieTitle %></h2>
                        <p><%= theaterName %></p>
                        <p><%= formattedDate %> <%= selectedTime %></p>
                    </div>
                </div>
                
                <div class="seat-selection-container">
                    <div class="ticket-selection">
                        <div class="ticket-type">
                            <span class="ticket-label">일반</span>
                            <div class="ticket-counter">
                                <button class="counter-btn minus" data-type="adult">-</button>
                                <span class="counter-value" id="adult-count">0</span>
                                <button class="counter-btn plus" data-type="adult">+</button>
                            </div>
                        </div>
                        <div class="ticket-type">
                            <span class="ticket-label">청소년</span>
                            <div class="ticket-counter">
                                <button class="counter-btn minus" data-type="youth">-</button>
                                <span class="counter-value" id="youth-count">0</span>
                                <button class="counter-btn plus" data-type="youth">+</button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="seat-map-container">
                        <div class="screen">SCREEN</div>
                        
                        <div class="seat-map">
                            <% 
                                // 상영관별 좌석 수 설정
                                int totalRows = 10;
                                int totalCols = 18;
                                boolean isIMAX = false;
                                
                                // 상영관 ID에 따라 좌석 수 조정
                                if (screeningId != null) {
                                    int screeningIdInt = Integer.parseInt(screeningId);
                                    if (screeningIdInt >= 100 && screeningIdInt < 200) {
                                        // 1관 (일반)
                                        totalRows = 10;
                                        totalCols = 15;
                                    } else if (screeningIdInt >= 200 && screeningIdInt < 300) {
                                        // 2관 (일반)
                                        totalRows = 8;
                                        totalCols = 15;
                                    } else if (screeningIdInt >= 300 && screeningIdInt < 400) {
                                        // 3관 (IMAX) - 특별 배치
                                        totalRows = 7;
                                        isIMAX = true;
                                    }
                                }
                                
                                // 좌석 행 배열
                                String[] rows = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"};
                                
                                if (isIMAX) {
                                    // IMAX 상영관 특별 배치
                                    for (int i = 0; i < totalRows; i++) {
                                        String row = rows[i];
                            %>
                            <div class="seat-row">
                                <div class="row-label"><%= row %></div>
                                <%
                                    if (i < 6) {
                                        // A~F행: 2 + 4 + 2 = 8석
                                        // 좌측 2석
                                        for (int col = 1; col <= 2; col++) {
                                            String seatId = row + col;
                                            String seatClass = "seat";
                                            if (occupiedSeats.contains(seatId)) {
                                                seatClass += " occupied";
                                            }
                                %>
                                <div class="<%= seatClass %>" data-seat-id="<%= seatId %>">
                                    <span class="seat-number"><%= col %></span>
                                </div>
                                <%
                                        }
                                %>
                                <!-- 좌측 통로 -->
                                <div class="aisle"></div>
                                <%
                                        // 가운데 4석
                                        for (int col = 3; col <= 6; col++) {
                                            String seatId = row + col;
                                            String seatClass = "seat";
                                            if (occupiedSeats.contains(seatId)) {
                                                seatClass += " occupied";
                                            }
                                %>
                                <div class="<%= seatClass %>" data-seat-id="<%= seatId %>">
                                    <span class="seat-number"><%= col %></span>
                                </div>
                                <%
                                        }
                                %>
                                <!-- 우측 통로 -->
                                <div class="aisle"></div>
                                <%
                                        // 우측 2석
                                        for (int col = 7; col <= 8; col++) {
                                            String seatId = row + col;
                                            String seatClass = "seat";
                                            if (occupiedSeats.contains(seatId)) {
                                                seatClass += " occupied";
                                            }
                                %>
                                <div class="<%= seatClass %>" data-seat-id="<%= seatId %>">
                                    <span class="seat-number"><%= col %></span>
                                </div>
                                <%
                                        }
                                    } else {
                                        // G행: VIP 2석만
                                        for (int col = 1; col <= 2; col++) {
                                            String seatId = row + col;
                                            String seatClass = "seat vip";
                                            if (occupiedSeats.contains(seatId)) {
                                                seatClass += " occupied";
                                            }
                                %>
                                <div class="<%= seatClass %>" data-seat-id="<%= seatId %>">
                                    <span class="seat-number"><%= col %></span>
                                </div>
                                <%
                                        }
                                    }
                                %>
                            </div>
                            <%
                                    }
                                } else {
                                    // 일반 상영관 배치
                                    for (int i = 0; i < totalRows; i++) {
                                        String row = rows[i];
                            %>
                            <div class="seat-row">
                                <div class="row-label"><%= row %></div>
                                <% 
                                    for (int col = 1; col <= totalCols; col++) {
                                        String seatId = row + col;
                                        String seatClass = "seat";
                                        
                                        // 이미 예매된 좌석인지 확인
                                        if (occupiedSeats.contains(seatId)) {
                                            seatClass += " occupied";
                                        }
                                        
                                        // 복도 설정 (4번째와 totalCols-4번째 좌석 사이)
                                        if (col == 4 || col == totalCols - 4) {
                                            seatClass += " aisle-right";
                                        }
                                %>
                                <div class="<%= seatClass %>" data-seat-id="<%= seatId %>">
                                    <span class="seat-number"><%= col %></span>
                                </div>
                                <% } %>
                            </div>
                            <% 
                                    }
                                }
                            %>
                        </div>
                        
                        <div class="seat-legend">
                            <div class="legend-item">
                                <div class="seat-sample"></div>
                                <span>선택 가능</span>
                            </div>
                            <div class="legend-item">
                                <div class="seat-sample selected"></div>
                                <span>선택한 좌석</span>
                            </div>
                            <div class="legend-item">
                                <div class="seat-sample occupied"></div>
                                <span>예매된 좌석</span>
                            </div>
                            <% if (isIMAX) { %>
                            <div class="legend-item">
                                <div class="seat-sample vip"></div>
                                <span>VIP석</span>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    
                    <div class="booking-summary">
                        <div class="summary-item">
                            <span class="summary-label">선택한 좌석</span>
                            <span class="summary-value" id="selected-seats">-</span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">인원</span>
                            <span class="summary-value" id="selected-people">인원을 선택해주세요</span>
                        </div>
                    </div>
                    
                    <div class="booking-actions">
                        <button class="action-btn back-btn" onclick="history.back()">이전으로</button>
                        <button class="action-btn book-btn" id="book-btn" disabled>예매하기</button>
                    </div>
                </div>
                
                <!-- 예매 정보를 서버로 전송하기 위한 폼 -->
                <form id="booking-form" action="../BookingServlet" method="post" style="display: none;">
                    <input type="hidden" name="screeningId" value="<%= screeningId %>">
                    <input type="hidden" name="movieId" value="<%= movieId != null ? movieId : "" %>">
                    <input type="hidden" name="movieTitle" value="<%= movieTitle %>">
                    <input type="hidden" name="theaterName" value="<%= theaterName %>">
                    <input type="hidden" name="screeningDate" value="<%= selectedDate %>">
                    <input type="hidden" name="screeningTime" value="<%= selectedTime %>">
                    <input type="hidden" name="adultCount" id="adult-count-input" value="0">
                    <input type="hidden" name="youthCount" id="youth-count-input" value="0">
                    <input type="hidden" name="selectedSeats" id="selected-seats-input" value="">
                </form>
            </section>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../footer.jsp" />
    </div>
    
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // 요소 참조
        const adultCountEl = document.getElementById('adult-count');
        const youthCountEl = document.getElementById('youth-count');
        const selectedSeatsEl = document.getElementById('selected-seats');
        const selectedPeopleEl = document.getElementById('selected-people');
        const bookBtn = document.getElementById('book-btn');
        const bookingForm = document.getElementById('booking-form');
        const adultCountInput = document.getElementById('adult-count-input');
        const youthCountInput = document.getElementById('youth-count-input');
        const selectedSeatsInput = document.getElementById('selected-seats-input');
        
        // 상태 변수
        let adultCount = 0;
        let youthCount = 0;
        let selectedSeats = [];
        
        // 인원 수 조절 버튼 이벤트
        document.querySelectorAll('.counter-btn').forEach(btn => {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                
                const type = this.getAttribute('data-type');
                const isPlus = this.classList.contains('plus');
                
                if (type === 'adult') {
                    if (isPlus && adultCount < 8) {
                        adultCount++;
                    } else if (!isPlus && adultCount > 0) {
                        adultCount--;
                    }
                    adultCountEl.textContent = adultCount;
                    adultCountInput.value = adultCount;
                } else if (type === 'youth') {
                    if (isPlus && youthCount < 8) {
                        youthCount++;
                    } else if (!isPlus && youthCount > 0) {
                        youthCount--;
                    }
                    youthCountEl.textContent = youthCount;
                    youthCountInput.value = youthCount;
                }
                
                // 총 인원 수 제한 (최대 8명)
                const totalCount = adultCount + youthCount;
                if (totalCount > 8) {
                    if (type === 'adult') {
                        adultCount--;
                        adultCountEl.textContent = adultCount;
                        adultCountInput.value = adultCount;
                    } else {
                        youthCount--;
                        youthCountEl.textContent = youthCount;
                        youthCountInput.value = youthCount;
                    }
                    alert('최대 8명까지 선택 가능합니다.');
                }
                
                // 선택한 인원 수가 선택한 좌석 수보다 적으면 좌석 선택 초기화
                if (totalCount < selectedSeats.length) {
                    resetSeatSelection();
                }
                
                updateSummary();
                validateSelection();
            });
        });
        
        // 좌석 선택 이벤트
        document.querySelectorAll('.seat').forEach(seat => {
            seat.addEventListener('click', function() {
                if (this.classList.contains('occupied')) {
                    alert('이미 예매된 좌석입니다.');
                    return; // 이미 예약된 좌석은 선택 불가
                }
                
                const seatId = this.getAttribute('data-seat-id');
                
                if (this.classList.contains('selected')) {
                    // 선택 해제
                    this.classList.remove('selected');
                    selectedSeats = selectedSeats.filter(id => id !== seatId);
                } else {
                    // 선택한 인원 수 확인
                    const totalSelected = adultCount + youthCount;
                    
                    if (selectedSeats.length >= totalSelected) {
                        alert('선택한 인원 수보다 많은 좌석을 선택할 수 없습니다.');
                        return;
                    }
                    
                    // 좌석 선택
                    this.classList.add('selected');
                    selectedSeats.push(seatId);
                }
                
                updateSummary();
                validateSelection();
            });
        });
        
        // 좌석 선택 초기화 함수
        function resetSeatSelection() {
            document.querySelectorAll('.seat.selected').forEach(seat => {
                seat.classList.remove('selected');
            });
            selectedSeats = [];
            alert('인원 수가 변경되어 좌석 선택이 초기화되었습니다.');
        }
        
        // 예매 버튼 클릭 이벤트
        bookBtn.addEventListener('click', function() {
            if (!validateSelection()) {
                return;
            }
            
            // 로그인 상태 확인
            fetch('../CheckLoginServlet')
                .then(response => response.json())
                .then(data => {
                    if (!data.loggedIn) {
                        alert('로그인이 필요합니다.');
                        window.location.href = '../member/login.jsp?redirect=' + encodeURIComponent(window.location.pathname + window.location.search);
                        return;
                    }
                    
                    // 폼 제출
                    selectedSeatsInput.value = selectedSeats.join(',');
                    bookingForm.submit();
                })
                .catch(error => {
                    console.error('로그인 상태 확인 중 오류:', error);
                    // 오류 발생 시에도 폼 제출 시도
                    selectedSeatsInput.value = selectedSeats.join(',');
                    bookingForm.submit();
                });
        });
        
        // 요약 정보 업데이트
        function updateSummary() {
            // 선택한 좌석 정보 업데이트
            if (selectedSeats.length > 0) {
                selectedSeatsEl.textContent = selectedSeats.sort().join(', ');
            } else {
                selectedSeatsEl.textContent = '-';
            }
            
            // 인원 정보 업데이트
            const totalPeople = adultCount + youthCount;
            if (totalPeople > 0) {
                selectedPeopleEl.textContent = '일반 ' + adultCount + '명, 청소년 ' + youthCount + '명 (총 ' + totalPeople + '명)';
            } else {
                selectedPeopleEl.textContent = '인원을 선택해주세요';
            }
        }
        
        // 선택 유효성 검사
        function validateSelection() {
            const totalPeople = adultCount + youthCount;
            const isValid = totalPeople > 0 && selectedSeats.length === totalPeople;
            
            bookBtn.disabled = !isValid;
            
            return isValid;
        }
        
        // 초기화
        updateSummary();
    });
    </script>
</body>
</html>
