<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<footer class="site-footer">
    <div class="footer-container">
        <div class="footer-content">
            <div class="footer-logo">
                <i class="fas fa-film"></i>
                <span>CinemaWorld</span>
            </div>
            <div class="footer-project-info">
                <div class="project-title">JSP 예매 리뷰 서비스 프로젝트</div>
                <div class="student-info">
                    <div class="department-id">소프트웨어학과 2020E7339</div>
                    <div class="student-name">정현구</div>
                </div>
            </div>
            <div class="footer-copyright">
                &copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> CinemaWorld v10. All rights reserved.
            </div>
        </div>
    </div>
</footer>

<style>
.footer-project-info {
    text-align: center;
    margin: 10px 0;
}

.project-title {
    font-size: 16px;
    font-weight: bold;
    color: #cccccc;
    margin-bottom: 8px;
}

.student-info {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 5px;
    font-size: 14px;
    color: #cccccc;
}

.department-id {
    padding: 2px 8px;
}

.student-name {
    font-weight: 600;
    color: #cccccc;
    padding: 2px 8px;
}

@media (max-width: 768px) {
    .student-info {
        gap: 3px;
    }
}
</style>
