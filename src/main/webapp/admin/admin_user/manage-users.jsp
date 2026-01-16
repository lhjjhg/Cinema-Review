<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../admin-check.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 사용자 관리</title>
    <link rel="stylesheet" href="../../css/Style.css">
    <link rel="stylesheet" href="../../css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
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
            margin-bottom: 40px;
        }
        
        .admin-title h1 {
            font-size: 32px;
            color: #fff;
            margin-bottom: 10px;
            position: relative;
            display: inline-block;
        }
        
        .admin-title h1:after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 3px;
            background-color: #e50914;
        }
        
        .admin-title p {
            color: #bbb;
            font-size: 16px;
            margin-top: 20px;
        }
        
        .user-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            color: #fff;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            border-radius: 8px;
        }
        
        .user-table th, .user-table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .user-table th {
            background-color: rgba(229, 9, 20, 0.8);
            color: white;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 14px;
            letter-spacing: 1px;
        }
        
        .user-table tr:hover {
            background-color: rgba(255, 255, 255, 0.05);
            transition: all 0.3s ease;
        }
        
        .user-table tr:last-child td {
            border-bottom: none;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
        }
        
        .action-btn {
            padding: 8px 14px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
            font-size: 13px;
        }
        
        .edit-btn {
            background-color: #4CAF50;
            color: white;
        }
        
        .delete-btn {
            background-color: #e50914;
            color: white;
        }
        
        .action-btn:hover {
            opacity: 0.8;
            transform: translateY(-2px);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }
        
        .search-filter {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
            background-color: rgba(255, 255, 255, 0.05);
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        
        .search-box {
            display: flex;
            gap: 10px;
            flex: 1;
            max-width: 500px;
        }
        
        .search-box input {
            padding: 12px 15px;
            border: none;
            border-radius: 4px;
            background-color: #333;
            color: #fff;
            flex: 1;
            font-size: 14px;
            box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.2);
        }
        
        .search-box button {
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            background-color: #e50914;
            color: white;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }
        
        .search-box button:hover {
            background-color: #c70812;
            transform: translateY(-2px);
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 30px;
        }
        
        .pagination a {
            color: #fff;
            padding: 10px 16px;
            text-decoration: none;
            transition: all 0.3s;
            border: 1px solid #333;
            margin: 0 4px;
            border-radius: 4px;
        }
        
        .pagination a.active {
            background-color: #e50914;
            color: white;
            border: 1px solid #e50914;
        }
        
        .pagination a:hover:not(.active) {
            background-color: #333;
            transform: translateY(-2px);
        }
        
        .back-link {
            display: inline-block;
            text-align: center;
            margin-top: 40px;
            color: #bbb;
            text-decoration: none;
            transition: all 0.3s ease;
            padding: 10px 20px;
            border: 1px solid #444;
            border-radius: 4px;
            background-color: rgba(255, 255, 255, 0.05);
        }
        
        .back-link:hover {
            color: #e50914;
            background-color: rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.8);
            backdrop-filter: blur(5px);
            transition: all 0.3s ease;
        }
        
        .modal-content {
            background-color: #1f1f1f;
            margin: 10% auto;
            padding: 30px;
            border-radius: 10px;
            width: 50%;
            max-width: 500px;
            color: #fff;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            transform: translateY(20px);
            opacity: 0;
            transition: all 0.3s ease;
        }
        
        .modal.show .modal-content {
            transform: translateY(0);
            opacity: 1;
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 1px solid #333;
            padding-bottom: 15px;
        }
        
        .modal-title {
            font-size: 24px;
            font-weight: 600;
            color: #e50914;
        }
        
        .close {
            color: #aaa;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .close:hover {
            color: #e50914;
            transform: rotate(90deg);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #ddd;
        }
        
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #333;
            border-radius: 4px;
            background-color: #333;
            color: #fff;
            font-size: 14px;
            transition: all 0.3s;
        }
        
        .form-group input:focus, .form-group select:focus {
            border-color: #e50914;
            outline: none;
            box-shadow: 0 0 0 2px rgba(229, 9, 20, 0.2);
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 30px;
        }
        
        .form-actions button {
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }
        
        .save-btn {
            background-color: #4CAF50;
            color: white;
        }
        
        .save-btn:hover {
            background-color: #3e8e41;
            transform: translateY(-2px);
        }
        
        .cancel-btn {
            background-color: #555;
            color: white;
        }
        
        .cancel-btn:hover {
            background-color: #444;
            transform: translateY(-2px);
        }
        
        .no-data {
            text-align: center;
            padding: 40px;
            color: #aaa;
            font-style: italic;
            background-color: rgba(255, 255, 255, 0.02);
            border-radius: 8px;
            margin-top: 20px;
        }
        
        /* 애니메이션 효과 */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .user-table {
            animation: fadeIn 0.5s ease-out;
        }
        
        .admin-title h1 {
            animation: fadeIn 0.5s ease-out;
        }
        
        /* 반응형 디자인 */
        @media (max-width: 992px) {
            .modal-content {
                width: 70%;
            }
        }
        
        @media (max-width: 768px) {
            .search-filter {
                flex-direction: column;
                gap: 15px;
            }
            
            .search-box {
                max-width: 100%;
            }
            
            .user-table th:nth-child(5),
            .user-table td:nth-child(5),
            .user-table th:nth-child(6),
            .user-table td:nth-child(6) {
                display: none;
            }
            
            .modal-content {
                width: 90%;
                padding: 20px;
            }
        }
        
        @media (max-width: 576px) {
            .user-table th:nth-child(4),
            .user-table td:nth-child(4) {
                display: none;
            }
            
            .action-buttons {
                flex-direction: column;
                gap: 5px;
            }
            
            .action-btn {
                width: 100%;
                text-align: center;
            }
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
                    <h1>사용자 관리</h1>
                    <p>시스템에 등록된 사용자 정보를 관리합니다</p>
                </div>
                
                <div class="search-filter">
                    <div class="search-box">
                        <input type="text" id="searchInput" placeholder="사용자명, 닉네임 또는 이름으로 검색...">
                        <button onclick="searchUsers()"><i class="fas fa-search"></i> 검색</button>
                    </div>
                </div>
                
                <table class="user-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>사용자명</th>
                            <th>닉네임</th>
                            <th>이름</th>
                            <th>가입일</th>
                            <th>작업</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        boolean hasData = false;
                        
                        try {
                            conn = DBConnection.getConnection();
                            String sql = "SELECT * FROM user ORDER BY id";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            
                            while(rs.next()) {
                                hasData = true;
                                int id = rs.getInt("id");
                                String userName = rs.getString("username") != null ? rs.getString("username") : "";
                                String userNickname = rs.getString("nickname") != null ? rs.getString("nickname") : "";
                                String name = rs.getString("name") != null ? rs.getString("name") : "";
                                Timestamp createdAt = rs.getTimestamp("created_at");
                                
                                // JavaScript에서 안전하게 사용할 수 있도록 특수문자 이스케이프
                                String safeUserName = userName.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"");
                                String safeUserNickname = userNickname.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"");
                                String safeName = name.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"");
                        %>
                        <tr>
                            <td><%= id %></td>
                            <td><%= userName %></td>
                            <td><%= userNickname %></td>
                            <td><%= name %></td>
                            <td><%= createdAt %></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="action-btn edit-btn" onclick="openEditModal(<%= id %>, '<%= safeUserName %>', '<%= safeUserNickname %>', '<%= safeName %>')">
                                        <i class="fas fa-edit"></i> 수정
                                    </button>
                                    <button class="action-btn delete-btn" onclick="confirmDelete(<%= id %>, '<%= safeUserName %>')">
                                        <i class="fas fa-trash-alt"></i> 삭제
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <%
                            }
                        } catch(Exception e) {
                            e.printStackTrace();
                        } finally {
                            if(rs != null) try { rs.close(); } catch(Exception e) {}
                            if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                            if(conn != null) try { conn.close(); } catch(Exception e) {}
                        }
                        
                        if (!hasData) {
                        %>
                        <tr>
                            <td colspan="6" class="no-data">등록된 사용자가 없습니다.</td>
                        </tr>
                        <%
                        }
                        %>
                    </tbody>
                </table>
                
                <div class="pagination">
                    <a href="#" class="active">1</a>
                    <a href="#">2</a>
                    <a href="#">3</a>
                    <a href="#">4</a>
                    <a href="#">5</a>
                </div>
                
                <a href="../index.jsp" class="back-link"><i class="fas fa-arrow-left"></i> 관리자 메인으로 돌아가기</a>
            </div>
        </main>
        
        <!-- 사용자 수정 모달 -->
        <div id="editModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="modal-title">사용자 정보 수정</h2>
                    <span class="close">&times;</span>
                </div>
                <form id="editForm" action="update_user.jsp" method="post">
                    <input type="hidden" id="userId" name="userId">
                    <div class="form-group">
                        <label for="username">사용자명</label>
                        <input type="text" id="username" name="username" readonly>
                    </div>
                    <div class="form-group">
                        <label for="nickname">닉네임</label>
                        <input type="text" id="nickname" name="nickname" required>
                    </div>
                    <div class="form-group">
                        <label for="name">이름</label>
                        <input type="text" id="name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="address">주소</label>
                        <input type="text" id="address" name="address">
                    </div>
                    <div class="form-actions">
                        <button type="button" class="cancel-btn" onclick="closeModal()">취소</button>
                        <button type="submit" class="save-btn">저장</button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- 푸터 포함 -->
        <jsp:include page="../../footer.jsp" />
    </div>
    
    <script>
        // 사용자 검색 함수
        function searchUsers() {
            const input = document.getElementById('searchInput').value.toLowerCase();
            const rows = document.querySelectorAll('.user-table tbody tr');
            
            rows.forEach(row => {
                if (row.querySelector('.no-data')) return;
                
                const username = row.cells[1].textContent.toLowerCase();
                const nickname = row.cells[2].textContent.toLowerCase();
                const name = row.cells[3].textContent.toLowerCase();
                
                if (username.includes(input) || nickname.includes(input) || name.includes(input)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }
        
        // 수정 모달 열기
        function openEditModal(id, username, nickname, name) {
            console.log('Opening edit modal for user:', { id, username, nickname, name });
            
            document.getElementById('userId').value = id;
            document.getElementById('username').value = username;
            document.getElementById('nickname').value = nickname;
            document.getElementById('name').value = name;
            
            // 추가 사용자 데이터 가져오기
            fetch('get_user_data.jsp?id=' + encodeURIComponent(id))
                .then(response => {
                    if (!response.ok) {
                        throw new Error('네트워크 응답이 올바르지 않습니다.');
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.error) {
                        console.error('서버 오류:', data.error);
                        document.getElementById('address').value = '';
                    } else {
                        document.getElementById('address').value = data.address || '';
                    }
                })
                .catch(error => {
                    console.error('Error fetching user data:', error);
                    document.getElementById('address').value = '';
                });
            
            const modal = document.getElementById('editModal');
            modal.style.display = 'block';
            setTimeout(() => {
                modal.classList.add('show');
            }, 10);
        }
        
        // 삭제 확인
        function confirmDelete(id, username) {
            console.log('Attempting to delete user:', { id, username });
            
            // ID 유효성 검사
            if (!id || id === '' || id === 'undefined' || id === 'null') {
                alert('사용자 ID가 올바르지 않습니다.');
                return;
            }
            
            // 사용자명이 없는 경우 기본값 설정
            const displayName = username && username !== '' ? username : 'Unknown User';
            
            // 확인 메시지
            const confirmMessage = '정말로 사용자 "' + displayName + '" (ID: ' + id + ')을(를) 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.';
            
            if (confirm(confirmMessage)) {
                console.log('User confirmed deletion, redirecting to:', 'delete_user.jsp?id=' + encodeURIComponent(id));
                window.location.href = 'delete_user.jsp?id=' + encodeURIComponent(id);
            }
        }
        
        // 모달 닫기
        function closeModal() {
            const modal = document.getElementById('editModal');
            modal.classList.remove('show');
            setTimeout(() => {
                modal.style.display = 'none';
            }, 300);
        }
        
        // 모달 닫기 버튼 이벤트
        document.querySelector('.close').addEventListener('click', closeModal);
        
        // 모달 외부 클릭 시 닫기
        window.addEventListener('click', function(event) {
            if (event.target == document.getElementById('editModal')) {
                closeModal();
            }
        });
        
        // 페이지 로드 시 실행
        document.addEventListener('DOMContentLoaded', function() {
            // 세션 메시지 확인 및 표시
            <%
            String deleteSuccess = (String) session.getAttribute("deleteSuccess");
            String deleteError = (String) session.getAttribute("deleteError");
            String deleteMessage = (String) session.getAttribute("deleteMessage");
            
            if ("true".equals(deleteSuccess)) {
                session.removeAttribute("deleteSuccess");
                session.removeAttribute("deleteMessage");
            %>
                alert('<%= deleteMessage != null ? deleteMessage.replace("'", "\\'") : "사용자가 성공적으로 삭제되었습니다." %>');
            <%
            } else if ("true".equals(deleteError)) {
                session.removeAttribute("deleteError");
                session.removeAttribute("deleteMessage");
            %>
                alert('<%= deleteMessage != null ? deleteMessage.replace("'", "\\'") : "오류가 발생했습니다." %>');
            <%
            }
            %>
            
            // URL 파라미터 확인
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('success') === 'true') {
                const message = urlParams.get('message') || '작업이 성공적으로 완료되었습니다.';
                alert(decodeURIComponent(message));
                // URL에서 파라미터 제거
                window.history.replaceState({}, document.title, window.location.pathname);
            } else if (urlParams.get('error')) {
                const errorType = urlParams.get('error');
                const message = urlParams.get('message');
                
                let errorMessage = '오류가 발생했습니다.';
                if (message) {
                    errorMessage = decodeURIComponent(message);
                } else {
                    switch(errorType) {
                        case 'update':
                            errorMessage = '사용자 정보 업데이트에 실패했습니다.';
                            break;
                        case 'delete':
                            errorMessage = '사용자 삭제에 실패했습니다.';
                            break;
                        case 'invalid_id':
                            errorMessage = '잘못된 사용자 ID입니다.';
                            break;
                        case 'exception':
                            errorMessage = '시스템 오류가 발생했습니다.';
                            break;
                    }
                }
                
                alert(errorMessage);
                // URL에서 파라미터 제거
                window.history.replaceState({}, document.title, window.location.pathname);
            }
            
            // 페이지네이션 이벤트
            const paginationLinks = document.querySelectorAll('.pagination a');
            paginationLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    paginationLinks.forEach(l => l.classList.remove('active'));
                    this.classList.add('active');
                });
            });
        });
    </script>
</body>
</html>
