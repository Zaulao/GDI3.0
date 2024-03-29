CREATE OR REPLACE TYPE tp_pessoa AS OBJECT(
    nome VARCHAR2(255),
    ID NUMBER,
    email VARCHAR2(255),
    MEMBER FUNCTION comparaID (p tp_pessoa) RETURN INTEGER
) NOT FINAL NOT INSTANTIABLE;
/

CREATE OR REPLACE TYPE BODY tp_pessoa AS
MEMBER FUNCTION comparaID (p tp_pessoa) RETURN INTEGER IS
RETURN      
      CASE
            WHEN SELF.ID = P.ID then 0
            WHEN SELF.ID <> P.ID then 1            
            END;
      END;
/       

CREATE OR REPLACE TYPE tp_fone AS OBJECT(
    NUMERO NUMBER
);
/

CREATE OR REPLACE TYPE tp_nt_fone AS TABLE OF tp_fone;
/

CREATE OR REPLACE TYPE tp_contato AS OBJECT(
    site VARCHAR2(255),
    fones tp_nt_fone
);
/


CREATE TABLE tb_contato OF tp_contato NESTED TABLE fones STORE AS tb_lista_fones;

INSERT INTO tb_contato VALUES ('www.contato-froid.com.br', tp_nt_fone(tp_fone(30404085), tp_fone(998167293)));

CREATE OR REPLACE TYPE tp_artista UNDER tp_pessoa(
    -- CONSTRUCTOR FUNCTION tp_artista (x1 tp_pessoa)
    --     RETURN SELF AS RESULT,
    contato REF tp_contato
);
/

CREATE TABLE tb_artista OF tp_artista(
    nome NOT NULL,
    ID PRIMARY KEY,
    email NOT NULL,
    contato SCOPE IS tb_contato
) ;


INSERT INTO tb_artista SELECT 'Froid', 2, 'froid@gmail.com', REF(c) FROM tb_contato c WHERE c.site = 'www.contato-froid.com.br';

SELECT * FROM TABLE (SELECT FONES FROM tb_contato)

CREATE OR REPLACE TYPE tp_usuario UNDER tp_pessoa(
    -- CONSTRUCTOR FUNCTION tp_usuario (x1 tp_pessoa)
    --     RETURN SELF AS RESULT,
    idade NUMBER
);
/

CREATE OR REPLACE TYPE BODY tp_usuario AS
OVERRIDING MEMBER FUNCTION comparaID (p tp_pessoa)  RETURN INTEGER IS
   m tp_usuario;
      r integer;
     begin
        if p is of ( tp_usuario ) then
           m := treat( p as tp_usuario );
           r :=
             case
                when self.ID = m.ID then 0
                 when self.ID > m.ID then 1
                when self.ID < m.ID then -1
               end;
       end if;
   return r;
     end;
end;
/

CREATE TABLE tb_usuario OF tp_usuario;

INSERT INTO tb_usuario VALUES (tp_usuario('Luan', 1, 'lab7@cin.ufpe.br', 21));
CREATE OR REPLACE TYPE tp_genero AS OBJECT(
    genero VARCHAR(255)
);
/

CREATE OR REPLACE TYPE tp_genero2 AS OBJECT(
    genero VARCHAR(244)
)NOT FINAL NOT INSTANTIABLE;
/

CREATE OR REPLACE TYPE tp_generos AS VARRAY(5) OF tp_genero;
CREATE OR REPLACE TYPE tp_nt_genero AS TABLE OF tp_genero;

CREATE OR REPLACE TYPE tp_musica AS OBJECT(
    musica_id NUMBER,
    nome VARCHAR(255),
    generos tp_nt_genero,
    ORDER MEMBER FUNCTION comparaDuracao (X tp_musica) RETURN INTEGER
);
/

CREATE TABLE tb_musica OF tp_musica NESTED TABLE generos STORE AS generos;

INSERT INTO tb_musica VALUES(1, 'Franz Café', tp_nt_genero(tp_genero('Rap'), tp_genero('Love song')));

SELECT m.nome as Musica, m.generos as Generos_VARRAY FROM tb_musica m;

ALTER TYPE tp_musica ADD ATTRIBUTE (duracao_segundos NUMBER) CASCADE;

CREATE OR REPLACE TYPE BODY tp_musica AS
ORDER MEMBER FUNCTION comparaDuracao (X tp_musica) RETURN NUMBER IS
begin
  RETURN SELF.duracao_segundos - X.duracao_segundos;
end;
END;
/

CREATE OR REPLACE TYPE tp_nt_musica AS TABLE OF tp_musica
/

CREATE OR REPLACE TYPE l_musica_ref IS VARRAY(100) of REF tp_musica;

-- INSERT into table1 (approvaldate) VALUES (CONVERT(date,'18-06-12', 5)); -- erro tvz pq não haja table1
CREATE OR REPLACE TYPE tp_album AS OBJECT(
    album_id NUMBER,
    nome VARCHAR2(255),
    data_lancamento VARCHAR2(255),
    musicas l_musica_ref,
    artista REF tp_artista,
    FINAL MAP MEMBER FUNCTION albumOrderBy RETURN VARCHAR2
);

DROP TABLE tb_album;

CREATE TABLE tb_album OF tp_album(
    album_id PRIMARY KEY,
    nome NOT NULL,
    artista WITH ROWID REFERENCES tb_artista
);

INSERT INTO tb_album VALUES (1, 'O pior disco do ano', '18-05-2017', l_musica_ref(SELECT REF(mm) from tb_musica mm WHERE mm.musica_id = 1), (SELECT REF(aa) FROM tb_artista aa WHERE aa.nome = 'Froid'));
    
-- SELECT aa.nome as Album FROM tb_album aa WHERE aa.nome = 'O pior disco do ano';

SELECT a.nome as Album, DEREF(a.artista) as Artista FROM tb_album a WHERE a.nome = 'O pior disco do ano';

SELECT VALUE(a) Album_objects FROM tb_album a;

CREATE OR REPLACE TYPE BODY tp_album AS
FINAL MAP MEMBER FUNCTION albumOrderBy RETURN VARCHAR2 IS
    n VARCHAR2(255) := nome;
    begin
      RETURN n;
    end;

CREATE OR REPLACE TYPE tp_playlist AS OBJECT(
    nome VARCHAR2(255),
    musicas tp_nt_musica,
    MEMBER PROCEDURE alteraNome(SELF tp_playlist)
);
/

ALTER TYPE tp_playlist ADD ATTRIBUTE playlist_id NUMBER CASCADE;

CREATE OR REPLACE TYPE BODY tp_playlist AS
    MEMBER PROCEDURE alteraNome(SELF tp_playlist, novo_nome VARCHAR2(255)) IS
        BEGIN
            SELF.nome := novo_nome;
        END;
END;
/

ALTER TYPE tp_usuario ADD ATTRIBUTE (playlist tp_playlist) CASCADE;
/

create table tb_playlist(
    playlist_id PRIMARY KEY
) NESTED TABLE musicas STORE AS musicas;

ALTER TYPE tp_musica DROP ATTRIBUTE l_generos CASCADE;

ALTER TYPE tp_musica DROP ATTRIBUTE l_generos CASCADE;
ALTER TYPE tp_musica ADD ATTRIBUTE (tb_generos tp_nt_genero) CASCADE;

ALTER TYPE tp_album DROP ATTRIBUTE musicas

CREATE TABLE tb_musica_2 of tp_musica NESTED TABLE tb_generos STORE AS generos_2;

INSERT INTO tb_musica_2 VALUES(1, 'Franz Café', tp_nt_genero(tp_genero('Rap'), tp_genero('Love song')));

CREATE TABLE tb_album_2 of tp_album NESTED TABLE musicas STORE AS musicas (NESTED TABLE tb_generos STORE AS generos);

INSERT INTO tb_album VALUES (1, "O pior disco do ano", '18-05-2017', tp_nt_musica(
        tp_musica(SELECT VALUE(m) FROM tb_musica m WHERE m.nome = "Franz Café"),
    ), (SELECT REF(a) FROM tb_artista a WHERE a.nome = "Froid"));
