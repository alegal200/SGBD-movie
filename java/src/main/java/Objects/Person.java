package Objects;

public class Person {
    private String name ;
    private String type ;
    private String charectera ;


    public Person(String n , String t , String c){
        name = n ;
        type = t ;
        charectera = c ;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getCharectera() {
        return charectera;
    }

    public void setCharectera(String charectera) {
        this.charectera = charectera;
    }
}
