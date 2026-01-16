<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaWorld - 영화 상세 정보</title>
    <link rel="stylesheet" href="css/Style.css">
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/movie-detail.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
</head>
<body class="main-page">
    <div class="site-wrapper">
        <!-- 헤더 포함 -->
        <jsp:include page="header.jsp" />
        
        <main class="main-content">
            <%
                String movieId = request.getParameter("id");
                
                if (movieId == null || movieId.isEmpty()) {
                    // ID가 없으면 영화 목록 페이지로 리다이렉트
                    response.sendRedirect("movies.jsp");
                    return;
                }
                
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = DBConnection.getConnection();
                    
                    // 영화 기본 정보와 상세 정보 조회
                    String sql = "SELECT m.*, md.* FROM movie m " +
                                "LEFT JOIN movie_detail md ON m.movie_id = md.movie_id " +
                                "WHERE m.movie_id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, movieId);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        String title = rs.getString("title");
                        String englishTitle = rs.getString("english_title");
                        String posterUrl = rs.getString("poster_url");
                        double rating = rs.getDouble("rating");
                        String director = rs.getString("director");
                        String actors = rs.getString("actors");
                        String plot = rs.getString("plot");
                        String movieRating = rs.getString("md.rating"); // 관람등급
                        String runningTime = rs.getString("running_time");
                        String releaseDate = rs.getString("release_date");
                        String genre = rs.getString("genre");
                        String status = rs.getString("status");
                        
                        // 포스터 URL이 없는 경우 기본 이미지 사용
                        if (posterUrl == null || posterUrl.isEmpty()) {
                            posterUrl = "image/default-movie.jpg";
                        }
                        
                        // 좋아요 상태 확인
                        boolean isLiked = false;
                        if (session.getAttribute("userId") != null) {
                            Integer userId = (Integer) session.getAttribute("userId");
                            PreparedStatement likePstmt = null;
                            ResultSet likeRs = null;
                            
                            try {
                                String likeSql = "SELECT * FROM movie_likes WHERE user_id = ? AND movie_id = ?";
                                likePstmt = conn.prepareStatement(likeSql);
                                likePstmt.setInt(1, userId);
                                likePstmt.setString(2, movieId);
                                likeRs = likePstmt.executeQuery();
                                
                                if (likeRs.next()) {
                                    isLiked = true;
                                }
                            } finally {
                                if (likeRs != null) likeRs.close();
                                if (likePstmt != null) likePstmt.close();
                            }
                        }
            %>
            
            <div class="movie-detail-container">
                <div class="movie-detail-header">
                    <div class="movie-poster">
                        <img src="<%= posterUrl %>" alt="<%= title %> 포스터" onerror="this.src='image/default-movie.jpg';">
                    </div>
                    <div class="movie-info">
                        <h1 class="movie-title"><%= title %></h1>
                        <% if (englishTitle != null && !englishTitle.isEmpty()) { %>
                            <h2 class="english-title"><%= englishTitle %></h2>
                        <% } %>
                        
                        <div class="movie-meta">
                            <% if (movieRating != null && !movieRating.isEmpty()) { %>
                                <span class="rating-badge"><%= movieRating %></span>
                            <% } %>
                            <% if (genre != null && !genre.isEmpty()) { %>
                                <span class="genre"><%= genre %></span>
                            <% } %>
                            <% if (runningTime != null && !runningTime.isEmpty()) { %>
                                <span class="runtime"><%= runningTime %></span>
                            <% } %>
                            <% if (releaseDate != null && !releaseDate.isEmpty()) { %>
                                <span class="release-date"><%= releaseDate %> 개봉</span>
                            <% } %>
                        </div>
                        
                        <div class="movie-rating">
                            <div class="star-rating">
                                <i class="fas fa-star"></i>
                                <span><%= String.format("%.1f", rating) %></span>
                            </div>
                        </div>
                        
                        <div class="movie-people">
                            <% if (director != null && !director.isEmpty()) { %>
                                <div class="director">
                                    <strong>감독:</strong> <%= director %>
                                </div>
                            <% } %>
                            <% if (actors != null && !actors.isEmpty()) { %>
                                <div class="actors">
                                    <strong>출연:</strong> <%= actors %>
                                </div>
                            <% } %>
                        </div>
                        
                        <div class="movie-actions">
                            <% if ("current".equals(status)) { %>
                                <a href="booking/booking.jsp?id=<%= movieId %>" class="booking-btn">
                                    예매
                                </a>
                            <% } else { %>
                                <button class="disabled-btn" disabled>상영 예정작</button>
                            <% } %>
                            
                            <button class="like-btn <%= isLiked ? "liked" : "" %>" id="likeBtn" data-movie-id="<%= movieId %>" title="<%= isLiked ? "좋아요 취소" : "좋아요" %>">
                                <i class="fas fa-thumbs-up"></i>
                            </button>
                        </div>
                    </div>
                </div>
                
                <div class="movie-detail-content">
                    <div class="movie-tabs">
                        <ul class="tab-nav">
                            <li class="active" data-tab="plot">줄거리</li>
                            <li data-tab="reviews">관람평</li>
                        </ul>
                        
                        <div class="tab-content">
                            <div id="plot" class="tab-pane active">
                                <% if (plot != null && !plot.isEmpty()) { %>
                                    <p><%= plot %></p>
                                <% } else { %>
                                    <p class="no-content">등록된 줄거리가 없습니다.</p>
                                <% } %>
                            </div>
                            
                            
                            
                            <div id="reviews" class="tab-pane">
                                <div class="reviews-section">
                                    <!-- 알림 메시지 표시 -->
                                    <% 
                                        String successMessage = (String) session.getAttribute("successMessage");
                                        String errorMessage = (String) session.getAttribute("errorMessage");
                                        
                                        if (successMessage != null) {
                                    %>
                                    <div class="alert alert-success">
                                        <%= successMessage %>
                                    </div>
                                    <%
                                            session.removeAttribute("successMessage");
                                        }
                                        
                                        if (errorMessage != null) {
                                    %>
                                    <div class="alert alert-danger">
                                        <%= errorMessage %>
                                    </div>
                                    <%
                                            session.removeAttribute("errorMessage");
                                        }
                                    %>
                                    
                                    <div class="reviews-header">
                                        <h3>관람객 리뷰</h3>
                                        <% if (session.getAttribute("userId") != null) { %>
                                            <button class="write-review-btn" id="writeReviewBtn">리뷰 작성하기</button>
                                        <% } else { %>
                                            <a href="member/login.jsp?redirect=movie-detail.jsp?id=<%= movieId %>" class="login-to-review">로그인하고 리뷰 작성하기</a>
                                        <% } %>
                                    </div>
                                    
                                    <% if (session.getAttribute("userId") != null) { %>
                                    <div class="review-form" id="reviewForm" style="display: none;">
                                        <form action="ReviewServlet" method="post">
                                            <input type="hidden" name="movieId" value="<%= movieId %>">
                                            <input type="hidden" name="action" value="add">
                                            
                                            <div class="rating-select">
                                                <p>평점:</p>
                                                <div class="star-select">
                                                    <% for (int i = 5; i >= 1; i--) { %>
                                                        <input type="radio" id="star<%= i %>" name="rating" value="<%= i %>" <%= i == 5 ? "checked" : "" %>>
                                                        <label for="star<%= i %>"><i class="fas fa-star"></i></label>
                                                    <% } %>
                                                </div>
                                            </div>
                                            
                                            <textarea name="content" rows="5" placeholder="이 영화에 대한 생각을 자유롭게 작성해주세요." required></textarea>
                                            
                                            <div class="form-actions">
                                                <button type="button" id="cancelReview" class="cancel-btn">취소</button>
                                                <button type="submit" class="submit-btn">등록하기</button>
                                            </div>
                                        </form>
                                    </div>
                                    
                                    <!-- 리뷰 수정 폼 (처음에는 숨겨져 있음) -->
                                    <div class="edit-review-form" id="editReviewForm" style="display: none;">
                                        <form action="ReviewServlet" method="post">
                                            <input type="hidden" name="movieId" value="<%= movieId %>">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="id" id="editReviewId">
                                            
                                            <div class="rating-select">
                                                <p>평점:</p>
                                                <div class="star-select">
                                                    <% for (int i = 5; i >= 1; i--) { %>
                                                        <input type="radio" id="editStar<%= i %>" name="rating" value="<%= i %>">
                                                        <label for="editStar<%= i %>"><i class="fas fa-star"></i></label>
                                                    <% } %>
                                                </div>
                                            </div>
                                            
                                            <textarea name="content" id="editReviewContent" rows="5" placeholder="이 영화에 대한 생각을 자유롭게 작성해주세요." required></textarea>
                                            
                                            <div class="form-actions">
                                                <button type="button" id="cancelEditReview" class="cancel-edit-btn">취소</button>
                                                <button type="submit" class="submit-edit-btn">수정하기</button>
                                            </div>
                                        </form>
                                    </div>
                                    <% } %>
                                    
                                    <div class="reviews-list">
                                        <%
                                            // 영화 리뷰 로드
                                            PreparedStatement reviewPstmt = null;
                                            ResultSet reviewRs = null;
                                            
                                            try {
                                                String reviewSql = "SELECT r.*, u.nickname, u.profile_image FROM review r " +
                                                                  "JOIN user u ON r.user_id = u.id " +
                                                                  "WHERE r.movie_id = ? " +
                                                                  "ORDER BY r.created_at DESC";
                                                reviewPstmt = conn.prepareStatement(reviewSql);
                                                reviewPstmt.setString(1, movieId);
                                                reviewRs = reviewPstmt.executeQuery();
                                                
                                                boolean hasReviews = false;
                                                
                                                while (reviewRs.next()) {
                                                    hasReviews = true;
                                                    int reviewId = reviewRs.getInt("id");
                                                    int userId = reviewRs.getInt("user_id");
                                                    String content = reviewRs.getString("content");
                                                    int reviewRating = reviewRs.getInt("rating");
                                                    int likes = reviewRs.getInt("likes");
                                                    String createdAt = reviewRs.getTimestamp("created_at").toString();
                                                    String nickname = reviewRs.getString("nickname");
                                                    String profileImage = reviewRs.getString("profile_image");
                                                    
                                                    // 프로필 이미지가 없는 경우 기본 이미지 사용
                                                    if (profileImage == null || profileImage.isEmpty()) {
                                                        profileImage = "image/default-profile.png";
                                                    }
                                                    
                                                    // 현재 로그인한 사용자가 작성한 리뷰인지 확인
                                                    boolean isMyReview = session.getAttribute("userId") != null && userId == (Integer)session.getAttribute("userId");
                                                    
                                                    // 현재 로그인한 사용자가 이 리뷰에 좋아요를 눌렀는지 확인
                                                    boolean userLikedReview = false;
                                                    if (session.getAttribute("userId") != null) {
                                                        PreparedStatement likePstmt = null;
                                                        ResultSet likeRs = null;
                                                        
                                                        try {
                                                            String likeSql = "SELECT * FROM review_likes WHERE user_id = ? AND review_id = ?";
                                                            likePstmt = conn.prepareStatement(likeSql);
                                                            likePstmt.setInt(1, (Integer)session.getAttribute("userId"));
                                                            likePstmt.setInt(2, reviewId);
                                                            likeRs = likePstmt.executeQuery();
                                                            
                                                            if (likeRs.next()) {
                                                                userLikedReview = true;
                                                            }
                                                        } finally {
                                                            if (likeRs != null) likeRs.close();
                                                            if (likePstmt != null) likePstmt.close();
                                                        }
                                                    }
                                        %>
                                        <div class="review-item" id="review-<%= reviewId %>">
                                            <div class="review-header">
                                                <div class="reviewer-info">
                                                    <img src="<%= profileImage %>" alt="<%= nickname %> 프로필" class="reviewer-image" onerror="this.src='image/default-profile.png';">
                                                    <span class="reviewer-name"><%= nickname %></span>
                                                </div>
                                                <div class="review-rating">
                                                    <% for (int i = 1; i <= 5; i++) { %>
                                                        <i class="fas fa-star <%= i <= reviewRating ? "filled" : "" %>"></i>
                                                    <% } %>
                                                </div>
                                            </div>
                                            <div class="review-content">
                                                <p><%= content %></p>
                                            </div>
                                            <div class="review-footer">
                                                <div class="review-date"><%= createdAt %></div>
                                                <div class="review-actions">
                                                    <button class="like-review <%= userLikedReview ? "liked" : "" %>" data-id="<%= reviewId %>">
                                                        <i class="fas fa-heart"></i> <span><%= likes %></span>
                                                    </button>
                                                    <% if (isMyReview) { %>
                                                        <button class="edit-review" data-id="<%= reviewId %>">수정</button>
                                                        <a href="ReviewServlet?action=delete&id=<%= reviewId %>&movieId=<%= movieId %>" class="delete-review" onclick="return confirm('정말로 이 리뷰를 삭제하시겠습니까?');">삭제</a>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                                        <%
                                                }
                                                
                                                if (!hasReviews) {
                                        %>
                                        <div class="no-reviews">
                                            <i class="fas fa-comment-slash"></i>
                                            <p>아직 작성된 리뷰가 없습니다.</p>
                                            <p>첫 번째 리뷰를 작성해보세요!</p>
                                        </div>
                                        <%
                                                }
                                            } finally {
                                                if (reviewRs != null) reviewRs.close();
                                                if (reviewPstmt != null) reviewPstmt.close();
                                            }
                                        %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <%
                    } else {
            %>
            <div class="error-container">
                <i class="fas fa-exclamation-circle"></i>
                <h2>영화 정보를 찾을 수 없습니다.</h2>
                <p>요청하신 영화 정보를 찾을 수 없습니다. 다른 영화를 선택해주세요.</p>
                <a href="movies.jsp" class="return-btn">영화 목록으로 돌아가기</a>
            </div>
            <%
                    }
                    
                } catch (SQLException e) {
                    e.printStackTrace();
            %>
            <div class="error-container">
                <i class="fas fa-exclamation-circle"></i>
                <h2>데이터베이스 오류</h2>
                <p>영화 정보를 불러오는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.</p>
                <a href="movies.jsp" class="return-btn">영화 목록으로 돌아가기</a>
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
        </main>
        
        <!-- 푸터 포함 -->
        <jsp:include page="footer.jsp" />
    </div>
    
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // 탭 기능
        const tabNavItems = document.querySelectorAll('.tab-nav li');
        const tabPanes = document.querySelectorAll('.tab-pane');
        
        tabNavItems.forEach(item => {
            item.addEventListener('click', function() {
                // 활성 탭 변경
                tabNavItems.forEach(nav => nav.classList.remove('active'));
                this.classList.add('active');
                
                // 활성 콘텐츠 변경
                const tabId = this.getAttribute('data-tab');
                tabPanes.forEach(pane => pane.classList.remove('active'));
                document.getElementById(tabId).classList.add('active');
            });
        });
        
        // 리뷰 작성 폼 토글
        const writeReviewBtn = document.getElementById('writeReviewBtn');
        const reviewForm = document.getElementById('reviewForm');
        const cancelReview = document.getElementById('cancelReview');
        
        if (writeReviewBtn && reviewForm) {
            writeReviewBtn.addEventListener('click', function() {
                reviewForm.style.display = 'block';
                writeReviewBtn.style.display = 'none';
            });
        }
        
        if (cancelReview && reviewForm && writeReviewBtn) {
            cancelReview.addEventListener('click', function() {
                reviewForm.style.display = 'none';
                writeReviewBtn.style.display = 'block';
            });
        }
        
        // 리뷰 수정 폼 토글
        const editReviewForm = document.getElementById('editReviewForm');
        const cancelEditReview = document.getElementById('cancelEditReview');
        const editButtons = document.querySelectorAll('.edit-review');
        
        if (editButtons.length > 0) {
            editButtons.forEach(button => {
                button.addEventListener('click', function() {
                    const reviewId = this.getAttribute('data-id');
                    
                    // 리뷰 정보 가져오기
                    fetch('ReviewServlet?action=getReview&id=' + reviewId)
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('서버 응답 오류');
                            }
                            return response.json();
                        })
                        .then(data => {
                            if (data.success) {
                                // 수정 폼에 데이터 설정
                                document.getElementById('editReviewId').value = reviewId;
                                document.getElementById('editReviewContent').value = data.content;
                                
                                // 별점 설정
                                const rating = data.rating;
                                for (let i = 1; i <= 5; i++) {
                                    const radioBtn = document.getElementById('editStar' + i);
                                    if (i === rating) {
                                        radioBtn.checked = true;
                                    } else {
                                        radioBtn.checked = false;
                                    }
                                }
                                
                                // 수정 폼 표시
                                editReviewForm.style.display = 'block';
                                
                                // 해당 리뷰로 스크롤
                                const reviewElement = document.getElementById('review-' + reviewId);
                                if (reviewElement) {
                                    reviewElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
                                }
                                
                                // 리뷰 작성 폼 숨기기
                                if (reviewForm) {
                                    reviewForm.style.display = 'none';
                                }
                                if (writeReviewBtn) {
                                    writeReviewBtn.style.display = 'block';
                                }
                            } else {
                                alert('리뷰 정보를 가져오는데 실패했습니다: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('리뷰 정보를 가져오는 중 오류가 발생했습니다. 다시 시도해주세요.');
                        });
                });
            });
        }
        
        if (cancelEditReview && editReviewForm) {
            cancelEditReview.addEventListener('click', function() {
                editReviewForm.style.display = 'none';
            });
        }
        
        // 리뷰 좋아요 버튼 이벤트
        const likeButtons = document.querySelectorAll('.like-review');
        likeButtons.forEach(button => {
            button.addEventListener('click', function() {
                <% if (session.getAttribute("userId") != null) { %>
                    const reviewId = this.getAttribute('data-id');
                    const likeButton = this;
                    
                    // 버튼 상태 변경을 즉시 반영 (UX 개선)
                    const isCurrentlyLiked = this.classList.contains('liked');
                    
                    if (isCurrentlyLiked) {
                        this.classList.remove('liked');
                    } else {
                        this.classList.add('liked');
                    }
                    
                    fetch('ReviewServlet?action=like&id=' + reviewId)
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('서버 응답 오류');
                            }
                            return response.json();
                        })
                        .then(data => {
                            if (data.success) {
                                const countSpan = likeButton.querySelector('span');
                                countSpan.textContent = data.likes;
                                
                                // 서버 응답에 따라 좋아요 상태 업데이트
                                if (data.liked) {
                                    likeButton.classList.add('liked');
                                } else {
                                    likeButton.classList.remove('liked');
                                }
                            } else {
                                alert('좋아요 처리 중 오류가 발생했습니다: ' + data.message);
                                // 오류 발생 시 UI 상태 되돌리기
                                if (isCurrentlyLiked) {
                                    likeButton.classList.add('liked');
                                } else {
                                    likeButton.classList.remove('liked');
                                }
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('좋아요 처리 중 오류가 발생했습니다. 다시 시도해주세요.');
                            // 오류 발생 시 UI 상태 되돌리기
                            if (isCurrentlyLiked) {
                                likeButton.classList.add('liked');
                            } else {
                                likeButton.classList.remove('liked');
                            }
                        });
                <% } else { %>
                    // 로그인되지 않은 경우
                    if (confirm('로그인이 필요한 서비스입니다. 로그인 페이지로 이동하시겠습니까?')) {
                        window.location.href = 'member/login.jsp?redirect=movie-detail.jsp?id=<%= movieId %>';
                    }
                <% } %>
            });
        });

        // 영화 좋아요 버튼 이벤트
        const likeBtn = document.getElementById('likeBtn');
        if (likeBtn) {
            likeBtn.addEventListener('click', function() {
                <% if (session.getAttribute("userId") != null) { %>
                    const movieId = this.getAttribute('data-movie-id');
                    
                    // 버튼 상태 변경을 즉시 반영 (UX 개선)
                    const isCurrentlyLiked = this.classList.contains('liked');
                    
                    if (isCurrentlyLiked) {
                        this.classList.remove('liked');
                        this.title = '좋아요';
                    } else {
                        this.classList.add('liked');
                        this.title = '좋아요 취소';
                    }
                    
                    // 서버에 요청 보내기
                    fetch('MovieLikeServlet?movieId=' + movieId)
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('서버 응답 오류');
                            }
                            return response.json();
                        })
                        .then(data => {
                            console.log('좋아요 응답:', data);
                            if (!data.success) {
                                // 서버 처리 실패 시 UI 상태 되돌리기
                                if (isCurrentlyLiked) {
                                    this.classList.add('liked');
                                    this.title = '좋아요 취소';
                                } else {
                                    this.classList.remove('liked');
                                    this.title = '좋아요';
                                }
                                alert('좋아요 처리 중 오류가 발생했습니다: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            // 오류 발생 시 UI 상태 되돌리기
                            if (isCurrentlyLiked) {
                                this.classList.add('liked');
                                this.title = '좋아요 취소';
                            } else {
                                this.classList.remove('liked');
                                this.title = '좋아요';
                            }
                            alert('좋아요 처리 중 오류가 발생했습니다. 다시 시도해주세요.');
                        });
                <% } else { %>
                    // 로그인되지 않은 경우
                    if (confirm('로그인이 필요한 서비스입니다. 로그인 페이지로 이동하시겠습니까?')) {
                        window.location.href = 'member/login.jsp?redirect=movie-detail.jsp?id=<%= movieId %>';
                    }
                <% } %>
            });
        }
        
        // 알림 메시지 자동 숨김
        const alerts = document.querySelectorAll('.alert');
        if (alerts.length > 0) {
            setTimeout(() => {
                alerts.forEach(alert => {
                    alert.style.display = 'none';
                });
            }, 5000); // 5초 후 숨김
        }
        
        // URL 파라미터에 따라 탭 활성화
        const urlParams = new URLSearchParams(window.location.search);
        const tab = urlParams.get('tab');
        if (tab === 'reviews') {
            // 리뷰 탭 활성화
            tabNavItems.forEach(nav => nav.classList.remove('active'));
            tabPanes.forEach(pane => pane.classList.remove('active'));
            
            const reviewsTab = document.querySelector('[data-tab="reviews"]');
            if (reviewsTab) {
                reviewsTab.classList.add('active');
                document.getElementById('reviews').classList.add('active');
            }
        }
    });
    </script>
</body>
</html>
