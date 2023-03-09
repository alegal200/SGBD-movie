import GUI.Menu;
import com.mongodb.MongoException;
import com.mongodb.client.*;
import org.bson.BsonDocument;
import org.bson.BsonInt64;
import org.bson.Document;
import org.bson.conversions.Bson;


import java.util.ArrayList;
import java.util.List;

public class MainProcess {
    public static void main(String[] args) {
        System.out.println("hello world");
        Menu mn = new Menu();
/*

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
            List<String> list = new ArrayList<>();
//collection.find().map(Document::toJson).forEach(list::add);
            // parcourir tout les elements
            try (MongoCursor<Document> cursor = collection.find().iterator()) {
                while (cursor.hasNext()) {
                    System.out.println(cursor.next());
                }
            }
            // ajouter un objet
            Document to_add = new Document();
            to_add.append("requette", "ale");
            to_add.append("result", "22ddqdsqkd");

            collection.insertOne(to_add);

            System.out.println(" alors");
            Document filter = new Document();
            filter.append("requette", "ale");
            try (MongoCursor<Document> cursor = collection.find(filter).iterator()) {
                while (cursor.hasNext()) {
                    System.out.println(cursor.next());
                }
            }



        }
    }



*/
    }
}
