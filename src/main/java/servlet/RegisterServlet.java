package servlet;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import DB.DBConnection;

@WebServlet("/RegisterServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, 
    maxFileSize = 1024 * 1024 * 10,  
    maxRequestSize = 1024 * 1024 * 50 
)
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String name = request.getParameter("name");
        String nickname = request.getParameter("nickname");
        
        String birthdate = request.getParameter("birthdate");
        if (birthdate != null && birthdate.trim().isEmpty()) {
            birthdate = null;
        }

        String fullAddress = request.getParameter("fullAddress");
        if (fullAddress != null && fullAddress.trim().isEmpty()) {
            fullAddress = null;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // 아이디 중복 확인
            String checkSql = "SELECT COUNT(*) FROM user WHERE username = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                request.setAttribute("errorMessage", "이미 사용 중인 아이디입니다.");
                request.getRequestDispatcher("member/register.jsp").forward(request, response);
                return;
            }
            
            // 프로필 이미지 처리
            String imagePath = "image/default-profile.png"; // 기본 이미지 경로
            Part filePart = request.getPart("profileImage");
            
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = username + "_" + System.currentTimeMillis() + getFileExtension(filePart);
                String uploadDir = getServletContext().getRealPath("/image");
                
                File uploadDirFile = new File(uploadDir);
                if (!uploadDirFile.exists()) {
                    uploadDirFile.mkdirs();
                }
                
                Path path = Paths.get(uploadDir + File.separator + fileName);
                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, path, StandardCopyOption.REPLACE_EXISTING);
                }
                
                imagePath = "image/" + fileName;
            }
            
            // role 컬럼 존재 여부 확인
            boolean hasRoleColumn = checkRoleColumnExists(conn);
            
            String insertSql;
            if (hasRoleColumn) {
                insertSql = "INSERT INTO user (username, password, name, nickname, address, birthdate, profile_image, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            } else {
                insertSql = "INSERT INTO user (username, password, name, nickname, address, birthdate, profile_image) VALUES (?, ?, ?, ?, ?, ?, ?)";
            }
            
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, username);
            pstmt.setString(2, password); 
            pstmt.setString(3, name);
            pstmt.setString(4, nickname);

            // 주소 처리
            if (fullAddress != null) {
                pstmt.setString(5, fullAddress);
            } else {
                pstmt.setNull(5, java.sql.Types.VARCHAR);
            }

            // 생년월일 처리
            if (birthdate != null) {
                pstmt.setString(6, birthdate);
            } else {
                pstmt.setNull(6, java.sql.Types.DATE);
            }

            pstmt.setString(7, imagePath);

            if (hasRoleColumn) {
                pstmt.setString(8, "USER"); 
            }
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                // 회원가입 성공
                response.sendRedirect("member/login.jsp?registered=true");
            } else {
                // 회원가입 실패
                request.setAttribute("errorMessage", "회원가입에 실패했습니다. 다시 시도해주세요.");
                request.getRequestDispatcher("member/register.jsp").forward(request, response);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "데이터베이스 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("member/register.jsp").forward(request, response);
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
    
    private boolean checkRoleColumnExists(Connection conn) {
        try {
            PreparedStatement pstmt = conn.prepareStatement("SHOW COLUMNS FROM user LIKE 'role'");
            ResultSet rs = pstmt.executeQuery();
            boolean exists = rs.next();
            rs.close();
            pstmt.close();
            return exists;
        } catch (SQLException e) {
            return false;
        }
    }
    
    private String getFileExtension(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                String fileName = item.substring(item.indexOf("=") + 2, item.length() - 1);
                int dotIndex = fileName.lastIndexOf(".");
                if (dotIndex > 0) {
                    return fileName.substring(dotIndex);
                }
            }
        }
        return "";
    }
}
