package GUI;

import Objects.Cote;
import Objects.FullMovie;
import Objects.ShortMovie;
import controleur.Controleur;

import javax.imageio.ImageIO;
import javax.swing.*;
import javax.swing.event.AncestorEvent;
import javax.swing.event.AncestorListener;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.swing.table.DefaultTableModel;
import java.awt.event.*;
import java.awt.image.BufferedImage;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.beans.PropertyVetoException;
import java.beans.VetoableChangeListener;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Base64;

public class Film_More extends JDialog {
    private JPanel contentPane;
    private JButton buttonCancel;
    private JPanel jpaneavis;
    private JPanel JpanelFilm;
    private JPanel jpanelinfoFilm;
    private JPanel jpanelImg;
    private JLabel LabelID;
    private JLabel label_change_id;
    private JLabel jLabel_title;
    private JLabel jLAbel_original_title;
    private JLabel jLabel_date;
    private JLabel jLabel_status;
    private JLabel jlabel_runtime;
    private JLabel jlabelbudget;
    private JLabel jlabel_note_avg_old;
    private JLabel jlabel_note_count_old;
    private JTable table_actor_director;
    private JLabel jlableImg;
    private JTextField textField_user;
    private JButton connectionButton;
    private JTextArea textAreaAvis;
    private JSpinner spinner1;
    private JButton envoyerButton;
    private JButton supprimerButton;
    private JTable tableavis;
    private JLabel jlabel_certif;
    private JLabel jlabeltag;
    private JList list1;
    private JLabel jlabel_avg;
    private JLabel jlabel_count;
    private FullMovie movie_Obj ;
    private ArrayList<Cote> arrcote ;
    private  String user ;
    private  int id ;

    public Film_More( int idd) {
        id = idd ;
        setContentPane(contentPane);
        setModal(true);


        buttonCancel.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                onCancel();
            }
        });

        // call onCancel() when cross is clicked
        setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
        addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                onCancel();
            }
        });

        // call onCancel() on ESCAPE
        contentPane.registerKeyboardAction(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                onCancel();
            }
        }, KeyStroke.getKeyStroke(KeyEvent.VK_ESCAPE, 0), JComponent.WHEN_ANCESTOR_OF_FOCUSED_COMPONENT);

         movie_Obj = Controleur.getFullDataMovi(id) ;

         label_change_id.setText(movie_Obj.getId()+"");
         jLabel_title.setText(movie_Obj.getTitle());
         jLAbel_original_title.setText(movie_Obj.getOriginal_title());
         jLabel_date.setText(movie_Obj.getRelease_date());
         jLabel_status.setText(movie_Obj.getStatus());
         jlabel_runtime.setText(movie_Obj.getRuntime()+"");
         jlabel_certif.setText(movie_Obj.getCertification());
         jlabelbudget.setText( movie_Obj.getBudget()+"");
         jlabeltag.setText(movie_Obj.getTag_line());
         jlabel_note_avg_old.setText(movie_Obj.getNote_avg_old());
         jlabel_note_count_old.setText(movie_Obj.getNote_count_old()+"");
         DefaultListModel<String> genrelst = new DefaultListModel<>();
        for (int i = 0; i < movie_Obj.getGenres().size(); i++) {
            genrelst.addElement(movie_Obj.getGenres().get(i));
        }
         list1.setModel(genrelst);

        String titretab [] = {"type","name","charectera"};
        String datatab [][] = new String[movie_Obj.getActor_dir_list().size()+1][3];
        for (int i = 0; i < movie_Obj.getActor_dir_list().size(); i++) {
            datatab[i][0] = movie_Obj.getActor_dir_list().get(i).getType();
            datatab[i][1] = movie_Obj.getActor_dir_list().get(i).getName() ;
            datatab[i][2] = movie_Obj.getActor_dir_list().get(i).getCharectera();
        }
        table_actor_director.setModel(new DefaultTableModel(datatab,titretab));
        table_actor_director.updateUI();

        byte[] btDataFile = null;
        try {

            if (movie_Obj.getPicture()!=null && ! movie_Obj.getPicture().equals("")) {
                btDataFile = Base64.getDecoder().decode((String) movie_Obj.getPicture());
                BufferedImage image = ImageIO.read(new ByteArrayInputStream(btDataFile));
                ImageIcon icon = new ImageIcon(image);
                jlableImg.setIcon(icon);
            }

        } catch (Exception ex) {
        }
        spinner1.setModel(new SpinnerNumberModel(5,0,10,1));


      miseajoucote();


        connectionButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                user = textField_user.getText();
                if( arrcote != null && arrcote.get(0)!= null){
                    for (int i = 0; i < arrcote.size(); i++) {
                        if( user.equals( arrcote.get(i).getUser())){
                            spinner1.setValue(arrcote.get(i).getNote());
                            textAreaAvis.setText(arrcote.get(i).getAvis());
                            return;
                        }
                    }



                }
                spinner1.setValue(5);
                textAreaAvis.setText("");
            }
        });
        supprimerButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Controleur.deletecote(user,id);
                miseajoucote();

            }
        });
        envoyerButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {

                    Controleur.insertCote(user, id , (int) spinner1.getValue(), textAreaAvis.getText());
                    System.out.println("+");
                    miseajoucote();
                    System.out.println("-*-");
                }catch (Exception eee){}

            }
        });
    }

    private void miseajoucote() {

        arrcote = new ArrayList<>();
        arrcote = Controleur.getnotesFilm(id);



        if( arrcote != null && arrcote.size() >0 && arrcote.get(0)!= null) {
            String titretabcote [] = {"user","note","date","avis"};
            String datatabcote [][] = new String[arrcote.size()+1][4];
            for (int i = 0; i < arrcote.size(); i++) {
                datatabcote[i][0] = arrcote.get(i).getUser();
                datatabcote[i][1] = arrcote.get(i).getNote() +"" ;
                datatabcote[i][2] = arrcote.get(i).getDate() ;
                datatabcote[i][3] = arrcote.get(i).getAvis()+"";
            }
            tableavis.setModel(new DefaultTableModel(datatabcote,titretabcote));
            tableavis.updateUI();

            jlabel_avg.setText(arrcote.get(0).getAvg() + "");
            jlabel_count.setText(arrcote.get(0).getCount() + "");
        }

    }


    private void onCancel() {
        // add your code here if necessary
        dispose();
    }
/*
    public static void main(String[] args) {
        Film_More dialog = new Film_More( 0 );
        dialog.pack();
        dialog.setVisible(true);
        System.exit(0);
    }
*/
    private void createUIComponents() {
        // TODO: place custom component creation code here
    }
}
