-- CREATE USER

alter session set "_ORACLE_SCRIPT"=true;

create role sgbd2s_role not identified;
grant alter session to sgbd2s_role;
grant create session to sgbd2s_role;
grant create table to sgbd2s_role;
grant create procedure to sgbd2s_role;
grant create sequence to sgbd2s_role;
grant create trigger to sgbd2s_role;
grant create type to sgbd2s_role;
grant execute on sys.owa_opt_lock to sgbd2s_role;
grant execute on sys.dbms_lock to sgbd2s_role;


-- CREATE SHORTCUT TO A FILE

CREATE OR REPLACE DIRECTORY MYDIR AS '/home/oracle/ExternalTables';


-- CREATE  EXTERNAL TABLE 


drop table movies_ext;

CREATE TABLE movies_ext
(
	id NUMBER(4) ,
	title VARCHAR(3000),
	original_title VARCHAR(3000),
	release_date  DATE ,
    status VARCHAR(30) ,
    vote_average VARCHAR(5) ,
    vote_count NUMBER(10) ,
    runtime NUMBER(10) ,
    certification VARCHAR(6) ,
    poster_path VARCHAR(200) ,
    budget NUMBER(10) ,
    tagline VARCHAR(3000) ,
    genres VARCHAR(3000) ,
    directors VARCHAR(3000) ,
    actors VARCHAR(3000)
)
ORGANIZATION EXTERNAL
(
	TYPE ORACLE_LOADER
	DEFAULT DIRECTORY MYDIR
	ACCESS PARAMETERS
	(
		--commentaires
		RECORDS DELIMITED BY '\r\n'
		characterset "AL32UTF8"
		string sizes are in characters
		FIELDS TERMINATED BY X"E280A3"
		MISSING FIELD VALUES ARE NULL
		(
			
            id   unsigned integer external(4),
            title char(3000),
            original_title char(3000),
            release_date  char(10) date_format date mask "yy-mm-dd" ,
            status char(30) , 
            vote_average char(5),
            vote_count  unsigned integer external(10),
            runtime  unsigned integer external(10), 
            certification char(6) , 
            poster_path char(200) , 
            budget unsigned integer external(10), 
            tagline  char(3000) , 
            genres  char(3000) ,
            directors  char(3000) , 
            actors char(3000)

            
		)
	)
	LOCATION('movie.txt')
)
REJECT LIMIT UNLIMITED;

select COUNT(*) FROM movies_ext;


------------- CREATIONS DES TABLES 

---- movies : 

CREATE TABLE MOVIES
( 
    ID_MOVIE NUMBER(10) CONSTRAINT ID_MOVIE_PK PRIMARY KEY ,
    TITLE VARCHAR(300),
    ORIGINAL_TITLE VARCHAR(300) NOT NULL ,
    RELEASE_DATE DATE ,
    STATUS VARCHAR(15) ,
    RUNTIME NUMBER(5) ,
    CERTIFICATION VARCHAR(10) ,
    PICTURE BLOB ,
    BUDGET NUMBER ,
    TAG_LINE VARCHAR(3000) 
);

--- genre 
CREATE TABLE GENRE 
(
ID  NUMBER(5) CONSTRAINT ID_GENRE_PK PRIMARY KEY ,
NAME VARCHAR(30) 
) ;

---- director 

CREATE TABLE DIRECTOR
(
ID  NUMBER(10) CONSTRAINT ID_DIRECTOR_PK PRIMARY KEY ,
NAME VARCHAR(30) 
) ;

--- actor


CREATE TABLE ACTOR
(
ID  NUMBER(10) CONSTRAINT ID_ACTOR_PK PRIMARY KEY ,
NAME VARCHAR(30) 
) ;


----  LOGS


CREATE TABLE LOGs
(
    DATEinfo DATE ,
    LOG_TITLE VARCHAR(30) ,
    LOG_DESC VARCHAR(500)
) ;


------ FILMOLDCOTE


CREATE TABLE MOVIE_OLDCOTE
(
    ID_MOVIE NUMBER(10) UNIQUE NOT NULL ,
    NOTE_AVG VARCHAR(5) ,
    NOTE_COUNT NUMBER(7) ,
    CONSTRAINT fk_MOVIE_OLD_COTE1
    FOREIGN KEY (ID_MOVIE)
    REFERENCES MOVIES(ID_MOVIE)
    
    
)    
 ;


-------- FILMECOTE
CREATE TABLE MOVIE_COTE
(
    ID_MOVIE NUMBER(10) NOT NULL ,
    NOTE NUMBER(3) ,
    USERx VARCHAR(30) NOT NULL ,
    DATEx DATE DEFAULT SYSDATE , 
    AVISx varchar(1000),
    
    CONSTRAINT fk_MOVIE_COTE1
    FOREIGN KEY (ID_MOVIE)
    REFERENCES MOVIES(ID_MOVIE),
    
    CONSTRAINT pk_MOVIE_COTE
    PRIMARY KEY (ID_MOVIE,USERx )   --- -> filmxuser = unique 
    
)    
 ;


------- FILM ACTOR


--DROP TABLE MOVIE_ACTOR ;
CREATE TABLE MOVIE_ACTOR 
(
    ID_MOVIE NUMBER(10) NOT NULL ,
    ID_ACTOR NUMBER(10) NOT NULL,
    CHARACTERA VARCHAR(300) ,
    CONSTRAINT fk_MOVIE_ACTOR1
    FOREIGN KEY (ID_MOVIE)
    REFERENCES MOVIES(ID_MOVIE),
    CONSTRAINT fk_MOVIE_ACTOR2
    FOREIGN KEY (ID_ACTOR)
    REFERENCES ACTOR(ID),
    PRIMARY KEY (ID_MOVIE,ID_ACTOR)
)    
 ;

------ FILM DIRECTOR

CREATE TABLE MOVIE_DIRECTOR 
(
    ID_MOVIE NUMBER(10) NOT NULL ,
    ID_DIRECTOR NUMBER(5) NOT NULL,
    CONSTRAINT fk_MOVIE_DIRECTOR1
    FOREIGN KEY (ID_MOVIE)
    REFERENCES MOVIES(ID_MOVIE),
    CONSTRAINT fk_MOVIE_DIRECTOR2
    FOREIGN KEY (ID_DIRECTOR)
    REFERENCES DIRECTOR(ID),
    PRIMARY KEY (ID_MOVIE,ID_DIRECTOR)
)    
 ;


------ FILM GENRE 



CREATE TABLE MOVIE_GENRE 
(
    ID_MOVIE NUMBER(10) NOT NULL ,
    ID_GENRE NUMBER(5) NOT NULL,
    CONSTRAINT fk_MOVIE_GENRE1
    FOREIGN KEY (ID_MOVIE)
    REFERENCES MOVIES(ID_MOVIE),
    CONSTRAINT fk_MOVIE_GENRE2
    FOREIGN KEY (ID_GENRE)
    REFERENCES GENRE(ID),
    PRIMARY KEY (ID_MOVIE,ID_GENRE)
)    
 ;

--------------------------------------
 ------   PROC2DURES 

---- setup images 



BEGIN
	DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
		acl => 'aclBLOB', 
		description => 'Acces a internet pour les images', 
		principal => 'ALEX',
		is_grant => true,
		privilege => 'connect'
);

DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(
	acl => 'aclBLOB',
	host => 'image.tmdb.org');
END;




 --------------------------------


CREATE OR REPLACE PROCEDURE ADDMOVIE(IDD number)
AS
    TYPE collenctionOfGenres  IS TABLE OF MOVIES_EXT.GENRES%type;
    TYPE collenctionOfActor  IS TABLE OF MOVIES_EXT.ACTORS%type;
    TYPE collenctionOfDirector  IS TABLE OF MOVIES_EXT.DIRECTORS%type;
    listeOfGenre    collenctionOfGenres ;
    listeOfActor    collenctionOfActor  ;
    listeOfDirector collenctionOfDirector ;
    
    NEW_Movie_Actor MOVIE_ACTOR%rowtype ;
    NEW_Director    DIRECTOR%rowtype ;
    NEW_Actor       ACTOR%rowtype ;
    NEW_GENRE       GENRE%rowtype ;
  --  NEW_OLDCOTE     MOVIES_OLDCOTE%rowtype;
    EXT_MOVIE       MOVIES_EXT%rowtype ;
    i               INTEGER;
    j               INTEGER;
    c               INTEGER;
    url             varchar2(200):= 'http://image.tmdb.org/t/p/w185' ;
    image           BLOB ; 
BEGIN
    DBMS_OUTPUT.PUT_LINE('Debut de la procédure de replissage de films');
    
    SELECT * INTO EXT_MOVIE FROM MOVIES_EXT WHERE  MOVIES_EXT.ID = IDD ;   --- put in memory external tuple
    
    
    SELECT COUNT(*) INTO C FROM MOVIES WHERE id_movie = IDD ;   --- verify if the movie is already on movies table 

    if( c = 0) THEN 
        DBMS_OUTPUT.PUT_LINE('le film n est pas dans la table');
        INSERT INTO MOVIES
        VALUES (EXT_MOVIE.ID ,EXT_MOVIE.TITLE ,EXT_MOVIE.ORIGINAL_TITLE ,EXT_MOVIE.RELEASE_DATE ,EXT_MOVIE.STATUS ,EXT_MOVIE.RUNTIME ,
        EXT_MOVIE.CERTIFICATION ,NULL   ,EXT_MOVIE.BUDGET     ,EXT_MOVIE.TAGLINE);
        -- insertion des données dans la table movie
        INSERT INTO MOVIE_OLDCOTE
        VALUES(EXT_MOVIE.ID,EXT_MOVIE.VOTE_AVERAGE,EXT_MOVIE.VOTE_COUNT);
        
        
        if(EXT_MOVIE.GENRES IS NOT NULL ) THEN
            DBMS_OUTPUT.PUT_LINE('traitement des genres');
            
            WITH DATA AS ( SELECT EXT_MOVIE.GENRES as str FROM dual ) 
            SELECT regexp_substr( str ,'[^' || UNISTR('\2016') || ']+',1,level ) 
            BULK COLLECT INTO listeOfGenre 
            FROM DATA  connect by level <= 
            length ( str ) - length ( replace ( str, UNISTR('\2016') ) ) + 1;
            -- on décupe le texte au ||
            
            i := listeofgenre.first;
            while i is not null LOOP
                DBMS_OUTPUT.PUT_LINE('listeofgenre i '|| listeofgenre(i) );
                
                    j := INSTR(listeofgenre(i),'․');
                    if( j != 0 ) then
                        NEW_GENRE.ID := TO_NUMBER(SUBSTR(listeofgenre(i),1,j-1));   -- 1 ere carct -> carctère ptn ( sans le prendre ) 
                        listeofgenre(i) := SUBSTR(listeofgenre(i),j+1);   
                        NEW_GENRE.NAME := listeofgenre(i) ;
                    else     
                        NEW_GENRE.ID := TO_NUMBER ( listeofgenre(i) ) ;
                         NEW_GENRE.NAME := null ;
                    end if ;
                    
                    
                    SELECT COUNT(*) INTO C FROM GENRE WHERE ID = NEW_GENRE.ID;
                    DBMS_OUTPUT.PUT_LINE( 'result : ' ||NEW_GENRE.ID || ' et aussi ' || NEW_GENRE.NAME);
                    if( c = 0 ) THEN
                        INSERT INTO GENRE VALUES ( NEW_GENRE.ID , NEW_GENRE.NAME );
                    end if ;
                    
                    INSERT INTO MOVIE_GENRE VALUES( EXT_MOVIE.ID , NEW_GENRE.ID);
                    
                    i := listeofgenre.next(i);
            
            END LOOP ;
        
        
        end if ;
        
        -- ACTOR
        if(EXT_MOVIE.ACTORs IS NOT NULL ) THEN
            --DBMS_OUTPUT.PUT_LINE('traitement des genres');
            
            WITH DATA AS ( SELECT EXT_MOVIE.ACTORS as str FROM dual ) 
            SELECT regexp_substr( str ,'[^' || UNISTR('\2016') || ']+',1,level ) 
            BULK COLLECT INTO listeOfActor
            FROM DATA  connect by level <= 
            length ( str ) - length ( replace ( str, UNISTR('\2016') ) ) + 1;
            -- on décupe le texte au ||
            i := listeofActor.first;
            while i is not null LOOP
                     DBMS_OUTPUT.PUT_LINE('listeofa i '|| listeofactor(i) );
                j := INSTR(listeofActor(i),'․');
                if( j != 0 ) then
                    
                    NEW_Actor.ID := TO_NUMBER(SUBSTR(listeofActor(i),1,j-1));   -- 1 ere carct -> carctère ptn ( sans le prendre ) 
                    listeofActor(i) := SUBSTR(listeofActor(i),j+1);    
                    j := INSTR(listeofActor(i),'․');
                    if( j = 0) then 
                        NEW_Actor.NAME := listeofActor(i) ;
                    else 
                       NEW_Actor.NAME := (SUBSTR(listeofActor(i),1,j-1));
                       listeofActor(i) := SUBSTR(listeofActor(i),j+1);
                       NEW_MOvie_Actor.CHARACTERA := listeofActor(i) ;
                    end if ;
                    
                else     
                   NEW_Actor.ID := TO_NUMBER ( listeofActor(i) ) ;
                   NEW_Actor.NAME := null ;
                end if ;    
        
                 SELECT COUNT(*) INTO C FROM ACTOR WHERE ID = NEW_ACTOR.ID;
        
               if( c = 0 ) THEN
                   INSERT INTO ACTOR VALUES ( NEW_ACTOR.ID , NEW_ACTOR.NAME );
                
                end if ;
                
               INSERT INTO MOVIE_ACTOR VALUES( EXT_MOVIE.ID , NEW_ACTOR.ID, NEW_MOvie_Actor.CHARACTERA );

            
            i := listeofActor.next(i);
            END LOOP ;
         end if ;   
            ---- director           
         if(EXT_MOVIE.DIRECTORS IS NOT NULL ) THEN
        DBMS_OUTPUT.PUT_LINE('traitement des directeur');
        
        WITH DATA AS ( SELECT EXT_MOVIE.DIRECTORS as str FROM dual ) 
        SELECT regexp_substr( str ,'[^' || UNISTR('\2016') || ']+',1,level ) 
        BULK COLLECT INTO listeofdirector 
        FROM DATA  connect by level <= 
        length ( str ) - length ( replace ( str, UNISTR('\2016') ) ) + 1;
        -- on décupe le texte au ||
        
        i := listeofdirector.first;
        while i is not null LOOP
            DBMS_OUTPUT.PUT_LINE('listeodire i '|| listeofdirector(i) );
            
                j := INSTR(listeofdirector(i),'․');
                if( j != 0 ) then
                    NEW_Director.ID := TO_NUMBER(SUBSTR(listeofdirector(i),1,j-1));   -- 1 ere carct -> carctère ptn ( sans le prendre ) 
                    listeofdirector(i) := SUBSTR(listeofdirector(i),j+1);   
                    NEW_Director.NAME := listeofdirector(i) ;
                else     
                    NEW_Director.ID := TO_NUMBER ( listeofdirector(i) ) ;
                    NEW_Director.NAME := null ;
                end if ;
                
                
                SELECT COUNT(*) INTO C FROM DIRECTOR WHERE ID = NEW_Director.ID;
                DBMS_OUTPUT.PUT_LINE( 'result : ' ||NEW_Director.ID || ' et aussi ' || NEW_Director.NAME);
                if( c = 0 ) THEN
                    INSERT INTO DIRECTOR VALUES ( NEW_Director.ID , NEW_Director.NAME );
                end if ;
                
                INSERT INTO MOVIE_DIRECTOR VALUES( EXT_MOVIE.ID , NEW_DIRECTOR.ID);
                
                i := listeofdirector.next(i);
        
        END LOOP ;
        
        
         end if ;
                
        ---- fin director 
        --- blob 
        url := concat (url , EXT_MOVIE.POSTER_PATH);
        image := httpuritype.createuri(url).getblob();
        UPDATE MOVIES SET MOVIES.PICTURE = image where ID_MOVIE = EXT_MOVIE.ID ;
            
    else
     DBMS_OUTPUT.PUT_LINE('le film  est deja dans la table');
      
    end if ; 
    -- else le film a déja été mit dans la db
   COMMIT; 
   EXCEPTION
    WHEN OTHERS THEN		
        DBMS_OUTPUT.PUT_LINE('exception');
   
   
END;

CALL ADDMOVIE(12);

select * from movies_ext ;
SELECT * FROM GENRE ;
select * from movie_genre ;
select * from movies ;

select * from actor ;
select * from movie_actor ;
select * from movie_director ;


delete  from MOVIE_ACTOR ;
delete  from movie_genre ;
delete from movie_director ;
delete from movie_oldcote ;
delete from director ;
DELETE  FROM GENRE  ;
delete  from ACTOR ;
DELETE  FROM MOVIES  ;

----  PROCENUDER ADDMOVIES N

CREATE OR REPLACE PROCEDURE ADDMOVIEN(NBR number)
iS
    type id_list_type  is table of movies.id_movie%TYPE;
    id_list_var id_list_type ;
    i integer ;    
BEGIN  
    
    with lesid as (
    select id   from movies_ext 
    minus select movies.id_movie from movies
    ), rdmid as (select * from lesid order by DBMS_RANDOM.VALUE )
    select id  bulk COLLECT into id_list_var from rdmid where rownum <= NBR ;
     i := id_list_var.first;
    while i is not null
    LOOP
       -- select trunc(dbms_random.value(1,max)) INTO idd from dual;  
        ADDMOVIE(id_list_var(i));
        DBMS_OUTPUT.PUT_LINE( i );
        i := id_list_var.next(i);
    END LOOP;

COMMIT; 
EXCEPTION
WHEN OTHERS THEN		
    DBMS_OUTPUT.PUT_LINE('exception');
   
   
END
----------    

----------    
-------procedure for reschearch movie

create or replace PROCEDURE postMovies(reqBody clob) IS

    querry_var varchar(9999) ;
    title_param varchar(400) ;
    date_param integer ; 
    operator_param varchar2(4) ;
    year_start_param integer ;
    year_end_param integer ;
    actor_param varchar(400) ;
    director_param varchar(400) ;
    c sys_refcursor ;
    type actor_list_type  is table of varchar2(64);
    actor_list_var actor_list_type ;
    type director_list_type  is table of varchar2(64);
    director_list_var director_list_type ;
    i integer ;
BEGIN
    apex_json.initialize_clob_output;
    apex_json.parse(reqBody); 
    title_param := apex_json.get_varchar2('title');
    date_param :=  apex_json.get_number('date');
    operator_param := apex_json.get_varchar2('operator');
    actor_param := apex_json.get_varchar2('actor');
    director_param := apex_json.get_varchar2('director');

     year_start_param := 0 ;
     year_end_param := 99999 ;
    if operator_param = '='
        then
         year_start_param := date_param -1 ;
         year_end_param := date_param + 1 ;
    end if;
    if operator_param = '<'
        then
         year_end_param := date_param  ;
    end if;
    if operator_param = '>'
        then
         year_start_param := date_param ;

    end if;
    ---- the case where operator is define and not the date
    if  date_param is null
        then
        year_start_param := 0 ;
        year_end_param := 99999 ;
    end if;

    querry_var := 'select MOVIES.id_movie as "id_movie",MOVIES.TITLE as "title" ,MOVIES.ORIGINAL_TITLE as "original_title" ,MOVIES.release_date as "release_date" ,MOVIES.status as "status" ,MOVIES.runtime as "runtime" ,MOVIES.certification as "certification" ,MOVIES.budget as "budget"  ,MOVIES.tag_line as "tag_line" from MOVIES  
    where 1 = 1 
    AND( UPPER(title) LIKE ''%'' || UPPER(''' || title_param ||''') || ''%'' or UPPER(ORIGINAL_TITLE) LIKE ''%'' || UPPER(''' ||title_param ||''' ) || ''%'' )
    AND to_number (Extract(year from release_date)) <  to_number( ''' ||year_end_param  ||''') and  to_number (Extract(year from release_date)) > to_number(''' || year_start_param ||''') '; 

  -- AND   upper ( Director.name ) like '%' || upper(director_param) || '%';


     if   actor_param is not null 
        then
         WITH actors_str AS (SELECT actor_param as str FROM dual)
        SELECT regexp_substr(
                       str,
                       '[^' || UNISTR('\002C') || ']+',
                       1,
                       level
                   ) BULK COLLECT
        INTO actor_list_var
        from actors_str
        connect by level <=   length(str) - length(replace(str, UNISTR('\002C'))) + 1;

        i := actor_list_var.first;

        while i is not null
            LOOP
                  querry_var := querry_var || 'AND MOVIES.ID_MOVIE IN (select id_movie from Movie_actor  where  upper (CHARACTERA )  like ''%'' || upper(''' || actor_list_var(i) ||''' )|| ''%'') ' ;

                  i := actor_list_var.next(i);
            END LOOP;

    end if;  



    if  director_param is not null
        then
         WITH directors_str AS (SELECT director_param as str FROM dual)
        SELECT regexp_substr(
                       str,
                       '[^' || UNISTR('\002C') || ']+',
                       1,
                       level
                   ) BULK COLLECT
        INTO director_list_var
        from directors_str
        connect by level <=   length(str) - length(replace(str, UNISTR('\002C'))) + 1;

        i := director_list_var.first;

        while i is not null
            LOOP
                  querry_var := querry_var || 'AND MOVIES.ID_MOVIE IN (select id_movie FROM movie_director left join director  on director.id = movie_director.id_director  where  upper (NAME )  like ''%'' || upper(''' || director_list_var(i) ||''' )|| ''%'') ' ;


                  i := director_list_var.next(i);
            END LOOP;

    end if;     


    OPEN c for querry_var ;


    apex_json.initialize_clob_output;
    apex_json.write(c);
    htb.send(apex_json.get_clob_output, 'application/json; charset=utf-8');
    apex_json.free_output;  


EXCEPTION
    when others then
        htb.reset;
        htb.append_nl('<html><body>');
        htb.append_nl('<p> SQLERRM : ' || htf.escape_sc(sqlerrm) || ' est l erreur survenue </p>');
        htb.append_nl('<p>' || querry_var || '</p>');
        htb.append_nl('</body></html>');
        htb.send(status_code => 500);
END postMovies ;




-------------------- get 
    
SELECT * FROM movies where id_movie = :idd
-------------------------post 


begin
    DBMS_OUTPUT.PUT_LINE('post reagit'); 
    postMovies(:body_text);
end;



------------------ ! add htb packages









-- creation d une 2 eme base de donnée 
 -- DANS SYS
CREATE USER ALEX2 IDENTIFIED BY *******   
  DEFAULT TABLESPACE USERS 
  TEMPORARY TABLESPACE TEMP 	
  PROFILE DEFAULT ACCOUNT UNLOCK;
ALTER USER ALEX2 QUOTA UNLIMITED ON USERS;

GRANT CONNECT TO ALEX2;
GRANT RESOURCE TO ALEX2;
GRANT EXECUTE ON SYS.DBMS_LOCK TO ALEX2;
GRANT EXECUTE ON SYS.OWA_OPT_LOCK TO ALEX2;
--- ajout 
ALTER USER ALEX2 QUOTA UNLIMITED ON USERS;
GRANT CONNECT TO ALEX2;
GRANT RESOURCE TO ALEX2;
GRANT EXECUTE ON SYS.DBMS_LOCK TO ALEX2;
GRANT EXECUTE ON SYS.OWA_OPT_LOCK TO ALEX2;
GRANT CREATE ANY DIRECTORY TO ALEX2;
GRANT PDB_DBA TO ALEX2;




-- atribution des roles nécéssaire aux data link 
-- DANS SYS
GRANT CREATE DATABASE LINK TO ALEX;
GRANT CREATE DATABASE LINK TO ALEX2;


--------------- DANS ALEX2
create database link alex_link CONNECT TO ALEX IDENTIFIED BY ********** using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=orcl)))';

----- dans alex 2 on re -exécute toutes les scripts de creations des tables de alex 

  
--- ajout dans ords alex 2 en get 

-- fonction base 64 
create or replace FUNCTION base64encode(p_blob IN BLOB) RETURN CLOB
-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/miscellaneous/base64encode.sql
-- Author       : Tim Hall
-- Description  : Encodes a BLOB into a Base64 CLOB.
-- Last Modified: 10/11/2021 by Samuel HIARD to remove the newlines
-- -----------------------------------------------------------------------------------
 IS
  l_clob CLOB;
  l_step PLS_INTEGER := 12000; -- make sure you set a multiple of 3 not higher than 24573
BEGIN
 IF(p_blob is not null) THEN
  FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(p_blob) - 1 )/l_step) LOOP
    l_clob := l_clob ||

    replace(
    replace(
      utl_raw.cast_to_varchar2(utl_encode.base64_encode(DBMS_LOB.substr(p_blob, l_step, i * l_step + 1))),
      chr(10)),
    chr(13)
  );
  END LOOP;
  END IF;
  RETURN l_clob;
END base64encode;



/* script html pour conv img 
let template = `
<img src='data:image/png;base64,{{img}}'/>
`;

pm.visualizer.set(template,{
    img: pm.response.json()[0]["BASE64PIC"]
});


*/


------------------- recuperer toutes les infos + metre en locale 
--- get film/:idd
Declare
  var_cond_row number;
  c sys_refcursor ;
  c2 SYS_REFCURSOR ;
  NotExistEXC EXCEPTION;
Begin
    select count(1) into  var_cond_row from movies@alex_link where id_movie = :idd;

    if ( 1 = var_cond_row) then
    select count(1) into  var_cond_row from movies where id_movie = :idd;
        if ( 1 <> var_cond_row ) then
             
            --movie
             insert into movies select * from movies@alex_link where id_movie = :idd ;
             --genre
             insert into genre  (select * from genre@alex_link where id in (
             select id_genre from movie_genre@alex_link where id_movie = :idd) minus select * from genre );
             --link genre movie
             insert into movie_genre select * from movie_genre@alex_link where id_movie = :idd;
             --director
             insert into director  (select * from director@alex_link where id in (
             select id_director from movie_director@alex_link where id_movie = :idd) minus select * from director );
             --link director movie
             insert into movie_director select * from movie_director@alex_link where id_movie = :idd;
             --actor
             insert into actor  (select * from actor@alex_link where id in (
             select id_actor from movie_actor@alex_link where id_movie = :idd) minus select * from actor );
             --link actor movie
             insert into movie_actor select * from movie_actor@alex_link where id_movie = :idd;
             -- add movie old cote 
             insert into movie_oldcote select * from movie_oldcote@alex_link where id_movie = :idd;
             -- add movie cote 

        end if ;
            -- after chck and insert send data
            OPEN c for select  movies.id_movie , movies.title , movies.original_title , movies.release_date , movies.status , movies.runtime , movies.certification ,movies.budget ,
            movies.tag_line, base64encode(picture) as base64pic , movie_oldcote.note_avg , movie_oldcote.note_count 
            from movies inner join movie_oldcote 
            on movies.id_movie = movie_oldcote.id_movie          
            where movies.id_movie = :idd   
            FETCH NEXT 1 ROW ONLY ;



            apex_json.initialize_clob_output;
              APEX_JSON.open_object;
            apex_json.write(c);
            
            open c2 for select LISTAGG( movie_actor.charactera , ',') WITHIN GROUP( ORDER by movie_actor.id_actor ) as charectera ,  LISTAGG( actor.name , ', ') WITHIN GROUP( ORDER by movie_actor.id_actor ) as actor 
            , LISTAGG( distinct director.name ,',') WITHIN GROUP( ORDER by director.name )as director , LISTAGG( distinct genre.name ,',') WITHIN GROUP( ORDER by genre.name )as genre
            from movie_actor inner join 
            actor 
            on actor.id =movie_actor.id_actor
            inner join movie_director
            on movie_actor.id_movie =movie_director.id_movie
            inner join director
            on director.id=movie_director.id_director
            inner join movie_genre 
            on movie_genre.id_movie = movie_actor.id_movie
            inner join genre
            on genre.id =movie_genre.id_genre
            where movie_actor.id_movie  = :idd
            FETCH NEXT 1 ROW ONLY ;
            
            apex_json.write(c2);
            APEX_JSON.close_object;
            htb.send(apex_json.get_clob_output, 'application/json; charset=utf-8');
            apex_json.free_output;  

    else 
        raise  NotExistEXC ;
    end if ;

EXCEPTION
    WHEN  NotExistEXC then
     htb.reset;
     htb.append_nl('<html><body>');
     htb.append_nl('<p>' || 'notfound with this id' || '</p>');
     htb.append_nl('</body></html>');
     htb.send(status_code => 500);
    when others then
        htb.reset;
        htb.append_nl('<html><body>');
        htb.append_nl('<p> SQLERRM : ' || htf.escape_sc(sqlerrm) || ' est l erreur survenue </p>');
        htb.append_nl('<p>' || 'error' || '</p>');
        htb.append_nl('</body></html>');
        htb.send(status_code => 500);
end ;
-------
--suite aux problèmes api rest 
create database link alex2_link CONNECT TO ALEX2 IDENTIFIED BY ********* using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=orcl)))';
--dans alex 


-- ajout de base64encode 

-- creation du get dans alex 


Declare
  var_cond_row number;
  c sys_refcursor ;
  c2 SYS_REFCURSOR ;
  c3 SYS_REFCURSOR ;
  c4 SYS_REFCURSOR ;
  NotExistEXC EXCEPTION;
Begin
    select count(1) into  var_cond_row from movies where id_movie = :idd;

    if ( 1 = var_cond_row) then
    select count(1) into  var_cond_row from movies@alex2_link where id_movie = :idd;
        if ( 1 <> var_cond_row ) then
             
            --movie
             insert into movies@alex2_link select * from movies where id_movie = :idd ;
             --genre
             insert into genre@alex2_link  (select * from genre where id in (
             select id_genre from movie_genre where id_movie = :idd) minus select * from genre@alex2_link );
             --link genre movie
             insert into movie_genre@alex2_link select * from movie_genre where id_movie = :idd;
             --director
             insert into director@alex2_link  (select * from director where id in (
             select id_director from movie_director where id_movie = :idd) minus select * from director@alex2_link );
             --link director movie
             insert into movie_director@alex2_link select * from movie_director where id_movie = :idd;
             --actor
             insert into actor@alex2_link  (select * from actor where id in (
             select id_actor from movie_actor where id_movie = :idd) minus select * from actor@alex2_link );
             --link actor movie
             insert into movie_actor@alex2_link select * from movie_actor where id_movie = :idd;
             -- add movie old cote 
             insert into movie_oldcote@alex2_link select * from movie_oldcote where id_movie = :idd;
             -- add movie cote 

        end if ;
            -- after chck and insert send data
            OPEN c for select  movies.id_movie , movies.title , movies.original_title , movies.release_date , movies.status , movies.runtime , movies.certification ,movies.budget ,
            movies.tag_line, base64encode(picture) as base64pic , movie_oldcote.note_avg , movie_oldcote.note_count 
            from movies@alex2_link inner join movie_oldcote@alex2_link 
            on movies.id_movie = movie_oldcote.id_movie          
            where movies.id_movie = :idd   
            FETCH NEXT 1 ROW ONLY ;



            apex_json.initialize_clob_output;
              APEX_JSON.open_object;
            apex_json.write(c);
           /* 
            open c2 for select LISTAGG( movie_actor.charactera , ',') WITHIN GROUP( ORDER by movie_actor.id_actor ) as charectera ,  LISTAGG( actor.name , ', ') WITHIN GROUP( ORDER by movie_actor.id_actor ) as actor 
            , LISTAGG( distinct director.name ,',') WITHIN GROUP( ORDER by director.name )as director , LISTAGG( distinct genre.name ,',') WITHIN GROUP( ORDER by genre.name )as genre
            from movie_actor@alex2_link inner join 
            actor@alex2_link 
            on actor.id =movie_actor.id_actor
            inner join movie_director@alex2_link
            on movie_actor.id_movie =movie_director.id_movie
            inner join director@alex2_link
            on director.id=movie_director.id_director
            inner join movie_genre@alex2_link 
            on movie_genre.id_movie = movie_actor.id_movie
            inner join genre@alex2_link
            on genre.id =movie_genre.id_genre
            where movie_actor.id_movie  = :idd
            FETCH NEXT 1 ROW ONLY ;
            */
            open c2 for select  movie_actor.charactera  as charectera ,   actor.name as actor 
            from movie_actor@alex2_link inner join 
            actor@alex2_link 
            on actor.id =movie_actor.id_actor
            where movie_actor.id_movie  = :idd ;
            
            apex_json.write(c2);
            
            open c3 for select director.name as director
            from movie_director@alex2_link 
            inner join director@alex2_link
            on movie_director.id_director = director.id
            where movie_director.id_movie  = :idd ;
            
            apex_json.write(c3); 
            
            open c4 for select genre.name as genre
            from movie_genre@alex2_link 
            inner join genre@alex2_link
            on movie_genre.id_genre = genre.id
            where movie_genre.id_movie  = :idd;
            
            
            apex_json.write(c4);
            APEX_JSON.close_object;
            htb.send(apex_json.get_clob_output, 'application/json; charset=utf-8');
            apex_json.free_output;  

    else 
        raise  NotExistEXC ;
    end if ;

EXCEPTION
    WHEN  NotExistEXC then
     htb.reset;
     htb.append_nl('<html><body>');
     htb.append_nl('<p>' || 'notfound with this id' || '</p>');
     htb.append_nl('</body></html>');
     htb.send(status_code => 500);
    when others then
        htb.reset;
        htb.append_nl('<html><body>');
        htb.append_nl('<p> SQLERRM : ' || htf.escape_sc(sqlerrm) || ' est l erreur survenue </p>');
        htb.append_nl('<p>' || 'error' || '</p>');
        htb.append_nl('</body></html>');
        htb.send(status_code => 500);
end ;

----------- procedure lancée par le post d un avis
create or replace PROCEDURE postAvis(reqBody clob) IS
 id_param movie_cote.id_movie%type ;
 user_param movie_cote.userx%type;
 note_param movie_cote.note%type;
 avis_param movie_cote.avisx%type ;
 verif_var number;
 BEGIN
 
     
 
    apex_json.initialize_clob_output;
    apex_json.parse(reqBody); 
    user_param := apex_json.get_varchar2('user');
    id_param := apex_json.get_number('id');
    note_param := apex_json.get_number('note');
    avis_param := null ;
    avis_param := apex_json.get_varchar2('avis');
    select count(1) into verif_var from movie_cote@alex2_link where id_movie = id_param and userx = user_param ;
    if( verif_var =1) then 
        update movie_cote@alex2_link 
         set note = note_param , datex = sysdate ,avisx = avis_param
         where id_movie = id_param and userx= user_param ;
    else
        insert into movie_cote@alex2_link values (id_param,note_param,user_param ,sysdate ,avis_param);
    end if ;
    
    

END postAvis ;

------------------------------- trigger -----------------------------------------------
----------------------------------------------------------------------------
---------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER insert_avis_trigger
  AFTER INSERT ON movie_cote
  FOR EACH ROW
  Declare 
  verif_var number ; 
BEGIN
 dbms_output.put_line('hello');
select count(1) into verif_var from movie_cote@alex_link where  userx = :new.userx ;
 dbms_output.put_line('val = '|| verif_var);
    if( verif_var <> 0) then 
        dbms_output.put_line('la condition est valide ') ;
      insert into movie_cote@alex_link values (:NEW.id_movie, :NEW.note ,:new.userx ,sysdate ,:NEW.avisx); 
      
    end if ;
    avis_log(:new.userx ,:NEW.id_movie, 'inserting');

END insert_avis_trigger;
----------------------------------
CREATE OR REPLACE TRIGGER alter_avis_trigger
  AFTER update ON movie_cote
  FOR EACH ROW
  Declare 
  verif_var number ; 
BEGIN
 dbms_output.put_line('hello');
select count(1) into verif_var from movie_cote@alex_link where  userx = :new.userx ;
 dbms_output.put_line('val = '|| verif_var);
    if( verif_var <> 0) then 
        dbms_output.put_line('la condition est valide ') ;  
        UPDATE movie_cote@alex_link
        SET    note = :NEW.note ,
               avisx = :NEW.avisx ,
               datex = sysdate 
        WHERE id_movie = :NEW.id_movie and userx = :new.userx ;
        
    end if ;
    avis_log(:new.userx ,:NEW.id_movie, 'updating');

END alter_avis_trigger;
-----------------------------------
create or replace TRIGGER delete_avis_trigger
  AFTER delete ON movie_cote
  FOR EACH ROW
  Declare 
  verif_var number ; 
BEGIN
 dbms_output.put_line('hello delette');
select count(1) into verif_var from movie_cote@alex_link where  userx = :new.userx ;
 dbms_output.put_line('val = '|| verif_var);
    if( verif_var <> 0) then 
        dbms_output.put_line('la condition est valide ') ;  
        delete movie_cote@alex_link
        WHERE id_movie = :old.id_movie and userx = :old.userx ;

    end if ;
     avis_log(:old.userx ,:old.id_movie, 'deleting');

END delete_avis_trigger;
-------------------------------------
--- dans sys 
GRANT CREATE JOB TO ALEX2;
GRANT MANAGE SCHEDULER TO ALEX2;
GRANT CREATE JOB TO ALEX;
GRANT MANAGE SCHEDULER TO ALEX;
---------------------------------------alex 2 
BEGIN
dbms_scheduler.create_job(
      job_name => 'job_avis_new_user',
      job_type => 'PLSQL_BLOCK',
      job_action => 'BEGIN newuse(); END;',
      start_date => sysdate-3,
      repeat_interval  =>  'FREQ=DAILY;INTERVAL=1', /* every other day */
      auto_drop => FALSE,
      comments => 'jobuser',
      enabled => true
    );
END;
------------------------------------------------- alex 2 
create or replace PROCEDURE newuse
iS
  
BEGIN         
            insert into movie_cote@alex_link (
            select *from movie_cote minus select * from movie_cote@alex_link)
            ;


EXCEPTION
WHEN OTHERS THEN		
    DBMS_OUTPUT.PUT_LINE('exception');

END;
----------------------------- dans alex2 
create table log_avis
(
 id_movie number(10) not null ,
 user_m  varchar(60) not null ,
 date_m Date ,
 type_m varchar(20) 
 );
--------------
create or replace PROCEDURE avis_log(userx varchar , idx number , typex varchar) IS
begin
    INSERT INTO log_avis VALUES (idx,userx,sysdate,typex);
end ;


--------------------------------- modif des trigger 

----dans alex 
BEGIN
dbms_scheduler.create_job(
      job_name => 'job_avis_log',
      job_type => 'PLSQL_BLOCK',
      job_action => 'BEGIN log_av(); END;',
      start_date => sysdate,
      repeat_interval  =>  'FREQ=DAILY;INTERVAL=1', /* every other day */
      auto_drop => FALSE,
      comments => 'jobuser',
      enabled => true
    );
END;

-------------
create or replace PROCEDURE log_av IS
begin
    INSERT INTO log_avis ( select * from log_avis@alex2_link minus select * from log_avis );
end ;
----------------------
CREATE VIEW view_avis_moyen
 AS select count(*)   /( select  count ( distinct( EXTRACT(month FROM date_m )|| EXTRACT(day FROM date_m ) )  ) from log_avis where type_m = 'inserting')
    as t from log_avis where type_m = 'inserting' group by 1 ;
 -----------
  select * from  view_avis_moyen ; 
  ----------------
CREATE VIEW view_avis_moyen_modif
 AS select count(*) / (select count(*) from log_avis where type_m = 'updating' )  as t from log_avis where type_m = 'inserting' group by 1 ;
  
  select * from  view_avis_moyen_modif ;  
     
--------------------------------------------------
select count(id_genre) cnt , id_genre  , genre.name from log_avis left join movie_genre 
on log_avis.id_movie = movie_genre.id_movie 
left join genre 
on movie_genre.id_genre=genre.id
group by  (id_genre , genre.name) 
order by cnt desc
------------------------------------------------
CREATE VIEW view_genre_popular as 
select count(id_genre) cnt , id_genre  , genre.name from log_avis left join movie_genre 
on log_avis.id_movie = movie_genre.id_movie 
left join genre 
on movie_genre.id_genre=genre.id
group by  (id_genre , genre.name) 
order by cnt desc;

select * from view_genre_popular ;







