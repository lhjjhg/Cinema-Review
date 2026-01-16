<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 세션에서 사용자 정보 가져오기
    String username = (String) session.getAttribute("username");
    Integer userId = (Integer) session.getAttribute("userId");
    String nickname = (String) session.getAttribute("nickname");
    boolean isLoggedIn = (username != null && userId != null);
    
    // 관리자 여부 확인
    String userRole = (String) session.getAttribute("userRole");
    boolean isAdmin = (userRole != null && userRole.equals("ADMIN"));
    
    // 현재 경로 확인
    String currentPath = request.getRequestURI();
    String contextPath = request.getContextPath();
%>
<link rel="stylesheet" href="<%= contextPath %>/css/main.css">
<header class="site-header">
    <div class="header-container">
        <div class="logo-search-container">
            <div class="logo">
                <a href="<%= contextPath %>/index.jsp">
                    <i class="fas fa-film"></i>
                    <h1>CinemaWorld</h1>
                </a>
            </div>
            <div class="search-container">
                <form action="<%= contextPath %>/search.jsp" method="get">
                    <input type="text" name="query" placeholder="영화 검색..." required>
                    <button type="submit"><i class="fas fa-search"></i></button>
                </form>
            </div>
        </div>
        <nav class="main-nav">
            <ul class="nav-links">
                <li><a href="<%= contextPath %>/index.jsp" class="nav-link <%= currentPath.endsWith("index.jsp") ? "active" : "" %>">홈</a></li>
                <li><a href="<%= contextPath %>/movies.jsp" class="nav-link <%= currentPath.endsWith("movies.jsp") ? "active" : "" %>">영화</a></li>
                 <li><a href="<%= contextPath %>/booking/booking.jsp" class="nav-link <%= currentPath.endsWith("booking.jsp") || currentPath.contains("/booking/") ? "active" : "" %>">예매</a></li>
                <li><a href="<%= contextPath %>/board/list.jsp?category=1" class="nav-link <%= currentPath.contains("/board/") ? "active" : "" %>">게시판</a></li>
                <% if (isLoggedIn) { %>
                    <% if (isAdmin) { %>
                        <li><a href="<%= contextPath %>/admin/index.jsp" class="nav-link <%= currentPath.contains("/admin/") ? "active" : "" %>">관리자</a></li>
                    <% } else { %>
                        <li><a href="<%= contextPath %>/member/profile.jsp" class="nav-link <%= currentPath.endsWith("member/profile.jsp") ? "active" : "" %>">마이페이지</a></li>
                    <% } %>
                    <li><a href="<%= contextPath %>/member/logout.jsp" class="nav-link logout">로그아웃</a></li>
                <% } else { %>
                    <li><a href="<%= contextPath %>/member/login.jsp" class="nav-link <%= currentPath.endsWith("member/login.jsp") ? "active" : "" %>">로그인</a></li>
                    <li><a href="<%= contextPath %>/member/register.jsp" class="nav-link <%= currentPath.endsWith("member/register.jsp") ? "active" : "" %>">회원가입</a></li>
                <% } %>
            </ul>
        </nav>
        <div class="mobile-menu-toggle">
            <i class="fas fa-bars"></i>
        </div>
    </div>
</header>