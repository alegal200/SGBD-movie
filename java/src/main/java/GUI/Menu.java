package GUI;

import Objects.ShortMovie;
import controleur.Controleur;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.ArrayList;

public class Menu  extends  JFrame{
    private JButton rechercherButton;
    private JTable table1;
    private JPanel botom;
    private JPanel core;
    private JPanel top;
    private JPanel result;
    private JPanel infos;
    private JRadioButton multiCritèreRadioButton;
    private JRadioButton parIDRadioButton;
    private JPanel tottalPanel;
    private JTextField actorfield;
    private JTextField titlefield;
    private JTextField directorfield;
    private JTextField yearfield;
    private JComboBox operatorcombo;
    private JPanel multicritfield;
    private JPanel utilinfo;
    private JTextField idfield;
    private JPanel idcrit;


    public Menu(){
        createUIComponents();
        idcrit.setVisible(false);




        rechercherButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                //listener du menu rechercher
                if(parIDRadioButton.isSelected()){
                    int nbrId;
                    try{
                        nbrId = Integer.parseInt(idfield.getText());
                        ArrayList<ShortMovie> arrmv =  Controleur.getMovies(nbrId) ;
                        filltable(arrmv);

                    }catch (Exception exp){
                        System.out.println(exp.toString());
                    }
                }
                if(multiCritèreRadioButton.isSelected()){
                    try{
                        int year = Integer.parseInt(yearfield.getText());

                        ArrayList<ShortMovie> arrmv =  Controleur.getMovies(titlefield.getText() ,operatorcombo.getSelectedItem().toString() ,year,actorfield.getText() ,directorfield.getText() ) ;
                        filltable(arrmv);
                    }catch (Exception exp){

                        ArrayList<ShortMovie> arrmv =  Controleur.getMovies(titlefield.getText() ,actorfield.getText() ,directorfield.getText() ) ;
                        filltable(arrmv);
                    }
                }




            }
        });


        parIDRadioButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                // id radio button
                System.out.println("id selectionner ");
                multicritfield.setVisible(false);
                idcrit.setVisible(true);

                infos.updateUI();
            }
        });
        multiCritèreRadioButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                // critere radio button
                System.out.println("critères sélec");
                idcrit.setVisible(false);
                multicritfield.setVisible(true);
                infos.updateUI();
            }
        });
        table1.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                super.mouseClicked(e);
                try{
                    System.out.println("click on movie");
                Film_More flm = new Film_More(Integer.parseInt( table1.getModel().getValueAt( table1.getSelectedRow(),0).toString()));
                flm.setSize(600,600);
                flm.setVisible(true);}
                catch (Exception uuu){uuu.printStackTrace();}


            }
        });
    }

    private void filltable(ArrayList<ShortMovie> arrmv) {
        if(arrmv == null)
            return;
        String[][] data = new String[arrmv.size()][10];
        String[] title =  {"id", "title", "original_title", "release_date" , "status",  "runtime", "certification", "budget", "tag_line"};

        for (int i = 0; i < arrmv.size(); i++) {
            data[i][0] = arrmv.get(i).getId() +"";
            data[i][1] = arrmv.get(i).getTitle() ;
            data[i][2] = arrmv.get(i).getOriginal_title();
            data[i][3] = arrmv.get(i).getRelease_date() ;
            data[i][4] = arrmv.get(i).getStatus();
            data[i][5] = arrmv.get(i).getRuntime() +"" ;
            data[i][6] = arrmv.get(i).getCertification() ;
            data[i][7] = arrmv.get(i).getBudget() +"" ;
            data[i][8] = arrmv.get(i).getTag_line() ;
        }

        table1.setModel(new DefaultTableModel(data, title) );
        table1.updateUI();

    }

    private void createUIComponents() {
        // TODO: place custom component creation code here
        setTitle("mega class fenetre ");
        setSize(450,300);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        setVisible(true);
        setContentPane(tottalPanel);

    }
}
