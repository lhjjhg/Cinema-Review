package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import DB.DBConnection;
import dto.Movie;
import dto.User;

public class StatisticsDAO {
    
    // 총 사용자 수 가져오기
    public int getTotalUserCount() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM user";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return count;
    }
    
    // 오늘 가입한 사용자 수 가져오기
    public int getTodayUserCount() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM user WHERE DATE(created_at) = CURDATE()";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return count;
    }
    
    // 총 영화 수 가져오기
    public int getTotalMovieCount() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM movie";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return count;
    }
    
    // 총 리뷰 수 가져오기
    public int getTotalReviewCount() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM review";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return count;
    }
    
    // 총 게시글 수 가져오기
    public int getTotalBoardCount() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM board";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return count;
    }
    
    // 총 댓글 수 가져오기
    public int getTotalCommentCount() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM board_comment";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return count;
    }
    
    // 인기 영화 TOP 5 가져오기
    public List<Map<String, Object>> getTopMovies() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> movies = new ArrayList<>();
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT m.movie_id, m.title, m.rating, COUNT(r.id) as review_count " +
                         "FROM movie m " +
                         "LEFT JOIN review r ON m.movie_id = r.movie_id " +
                         "GROUP BY m.movie_id " +
                         "ORDER BY m.rating DESC, review_count DESC " +
                         "LIMIT 5";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> movie = new HashMap<>();
                movie.put("movieId", rs.getString("movie_id"));
                movie.put("title", rs.getString("title"));
                movie.put("rating", rs.getDouble("rating"));
                movie.put("reviewCount", rs.getInt("review_count"));
                movies.add(movie);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return movies;
    }
    
    // 활발한 사용자 TOP 5 가져오기
    public List<Map<String, Object>> getTopUsers() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> users = new ArrayList<>();
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT u.id, u.username, u.nickname, " +
                         "(SELECT COUNT(*) FROM review WHERE user_id = u.id) as review_count, " +
                         "(SELECT COUNT(*) FROM board WHERE user_id = u.id) as board_count, " +
                         "(SELECT COUNT(*) FROM board_comment WHERE user_id = u.id) as comment_count " +
                         "FROM user u " +
                         "ORDER BY (review_count + board_count + comment_count) DESC " +
                         "LIMIT 5";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> user = new HashMap<>();
                user.put("id", rs.getInt("id"));
                user.put("username", rs.getString("username"));
                user.put("nickname", rs.getString("nickname"));
                user.put("reviewCount", rs.getInt("review_count"));
                user.put("boardCount", rs.getInt("board_count"));
                user.put("commentCount", rs.getInt("comment_count"));
                user.put("totalActivity", rs.getInt("review_count") + rs.getInt("board_count") + rs.getInt("comment_count"));
                users.add(user);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return users;
    }
    
    // 최근 활동 내역 가져오기
    public List<Map<String, Object>> getRecentActivities() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> activities = new ArrayList<>();
        
        try {
            conn = DBConnection.getConnection();
            
            // 최근 리뷰
            String reviewSql = "SELECT 'review' as type, r.id, r.content, r.created_at, u.username, u.nickname, m.title as target " +
                              "FROM review r " +
                              "JOIN user u ON r.user_id = u.id " +
                              "JOIN movie m ON r.movie_id = m.movie_id " +
                              "ORDER BY r.created_at DESC LIMIT 5";
            pstmt = conn.prepareStatement(reviewSql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> activity = new HashMap<>();
                activity.put("type", rs.getString("type"));
                activity.put("id", rs.getInt("id"));
                activity.put("content", rs.getString("content"));
                activity.put("createdAt", rs.getTimestamp("created_at"));
                activity.put("username", rs.getString("username"));
                activity.put("nickname", rs.getString("nickname"));
                activity.put("target", rs.getString("target"));
                activities.add(activity);
            }
            
            // 최근 게시글
            String boardSql = "SELECT 'board' as type, b.id, b.title as content, b.created_at, u.username, u.nickname, c.name as target " +
                             "FROM board b " +
                             "JOIN user u ON b.user_id = u.id " +
                             "JOIN board_category c ON b.category_id = c.id " +
                             "ORDER BY b.created_at DESC LIMIT 5";
            pstmt = conn.prepareStatement(boardSql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> activity = new HashMap<>();
                activity.put("type", rs.getString("type"));
                activity.put("id", rs.getInt("id"));
                activity.put("content", rs.getString("content"));
                activity.put("createdAt", rs.getTimestamp("created_at"));
                activity.put("username", rs.getString("username"));
                activity.put("nickname", rs.getString("nickname"));
                activity.put("target", rs.getString("target"));
                activities.add(activity);
            }
            
            // 최근 댓글
            String commentSql = "SELECT 'comment' as type, c.id, c.content, c.created_at, u.username, u.nickname, b.title as target " +
                               "FROM board_comment c " +
                               "JOIN user u ON c.user_id = u.id " +
                               "JOIN board b ON c.board_id = b.id " +
                               "ORDER BY c.created_at DESC LIMIT 5";
            pstmt = conn.prepareStatement(commentSql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> activity = new HashMap<>();
                activity.put("type", rs.getString("type"));
                activity.put("id", rs.getInt("id"));
                activity.put("content", rs.getString("content"));
                activity.put("createdAt", rs.getTimestamp("created_at"));
                activity.put("username", rs.getString("username"));
                activity.put("nickname", rs.getString("nickname"));
                activity.put("target", rs.getString("target"));
                activities.add(activity);
            }
            
            // 날짜순으로 정렬
            activities.sort((a, b) -> ((java.sql.Timestamp)b.get("createdAt")).compareTo((java.sql.Timestamp)a.get("createdAt")));
            
            if (activities.size() > 10) {
                activities = activities.subList(0, 10);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return activities;
    }
    
    // 월별 가입자 통계 가져오기
    public Map<String, Integer> getMonthlyRegistrations() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Map<String, Integer> monthlyData = new HashMap<>();
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT DATE_FORMAT(created_at, '%Y-%m') as month, COUNT(*) as count " +
                         "FROM user " +
                         "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) " +
                         "GROUP BY DATE_FORMAT(created_at, '%Y-%m') " +
                         "ORDER BY month";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                monthlyData.put(rs.getString("month"), rs.getInt("count"));
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return monthlyData;
    }
    
    // 카테고리별 게시글 수 가져오기
    public Map<String, Integer> getCategoryPostCounts() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Map<String, Integer> categoryData = new HashMap<>();
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT c.name, COUNT(b.id) as count " +
                         "FROM board_category c " +
                         "LEFT JOIN board b ON c.id = b.category_id " +
                         "GROUP BY c.id " +
                         "ORDER BY count DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                categoryData.put(rs.getString("name"), rs.getInt("count"));
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return categoryData;
    }
}
