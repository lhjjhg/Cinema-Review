<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>크롤링 디버그 페이지</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: #fff;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1, h2 {
            color: #333;
        }
        .card {
            background: #f9f9f9;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            border-left: 4px solid #4CAF50;
        }
        .error {
            border-left: 4px solid #f44336;
            background: #ffebee;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .btn {
            display: inline-block;
            background: #4CAF50;
            color: white;
            padding: 10px 15px;
            text-decoration: none;
            border-radius: 5px;
            margin-right: 10px;
            border: none;
            cursor: pointer;
        }
        .btn-error {
            background: #f44336;
        }
        pre {
            background: #f0f0f0;
            padding: 10px;
            overflow-x: auto;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>영화 크롤링 디버그 페이지</h1>
        <p>이 페이지에서는 크롤링 과정에서 발생할 수 있는 다양한 문제를 진단하고 해결할 수 있습니다.</p>
        
        <h2>1. 데이터베이스 연결 테스트</h2>
        <div class="card <%= request.getParameter("db_test") != null ? "" : "hidden" %>">
            <%
                if (request.getParameter("db_test") != null) {
                    Connection conn = null;
                    try {
                        conn = DBConnection.getConnection();
                        out.println("<p>✅ 데이터베이스 연결 성공!</p>");
                        
                        // 테이블 존재 여부 확인
                        DatabaseMetaData dbm = conn.getMetaData();
                        ResultSet tables = dbm.getTables(null, null, "movie", null);
                        boolean movieTableExists = tables.next();
                        
                        tables = dbm.getTables(null, null, "movie_detail", null);
                        boolean detailTableExists = tables.next();
                        
                        tables = dbm.getTables(null, null, "movie_stillcut", null);
                        boolean stillcutTableExists = tables.next();
                        
                        out.println("<p>테이블 존재 여부:</p>");
                        out.println("<ul>");
                        out.println("<li>movie 테이블: " + (movieTableExists ? "존재함 ✅" : "존재하지 않음 ❌") + "</li>");
                        out.println("<li>movie_detail 테이블: " + (detailTableExists ? "존재함 ✅" : "존재하지 않음 ❌") + "</li>");
                        out.println("<li>movie_stillcut 테이블: " + (stillcutTableExists ? "존재함 ✅" : "존재하지 않음 ❌") + "</li>");
                        out.println("</ul>");
                    } catch (Exception e) {
                        out.println("<div class='card error'>");
                        out.println("<p>❌ 데이터베이스 연결 실패: " + e.getMessage() + "</p>");
                        out.println("<pre>");
                        e.printStackTrace(new java.io.PrintWriter(out));
                        out.println("</pre>");
                        out.println("</div>");
                    } finally {
                        if (conn != null) {
                            try {
                                conn.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                    }
                }
            %>
        </div>
        <form method="get">
            <button type="submit" name="db_test" value="true" class="btn">데이터베이스 연결 테스트</button>
        </form>
        
        <h2>2. JSoup 연결 테스트</h2>
        <div class="card <%= request.getParameter("jsoup_test") != null ? "" : "hidden" %>">
            <%
                if (request.getParameter("jsoup_test") != null) {
                    try {
                        String testUrl = "http://www.cgv.co.kr/movies/";
                        org.jsoup.Connection jsoupConn = org.jsoup.Jsoup.connect(testUrl)
                                .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
                                .timeout(30000);
                        
                        org.jsoup.nodes.Document doc = jsoupConn.get();
                        String title = doc.title();
                        
                        out.println("<p>✅ JSoup 연결 성공!</p>");
                        out.println("<p>페이지 제목: " + title + "</p>");
                        
                        // CGV 영화 차트 요소 확인
                        org.jsoup.select.Elements movieElements = doc.select(".sect-movie-chart ol li");
                        int movieCount = movieElements.size();
                        
                        out.println("<p>찾은 영화 개수: " + movieCount + "</p>");
                        
                        if (movieCount > 0) {
                            out.println("<table>");
                            out.println("<tr><th>순위</th><th>제목</th><th>포스터</th></tr>");
                            
                            for (int i = 0; i < Math.min(3, movieCount); i++) {
                                org.jsoup.nodes.Element movie = movieElements.get(i);
                                String rank = movie.select(".rank").text();
                                String movieTitle = movie.select(".title").text();
                                String posterUrl = movie.select(".thumb-image img").attr("src");
                                
                                out.println("<tr>");
                                out.println("<td>" + rank + "</td>");
                                out.println("<td>" + movieTitle + "</td>");
                                out.println("<td><img src='" + posterUrl + "' width='100' alt='" + movieTitle + "'></td>");
                                out.println("</tr>");
                            }
                            
                            out.println("</table>");
                        } else {
                            out.println("<p class='error'>영화 목록을 찾을 수 없습니다. CGV 웹사이트 구조가 변경되었을 수 있습니다.</p>");
                        }
                        
                    } catch (Exception e) {
                        out.println("<div class='card error'>");
                        out.println("<p>❌ JSoup 연결 실패: " + e.getMessage() + "</p>");
                        out.println("<pre>");
                        e.printStackTrace(new java.io.PrintWriter(out));
                        out.println("</pre>");
                        out.println("</div>");
                    }
                }
            %>
        </div>
        <form method="get">
            <button type="submit" name="jsoup_test" value="true" class="btn">JSoup 연결 테스트</button>
        </form>
        
        <h2>3. 현재 영화 테이블 데이터 확인</h2>
        <div class="card <%= request.getParameter("check_movies") != null ? "" : "hidden" %>">
            <%
                if (request.getParameter("check_movies") != null) {
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    
                    try {
                        conn = DBConnection.getConnection();
                        
                        String sql = "SELECT COUNT(*) FROM movie";
                        pstmt = conn.prepareStatement(sql);
                        rs = pstmt.executeQuery();
                        
                        int movieCount = 0;
                        if (rs.next()) {
                            movieCount = rs.getInt(1);
                        }
                        
                        if (movieCount > 0) {
                            out.println("<p>✅ movie 테이블에 " + movieCount + "개의 영화가 있습니다.</p>");
                            
                            // 영화 데이터 샘플 확인
                            sql = "SELECT * FROM movie LIMIT 5";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            
                            out.println("<table>");
                            out.println("<tr><th>ID</th><th>영화 ID</th><th>제목</th><th>평점</th><th>상태</th></tr>");
                            
                            while (rs.next()) {
                                out.println("<tr>");
                                out.println("<td>" + rs.getInt("id") + "</td>");
                                out.println("<td>" + rs.getString("movie_id") + "</td>");
                                out.println("<td>" + rs.getString("title") + "</td>");
                                out.println("<td>" + rs.getDouble("rating") + "</td>");
                                out.println("<td>" + rs.getString("status") + "</td>");
                                out.println("</tr>");
                            }
                            
                            out.println("</table>");
                        } else {
                            out.println("<p>❌ movie 테이블에 영화가 없습니다.</p>");
                        }
                        
                    } catch (Exception e) {
                        out.println("<div class='card error'>");
                        out.println("<p>❌ 데이터베이스 조회 실패: " + e.getMessage() + "</p>");
                        out.println("<pre>");
                        e.printStackTrace(new java.io.PrintWriter(out));
                        out.println("</pre>");
                        out.println("</div>");
                    } finally {
                        try {
                            if (rs != null) rs.close();
                            if (pstmt != null) pstmt.close();
                            if (conn != null) conn.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                }
            %>
        </div>
        <form method="get">
            <button type="submit" name="check_movies" value="true" class="btn">영화 데이터 확인</button>
        </form>
        
        <h2>4. 테이블 재생성 (주의: 기존 데이터 삭제됨)</h2>
        <div class="card <%= request.getParameter("recreate_tables") != null ? "" : "hidden" %>">
            <%
                if (request.getParameter("recreate_tables") != null) {
                    Connection conn = null;
                    Statement stmt = null;
                    
                    try {
                        conn = DBConnection.getConnection();
                        stmt = conn.createStatement();
                        
                        // 테이블 삭제 (외래 키 제약 조건 때문에 순서 중요)
                        stmt.executeUpdate("DROP TABLE IF EXISTS movie_stillcut");
                        stmt.executeUpdate("DROP TABLE IF EXISTS movie_detail");
                        stmt.executeUpdate("DROP TABLE IF EXISTS review");
                        stmt.executeUpdate("DROP TABLE IF EXISTS movie");
                        
                        out.println("<p>✅ 테이블 삭제 완료</p>");
                        
                        // 테이블 재생성
                        stmt.executeUpdate(
                            "CREATE TABLE movie (" +
                            "id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "movie_id VARCHAR(50) NOT NULL UNIQUE, " +
                            "title VARCHAR(255) NOT NULL, " +
                            "poster_url VARCHAR(500), " +
                            "rating DOUBLE DEFAULT 0, " +
                            "movie_rank INT, " +
                            "release_date VARCHAR(100), " +
                            "genre VARCHAR(100), " +
                            "running_time VARCHAR(50), " +
                            "status VARCHAR(20) DEFAULT 'current', " +
                            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                            "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                            ")"
                        );
                        
                        stmt.executeUpdate(
                            "CREATE TABLE movie_detail (" +
                            "id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "movie_id VARCHAR(50) NOT NULL UNIQUE, " +
                            "english_title VARCHAR(255), " +
                            "director VARCHAR(255), " +
                            "actors TEXT, " +
                            "plot TEXT, " +
                            "rating VARCHAR(50), " +
                            "running_time VARCHAR(50), " +
                            "release_date VARCHAR(100), " +
                            "genre VARCHAR(100), " +
                            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                            "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, " +
                            "FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE CASCADE" +
                            ")"
                        );
                        
                        stmt.executeUpdate(
                            "CREATE TABLE movie_stillcut (" +
                            "id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "movie_id VARCHAR(50) NOT NULL, " +
                            "image_url VARCHAR(500) NOT NULL, " +
                            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                            "FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE CASCADE" +
                            ")"
                        );
                        
                        out.println("<p>✅ 테이블 재생성 완료</p>");
                        
                    } catch (Exception e) {
                        out.println("<div class='card error'>");
                        out.println("<p>❌ 테이블 재생성 실패: " + e.getMessage() + "</p>");
                        out.println("<pre>");
                        e.printStackTrace(new java.io.PrintWriter(out));
                        out.println("</pre>");
                        out.println("</div>");
                    } finally {
                        try {
                            if (stmt != null) stmt.close();
                            if (conn != null) conn.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                }
            %>
        </div>
        <form method="get" onsubmit="return confirm('정말로 테이블을 재생성하시겠습니까? 모든 영화 데이터가 삭제됩니다!');">
            <button type="submit" name="recreate_tables" value="true" class="btn btn-error">테이블 재생성</button>
        </form>
        
        <br>
        <hr>
        <a href="crawl-movies.jsp" class="btn">크롤링 페이지로 돌아가기</a>
        <a href="../index.jsp" class="btn">메인 페이지로 이동</a>
    </div>
</body>
</html>
