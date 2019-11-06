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
    contatos tp_contato
);
/

CREATE OR REPLACE TYPE tp_usuario UNDER tp_pessoa(
    idade NUMBER
);
/

CREATE OR REPLACE TYPE tp_genero AS OBJECT(
    genero VARCHAR(255)
);
/

CREATE OR REPLACE TYPE tp_generos AS VARRAY(5) OF tp_genero;
/

CREATE OR REPLACE TYPE tp_musica AS OBJECT(
    ID NUMBER,
    nome VARCHAR(255),
    l_generos tp_generos,
    FINAL MAP MEMBER FUNCTION musicaToInt RETURN VARCHAR2,
    ORDER MEMBER FUNCTION comparaDuracao (X tp_musica) RETURN INTEGER
);
/

ALTER TYPE tp_musica ADD ATTRIBYTE (duracao_segundos NUMBER) CASCADE;
/

CREATE OR REPLACE TYPE BODY tp_musica AS
FINAL MAP MEMBER FUNCTION musicaToInt RETURN NUMBER IS
    p NUMBER:= ID;
    begin
      RETURN p;
    end;
ORDER MEMBER FUNCTION comparaDuracao (X tp_musica) RETURN NUMBER IS
begin
  RETURN SELF.duracao_segundos - X.duracao_segundos;
end;
END;
/

--INSERT table1 (approvaldate) VALUES (CONVERT(datetime,'18-06-12 10:34:09 PM',5));
CREATE OR REPLACE TYPE tp_album AS OBJECT(
    ID NUMBER,
    nome VARCHAR2(255),
    data_lancamento DATE,

);
/