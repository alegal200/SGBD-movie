package Objects;

import java.util.ArrayList;

public class FullMovie {

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
private String note_avg_old ;
private int note_count_old ;
private ArrayList<Person> actor_dir_list ;
private ArrayList<String> genres ;





    public FullMovie(int id, String title, String original_title, String release_date, String status, int runtime, String certification, String picture, int budget, String tag_line
   , String note_avg_old , int note_count_old , ArrayList<Person> actor_dir_list , ArrayList<String> genres) {
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
        this.note_avg_old = note_avg_old ;
        this.note_count_old = note_count_old ;
        this.actor_dir_list = actor_dir_list ;
        this.genres = genres ;

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

    public String getNote_avg_old() {
        return note_avg_old;
    }

    public void setNote_avg_old(String note_avg_old) {
        this.note_avg_old = note_avg_old;
    }

    public int getNote_count_old() {
        return note_count_old;
    }

    public void setNote_count_old(int note_count_old) {
        this.note_count_old = note_count_old;
    }

    public ArrayList<Person> getActor_dir_list() {
        return actor_dir_list;
    }

    public void setActor_dir_list(ArrayList<Person> actor_dir_list) {
        this.actor_dir_list = actor_dir_list;
    }

    public ArrayList<String> getGenres() {
        return genres;
    }

    public void setGenres(ArrayList<String> genres) {
        this.genres = genres;
    }
}
