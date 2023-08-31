

create schema if not exists institucional AUTHORIZATION postgres;

-- institucional.se_cat_colonias definition

-- Drop table

-- DROP TABLE institucional.se_cat_colonias;

drop table if exists institucional.se_cat_colonias;
create table institucional.se_cat_colonias (
	id_colonia int4 NOT NULL,
	cve_pais varchar(3) NULL,
	cve_estado varchar(6) NULL,
	cve_municip_deleg int4 NULL,
	cve_colonia varchar(10) NULL,
	f_inicio_vigencia timestamp NULL,
	f_fin_vigencia timestamp NULL,
	desc_colonia varchar(256) NULL,
	tipo_asentamiento timestamp NULL,
	tipo_asentamiento_cd timestamp NULL,
	codigo_postal varchar(5) NULL,
	sit_colonia varchar(2) NULL
);


-- institucional.se_cat_estados definition

-- Drop table

-- DROP TABLE institucional.se_cat_estados;

drop table if exists institucional.se_cat_estados;
create table institucional.se_cat_estados (
	cve_pais varchar(3) NULL,
	cve_estado varchar(6) NULL,
	desc_estado varchar(256) NULL,
	id_estado int4 NULL,
	sit_estado varchar(2) NULL
);


-- institucional.se_cat_localidades definition

-- Drop table

-- DROP TABLE institucional.se_cat_localidades;

drop table if exists institucional.se_cat_localidades;
create table  institucional.se_cat_localidades (
	id_localidad int4 NOT NULL,
	cve_pais varchar(3) NULL,
	cve_estado varchar(6) NULL,
	cve_municip_deleg int4 NULL,
	cve_localidad varchar(10) NULL,
	f_inicio_vigencia timestamp NULL,
	f_fin_vigencia timestamp NULL,
	desc_localidad varchar(256) NULL,
	tipo_asentamiento int4 NULL,
	tipo_asentamiento_cd int4 NULL,
	codigo_postal varchar(5) NULL,
	cve_temp varchar(10) NULL,
	sit_localidad varchar(2) NULL
);


-- institucional.se_cat_municip_deleg definition

-- Drop table

-- DROP TABLE institucional.se_cat_municip_deleg;
drop table if exists institucional.se_cat_municip_deleg;
create table  institucional.se_cat_municip_deleg (
	cve_pais varchar(3) NULL,
	cve_estado varchar(6) NULL,
	cve_municip_deleg int4 NULL,
	f_inicio_vigencia timestamp NULL,
	f_fin_vigencia timestamp NULL,
	desc_municip_deleg varchar(256) NULL,
	sit_municip_deleg varchar(2) NULL
);


-- institucional.se_cat_paises definition

-- Drop table

-- DROP TABLE institucional.se_cat_paises;

drop table if exists institucional.se_cat_paises;
create table  institucional.se_cat_paises (
	cve_pais varchar(3) NULL,
	desc_pais varchar(255) NULL,
	desc_corta_pais varchar(100) NULL,
	pais_2car varchar(2) NULL,
	ue_estado_miembro varchar(1) NULL,
	procedencia varchar(3) NULL,
	id_nacionalidad int4 NULL,
	nacionalidad varchar(255) NULL,
	sit_pais varchar(2) NULL,
	cve_pais_impi varchar(3) NULL
);


-- institucional.se_cat_tip_vialidad_desc definition

-- Drop table

-- DROP TABLE institucional.se_cat_tip_vialidad_desc;

drop table if exists institucional.se_cat_tip_vialidad_desc;
create table  institucional.se_cat_tip_vialidad_desc (
	id_tipo_vialidad int4 NOT NULL,
	cve_idioma varchar(2) NULL,
	desc_tipo_vialidad varchar(100) NULL
);


-- institucional.se_cat_tipos_vialidad definition

-- Drop table

-- DROP TABLE institucional.se_cat_tipos_vialidad;
drop table if exists institucional.se_cat_tipos_vialidad;
create table institucional.se_cat_tipos_vialidad (
	id_tipo_vialidad int4 NOT NULL,
	desc_tipo_vialidad varchar(30) NULL,
	desc_corta_tipo_via varchar(15) NULL,
	b_ref_calles_oblig varchar(1) NULL,
	sit_tipo_vialidad varchar(2) NULL
);