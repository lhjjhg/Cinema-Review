package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

import dto.User;
import DB.DBConnection;

public class UserDAO {
    
    // 사용자 로그인 확인
    public User login(String username, String password) throws SQLException {
        User user = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM user WHERE username = ? AND password = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setName(rs.getString("name"));
                user.setNickname(rs.getString("nickname"));
                user.setAddress(rs.getString("address"));
                user.setBirthdate(rs.getString("birthdate"));
                user.setProfileImage(rs.getString("profile_image"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setRole(rs.getString("role")); // role 필드 추가
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return user;
    }
    
    // 회원가입 
    public boolean register(User user) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO user (username, password, name, nickname, address, birthdate, profile_image, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getName());
            pstmt.setString(4, user.getNickname());
            pstmt.setString(5, user.getAddress());
            pstmt.setString(6, user.getBirthdate());
            pstmt.setString(7, user.getProfileImage());
            pstmt.setString(8, user.getRole() != null ? user.getRole() : "USER"); 
            
            int result = pstmt.executeUpdate();
            return result > 0;
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
    
    // 사용자 ID로 사용자 정보 가져오기
    public User getUserById(int userId) throws SQLException {
        User user = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM user WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setName(rs.getString("name"));
                user.setNickname(rs.getString("nickname"));
                user.setAddress(rs.getString("address"));
                user.setBirthdate(rs.getString("birthdate"));
                user.setProfileImage(rs.getString("profile_image"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return user;
    }
    
    // 사용자 정보 업데이트
    public boolean updateUser(User user) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE user SET password = ?, name = ?, nickname = ?, address = ?, birthdate = ?, profile_image = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getPassword());
            pstmt.setString(2, user.getName());
            pstmt.setString(3, user.getNickname());
            pstmt.setString(4, user.getAddress());
            pstmt.setString(5, user.getBirthdate());
            pstmt.setString(6, user.getProfileImage());
            pstmt.setInt(7, user.getId());
            
            int result = pstmt.executeUpdate();
            return result > 0;
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
    
    // 사용자 이름 중복 확인
    public boolean isUsernameExists(String username) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM user WHERE username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
}
