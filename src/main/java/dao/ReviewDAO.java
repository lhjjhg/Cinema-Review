package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.Review;
import DB.DBConnection;

public class ReviewDAO {
    
    public List<Review> getReviewsByMovieId(String movieId) throws SQLException {
        List<Review> reviews = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT r.*, u.username, u.nickname FROM review r " +
                         "JOIN user u ON r.user_id = u.id " +
                         "WHERE r.movie_id = ? " +
                         "ORDER BY r.created_at DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, movieId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Review review = new Review();
                review.setId(rs.getInt("id"));
                review.setMovieId(rs.getString("movie_id"));
                review.setUserId(rs.getInt("user_id"));
                review.setUsername(rs.getString("username"));
                review.setNickname(rs.getString("nickname"));
                review.setRating(rs.getInt("rating"));
                review.setContent(rs.getString("content"));
                review.setLikes(rs.getInt("likes"));
                review.setCreatedAt(rs.getTimestamp("created_at"));
                review.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                reviews.add(review);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return reviews;
    }
    
    // 사용자 ID로 리뷰 가져오기
    public List<Review> getReviewsByUserId(int userId) throws SQLException {
        List<Review> reviews = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT r.*, u.username, u.nickname, m.title FROM review r " +
                         "JOIN user u ON r.user_id = u.id " +
                         "JOIN movie m ON r.movie_id = m.movie_id " +
                         "WHERE r.user_id = ? " +
                         "ORDER BY r.created_at DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Review review = new Review();
                review.setId(rs.getInt("id"));
                review.setMovieId(rs.getString("movie_id"));
                review.setUserId(rs.getInt("user_id"));
                review.setUsername(rs.getString("username"));
                review.setNickname(rs.getString("nickname"));
                review.setRating(rs.getInt("rating"));
                review.setContent(rs.getString("content"));
                review.setLikes(rs.getInt("likes"));
                review.setCreatedAt(rs.getTimestamp("created_at"));
                review.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                reviews.add(review);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return reviews;
    }
    
    // 리뷰 ID로 리뷰 가져오기
    public Review getReviewById(int reviewId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Review review = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT r.*, u.username, u.nickname FROM review r " +
                         "JOIN user u ON r.user_id = u.id " +
                         "WHERE r.id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, reviewId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                review = new Review();
                review.setId(rs.getInt("id"));
                review.setMovieId(rs.getString("movie_id"));
                review.setUserId(rs.getInt("user_id"));
                review.setUsername(rs.getString("username"));
                review.setNickname(rs.getString("nickname"));
                review.setRating(rs.getInt("rating"));
                review.setContent(rs.getString("content"));
                review.setLikes(rs.getInt("likes"));
                review.setCreatedAt(rs.getTimestamp("created_at"));
                review.setUpdatedAt(rs.getTimestamp("updated_at"));
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return review;
    }
    
    // 사용자가 영화에 리뷰를 작성했는지 확인
    public boolean hasUserReviewedMovie(int userId, String movieId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean hasReviewed = false;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM review WHERE user_id = ? AND movie_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setString(2, movieId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                hasReviewed = rs.getInt(1) > 0;
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return hasReviewed;
    }
    
    // 리뷰 추가
    public boolean addReview(Review review) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO review (movie_id, user_id, rating, content) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, review.getMovieId());
            pstmt.setInt(2, review.getUserId());
            pstmt.setInt(3, review.getRating());
            pstmt.setString(4, review.getContent());
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                // 영화 평점 업데이트
                updateMovieRating(conn, review.getMovieId());
                return true;
            }
            return false;
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
    
    // 리뷰 업데이트
    public boolean updateReview(Review review) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE review SET rating = ?, content = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, review.getRating());
            pstmt.setString(2, review.getContent());
            pstmt.setInt(3, review.getId());
            pstmt.setInt(4, review.getUserId());
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                // 영화 평점 업데이트
                updateMovieRating(conn, review.getMovieId());
                return true;
            }
            return false;
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
    
    // 리뷰 삭제
    public boolean deleteReview(int reviewId, int userId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String movieId = null;
        
        try {
            conn = DBConnection.getConnection();
            
            String selectSql = "SELECT movie_id FROM review WHERE id = ?";
            pstmt = conn.prepareStatement(selectSql);
            pstmt.setInt(1, reviewId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                movieId = rs.getString("movie_id");
            }
            
            if (movieId != null) {
                // 리뷰 삭제
                String deleteSql = "DELETE FROM review WHERE id = ? AND user_id = ?";
                pstmt = conn.prepareStatement(deleteSql);
                pstmt.setInt(1, reviewId);
                pstmt.setInt(2, userId);
                
                int result = pstmt.executeUpdate();
                
                if (result > 0) {
                    // 영화 평점 업데이트
                    updateMovieRating(conn, movieId);
                    return true;
                }
            }
            return false;
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
    
    // 리뷰 좋아요 증가
    public int incrementLikes(int reviewId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String updateSql = "UPDATE review SET likes = likes + 1 WHERE id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setInt(1, reviewId);
            pstmt.executeUpdate();
            
            // 업데이트된 좋아요 수 가져오기
            String selectSql = "SELECT likes FROM review WHERE id = ?";
            pstmt = conn.prepareStatement(selectSql);
            pstmt.setInt(1, reviewId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("likes");
            }
            return 0;
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
    
    // 영화 평점 업데이트
    private void updateMovieRating(Connection conn, String movieId) throws SQLException {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // 영화의 모든 리뷰 평균 평점 계산
            String avgSql = "SELECT AVG(rating) as avg_rating FROM review WHERE movie_id = ?";
            pstmt = conn.prepareStatement(avgSql);
            pstmt.setString(1, movieId);
            rs = pstmt.executeQuery();
            
            double avgRating = 0.0;
            if (rs.next()) {
                avgRating = rs.getDouble("avg_rating");
            }
            
            // 영화 테이블 평점 업데이트
            String updateSql = "UPDATE movie SET rating = ? WHERE movie_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setDouble(1, avgRating);
            pstmt.setString(2, movieId);
            pstmt.executeUpdate();
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }
    }
}
