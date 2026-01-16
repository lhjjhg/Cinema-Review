package servlet;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

@WebServlet("/ScreeningServlet")
public class ScreeningServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // 임시 상영관 정보 제공
        JSONArray screensArray = new JSONArray();
        
        // 기본 상영관 정보
        for (int i = 1; i <= 5; i++) {
            JSONObject screen = new JSONObject();
            screen.put("id", i);
            screen.put("name", i + "관");
            screen.put("totalSeats", 150);
            screensArray.add(screen);
        }
        
        JSONObject resultObj = new JSONObject();
        resultObj.put("success", true);
        resultObj.put("screens", screensArray);
        
        out.print(resultObj.toJSONString());
    }
}
