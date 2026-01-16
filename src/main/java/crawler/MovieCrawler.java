package crawler;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.sql.DatabaseMetaData;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import DB.DBConnection;
import dto.Movie;
import dto.MovieDetail;
import dao.MovieDAO;

public class MovieCrawler {
    
    private static final String CGV_CHART_URL = "http://www.cgv.co.kr/movies/?lt=1&ft=1";
    private static final String CGV_COMING_URL = "http://www.cgv.co.kr/movies/pre-movies.aspx";
    private static final String CGV_MOVIE_DETAIL_URL = "http://www.cgv.co.kr/movies/detail-view/?midx=";
    
    private StringBuilder logBuilder = new StringBuilder();
    
    public String getLog() {
        return logBuilder.toString();
    }
    
    private void log(String message) {
        System.out.println(message);
        logBuilder.append(message).append("<br>");
    }
    
    private String cleanText(String text) {
        if (text == null || text.isEmpty()) {
            return text;
        }
        
        // HTML 태그 제거
        text = text.replaceAll("<[^>]*>", "");
        
        // HTML 엔티티 디코딩
        text = text.replace("&lt;", "<")
                  .replace("&gt;", ">")
                  .replace("&amp;", "&")
                  .replace("&quot;", "\"")
                  .replace("&#39;", "'")
                  .replace("&nbsp;", " ");
        
        text = text.replaceAll("[<>]", "");
        
        text = text.replaceAll("\\s+", " ");
        
        text = text.trim();
        
        return text;
    }
    
    private String cleanGenre(String genre) {
        if (genre == null || genre.isEmpty()) {
            return genre;
        }
        
        genre = cleanText(genre);
        
        genre = genre.replaceAll("[<>\\[\\](){}]", "");
        genre = genre.replaceAll("[/\\\\|]", ","); 
        
        // 여러 장르가 있는 경우 첫 번째 장르만 사용
        if (genre.contains(",")) {
            genre = genre.split(",")[0].trim();
        }
        
        // 숫자나 특수문자로 시작하는 경우 제거
        genre = genre.replaceAll("^[^가-힣a-zA-Z]+", "");
        
        if (genre.length() > 20) {
            genre = genre.substring(0, 20);
        }
        
        return genre.trim();
    }
    
    /**
     * 러닝타임 텍스트를 정제하는 메서드
     */
    private String cleanRunningTime(String runningTime) {
        if (runningTime == null || runningTime.isEmpty()) {
            return runningTime;
        }
        
        runningTime = cleanText(runningTime);
        
        // 숫자와 "분"만 추출
        Pattern pattern = Pattern.compile("(\\d+)분");
        Matcher matcher = pattern.matcher(runningTime);
        if (matcher.find()) {
            return matcher.group(0); 
        }
        
        // 패턴이 매치되지 않으면 숫자만 추출해서 "분" 추가
        Pattern numberPattern = Pattern.compile("\\d+");
        Matcher numberMatcher = numberPattern.matcher(runningTime);
        if (numberMatcher.find()) {
            return numberMatcher.group(0) + "분";
        }
        
        return runningTime.trim();
    }
    
    /**
     * 현재 상영 중인 영화 목록을 크롤링하여 반환 
     */
    public List<Movie> crawlCurrentMovies() {
        List<Movie> movies = new ArrayList<>();
        
        try {
            log("CGV 현재 상영작 URL 접속 시도: " + CGV_CHART_URL);
            
            // 더 많은 헤더 추가 및 타임아웃 증가
            Document doc = Jsoup.connect(CGV_CHART_URL)
                    .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
                    .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8")
                    .header("Accept-Language", "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7")
                    .header("Accept-Encoding", "gzip, deflate")
                    .header("Connection", "keep-alive")
                    .header("Cache-Control", "max-age=0")
                    .header("Upgrade-Insecure-Requests", "1")
                    .timeout(60000) 
                    .get();
            
            log("CGV 현재 상영작 페이지 접속 성공");
            
            log("페이지 제목: " + doc.title());
            
            Element chartContainer = doc.selectFirst("div.sect-movie-chart");
            if (chartContainer == null) {
                log("영화 차트 컨테이너를 찾을 수 없습니다.");
                return movies;
            }
            
            Elements movieItems = chartContainer.select("ol > li");
            log("찾은 영화 아이템 수: " + movieItems.size());
            
            if (movieItems.isEmpty()) {
                log("영화 아이템을 찾을 수 없습니다. 다른 선택자 시도...");
                movieItems = doc.select("div.wrap-movie-chart div.box-image");
                log("대체 선택자로 찾은 영화 아이템 수: " + movieItems.size());
            }
            
            // 각 영화 정보 추출
            for (Element item : movieItems) {
                try {
                    Movie movie = new Movie();
                    
                    // 1. 영화 ID 추출
                    Element linkElement = item.selectFirst("a[href*='midx=']");
                    if (linkElement != null) {
                        String href = linkElement.attr("href");
                        if (href.contains("midx=")) {
                            String movieId = href.substring(href.indexOf("midx=") + 5);
                            if (movieId.contains("&")) {
                                movieId = movieId.substring(0, movieId.indexOf("&"));
                            }
                            movie.setMovieId(movieId);
                            log("영화 ID: " + movieId);
                        }
                    }
                    
                    if (movie.getMovieId() == null || movie.getMovieId().isEmpty()) {
                        log("영화 ID를 찾을 수 없어 건너뜁니다.");
                        continue;
                    }
                    
                    // 2. 영화 제목 추출 (순위, 예매율, 개봉일 제외)
                    Element titleElement = item.selectFirst("strong.title");
                    if (titleElement != null) {
                        String fullTitle = titleElement.text().trim();
                        log("원본 제목 텍스트: " + fullTitle);
                        
                        String cleanTitle = fullTitle.replaceAll("^No\\.\\d+\\s+", "");
                        
                        cleanTitle = cleanTitle.replaceAll("\\s+예매율\\d+(\\.\\d+)?%", "");
                        
                        cleanTitle = cleanTitle.replaceAll("\\s+\\d{4}\\.\\d{2}\\.\\d{2}\\s+개봉", "");
                        
                        cleanTitle = cleanText(cleanTitle);
                        
                        movie.setTitle(cleanTitle);
                        log("정제된 제목: " + cleanTitle);
                    }
                    
                    // 3. 포스터 URL 추출
                    Element posterElement = item.selectFirst("span.thumb-image img");
                    if (posterElement != null) {
                        String posterUrl = posterElement.attr("src");
                        if (posterUrl.isEmpty()) {
                            posterUrl = posterElement.attr("data-src");
                        }
                        movie.setPosterUrl(posterUrl);
                        log("포스터 URL: " + posterUrl);
                    } else {
                        posterElement = item.selectFirst("img");
                        if (posterElement != null) {
                            String posterUrl = posterElement.attr("src");
                            if (posterUrl.isEmpty()) {
                                posterUrl = posterElement.attr("data-src");
                            }
                            movie.setPosterUrl(posterUrl);
                            log("대체 선택자로 찾은 포스터 URL: " + posterUrl);
                        }
                    }
                    
                    // 4. 순위 추출
                    Element rankElement = item.selectFirst("strong.rank");
                    if (rankElement != null) {
                        String rankText = rankElement.text().trim();
                        log("순위 텍스트: " + rankText);
                        
                        Pattern pattern = Pattern.compile("\\d+");
                        Matcher matcher = pattern.matcher(rankText);
                        if (matcher.find()) {
                            int rank = Integer.parseInt(matcher.group());
                            movie.setMovieRank(rank);
                            log("추출된 순위: " + rank);
                        }
                    } else {
                        // 제목에서 순위 추출 시도
                        Element titleElem = item.selectFirst("strong.title");
                        if (titleElem != null) {
                            String titleText = titleElem.text().trim();
                            Pattern pattern = Pattern.compile("^No\\.(\\d+)");
                            Matcher matcher = pattern.matcher(titleText);
                            if (matcher.find()) {
                                int rank = Integer.parseInt(matcher.group(1));
                                movie.setMovieRank(rank);
                                log("제목에서 추출된 순위: " + rank);
                            }
                        }
                    }
                    
                    // 5. 평점 추출
                    Element ratingElement = item.selectFirst("strong.percent span");
                    if (ratingElement != null) {
                        String ratingText = ratingElement.text().replace("%", "").trim();
                        try {
                            double rating = Double.parseDouble(ratingText) / 10.0; 
                            movie.setRating(rating);
                            log("평점: " + rating);
                        } catch (NumberFormatException e) {
                            log("평점 파싱 실패: " + ratingText);
                        }
                    } else {
                        // 제목에서 예매율 추출 시도
                        Element titleElem = item.selectFirst("strong.title");
                        if (titleElem != null) {
                            String titleText = titleElem.text().trim();
                            Pattern pattern = Pattern.compile("예매율(\\d+(\\.\\d+)?)%");
                            Matcher matcher = pattern.matcher(titleText);
                            if (matcher.find()) {
                                String ratingText = matcher.group(1);
                                try {
                                    double rating = Double.parseDouble(ratingText) / 10.0;
                                    movie.setRating(rating);
                                    log("제목에서 추출된 평점: " + rating);
                                } catch (NumberFormatException e) {
                                    log("제목에서 평점 파싱 실패: " + ratingText);
                                }
                            }
                        }
                    }
                    
                    // 6. 개봉일 추출
                    Element infoElement = item.selectFirst("span.txt-info");
                    if (infoElement != null) {
                        String infoText = infoElement.text().trim();
                        log("정보 텍스트: " + infoText);
                        
                        if (infoText.contains("개봉")) {
                            String releaseDate = infoText.substring(0, infoText.indexOf("개봉")).trim();
                            releaseDate = cleanText(releaseDate);
                            movie.setReleaseDate(releaseDate);
                            log("개봉일: " + releaseDate);
                        }
                    } else {
                        // 제목에서 개봉일 추출 시도
                        Element titleElem = item.selectFirst("strong.title");
                        if (titleElem != null) {
                            String titleText = titleElem.text().trim();
                            Pattern pattern = Pattern.compile("(\\d{4}\\.\\d{2}\\.\\d{2})\\s+개봉");
                            Matcher matcher = pattern.matcher(titleText);
                            if (matcher.find()) {
                                String releaseDate = matcher.group(1);
                                movie.setReleaseDate(releaseDate);
                                log("제목에서 추출된 개봉일: " + releaseDate);
                            }
                        }
                    }
                    
                    movie.setStatus("current");
                    
                    if (movie.getTitle() != null && !movie.getTitle().isEmpty()) {
                        movies.add(movie);
                        log("영화 추가됨: " + movie.getTitle());
                    } else {
                        log("유효하지 않은 영화 정보 (제목 없음)");
                    }
                    
                } catch (Exception e) {
                    log("영화 정보 파싱 중 오류: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            log("총 " + movies.size() + "개의 영화 정보 수집 완료");
            
            if (movies.size() < 10) {
                log("영화가 적게 수집되어 다른 방법 시도...");
                
                // 직접 CGV 영화 차트 페이지 접속
                String alternativeUrl = "http://www.cgv.co.kr/movies/";
                log("대체 URL 접속: " + alternativeUrl);
                
                Document altDoc = Jsoup.connect(alternativeUrl)
                        .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
                        .timeout(30000)
                        .get();
                
                Elements altMovieItems = altDoc.select("div.sect-movie-chart ol > li");
                log("대체 URL에서 찾은 영화 수: " + altMovieItems.size());
                
                // 이미 수집된 영화 ID 목록
                List<String> collectedIds = new ArrayList<>();
                for (Movie m : movies) {
                    collectedIds.add(m.getMovieId());
                }
                
                for (Element item : altMovieItems) {
                    try {
                        // 영화 ID 추출
                        Element linkElement = item.selectFirst("a[href*='midx=']");
                        if (linkElement == null) continue;
                        
                        String href = linkElement.attr("href");
                        if (!href.contains("midx=")) continue;
                        
                        String movieId = href.substring(href.indexOf("midx=") + 5);
                        if (movieId.contains("&")) {
                            movieId = movieId.substring(0, movieId.indexOf("&"));
                        }
                        
                        // 이미 수집된 영화는 건너뛰기
                        if (collectedIds.contains(movieId)) {
                            log("이미 수집된 영화 ID: " + movieId);
                            continue;
                        }
                        
                        Movie movie = new Movie();
                        movie.setMovieId(movieId);
                        
                        // 영화 제목 추출
                        Element titleElement = item.selectFirst("strong.title");
                        if (titleElement != null) {
                            String title = cleanText(titleElement.text().trim());
                            movie.setTitle(title);
                        }
                        
                        // 포스터 URL 추출
                        Element posterElement = item.selectFirst("span.thumb-image img");
                        if (posterElement != null) {
                            String posterUrl = posterElement.attr("src");
                            if (posterUrl.isEmpty()) {
                                posterUrl = posterElement.attr("data-src");
                            }
                            movie.setPosterUrl(posterUrl);
                        }
                        
                        // 순위 추출
                        Element rankElement = item.selectFirst("strong.rank");
                        if (rankElement != null) {
                            String rankText = rankElement.text().trim();
                            Pattern pattern = Pattern.compile("\\d+");
                            Matcher matcher = pattern.matcher(rankText);
                            if (matcher.find()) {
                                movie.setMovieRank(Integer.parseInt(matcher.group()));
                            }
                        }
                        
                        movie.setStatus("current");
                        
                        if (movie.getTitle() != null && !movie.getTitle().isEmpty()) {
                            movies.add(movie);
                            collectedIds.add(movieId);
                            log("대체 URL에서 영화 추가됨: " + movie.getTitle());
                        }
                    } catch (Exception e) {
                        log("대체 URL에서 영화 파싱 중 오류: " + e.getMessage());
                    }
                }
            }
            
        } catch (IOException e) {
            log("CGV 영화 차트 크롤링 중 오류: " + e.getMessage());
            e.printStackTrace();
        }
        
        return movies;
    }
    
    /**
     * 상영 예정작 목록을 크롤링하여 반환
     */
    public List<Movie> crawlComingSoonMovies() {
        List<Movie> movies = new ArrayList<>();
        
        try {
            log("CGV 상영 예정작 URL 접속 시도: " + CGV_COMING_URL);
            Document doc = Jsoup.connect(CGV_COMING_URL)
                    .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
                    .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8")
                    .header("Accept-Language", "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7")
                    .timeout(60000)
                    .get();
            log("CGV 상영 예정작 페이지 접속 성공");
            
            Elements movieItems = doc.select("div.sect-movie-chart ol > li");
            log("찾은 상영 예정작 개수: " + movieItems.size());
            
            if (movieItems.isEmpty()) {
                log("상영 예정작 요소를 찾을 수 없습니다. 선택자를 확인하세요.");
                movieItems = doc.select("div.wrap-movie-chart > div.sect-movie-chart > ol > li");
                log("대체 선택자로 찾은 상영 예정작 개수: " + movieItems.size());
            }
            
            for (Element item : movieItems) {
                try {
                    Movie movie = new Movie();
                    
                    // 1. 영화 ID 추출
                    Element linkElement = item.selectFirst("a[href*='midx=']");
                    if (linkElement != null) {
                        String href = linkElement.attr("href");
                        if (href.contains("midx=")) {
                            String movieId = href.substring(href.indexOf("midx=") + 5);
                            if (movieId.contains("&")) {
                                movieId = movieId.substring(0, movieId.indexOf("&"));
                            }
                            movie.setMovieId(movieId);
                            log("영화 ID: " + movieId);
                        }
                    }
                    
                    if (movie.getMovieId() == null || movie.getMovieId().isEmpty()) {
                        log("영화 ID를 찾을 수 없어 건너뜁니다.");
                        continue;
                    }
                    
                    // 2. 영화 제목 추출
                    Element titleElement = item.selectFirst("strong.title");
                    if (titleElement != null) {
                        String title = cleanText(titleElement.text().trim());
                        movie.setTitle(title);
                        log("제목: " + movie.getTitle());
                    }
                    
                    // 3. 포스터 URL 추출
                    Element posterElement = item.selectFirst("span.thumb-image img");
                    if (posterElement != null) {
                        String posterUrl = posterElement.attr("src");
                        if (posterUrl.isEmpty()) {
                            posterUrl = posterElement.attr("data-src");
                        }
                        movie.setPosterUrl(posterUrl);
                        log("포스터 URL: " + posterUrl);
                    }
                    
                    // 4. 개봉일 추출
                    Element dateElement = item.selectFirst("span.txt-info strong");
                    if (dateElement != null) {
                        String dateText = dateElement.text().trim();
                        if (dateText.contains("개봉")) {
                            String releaseDate = dateText.replace("개봉", "").trim();
                            releaseDate = cleanText(releaseDate);
                            movie.setReleaseDate(releaseDate);
                            log("개봉일: " + releaseDate);
                        }
                    }
                    
                    movie.setStatus("coming");
                    
                    if (movie.getTitle() != null && !movie.getTitle().isEmpty()) {
                        movies.add(movie);
                        log("상영 예정작 추가됨: " + movie.getTitle());
                    }
                } catch (Exception e) {
                    log("상영 예정작 정보 파싱 중 오류: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
        } catch (IOException e) {
            log("CGV 상영 예정작 크롤링 중 오류: " + e.getMessage());
            e.printStackTrace();
        }
        
        log("상영 예정작 크롤링 완료. 영화 수: " + movies.size());
        return movies;
    }
    
    /**
     * 영화 상세 정보를 크롤링하여 반환 
     */
    public MovieDetail crawlMovieDetail(String movieId) {
        MovieDetail movieDetail = new MovieDetail();
        movieDetail.setMovieId(movieId);
        
        try {
            String detailUrl = CGV_MOVIE_DETAIL_URL + movieId;
            log("영화 상세 정보 URL 접속 시도: " + detailUrl);
            
            Document doc = Jsoup.connect(detailUrl)
                    .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
                    .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8")
                    .header("Accept-Language", "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7")
                    .timeout(60000)
                    .get();
            log("영화 상세 정보 페이지 접속 성공");
            
            log("상세 페이지 제목: " + doc.title());
            
            // 영화 기본 정보
            Element infoElement = doc.selectFirst("div.sect-base-movie");
            if (infoElement != null) {
                // 영화 제목
                Element titleElement = infoElement.selectFirst("div.box-contents > div.title > strong");
                if (titleElement != null) {
                    String title = cleanText(titleElement.text().trim());
                    movieDetail.setTitle(title);
                    log("영화 제목: " + title);
                }
                
                // 영어 제목
                Element engTitleElement = infoElement.selectFirst("div.box-contents > div.title > p");
                if (engTitleElement != null) {
                    String engTitle = cleanText(engTitleElement.text().trim());
                    movieDetail.setEnglishTitle(engTitle);
                    log("영어 제목: " + engTitle);
                }
                
                // 포스터 URL
                Element posterElement = infoElement.selectFirst("div.box-image > a > span > img");
                if (posterElement != null) {
                    String posterUrl = posterElement.attr("src");
                    if (!posterUrl.isEmpty()) {
                        movieDetail.setPosterUrl(posterUrl);
                        log("포스터 URL: " + posterUrl);
                    }
                }
                
                // 영화 상세 정보 (감독, 배우, 장르, 러닝타임 등)
                // 1. spec 영역 전체 텍스트 확인
                Element specElement = infoElement.selectFirst("div.box-contents div.spec");
                if (specElement != null) {
                    String specText = specElement.text();
                    log("SPEC 전체 텍스트: " + specText);
                }
                
                // 2. 개별 항목 추출
                Elements infoItems = infoElement.select(".box-contents .spec dl dt, .box-contents .spec dl dd");
                if (infoItems.isEmpty()) {
                    infoItems = infoElement.select(".box-contents .spec > *");
                    log("대체 선택자로 찾은 정보 항목 수: " + infoItems.size());
                }
                
                // 3. 직접 장르, 러닝타임 추출 시도
                Element specElement2 = infoElement.selectFirst("div.box-contents div.spec");
                if (specElement2 != null) {
                    String specText = specElement2.text(); 
                    log("SPEC 텍스트: " + specText);
                    
                    Pattern genrePattern = Pattern.compile("장르\\s*:\\s*([^/]+)");
                    Matcher genreMatcher = genrePattern.matcher(specText);
                    if (genreMatcher.find()) {
                        String genre = genreMatcher.group(1).trim();
                        genre = cleanGenre(genre); 
                        movieDetail.setGenre(genre);
                        log("추출된 장르 (정제 전): " + genreMatcher.group(1).trim());
                        log("추출된 장르 (정제 후): " + genre);
                    }
                    
                    Pattern timePattern = Pattern.compile("(\\d+)분");
                    Matcher timeMatcher = timePattern.matcher(specText);
                    if (timeMatcher.find()) {
                        String runningTime = timeMatcher.group(0);
                        runningTime = cleanRunningTime(runningTime); 
                        movieDetail.setRunningTime(runningTime);
                        log("추출된 러닝타임: " + runningTime);
                    }
                }
                
                String currentKey = "";
                for (Element item : infoItems) {
                    if (item.is("dt")) {
                        currentKey = cleanText(item.text().trim());
                        log("정보 타입: " + currentKey);
                    } else if (item.is("dd")) {
                        String value = cleanText(item.text().trim());
                        log(currentKey + ": " + value);
                        
                        if (currentKey.contains("감독")) {
                            movieDetail.setDirector(value);
                        } else if (currentKey.contains("배우")) {
                            movieDetail.setActors(value);
                        } else if (currentKey.contains("장르")) {
                            String[] parts = value.split(",|/");
                            for (String part : parts) {
                                part = part.trim();
                                if (part.contains("분")) {
                                    String runningTime = cleanRunningTime(part);
                                    movieDetail.setRunningTime(runningTime);
                                    log("파싱된 러닝타임: " + runningTime);
                                } else if (part.contains("개봉") || part.contains("재개봉")) {
                                    String releaseDate = cleanText(part);
                                    movieDetail.setReleaseDate(releaseDate);
                                    log("파싱된 개봉일: " + releaseDate);
                                } else if (!part.isEmpty() && !part.contains("세") && !part.contains("등급")) {
                                    String genre = cleanGenre(part);
                                    if (!genre.isEmpty()) {
                                        movieDetail.setGenre(genre);
                                        log("파싱된 장르: " + genre);
                                    }
                                }
                            }
                        } else if (currentKey.contains("등급")) {
                            String rating = cleanText(value);
                            movieDetail.setRating(rating);
                        }
                    } else {
                        String text = cleanText(item.text().trim());
                        if (text.contains("감독")) {
                            String director = text.substring(text.indexOf("감독") + 2).trim();
                            if (director.contains(",")) {
                                director = director.substring(0, director.indexOf(",")).trim();
                            }
                            director = cleanText(director);
                            movieDetail.setDirector(director);
                            log("대체 방식으로 추출한 감독: " + director);
                        } else if (text.contains("배우")) {
                            String actors = text.substring(text.indexOf("배우") + 2).trim();
                            actors = cleanText(actors);
                            movieDetail.setActors(actors);
                            log("대체 방식으로 추출한 배우: " + actors);
                        } else if (text.contains("장르")) {
                            String genreInfo = text.substring(text.indexOf("장르") + 2).trim();
                            String[] parts = genreInfo.split(",|/");
                            for (String part : parts) {
                                part = part.trim();
                                if (part.contains("분")) {
                                    String runningTime = cleanRunningTime(part);
                                    movieDetail.setRunningTime(runningTime);
                                    log("대체 방식으로 추출한 러닝타임: " + runningTime);
                                } else if (!part.isEmpty() && !part.contains("세") && !part.contains("등급")) {
                                    String genre = cleanGenre(part);
                                    if (!genre.isEmpty()) {
                                        movieDetail.setGenre(genre);
                                        log("대체 방식으로 추출한 장르: " + genre);
                                    }
                                }
                            }
                        }
                    }
                }
                
                if (movieDetail.getGenre() == null || movieDetail.getGenre().isEmpty() || 
                    movieDetail.getRunningTime() == null || movieDetail.getRunningTime().isEmpty()) {
                    
                    String fullText = doc.text();
                    
                    // 장르 추출
                    Pattern fullGenrePattern = Pattern.compile("장르\\s*:\\s*([^/]+)");
                    Matcher fullGenreMatcher = fullGenrePattern.matcher(fullText);
                    if (fullGenreMatcher.find()) {
                        String genre = fullGenreMatcher.group(1).trim();
                        genre = cleanGenre(genre);
                        if (!genre.isEmpty()) {
                            movieDetail.setGenre(genre);
                            log("텍스트에서 추출한 장르: " + genre);
                        }
                    }
                    
                    // 러닝타임 추출
                    Pattern fullTimePattern = Pattern.compile("(\\d+)분");
                    Matcher fullTimeMatcher = fullTimePattern.matcher(fullText);
                    if (fullTimeMatcher.find()) {
                        String runningTime = cleanRunningTime(fullTimeMatcher.group(0));
                        movieDetail.setRunningTime(runningTime);
                        log("텍스트에서 추출한 러닝타임: " + runningTime);
                    }
                }
            } else {
                log("영화 정보 요소(.sect-base-movie)를 찾을 수 없습니다.");
            }
            
            // 영화 줄거리
            Element plotElement = doc.selectFirst(".sect-story-movie");
            if (plotElement != null) {
                String plot = cleanText(plotElement.text().trim());
                movieDetail.setPlot(plot);
                log("줄거리: " + (plot.length() > 100 ? plot.substring(0, 100) + "..." : plot));
            } else {
                log("줄거리 요소(.sect-story-movie)를 찾을 수 없습니다.");
            }
            
        } catch (IOException e) {
            log("영화 상세 정보 크롤링 중 오류: " + e.getMessage());
            e.printStackTrace();
        }
        
        log("영화 상세 정보 크롤링 완료: " + movieId);
        log("최종 장르: " + movieDetail.getGenre());
        log("최종 러닝타임: " + movieDetail.getRunningTime());
        
        return movieDetail;
    }
    
    /**
     * 크롤링한 영화 정보를 데이터베이스에 저장 - 장르와 러닝타임 저장 확인
     */
    public void saveMoviesToDatabase(List<Movie> movies) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            log("데이터베이스 연결 시도...");
            conn = DBConnection.getConnection();
            log("데이터베이스 연결 성공");
            
            checkAndCreateTables(conn);
            
            String checkSql = "SELECT COUNT(*) FROM movie WHERE movie_id = ?";
            String insertSql = "INSERT INTO movie (movie_id, title, poster_url, rating, movie_rank, release_date, genre, running_time, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            String updateSql = "UPDATE movie SET title = ?, poster_url = ?, rating = ?, movie_rank = ?, release_date = ?, genre = ?, running_time = ?, status = ? WHERE movie_id = ?";
            
            int insertCount = 0;
            int updateCount = 0;
            int errorCount = 0;
            
            for (Movie movie : movies) {
                try {
                    if (movie.getMovieId() == null || movie.getMovieId().isEmpty()) {
                        log("영화 ID가 없어 저장을 건너뜁니다: " + movie.getTitle());
                        errorCount++;
                        continue;
                    }
                    
                    // 이미 존재하는 영화인지 확인
                    pstmt = conn.prepareStatement(checkSql);
                    pstmt.setString(1, movie.getMovieId());
                    rs = pstmt.executeQuery();
                    
                    boolean exists = false;
                    if (rs.next()) {
                        exists = rs.getInt(1) > 0;
                    }
                    
                    // 영화 상세 정보 크롤링 - 장르와 러닝타임을 먼저 가져옴
                    log("영화 상세 정보 크롤링 시작: " + movie.getTitle());
                    MovieDetail detail = crawlMovieDetail(movie.getMovieId());
                    
                    // 영화 객체에 장르와 러닝타임 설정 (정제된 데이터)
                    if (detail.getGenre() != null && !detail.getGenre().isEmpty()) {
                        String cleanedGenre = cleanGenre(detail.getGenre());
                        movie.setGenre(cleanedGenre);
                        log("영화 객체에 장르 설정: " + cleanedGenre);
                    }
                    
                    if (detail.getRunningTime() != null && !detail.getRunningTime().isEmpty()) {
                        String cleanedRunningTime = cleanRunningTime(detail.getRunningTime());
                        movie.setRunningTime(cleanedRunningTime);
                        log("영화 객체에 러닝타임 설정: " + cleanedRunningTime);
                    }
                    
                    if (exists) {
                        // 업데이트
                        log("기존 영화 정보 업데이트: " + movie.getTitle());
                        pstmt = conn.prepareStatement(updateSql);
                        pstmt.setString(1, movie.getTitle());
                        pstmt.setString(2, movie.getPosterUrl());
                        pstmt.setDouble(3, movie.getRating());
                        pstmt.setInt(4, movie.getMovieRank());
                        pstmt.setString(5, movie.getReleaseDate());
                        pstmt.setString(6, movie.getGenre());
                        pstmt.setString(7, movie.getRunningTime());
                        pstmt.setString(8, movie.getStatus());
                        pstmt.setString(9, movie.getMovieId());
                        
                        int result = pstmt.executeUpdate();
                        if (result > 0) {
                            updateCount++;
                            log("영화 정보 업데이트 성공: " + movie.getTitle());
                            log("업데이트된 장르: " + movie.getGenre());
                            log("업데이트된 러닝타임: " + movie.getRunningTime());
                        } else {
                            log("영화 정보 업데이트 실패: " + movie.getTitle());
                            errorCount++;
                        }
                    } else {
                        // 삽입
                        log("새 영화 정보 삽입: " + movie.getTitle());
                        pstmt = conn.prepareStatement(insertSql);
                        pstmt.setString(1, movie.getMovieId());
                        pstmt.setString(2, movie.getTitle());
                        pstmt.setString(3, movie.getPosterUrl());
                        pstmt.setDouble(4, movie.getRating());
                        pstmt.setInt(5, movie.getMovieRank());
                        pstmt.setString(6, movie.getReleaseDate());
                        pstmt.setString(7, movie.getGenre());
                        pstmt.setString(8, movie.getRunningTime());
                        pstmt.setString(9, movie.getStatus());
                        
                        int result = pstmt.executeUpdate();
                        if (result > 0) {
                            insertCount++;
                            log("영화 정보 삽입 성공: " + movie.getTitle());
                            log("삽입된 장르: " + movie.getGenre());
                            log("삽입된 러닝타임: " + movie.getRunningTime());
                        } else {
                            log("영화 정보 삽입 실패: " + movie.getTitle());
                            errorCount++;
                        }
                    }
                    
                    // 영화 상세 정보 저장
                    saveMovieDetail(conn, detail);
                    
                } catch (SQLException e) {
                    log("영화 저장 중 SQL 오류: " + e.getMessage());
                    e.printStackTrace();
                    errorCount++;
                }
            }
            
            log("영화 정보 저장 완료: 새로 삽입 " + insertCount + "개, 업데이트 " + updateCount + "개, 오류 " + errorCount + "개");
            
        } catch (SQLException e) {
            log("영화 정보 저장 중 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
                log("데이터베이스 연결 종료");
            } catch (SQLException e) {
                log("데이터베이스 연결 종료 중 오류: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }
    
    private void checkAndCreateTables(Connection conn) throws SQLException {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // 테이블이 존재하는지 확인
            DatabaseMetaData dbm = conn.getMetaData();
            
            // movie 테이블 확인
            rs = dbm.getTables(null, null, "movie", null);
            if (!rs.next()) {
                log("movie 테이블이 존재하지 않아 생성합니다.");
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
                log("movie 테이블 생성 완료");
            }
            
            // movie_detail 테이블 확인
            rs = dbm.getTables(null, null, "movie_detail", null);
            if (!rs.next()) {
                log("movie_detail 테이블이 존재하지 않아 생성합니다.");
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
                log("movie_detail 테이블 생성 완료");
                
                try {
                    pstmt = conn.prepareStatement(
                        "ALTER TABLE movie_detail " +
                        "ADD CONSTRAINT fk_movie_detail_movie_id " +
                        "FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE CASCADE"
                    );
                    pstmt.executeUpdate();
                    log("movie_detail 테이블에 외래 키 추가 완료");
                } catch (SQLException e) {
                    log("movie_detail 테이블 외래 키 추가 중 오류 (이미 존재할 수 있음): " + e.getMessage());
                }
            }
            
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }
    }
    
    /**
     * 영화 상세 정보를 데이터베이스에 저장 - 텍스트 정제 적용
     */
    private void saveMovieDetail(Connection conn, MovieDetail detail) throws SQLException {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            if (detail.getMovieId() == null || detail.getMovieId().isEmpty()) {
                log("영화 ID가 없어 상세 정보 저장을 건너뜁니다.");
                return;
            }
            
            if (detail.getGenre() != null) {
                detail.setGenre(cleanGenre(detail.getGenre()));
            }
            if (detail.getRunningTime() != null) {
                detail.setRunningTime(cleanRunningTime(detail.getRunningTime()));
            }
            if (detail.getDirector() != null) {
                detail.setDirector(cleanText(detail.getDirector()));
            }
            if (detail.getActors() != null) {
                detail.setActors(cleanText(detail.getActors()));
            }
            if (detail.getPlot() != null) {
                detail.setPlot(cleanText(detail.getPlot()));
            }
            if (detail.getRating() != null) {
                detail.setRating(cleanText(detail.getRating()));
            }
            
            // 영화 상세 정보 저장 또는 업데이트
            String checkSql = "SELECT COUNT(*) FROM movie_detail WHERE movie_id = ?";
            String insertSql = "INSERT INTO movie_detail (movie_id, english_title, director, actors, plot, rating, running_time, release_date, genre) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            String updateSql = "UPDATE movie_detail SET english_title = ?, director = ?, actors = ?, plot = ?, rating = ?, running_time = ?, release_date = ?, genre = ? WHERE movie_id = ?";
            
            // 이미 존재하는 영화 상세 정보인지 확인
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, detail.getMovieId());
            rs = pstmt.executeQuery();
            
            boolean exists = false;
            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }
            
            if (exists) {
                log("기존 영화 상세 정보 업데이트: " + detail.getTitle());
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setString(1, detail.getEnglishTitle());
                pstmt.setString(2, detail.getDirector());
                pstmt.setString(3, detail.getActors());
                pstmt.setString(4, detail.getPlot());
                pstmt.setString(5, detail.getRating());
                pstmt.setString(6, detail.getRunningTime());
                pstmt.setString(7, detail.getReleaseDate());
                pstmt.setString(8, detail.getGenre());
                pstmt.setString(9, detail.getMovieId());
                
                int result = pstmt.executeUpdate();
                if (result > 0) {
                    log("영화 상세 정보 업데이트 성공: " + detail.getTitle());
                    log("업데이트된 장르: " + detail.getGenre());
                    log("업데이트된 러닝타임: " + detail.getRunningTime());
                } else {
                    log("영화 상세 정보 업데이트 실패: " + detail.getTitle());
                }
            } else {
                // 삽입
                log("새 영화 상세 정보 삽입: " + detail.getTitle());
                pstmt = conn.prepareStatement(insertSql);
                pstmt.setString(1, detail.getMovieId());
                pstmt.setString(2, detail.getEnglishTitle());
                pstmt.setString(3, detail.getDirector());
                pstmt.setString(4, detail.getActors());
                pstmt.setString(5, detail.getPlot());
                pstmt.setString(6, detail.getRating());
                pstmt.setString(7, detail.getRunningTime());
                pstmt.setString(8, detail.getReleaseDate());
                pstmt.setString(9, detail.getGenre());
                
                int result = pstmt.executeUpdate();
                if (result > 0) {
                    log("영화 상세 정보 삽입 성공: " + detail.getTitle());
                    log("삽입된 장르: " + detail.getGenre());
                    log("삽입된 러닝타임: " + detail.getRunningTime());
                } else {
                    log("영화 상세 정보 삽입 실패: " + detail.getTitle());
                }
            }
            
            if (detail.getGenre() != null && !detail.getGenre().isEmpty() || 
                detail.getRunningTime() != null && !detail.getRunningTime().isEmpty()) {
                
                String updateMovieSql = "UPDATE movie SET genre = ?, running_time = ? WHERE movie_id = ?";
                pstmt = conn.prepareStatement(updateMovieSql);
                pstmt.setString(1, detail.getGenre());
                pstmt.setString(2, detail.getRunningTime());
                pstmt.setString(3, detail.getMovieId());
                int updateResult = pstmt.executeUpdate();
                
                if (updateResult > 0) {
                    log("영화 테이블 장르/러닝타임 업데이트 성공: " + detail.getTitle());
                    log("영화 테이블에 업데이트된 장르: " + detail.getGenre());
                    log("영화 테이블에 업데이트된 러닝타임: " + detail.getRunningTime());
                }
            }
            
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }
    }
    
    /**
     * 모든 영화 정보 크롤링 및 저장 실행
     */
    public void crawlAndSaveAllMovies() {
        log("영화 크롤링 프로세스 시작...");
        
        try {
            boolean resetTables = true; 
            
            if (resetTables) {
                log("영화 테이블 초기화 시작...");
                MovieDAO movieDAO = new MovieDAO();
                movieDAO.resetMovieTables();
                log("영화 테이블 초기화 완료");
            }
            
            // 테이블이 존재하는지 확인하고 없으면 생성
            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                checkAndCreateTables(conn);
            } finally {
                if (conn != null) conn.close();
            }
            
            List<Movie> currentMovies = crawlCurrentMovies();
            log("현재 상영작 크롤링 완료: " + currentMovies.size() + "개 영화");
            
            List<Movie> comingSoonMovies = crawlComingSoonMovies();
            log("상영 예정작 크롤링 완료: " + comingSoonMovies.size() + "개 영화");
            
            if (!currentMovies.isEmpty()) {
                log("현재 상영작 데이터베이스 저장 시작...");
                saveMoviesToDatabase(currentMovies);
            }
            
            if (!comingSoonMovies.isEmpty()) {
                log("상영 예정작 데이터베이스 저장 시작...");
                saveMoviesToDatabase(comingSoonMovies);
            }
            
            log("모든 영화 크롤링 및 저장 완료!");
        } catch (Exception e) {
            log("크롤링 및 저장 중 예외 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * 특정 영화 ID의 상세 정보만 다시 크롤링하여 업데이트
     */
    public boolean updateMovieDetail(String movieId) {
        log("영화 ID " + movieId + "의 상세 정보 업데이트 시작...");
        
        try {
            // 영화 상세 정보 크롤링
            MovieDetail detail = crawlMovieDetail(movieId);
            
            if (detail.getTitle() == null || detail.getTitle().isEmpty()) {
                log("영화 상세 정보를 가져오지 못했습니다.");
                return false;
            }
            
            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                
                // 영화 테이블 업데이트
                PreparedStatement pstmt = conn.prepareStatement(
                    "UPDATE movie SET genre = ?, running_time = ? WHERE movie_id = ?"
                );
                pstmt.setString(1, cleanGenre(detail.getGenre()));
                pstmt.setString(2, cleanRunningTime(detail.getRunningTime()));
                pstmt.setString(3, movieId);
                int result1 = pstmt.executeUpdate();
                pstmt.close();
                
                // 영화 상세 정보 테이블 업데이트
                saveMovieDetail(conn, detail);
                
                log("영화 ID " + movieId + "의 상세 정보 업데이트 완료");
                return true;
            } finally {
                if (conn != null) conn.close();
            }
        } catch (Exception e) {
            log("영화 상세 정보 업데이트 중 오류: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
