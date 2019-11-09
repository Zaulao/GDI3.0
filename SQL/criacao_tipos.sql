CREATE OR REPLACE TYPE tp_pessoa AS OBJECT(
    nome VARCHAR2(255),
    ID NUMBER,
    email VARCHAR2(255),
    MEMBER FUNCTION comparaID (p tp_pessoa) RETURN INTEGER
)NOT FINAL;
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

CREATE OR REPLACE TYPE tp_artista UNDER tp_pessoa(
    CONSTRUCTOR FUNCTION tp_artista (x1 tp_pessoa)
        RETURN SELF AS RESULT,
    contatos tp_contato
);
/

CREATE OR REPLACE TYPE tp_usuario UNDER tp_pessoa(
    CONSTRUCTOR FUNCTION tp_artista (x1 tp_pessoa)
        RETURN SELF AS RESULT,
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

CREATE OR REPLACE TYPE tp_genero AS OBJECT(
    genero VARCHAR(255)
);
/
CREATE OR REPLACE TYPE tp_genero2 AS OBJECT(
    genero VARCHAR(244)
)NOT INSTANTIABLE;
/

CREATE OR REPLACE TYPE tp_generos AS VARRAY(5) OF tp_genero;
/

CREATE OR REPLACE TYPE tp_musica AS OBJECT(
    ID NUMBER,
    nome VARCHAR(255),
    l_generos tp_generos,
    ORDER MEMBER FUNCTION comparaDuracao (X tp_musica) RETURN INTEGER
);
/

ALTER TYPE tp_musica ADD ATTRIBUTE (duracao_segundos NUMBER) CASCADE;
/

CREATE OR REPLACE TYPE BODY tp_musica AS
ORDER MEMBER FUNCTION comparaDuracao (X tp_musica) RETURN NUMBER IS
begin
  RETURN SELF.duracao_segundos - X.duracao_segundos;
end;
END;
/

CREATE OR REPLACE TYPE tp_nt_musica AS TABLE OF tp_musica;
/

--INSERT table1 (approvaldate) VALUES (CONVERT(date,'18-06-12', 5));
CREATE OR REPLACE TYPE tp_album AS OBJECT(
    ID NUMBER,
    nome VARCHAR2(255),
    data_lancamento DATE,
    FINAL MAP MEMBER FUNCTION albumOrderBy RETURN VARCHAR2,
    musicas tp_nt_musica
);
/

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

CREATE OR REPLACE TYPE BODY tp_playlist AS
    MEMBER PROCEDURE alteraNome(SELF tp_playlist, novo_nome VARCHAR2(255)) IS
        BEGIN
            SELF.nome := novo_nome;
        END;
END;
/

ALTER TYPE tp_usuario ADD ATTRIBUTE (playlist tp_playlist) CASCADE;
/