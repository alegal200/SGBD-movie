package Objects;

public class ShortMovie {

    private int id;
    private String title;
    private String original_title;
    private String release_date;
    private String status;
    private int runtime;
    private String certification;
    private String picture;
    private int budget;
    private String tag_line;


    public ShortMovie(int id, String title, String original_title, String release_date, String status, int runtime, String certification, String picture, int budget, String tag_line) {
        this.id = id ;
        this.title    =  title  ;
        this.original_title    =  original_title  ;
        this.release_date    =   release_date  ;
        this.status    =  status  ;
        this.runtime    =  runtime  ;
        this.certification    =  certification  ;
        this.picture    =  picture  ;
        this.budget    = budget   ;
        this.tag_line    =  tag_line  ;

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getOriginal_title() {
        return original_title;
    }

    public void setOriginal_title(String original_title) {
        this.original_title = original_title;
    }

    public String getRelease_date() {
        return release_date;
    }

    public void setRelease_date(String release_date) {
        this.release_date = release_date;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getRuntime() {
        return runtime;
    }

    public void setRuntime(int runtime) {
        this.runtime = runtime;
    }

    public String getCertification() {
        return certification;
    }

    public void setCertification(String certification) {
        this.certification = certification;
    }

    public String getPicture() {
        return picture;
    }

    public void setPicture(String picture) {
        this.picture = picture;
    }

    public int getBudget() {
        return budget;
    }

    public void setBudget(int budget) {
        this.budget = budget;
    }

    public String getTag_line() {
        return tag_line;
    }

    public void setTag_line(String tag_line) {
        this.tag_line = tag_line;
    }
}
