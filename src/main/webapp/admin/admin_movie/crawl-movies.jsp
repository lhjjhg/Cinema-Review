<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 영화 정보 크롤링</title>
    <link rel="stylesheet" href="../../css/Style.css">
    <link rel="stylesheet" href="../../css/main.css">
    <style>
        .admin-container {
            max-width: 800px;
            margin: 50px auto;
            padding: 30px;
            background-color: rgba(31, 31, 31, 0.9);
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
        
        .admin-title {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .admin-title h1 {
            font-size: 28px;
            color: #fff;
        }
        
        .admin-title p {
            color: #bbb;
        }
        
        .admin-actions {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 40px;
            flex-wrap: wrap;
        }
        
        .admin-btn {
            background-color: #e50914;
            color: white;
            padding: 12px 25px;
            border-radius: 5px;
            border: none;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .admin-btn:hover {
            background-color: #f40612;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }
        
        .admin-btn.secondary {
            background-color: #333;
        }
        
        .admin-btn.secondary:hover {
            background-color: #444;
        }
        
        .admin-btn.debug {
            background-color: #2196F3;
        }
        
        .admin-btn.debug:hover {
            background-color: #0b7dda;
        }
        
        .important-note {
            margin-top: 30px;
            padding: 15px;
            background-color: rgba(229, 9, 20, 0.1);
            border-left: 4px solid #e50914;
            color: #ddd;
        }
        
        .checklist {
            background-color: rgba(255, 255, 255, 0.05);
            padding: 20px;
            border-radius: 5px;
            margin-top: 30px;
        }
        
        .checklist h3 {
            margin-top: 0;
            color: #fff;
        }
        
        .checklist ul {
            list-style-type: none;
            padding-left: 0;
        }
        
        .checklist li {
            margin-bottom: 10px;
            padding-left: 30px;
            position: relative;
            color: #ddd;
        }
        
        .checklist li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: #4CAF50;
        }
        
        .loading {
            display: none;
            text-align: center;
            margin-top: 20px;
        }
        
        .loading-spinner {
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top: 4px solid #e50914;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 15px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="../../header.jsp" />
        
        <main class="main-content">
            <div class="admin-container">
                <div class="admin-title">
                    <h1>영화 정보 크롤링</h1>
                    <p>CGV 영화 정보를 크롤링하여 데이터베이스에 저장합니다</p>
                </div>
                
                <div class="checklist">
                    <h3>크롤링 전 확인사항</h3>
                    <ul>
                        <li>jsoup 라이브러리가 WEB-INF/lib 폴더에 추가되어 있는지 확인하세요.</li>
                        <li>데이터베이스 연결 정보(DBConnection.java)가 올바른지 확인하세요.</li>
                        <li>필요한 테이블이 데이터베이스에 생성되어 있는지 확인하세요.</li>
                        <li>인터넷 연결이 안정적인지 확인하세요.</li>
                        <li>크롤링은 시간이 걸릴 수 있으므로 페이지를 닫지 마세요.</li>
                    </ul>
                </div>
                
                <div class="important-note">
                    <p><strong>주의사항:</strong> 이 기능은 관리자만 사용할 수 있습니다. 크롤링은 서버 부하를 일으킬 수 있으므로 필요한 경우에만 실행하세요.</p>
                    <p>영화 정보가 크롤링되면 기존 정보는 업데이트되고, 새로운 영화는 추가됩니다.</p>
                </div>
                
                <div class="loading" id="loadingIndicator">
                    <div class="loading-spinner"></div>
                    <p>크롤링 중입니다. 이 작업은 몇 분 정도 소요될 수 있습니다.</p>
                </div>
                
                <div class="admin-actions">
                    <button class="admin-btn" id="crawlBtn">영화 정보 크롤링 시작</button>
                    <a href="crawl-debug.jsp" class="admin-btn debug">디버그 페이지</a>
                    <a href="../index.jsp" class="admin-btn secondary">돌아가기</a>
                </div>
            </div>
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../../footer.jsp" />
    </div>
    
    <script>
    document.getElementById('crawlBtn').addEventListener('click', function() {
        if (confirm('영화 정보 크롤링을 시작하시겠습니까?\n이 작업은 몇 분 정도 소요될 수 있습니다.')) {
            this.disabled = true;
            this.textContent = '크롤링 진행 중...';
            
            // 로딩 인디케이터 표시
            document.getElementById('loadingIndicator').style.display = 'block';
            
            // 페이지 이동
            window.location.href = 'crawl-movies';
        }
    });
    </script>
</body>
</html>
