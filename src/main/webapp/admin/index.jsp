<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="admin-check.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 관리자 페이지</title>
    <link rel="stylesheet" href="../css/Style.css">
    <link rel="stylesheet" href="../css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        .admin-container {
            max-width: 1200px;
            margin: 50px auto;
            padding: 30px;
            background-color: rgba(31, 31, 31, 0.9);
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
        
        .admin-title {
            text-align: center;
            margin-bottom: 50px;
        }
        
        .admin-title h1 {
            font-size: 36px;
            color: #fff;
            margin-bottom: 15px;
            position: relative;
            display: inline-block;
        }
        
        .admin-title h1:after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 100px;
            height: 4px;
            background: linear-gradient(90deg, #e50914, #f40612);
            border-radius: 2px;
        }
        
        .admin-title p {
            color: #bbb;
            font-size: 18px;
            margin-top: 20px;
        }
        
        .admin-sections {
            display: grid;
            gap: 40px;
        }
        
        .admin-section {
            background-color: rgba(255, 255, 255, 0.03);
            border-radius: 12px;
            padding: 30px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .section-title {
            display: flex;
            align-items: center;
            margin-bottom: 25px;
            font-size: 24px;
            color: #fff;
            font-weight: 600;
        }
        
        .section-title i {
            margin-right: 15px;
            color: #e50914;
            font-size: 28px;
        }
        
        .admin-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
        }
        
        .admin-card {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.05), rgba(255, 255, 255, 0.02));
            border-radius: 10px;
            padding: 25px;
            text-align: center;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.05);
            position: relative;
            overflow: hidden;
        }
        
        .admin-card:before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(229, 9, 20, 0.1), transparent);
            transition: left 0.5s ease;
        }
        
        .admin-card:hover:before {
            left: 100%;
        }
        
        .admin-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.3);
            border-color: rgba(229, 9, 20, 0.3);
        }
        
        .admin-card i {
            font-size: 48px;
            color: #e50914;
            margin-bottom: 20px;
            display: block;
        }
        
        .admin-card h3 {
            color: #fff;
            margin-bottom: 15px;
            font-size: 20px;
            font-weight: 600;
        }
        
        .admin-card p {
            color: #bbb;
            margin-bottom: 25px;
            line-height: 1.6;
            font-size: 14px;
        }
        
        .admin-btn {
            background: linear-gradient(135deg, #e50914, #f40612);
            color: white;
            padding: 12px 25px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
            position: relative;
            overflow: hidden;
        }
        
        .admin-btn:before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s ease;
        }
        
        .admin-btn:hover:before {
            left: 100%;
        }
        
        .admin-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(229, 9, 20, 0.4);
        }
        
        
        
        
        
        
        
        
        
        
        
        .logout-section {
            text-align: center;
            margin-top: 50px;
            padding-top: 30px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .logout-btn {
            background: linear-gradient(135deg, #555, #666);
            color: white;
            padding: 12px 30px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
        }
        
        .logout-btn:hover {
            background: linear-gradient(135deg, #666, #777);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
        }
        
        @media (max-width: 768px) {
            .admin-grid {
                grid-template-columns: 1fr;
            }
            
            
            
            .admin-card {
                padding: 20px;
            }
            
            .admin-card i {
                font-size: 36px;
            }
        }
    </style>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../header.jsp" />
        
        <main class="main-content">
            <div class="admin-container">
                <div class="admin-title">
                    <h1><i class="fas fa-crown"></i> 관리자 대시보드</h1>
                    <p>CinemaWorld 시스템을 효율적으로 관리하세요</p>
                </div>
                
                <div class="admin-sections">
                    <!-- 영화 관리 섹션 -->
                    <div class="admin-section">
                        <div class="section-title">
                            <i class="fas fa-film"></i>
                            영화 관리
                        </div>
                        <div class="admin-grid">
                           <!-- <div class="admin-card">
                                <i class="fas fa-spider"></i>
                                <h3>영화 크롤링</h3>
                                <p>CGV에서 최신 영화 정보를 자동으로 수집합니다</p>
                                <a href="admin_movie/crawl-movies.jsp" class="admin-btn">크롤링 시작</a>
                            </div> -->
                            <div class="admin-card">
                                <i class="fas fa-list-alt"></i>
                                <h3>영화 목록 관리</h3>
                                <p>등록된 영화들을 조회, 수정, 삭제할 수 있습니다</p>
                                <a href="admin_movie/manage-movies.jsp" class="admin-btn">영화 관리</a>
                            </div>
                            <div class="admin-card">
                                <i class="fas fa-plus-circle"></i>
                                <h3>영화 직접 추가</h3>
                                <p>영화 정보를 수동으로 입력하여 추가합니다</p>
                                <a href="admin_movie/add-movie.jsp" class="admin-btn">영화 추가</a>
                            </div>
                            <div class="admin-card">
                                <i class="fas fa-sync-alt"></i>
                                <h3>데이터 초기화</h3>
                                <p>영화 데이터베이스를 완전히 초기화합니다</p>
                                <a href="admin_movie/reset-movies.jsp" class="admin-btn">데이터 초기화</a>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 사용자 관리 섹션 -->
                    <div class="admin-section">
                        <div class="section-title">
                            <i class="fas fa-users"></i>
                            사용자 관리
                        </div>
                        <div class="admin-grid">
                            <div class="admin-card">
                                <i class="fas fa-user-cog"></i>
                                <h3>사용자 관리</h3>
                                <p>등록된 사용자들의 정보를 관리합니다</p>
                                <a href="admin_user/manage-users.jsp" class="admin-btn">사용자 관리</a>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 커뮤니티 관리 섹션 -->
                    <div class="admin-section">
                        <div class="section-title">
                            <i class="fas fa-comments"></i>
                            커뮤니티 관리
                        </div>
                        <div class="admin-grid">
                            <div class="admin-card">
                                <i class="fas fa-clipboard-list"></i>
                                <h3>게시판 관리</h3>
                                <p>게시글, 댓글, 카테고리를 관리합니다</p>
                                <a href="admin_board/manage-boards.jsp" class="admin-btn">게시판 관리</a>
                            </div>
                            <div class="admin-card">
                                <i class="fas fa-star"></i>
                                <h3>리뷰 관리</h3>
                                <p>사용자 리뷰를 관리하고 부적절한 내용을 제재합니다</p>
                                <a href="admin_review/manage-reviews.jsp" class="admin-btn">리뷰 관리</a>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 통계 및 분석 섹션 -->
                    <div class="admin-section">
                        <div class="section-title">
                            <i class="fas fa-chart-bar"></i>
                            통계 및 분석
                        </div>
                        <div class="admin-grid">
                            <div class="admin-card">
                                <i class="fas fa-analytics"></i>
                                <h3>사이트 통계</h3>
                                <p>사용자 활동, 인기 콘텐츠 등의 통계를 확인합니다</p>
                                <a href="stats/site-statistics.jsp" class="admin-btn">통계 보기</a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- 로그아웃 섹션 -->
                <div class="logout-section">
                    <a href="../index.jsp" class="logout-btn">
                        <i class="fas fa-home"></i> 메인 페이지로 돌아가기
                    </a>
                </div>
            </div>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../footer.jsp" />
    </div>
</body>
</html>
