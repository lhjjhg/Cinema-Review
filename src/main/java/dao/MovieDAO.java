package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.Movie;
import dto.MovieDetail;
import DB.DBConnection;

public class MovieDAO {
    
    public void resetMovieTables() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            
            pstmt = conn.prepareStatement("SET FOREIGN_KEY_CHECKS = 0");
            pstmt.executeUpdate();
            
            try {
                pstmt = conn.prepareStatement("TRUNCATE TABLE movie_detail");
                pstmt.executeUpdate();
                System.out.println("movie_detail 테이블 초기화 완료");
            } catch (SQLException e) {
                System.out.println("movie_detail 테이블이 존재하지 않아 생성합니다: " + e.getMessage());
                pstmt = conn.prepareStatement(
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
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                    ")"
                );
                pstmt.executeUpdate();
                System.out.println("movie_detail 테이블 생성 완료");
            }
            
            try {
                pstmt = conn.prepareStatement("TRUNCATE TABLE movie");
                pstmt.executeUpdate();
                System.out.println("movie 테이블 초기화 완료");
            } catch (SQLException e) {
                System.out.println("movie 테이블이 존재하지 않아 생성합니다: " + e.getMessage());
                pstmt = conn.prepareStatement(
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
                pstmt.executeUpdate();
                System.out.println("movie 테이블 생성 완료");
            }
            
            try {
                pstmt = conn.prepareStatement(
                    "ALTER TABLE movie_detail " +
                    "ADD CONSTRAINT fk_movie_detail_movie_id " +
                    "FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE CASCADE"
                );
                pstmt.executeUpdate();
                System.out.println("movie_detail 테이블에 외래 키 추가 완료");
            } catch (SQLException e) {
                System.out.println("movie_detail 테이블 외래 키 추가 중 오류 (이미 존재할 수 있음): " + e.getMessage());
            }
            
            pstmt = conn.prepareStatement("SET FOREIGN_KEY_CHECKS = 1");
            pstmt.executeUpdate();
            
            System.out.println("영화 테이블 초기화 및 AUTO_INCREMENT 값 재설정 완료");
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
}
