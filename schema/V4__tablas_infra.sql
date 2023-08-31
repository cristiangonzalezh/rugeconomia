

create schema if not exists infra AUTHORIZATION postgres;

-- Drop table

-- DROP TABLE infra.secu_preg_rec_psw_desc;

create table infra.secu_preg_rec_psw_desc (
	cve_idioma varchar(2) NULL,
	id_pregunta int4 NOT NULL,
	descripcion varchar(100) NULL
);


-- DROP TABLE infra.secu_preg_recupera_psw;

create table infra.secu_preg_recupera_psw (
	id_pregunta int4 NOT NULL,
	tx_pregunta varchar(60) NULL
);