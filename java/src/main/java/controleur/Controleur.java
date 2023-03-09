package controleur;

import Objects.Cote;
import Objects.FullMovie;
import Objects.Person;
import Objects.ShortMovie;
import com.mashape.unirest.http.Unirest;
import com.mongodb.MongoException;
import com.mongodb.client.*;
import org.bson.BsonDocument;
import org.bson.BsonInt64;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.json.JSONArray;
import org.json.JSONObject;
import java.util.ArrayList;


public class Controleur {


    public  static  ArrayList<ShortMovie> getMovies(int id){

        String rep  = mongo_Get("id"+id);
        if(rep != null )
            return  transform_json_shortmovie(rep) ;

        String reponse ;
        try {
            reponse = Unirest.get("http://localhost:8080/ords/alex/data/moviesbyid/"+id)
                    .header("Connection","keep-alive")
                    .asString().getBody();
                    mongo_Insert("id"+id , reponse);
            return  transform_json_shortmovie(reponse) ;

        }catch (Exception exp ){
            return  null ;
        }


    }

    public  static  ArrayList<ShortMovie> getMovies(String title , String opperator , int year , String actors , String Director){ // todo mongodb ici

        String rep  = mongo_Get("titre:"+title +"opperator:" + opperator +"year:"+year +"actors:"+actors+"Director:"+Director);

        if(rep != null )
            return  transform_json_shortmovie("{items:"+ rep +"}") ;

        JSONObject jsnObj = new JSONObject();
        jsnObj.put("title",title);
        jsnObj.put("operator",opperator);
        jsnObj.put("actor",actors );
        jsnObj.put("director",Director);
        jsnObj.put("date",year);
        String reponse ;
        //System.out.println("hson obj "+jsnObj.toString());
        try {
            reponse = Unirest.post("http://localhost:8080/ords/alex/data/moviescrit")
                    .header("Connection","keep-alive")
                    .body(jsnObj)
                    .asString().getBody();
            mongo_Insert("titre:"+title +"opperator:" + opperator +"year:"+year +"actors:"+actors+"Director:"+Director, reponse);
            return  transform_json_shortmovie("{items:"+ reponse +"}") ;

        }catch (Exception exp ){
            return  null ;
        }

    }

    private  static  ArrayList<ShortMovie> transform_json_shortmovie(String jsonString) {

            ArrayList<ShortMovie> arrmovies = new ArrayList<>();
        try {
            JSONObject obj = new JSONObject(jsonString);
            JSONArray arr = obj.getJSONArray("items");
            for (int i = 0; i < arr.length(); i++) {


                int id =   arr.getJSONObject(i).getInt("id_movie");
                String title = arr.getJSONObject(i).getString("title");
                String original_title = "null";
                try{
                    original_title = arr.getJSONObject(i).getString("original_title");
                }catch (Exception e){}

                String release_date = arr.getJSONObject(i).getString("release_date");
                String status = arr.getJSONObject(i).getString("status");
                int  runtime =   arr.getJSONObject(i).getInt("runtime");
                String certification = "null";
                try{
                    certification = arr.getJSONObject(i).getString("certification");
                }catch (Exception e){}
                String picture = "null";
                try {
                    picture = arr.getJSONObject(i).getString("picture");
                }catch (Exception e){}
                int budget = arr.getJSONObject(i).getInt("budget")  ;
                String tag_line ="null";
                try {
                    tag_line = arr.getJSONObject(i).getString("tag_line");
                }catch (Exception e){}

                ShortMovie shrtmv = new ShortMovie(id,title,original_title,release_date,status,runtime,certification,picture,budget,tag_line);
                arrmovies.add(shrtmv);


            }

        }catch (Exception e){

            e.printStackTrace();
            return  null ;
        }
        return  arrmovies ;
    }

    public static ArrayList<ShortMovie> getMovies(String title, String actors, String director) {
        String rep  = mongo_Get("titre:"+title +"actors:"+actors+"Director:"+director);

        if(rep != null )
            return  transform_json_shortmovie("{items:"+ rep +"}") ;


        JSONObject jsnObj = new JSONObject();
        jsnObj.put("title",title);
        jsnObj.put("actor",actors );
        jsnObj.put("director",director);
        String reponse ;
       // System.out.println("hson obj "+jsnObj.toString());
        try {
            reponse = Unirest.post("http://localhost:8080/ords/alex/data/moviescrit")
                    .header("Connection","keep-alive")
                    .body(jsnObj)
                    .asString().getBody();
           // System.out.println("rep:"+reponse);
            mongo_Insert("titre:"+title +"actors:"+actors+"Director:"+director,reponse);
            return  transform_json_shortmovie("{items:"+ reponse +"}") ;

        }catch (Exception exp ){
            return  null ;
        }
    }

    public static FullMovie getFullDataMovi(int id){
        String reponse ;
        try {
            reponse = Unirest.get("http://localhost:8080/ords/alex/data/film/"+id)
                    .header("Connection","keep-alive")
                    .asString().getBody();
            return  makefullmoviewithjson(reponse) ;

        }catch (Exception exp ){
            return  null ;
        }




    }

    private static FullMovie makefullmoviewithjson(String jsonString) {



        String jjsonString = jsonString.replace("}\n,","}]");
        String[] tmp = jjsonString.split("]");
        String titre ="";
        String ORIGINAL_TITLE = "";
        String RELEASE_DATE = "";
        String STATUS = "";
        String NOTE_AVG ="";
        String BASE64PIC ="";
        String CERTIFICATION = "";
        String TAG_LINE = "";
        int ID_MOVIE = 0 ;
        int RUNTIME = 0 ;
        int BUDGET = 0;
        int NOTE_COUNT = 0 ;
        ArrayList<String> genres = new ArrayList<>();
        ArrayList<Person> plist = new ArrayList<>();
        try {
            for (int i = 0; i < tmp.length-1; i++) {
                //System.out.println("*******"+tmp[i].substring(tmp[i].indexOf('{')));
                JSONObject jso = new JSONObject(tmp[i].substring(tmp[i].indexOf('{')));
                try{
                    titre = jso.get("TITLE").toString() ;
                }catch (Exception ee){}
                try{
                    ORIGINAL_TITLE = jso.get("ORIGINAL_TITLE").toString() ;

                }catch (Exception ee){}
                try{
                    RELEASE_DATE = jso.get("RELEASE_DATE").toString() ;
                }catch (Exception ee){}
                try{
                    TAG_LINE = jso.get("TAG_LINE").toString() ;
                }catch (Exception ee){}
                try{
                    STATUS = jso.get("STATUS").toString() ;
                }catch (Exception ee){}
                try{
                    CERTIFICATION = jso.get("CERTIFICATION").toString() ;
                }catch (Exception ee){}
                try{
                    NOTE_AVG = jso.get("NOTE_AVG").toString() ;
                }catch (Exception ee){}
                try{
                    ID_MOVIE = jso.getInt("ID_MOVIE") ;
                }catch (Exception ee){}
                try{
                    RUNTIME = jso.getInt("RUNTIME") ;
                }catch (Exception ee){}
                try{
                    BUDGET = jso.getInt("BUDGET") ;
                }catch (Exception ee){}
                try{
                    NOTE_COUNT = jso.getInt("NOTE_COUNT") ;
                }catch (Exception ee){}
                try{
                    genres.add(jso.get("GENRE").toString()) ;
                }catch (Exception ee){}
                try{
                    String ac  = jso.get("ACTOR").toString() ;
                    String cha ="";
                    try{
                        cha = jso.get("CHARECTERA").toString();
                    }catch (Exception eee0){}
                    plist.add( new Person(ac,"act",cha));
                }catch (Exception ee){}
                try {
                    String dir = jso.get("DIRECTOR").toString();
                    plist.add( new Person(dir,"dir",""));
                }catch (Exception eeeee ){}
                try {
                    BASE64PIC = jso.getString("BASE64PIC").toString();
                }catch (Exception ddqd){}

            }



        }catch(Exception e){

            e.printStackTrace();

        }

        return new FullMovie(ID_MOVIE,titre,ORIGINAL_TITLE,RELEASE_DATE,STATUS,RUNTIME,CERTIFICATION,BASE64PIC,BUDGET,TAG_LINE,NOTE_AVG,NOTE_COUNT,plist,genres);


    }

    public  static ArrayList<Cote> getnotesFilm(int id){
        String reponse ;
        try {
            reponse = Unirest.get("http://localhost:8080/ords/alex/data/cote/"+id)
                    .header("Connection","keep-alive")
                    .asString().getBody();
            return  makecotes(reponse) ;

        }catch (Exception exp ){
            return  null ;
        }




    }

    private static ArrayList<Cote> makecotes(String reponse) {
        ArrayList<Cote> arrcote = new ArrayList<>();
        JSONObject obj = new JSONObject(reponse);
        JSONArray arr = obj.getJSONArray("items");
        for (int i = 0; i < arr.length(); i++) {

            int id =   arr.getJSONObject(i).getInt("id_movie");
            String user = arr.getJSONObject(i).getString("userx");
            String date = "";
            String avis ="";
            int note = arr.getJSONObject(i).getInt("note");
            try{
                date = arr.getJSONObject(i).getString("datex");

            }catch (Exception e){}
            try{
                avis = arr.getJSONObject(i).getString("avisx");

            }catch (Exception e){}
            int count = arr.getJSONObject(i).getInt("count");
            double avg = arr.getJSONObject(i).getDouble("avg");
            arrcote.add(new Cote(id,note,user,date ,avis,count,avg));


        }
        return  arrcote ;
    }

    public static void deletecote(String user, int id) {
        //http://localhost:8080/ords/alex/data/deleteavis/24/aledx

        try {
             Unirest.get("http://localhost:8080/ords/alex/data/deleteavis/"+id+"/"+user)
                    .header("Connection","keep-alive")
                    .asString().getBody();
            return   ;

        }catch (Exception exp ){
            return   ;
        }

    }

    public static void insertCote(String user, int id, int value, String text) {


        JSONObject jsnObj = new JSONObject();
        jsnObj.put("user",user);
        jsnObj.put("id",id);
        jsnObj.put("note",value);
        if(text != null && !text.equals(""))
            jsnObj.put("avis",text);

        try {

            Unirest.post("http://localhost:8080/ords/alex/data/pcote").body(jsnObj).asString();
            System.out.println("json "+ jsnObj.toString());


        }catch (Exception exp ){
            exp.printStackTrace();
            return  ;
        }

    }

    private static void mongo_Insert(String idity, String reponse) {

        String uri = "mongodb://localhost:27017/?maxPoolSize=20&w=majority";
        try (MongoClient mongoClient = MongoClients.create(uri)) {
            MongoDatabase database = mongoClient.getDatabase("alexMD");
            Bson command;
            try {
                command = new BsonDocument("ping", new BsonInt64(1));
                Document commandResult = database.runCommand(command);
               // System.out.println("Connected successfully to server.");
            } catch (MongoException me) {
                System.err.println("An error occurred while attempting to run a command:" + me);
            }
            MongoCollection<Document> collection = database.getCollection("film");
            // ajouter un objet
            Document to_add = new Document();
            to_add.append("requette", idity);
            to_add.append("result", reponse);
            collection.insertOne(to_add);

        }
    }

    private static String mongo_Get(String idity) {
        String rep = null ;
        String uri = "mongodb://localhost:27017/?maxPoolSize=20&w=majority";
        try (MongoClient mongoClient = MongoClients.create(uri)) {
            MongoDatabase database = mongoClient.getDatabase("alexMD");
            Bson command;
            try {
                command = new BsonDocument("ping", new BsonInt64(1));
                Document commandResult = database.runCommand(command);
                System.out.println("Connected successfully to server.");
            } catch (MongoException me) {
                System.err.println("An error occurred while attempting to run a command:" + me);
            }
            MongoCollection<Document> collection = database.getCollection("film");
            Document filter = new Document();
            filter.append("requette", idity);
            try (MongoCursor<Document> cursor = collection.find(filter).iterator()) {
                while (cursor.hasNext()) {
                    rep = cursor.next().get("result").toString() ;

                }
            }

        }

        return  rep ;
    }


}
