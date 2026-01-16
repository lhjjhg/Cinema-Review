package dto;

public class Movie {
    private String movieId;
    private String title;
    private String posterUrl;
    private double rating;
    private int movieRank;
    private String releaseDate;
    private String genre;
    private String runningTime;
    private String status; // current, coming, old
    private MovieDetail detail; 
    
    public Movie() {
    }

    public String getMovieId() {
        return movieId;
    }

    public void setMovieId(String movieId) {
        this.movieId = movieId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getPosterUrl() {
        return posterUrl;
    }

    public void setPosterUrl(String posterUrl) {
        this.posterUrl = posterUrl;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getMovieRank() {
        return movieRank;
    }

    public void setMovieRank(int movieRank) {
        this.movieRank = movieRank;
    }

    public String getReleaseDate() {
        return releaseDate;
    }

    public void setReleaseDate(String releaseDate) {
        this.releaseDate = releaseDate;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public String getRunningTime() {
        return runningTime;
    }

    public void setRunningTime(String runningTime) {
        this.runningTime = runningTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
    public MovieDetail getDetail() {
        return detail;
    }

    public void setDetail(MovieDetail detail) {
        this.detail = detail;
    }

    @Override
    public String toString() {
        return "Movie [movieId=" + movieId + ", title=" + title + ", rating=" + rating + ", movieRank=" + movieRank
                + ", releaseDate=" + releaseDate + ", genre=" + genre + ", runningTime=" + runningTime + ", status="
                + status + "]";
    }
}
