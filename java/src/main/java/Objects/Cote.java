package Objects;

public class Cote {
    private  int id ;
    private String user  ;
    private  int note ;
    private String date ;
    private  String avis ;
    private  int count ;
    private  double avg ;


    public Cote(int idd , int notee , String userr , String dtae , String aviss , int countt , double avgg ){
        id = idd ;
        user = userr ;
        note = notee ;
        date = dtae ;
        avis = aviss ;
        count =countt ;
        avg =avgg ;

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public int getNote() {
        return note;
    }

    public void setNote(int note) {
        this.note = note;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getAvis() {
        return avis;
    }

    public void setAvis(String avis) {
        this.avis = avis;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public double getAvg() {
        return avg;
    }

    public void setAvg(double avg) {
        this.avg = avg;
    }
}
