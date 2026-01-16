<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.StatisticsDAO" %>
<%@ page import="java.util.*" %>
<%@ include file="../admin-check.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 사이트 통계</title>
    <link rel="stylesheet" href="../../css/Style.css">
    <link rel="stylesheet" href="../../css/main.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .stats-container {
            max-width: 1200px;
            margin: 50px auto;
            padding: 30px;
            background-color: rgba(31, 31, 31, 0.9);
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
        
        .stats-title {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .stats-title h1 {
            font-size: 32px;
            color: #fff;
            margin-bottom: 10px;
        }
        
        .stats-title p {
            color: #bbb;
            font-size: 16px;
        }
        
        .stats-overview {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        
        .stat-card {
            background-color: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 20px;
            text-align: center;
        }
        
        .stat-card .stat-value {
            font-size: 36px;
            font-weight: bold;
            color: #e50914;
            margin-bottom: 10px;
        }
        
        .stat-card .stat-label {
            font-size: 16px;
            color: #fff;
        }
        
        .stats-charts {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(500px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }
        
        .chart-container {
            background-color: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 20px;
        }
        
        .chart-title {
            font-size: 20px;
            color: #fff;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .stats-tables {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(500px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }
        
        .table-container {
            background-color: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 20px;
        }
        
        .table-title {
            font-size: 20px;
            color: #fff;
            margin-bottom: 20px;
            text-align: center;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        table th, table td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        table th {
            color: #e50914;
            font-weight: bold;
        }
        
        table td {
            color: #fff;
            vertical-align: middle;
            white-space: nowrap;
        }

        table td:nth-child(3) {
            white-space: normal;
            max-width: 200px;
            word-wrap: break-word;
        }
        
        .activity-table .activity-type {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            white-space: nowrap;
            min-width: 40px;
            text-align: center;
            vertical-align: middle;
        }
        
        .activity-table .activity-type.review {
            background-color: #4CAF50;
            color: white;
        }
        
        .activity-table .activity-type.board {
            background-color: #2196F3;
            color: white;
        }
        
        .activity-table .activity-type.comment {
            background-color: #FF9800;
            color: white;
        }
        
        .back-link {
            display: block;
            text-align: center;
            margin-top: 40px;
            color: #bbb;
            text-decoration: none;
            transition: color 0.3s ease;
            padding: 12px 25px;
            background: linear-gradient(135deg, #555, #666);
            border-radius: 25px;
            font-weight: 600;
            max-width: 300px;
            margin: 40px auto 0;
        }
        
        .back-link:hover {
            color: #fff;
            background: linear-gradient(135deg, #666, #777);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
        }
        
        .error-message {
            color: #e50914;
            text-align: center;
            padding: 50px;
            background-color: rgba(255, 255, 255, 0.03);
            border-radius: 12px;
            border: 1px solid rgba(229, 9, 20, 0.2);
        }
        
        @media (max-width: 768px) {
            .stats-charts, .stats-tables {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../../header.jsp" />
        
        <main class="main-content">
            <div class="stats-container">
                <div class="stats-title">
                    <h1>사이트 통계</h1>
                    <p>CinemaWorld 사이트의 통계 정보를 확인합니다</p>
                </div>
                
                <%
                try {
                    StatisticsDAO statsDAO = new StatisticsDAO();
                    
                    // 기본 통계 데이터
                    int totalUsers = statsDAO.getTotalUserCount();
                    int todayUsers = statsDAO.getTodayUserCount();
                    int totalMovies = statsDAO.getTotalMovieCount();
                    int totalReviews = statsDAO.getTotalReviewCount();
                    int totalBoards = statsDAO.getTotalBoardCount();
                    int totalComments = statsDAO.getTotalCommentCount();
                    
                    // 인기 영화 TOP 5
                    List<Map<String, Object>> topMovies = statsDAO.getTopMovies();
                    
                    // 활발한 사용자 TOP 5
                    List<Map<String, Object>> topUsers = statsDAO.getTopUsers();
                    
                    // 최근 활동 내역
                    List<Map<String, Object>> recentActivities = statsDAO.getRecentActivities();
                    
                    // 월별 가입자 통계
                    Map<String, Integer> monthlyRegistrations = statsDAO.getMonthlyRegistrations();
                    
                    // 카테고리별 게시글 수
                    Map<String, Integer> categoryPostCounts = statsDAO.getCategoryPostCounts();
                %>
                
                <!-- 기본 통계 -->
                <div class="stats-overview">
                    <div class="stat-card">
                        <div class="stat-value"><%= totalUsers %></div>
                        <div class="stat-label">총 사용자 수</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= todayUsers %></div>
                        <div class="stat-label">오늘 가입자 수</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= totalMovies %></div>
                        <div class="stat-label">총 영화 수</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= totalReviews %></div>
                        <div class="stat-label">총 리뷰 수</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= totalBoards %></div>
                        <div class="stat-label">총 게시글 수</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= totalComments %></div>
                        <div class="stat-label">총 댓글 수</div>
                    </div>
                </div>
                
                <!-- 차트 -->
                <div class="stats-charts">
                    <div class="chart-container">
                        <div class="chart-title">월별 가입자 통계</div>
                        <canvas id="registrationChart"></canvas>
                    </div>
                    <div class="chart-container">
                        <div class="chart-title">카테고리별 게시글 수</div>
                        <canvas id="categoryChart"></canvas>
                    </div>
                </div>
                
                <!-- 테이블 -->
                <div class="stats-tables">
                    <div class="table-container">
                        <div class="table-title">인기 영화 TOP 5</div>
                        <table>
                            <thead>
                                <tr>
                                    <th>순위</th>
                                    <th>제목</th>
                                    <th>평점</th>
                                    <th>리뷰 수</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                if (topMovies != null && !topMovies.isEmpty()) {
                                    int rank = 1;
                                    for (Map<String, Object> movie : topMovies) { 
                                %>
                                <tr>
                                    <td><%= rank++ %></td>
                                    <td><%= movie.get("title") != null ? movie.get("title") : "제목 없음" %></td>
                                    <td><%= movie.get("rating") != null ? String.format("%.1f", movie.get("rating")) : "0.0" %></td>
                                    <td><%= movie.get("reviewCount") != null ? movie.get("reviewCount") : "0" %></td>
                                </tr>
                                <% 
                                    }
                                } else {
                                %>
                                <tr>
                                    <td colspan="4" style="text-align: center;">데이터가 없습니다</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div class="table-container">
                        <div class="table-title">활발한 사용자 TOP 5</div>
                        <table>
                            <thead>
                                <tr>
                                    <th>순위</th>
                                    <th>닉네임</th>
                                    <th>리뷰</th>
                                    <th>게시글</th>
                                    <th>댓글</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                if (topUsers != null && !topUsers.isEmpty()) {
                                    int rank = 1;
                                    for (Map<String, Object> user : topUsers) { 
                                %>
                                <tr>
                                    <td><%= rank++ %></td>
                                    <td><%= user.get("nickname") != null ? user.get("nickname") : "닉네임 없음" %></td>
                                    <td><%= user.get("reviewCount") != null ? user.get("reviewCount") : "0" %></td>
                                    <td><%= user.get("boardCount") != null ? user.get("boardCount") : "0" %></td>
                                    <td><%= user.get("commentCount") != null ? user.get("commentCount") : "0" %></td>
                                </tr>
                                <% 
                                    }
                                } else {
                                %>
                                <tr>
                                    <td colspan="5" style="text-align: center;">데이터가 없습니다</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- 최근 활동 -->
                <div class="table-container activity-table">
                    <div class="table-title">최근 활동 내역</div>
                    <table>
                        <thead>
                            <tr>
                                <th>유형</th>
                                <th>사용자</th>
                                <th>내용</th>
                                <th>대상</th>
                                <th>날짜</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            if (recentActivities != null && !recentActivities.isEmpty()) {
                                for (Map<String, Object> activity : recentActivities) { 
                                    String type = (String)activity.get("type");
                                    String typeClass = "";
                                    String typeText = "";
                                    
                                    if ("review".equals(type)) {
                                        typeClass = "review";
                                        typeText = "리뷰";
                                    } else if ("board".equals(type)) {
                                        typeClass = "board";
                                        typeText = "게시글";
                                    } else if ("comment".equals(type)) {
                                        typeClass = "comment";
                                        typeText = "댓글";
                                    }
                            %>
                            <tr>
                                <td><span class="activity-type <%= typeClass %>"><%= typeText %></span></td>
                                <td><%= activity.get("nickname") != null ? activity.get("nickname") : "사용자 없음" %></td>
                                <td><%= activity.get("content") != null ? (((String)activity.get("content")).length() > 30 ? ((String)activity.get("content")).substring(0, 30) + "..." : activity.get("content")) : "내용 없음" %></td>
                                <td><%= activity.get("target") != null ? activity.get("target") : "대상 없음" %></td>
                                <td><%= activity.get("createdAt") != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(activity.get("createdAt")) : "날짜 없음" %></td>
                            </tr>
                            <% 
                                }
                            } else {
                            %>
                            <tr>
                                <td colspan="5" style="text-align: center;">최근 활동이 없습니다</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <script>
                    // 월별 가입자 통계 데이터
                    const monthlyRegistrationData = {
                        <% 
                        if (monthlyRegistrations != null && !monthlyRegistrations.isEmpty()) {
                            boolean firstMonth = true;
                            for (Map.Entry<String, Integer> entry : monthlyRegistrations.entrySet()) {
                                if (!firstMonth) {
                                    out.print(", ");
                                }
                                out.print("\"" + entry.getKey() + "\": " + entry.getValue());
                                firstMonth = false;
                            }
                        } else {
                            out.print("\"데이터 없음\": 0");
                        }
                        %>
                    };
                    
                    // 카테고리별 게시글 수 데이터
                    const categoryPostData = {
                        <% 
                        if (categoryPostCounts != null && !categoryPostCounts.isEmpty()) {
                            boolean firstCategory = true;
                            for (Map.Entry<String, Integer> entry : categoryPostCounts.entrySet()) {
                                if (!firstCategory) {
                                    out.print(", ");
                                }
                                out.print("\"" + entry.getKey() + "\": " + entry.getValue());
                                firstCategory = false;
                            }
                        } else {
                            out.print("\"데이터 없음\": 0");
                        }
                        %>
                    };
                    
                    // 월별 가입자 통계 차트
                    const registrationCtx = document.getElementById('registrationChart').getContext('2d');
                    
                    const months = Object.keys(monthlyRegistrationData).sort();
                    const registrationCounts = months.map(month => monthlyRegistrationData[month]);
                    
                    new Chart(registrationCtx, {
                        type: 'line',
                        data: {
                            labels: months,
                            datasets: [{
                                label: '가입자 수',
                                data: registrationCounts,
                                backgroundColor: 'rgba(229, 9, 20, 0.2)',
                                borderColor: 'rgba(229, 9, 20, 1)',
                                borderWidth: 2,
                                tension: 0.3
                            }]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: {
                                    labels: {
                                        color: '#fff'
                                    }
                                }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    ticks: {
                                        color: '#fff'
                                    },
                                    grid: {
                                        color: 'rgba(255, 255, 255, 0.1)'
                                    }
                                },
                                x: {
                                    ticks: {
                                        color: '#fff'
                                    },
                                    grid: {
                                        color: 'rgba(255, 255, 255, 0.1)'
                                    }
                                }
                            }
                        }
                    });
                    
                    // 카테고리별 게시글 수 차트
                    const categoryCtx = document.getElementById('categoryChart').getContext('2d');
                    
                    const categories = Object.keys(categoryPostData);
                    const postCounts = categories.map(category => categoryPostData[category]);
                    
                    // 색상 배열 생성
                    const backgroundColors = [
                        'rgba(229, 9, 20, 0.7)',
                        'rgba(54, 162, 235, 0.7)',
                        'rgba(255, 206, 86, 0.7)',
                        'rgba(75, 192, 192, 0.7)',
                        'rgba(153, 102, 255, 0.7)',
                        'rgba(255, 159, 64, 0.7)',
                        'rgba(199, 199, 199, 0.7)',
                        'rgba(83, 102, 255, 0.7)',
                        'rgba(255, 99, 132, 0.7)',
                        'rgba(54, 162, 235, 0.7)'
                    ];
                    
                    new Chart(categoryCtx, {
                        type: 'pie',
                        data: {
                            labels: categories,
                            datasets: [{
                                data: postCounts,
                                backgroundColor: backgroundColors,
                                borderColor: 'rgba(255, 255, 255, 0.8)',
                                borderWidth: 1
                            }]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: {
                                    position: 'right',
                                    labels: {
                                        color: '#fff'
                                    }
                                }
                            }
                        }
                    });
                </script>
                
                <%
                } catch (Exception e) {
                    e.printStackTrace();
                %>
                <div class="error-message">
                    <h3>통계 데이터를 불러오는 중 오류가 발생했습니다.</h3>
                    <p>오류 내용: <%= e.getMessage() %></p>
                    <p>관리자에게 문의하시기 바랍니다.</p>
                </div>
                <%
                }
                %>
                
                <a href="../index.jsp" class="back-link">관리자 메인 페이지로 돌아가기</a>
            </div>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../../footer.jsp" />
    </div>
</body>
</html>
