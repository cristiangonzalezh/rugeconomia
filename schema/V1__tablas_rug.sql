


create schema if not exists rug AUTHORIZATION postgres;

-- rug.avisos_prev definition

drop table if exists rug.avisos_prev;

create table rug.avisos_prev (
	id_tramite_temp int not null primary key,
	id_persona int null,
	desc_bienes bytea null,
	id_usuario int null,
	id_registro int null
);

comment on column rug.avisos_prev.id_tramite_temp is 'Identificador unico del tramite temporal';
comment on column rug.avisos_prev.id_persona is 'Identificador unico de  persona del otorgante';
comment on column rug.avisos_prev.desc_bienes is 'Descripcion de los bienes que incluyen el aviso';
comment on column rug.avisos_prev.id_usuario is 'Identificador unico de  persona del usuario que realiza el tramite';
comment on table rug.avisos_prev is 'Tabla que guarda los datos del aviso preventivo';

-- rug.bit_carga definition

-- Drop table

drop table if exists rug.bit_carga;

create table rug.bit_carga (
	id_bit_carga int null primary key,
	descripcion varchar(100) null,
	inicio varchar(100) null,
	fin varchar(100) null
);


-- rug.doctos_tram_firmados_rug definition

-- Drop table

drop table if exists rug.doctos_tram_firmados_rug;

create table rug.doctos_tram_firmados_rug (
	id_tramite_temp int not null primary key,
	cadena_orig_firmada varchar null,
	fh_registro timestamp null,
	fh_ult_actualizacion timestamp null,
	cadena_orig_no_firmada varchar null,
	cadena_orig_firmada_se varchar null,
	timestamp_se bytea null,
	procesado varchar null,
	id_usuario_firmo int null
);


-- rug.dr$desc_garantia_idx$i definition

-- Drop table

drop table if exists rug."dr$desc_garantia_idx$i";

create table rug."dr$desc_garantia_idx$i" (
	token_text varchar not null,
	token_type int not null,
	token_first int not null,
	token_last int not null,
	token_count int not null,
	token_info bytea null
);

CREATE UNIQUE INDEX "rug_dr$desc_garantia_idx$i_idx" ON rug.dr$desc_garantia_idx$i USING btree (token_text, token_type, token_first, token_last, token_count);






-- rug."dr$desc_garantia_idx$k" definition

-- Drop table

drop table if exists rug."dr$desc_garantia_idx$k";

create table rug."dr$desc_garantia_idx$k" (
	docid int not null,
	textkey varchar not null primary key
);


-- rug."dr$desc_garantia_idx$n" definition

-- Drop table

drop table if exists rug."dr$desc_garantia_idx$n";

create table rug."dr$desc_garantia_idx$n" (
	nlt_docid int not null primary key,
	nlt_mark varchar(1) not null
);


-- rug."dr$desc_garantia_idx$r" definition

-- Drop table

drop table if exists rug."dr$desc_garantia_idx$r";

create table rug."dr$desc_garantia_idx$r" (
	row_no int not null primary key,
	data bytea null
);


-- rug.dr$palabra_idx$i definition

-- Drop table

drop table if exists rug."dr$palabra_idx$i";

create table rug."dr$palabra_idx$i" (
	token_text varchar not null,
	token_type int not null,
	token_first int not null,
	token_last int not null,
	token_count int not null,
	token_info bytea null,
	constraint "rug_dr$palabra_idx$i_idx" unique (token_text, token_type, token_first, token_last, token_count)
);

-- rug.dr$palabra_idx$k definition

-- Drop table

drop table if exists rug.dr$palabra_idx$k;

create table rug.dr$palabra_idx$k (
	docid int null,
	textkey varchar not null primary key
);


-- rug."dr$palabra_idx$n" definition

-- Drop table

drop table if exists rug."dr$palabra_idx$n";

create table rug."dr$palabra_idx$n" (
	nlt_docid int not null primary key,
	nlt_mark varchar(1) null
);


-- rug."dr$palabra_idx$r" definition

-- Drop table

drop table if exists rug."dr$palabra_idx$r";

create table rug."dr$palabra_idx$r" (
	row_no int not null primary key,
	data bytea null
);


-- rug."dr$rug_pers_h_idx_tnom$i" definition

-- Drop table

drop table if exists rug."dr$rug_pers_h_idx_tnom$i";

create table rug."dr$rug_pers_h_idx_tnom$i" (
	token_text varchar not null,
	token_type int not null,
	token_first int not null,
	token_last int not null,
	token_count int not null,
	token_info bytea null,
	constraint "dr$rug_pers_h_idx_tnom$i_idx" unique (token_text, token_type, token_first, token_last, token_count)
);


-- rug."dr$rug_pers_h_idx_tnom$k" definition

-- Drop table

drop table if exists rug.dr$rug_pers_h_idx_tnom$k;

create table rug.dr$rug_pers_h_idx_tnom$k (
	docid int null,
	textkey varchar not null primary key
);



-- rug.dr$rug_pers_h_idx_tnom$n definition

-- Drop table

drop table if exists rug.dr$rug_pers_h_idx_tnom$n;

create table rug.dr$rug_pers_h_idx_tnom$n (
	nlt_docid int not null primary key,
	nlt_mark varchar(1) not null
);


-- rug.dr$rug_pers_h_idx_tnom$r definition

-- Drop table

drop table if exists rug.dr$rug_pers_h_idx_tnom$r;

create table rug.dr$rug_pers_h_idx_tnom$r (
	row_no int not null primary key,
	data bytea null
);


-- rug.fiel_parametros_conf definition

-- Drop table

drop table if exists rug.fiel_parametros_conf;

create table rug.fiel_parametros_conf (
	cve_parametro int not null primary key,
	valor_parametro varchar(4000) null,
	status_reg varchar(2) null
);


-- rug.fiel_servicio definition

-- Drop table

drop table if exists rug.fiel_servicio;

create table rug.fiel_servicio (
	id_servicio int not null primary key,
	servicio varchar(50) null,
	status_reg varchar(2) null,
	paquete varchar(500) null
);


-- rug.fiel_tramites_clases definition

-- Drop table

drop table if exists rug.fiel_tramites_clases;

create table rug.fiel_tramites_clases (
	id_tramite int null,
	id_servicio int null,
	clase varchar(200) null,
	status_reg varchar(2) null
);


-- rug.garan_cve_rast_fv definition

-- Drop table

drop table if exists rug.garan_cve_rast_fv;

create table rug.garan_cve_rast_fv (
	id_registro int not null primary key,
	id_garantia int not null,
	id_tipo_garantia int null,
	num_garantia int null,
	desc_garantia varchar null,
	meses_garantia int null,
	id_persona int null,
	id_anotacion int null,
	id_relacion int null,
	relacion_bien int null,
	valor_bienes float8 null,
	tipos_bienes_muebles varchar(800) null,
	ubicacion_bienes varchar(4000) null,
	folio_mercantil varchar(200) null,
	path_doc_garantia varchar(800) null,
	otros_terminos_garantia varchar null,
	fecha_inscr timestamp null,
	fecha_fin_gar timestamp null,
	vigencia int null,
	garantia_certificada varchar(1) null,
	garantia_status varchar(2) null,
	id_ultimo_tramite int null,
	b_ultimo_tramite varchar(1) null,
	monto_maximo_garantizado numeric(20, 2) null,
	fecha_modif_reg timestamp null,
	fecha_reg timestamp null,
	status_reg varchar(2) null,
	id_garantia_pend int null,
	cambios_bienes_monto varchar(1) null,
	instrumento_publico varchar(4000) null,
	id_moneda int null
);


-- rug.garantias_pendientes definition

-- Drop table

drop table if exists rug.garantias_pendientes;

create table rug.garantias_pendientes (
	id_garantia_pend int not null primary key,
	id_tipo_garantia int null,
	num_garantia int null,
	desc_garantia bytea null,
	meses_garantia int null,
	id_persona int null,
	id_anotacion int null,
	id_relacion int null,
	relacion_bien int null,
	valor_bienes float8 null,
	tipos_bienes_muebles varchar(800) null,
	ubicacion_bienes varchar(4000) null,
	folio_mercantil varchar(100) null,
	path_doc_garantia varchar(800) null,
	otros_terminos_garantia bytea null,
	fecha_inscr timestamp null,
	fecha_fin_gar timestamp null,
	vigencia int null,
	garantia_certificada varchar(1) null,
	garantia_status varchar(2) null,
	id_ultimo_tramite int null,
	b_ultimo_tramite varchar(1) null,
	monto_maximo_garantizado numeric(20, 2) null,
	id_garantia_modificar int not null,
	cambios_bienes_monto varchar(1) null,
	instrumento_publico varchar(4000) null,
	id_moneda int null
);

comment on column rug.garantias_pendientes.id_garantia_pend is 'Identificador de la garantia pendiente';
comment on column rug.garantias_pendientes.id_tipo_garantia is 'Identificador del tipo de garantia';
comment on column rug.garantias_pendientes.num_garantia is 'Numero de la garantia';
comment on column rug.garantias_pendientes.desc_garantia is 'Descripcion de la garantia';
comment on column rug.garantias_pendientes.meses_garantia is 'Meses de la garantia';
comment on column rug.garantias_pendientes.id_persona is 'Identificador de la persona que inscribe la garantia';
comment on column rug.garantias_pendientes.id_anotacion is 'Identificador de la anotacion';
comment on column rug.garantias_pendientes.id_relacion is 'Identificacion de la relacion';
comment on column rug.garantias_pendientes.relacion_bien is 'Relacion de la garantia con los bienes';
comment on column rug.garantias_pendientes.valor_bienes is 'Valor de los bienes';
comment on column rug.garantias_pendientes.tipos_bienes_muebles is 'Tipos de bienes';
comment on column rug.garantias_pendientes.ubicacion_bienes is 'Ubicacion de los bienes';
comment on column rug.garantias_pendientes.folio_mercantil is 'Folio mercantil para la garantia';
comment on column rug.garantias_pendientes.otros_terminos_garantia is 'Otros terminos de la garantia';
comment on column rug.garantias_pendientes.fecha_inscr is 'Fecha de inscripción de la garantia';
comment on column rug.garantias_pendientes.fecha_fin_gar is 'Fecha fin de la garantia';
comment on column rug.garantias_pendientes.vigencia is 'Vigencia de la garantia';
comment on column rug.garantias_pendientes.garantia_certificada is 'Indica si la garantia es certificada o no';
comment on column rug.garantias_pendientes.garantia_status is 'Estatus de la garantia';
comment on column rug.garantias_pendientes.id_ultimo_tramite is 'Identificador del ultimo tramite';
comment on column rug.garantias_pendientes.b_ultimo_tramite is 'Indica si es el ultimo tramite';
comment on column rug.garantias_pendientes.monto_maximo_garantizado is 'Monto maximo de la garantia';
comment on column rug.garantias_pendientes.id_garantia_modificar is 'Identificador de la garantia a modificar';
comment on column rug.garantias_pendientes.cambios_bienes_monto is 'Indica si los bienes de la garantia han sufrido cambios';
comment on column rug.garantias_pendientes.instrumento_publico is 'Instrumento publico';
comment on column rug.garantias_pendientes.id_moneda is 'Identificador de la moneda';


-- rug.rel_usu_acreedor definition

-- Drop table

drop table if exists rug.rel_usu_acreedor;

create table rug.rel_usu_acreedor (
	id_usuario int not null,
	id_acreedor int not null,
	b_firmado varchar(2) null,
	fecha_reg timestamp null,
	status_reg varchar(2) null,
	CONSTRAINT rel_usu_acreedor_pk PRIMARY KEY (id_usuario, id_acreedor)
);


-- rug.rug_anotaciones definition

-- Drop table

drop table if exists rug.rug_anotaciones;

create table rug.rug_anotaciones (
	id_anotacion int not null,
	id_garantia int null,
	autoridad_autoriza varchar(4000) null,
	anotacion varchar null,
	fecha_reg timestamp null,
	status_reg varchar(2) null,
	id_tramite_temp int not null,
	id_usuario int null,
	vigencia_anotacion int null,
	CONSTRAINT rug_anotaciones_pk PRIMARY KEY (id_anotacion, id_tramite_temp)
);


-- rug.rug_anotaciones_seg_inc_csg definition

-- Drop table

drop table if exists rug.rug_anotaciones_seg_inc_csg;

create table rug.rug_anotaciones_seg_inc_csg (
	id_anotacion_temp int not null primary key,
	id_tramite int null,
	id_tramite_padre int null,
	id_garantia int null,
	autoridad_autoriza varchar(4000) null,
	anotacion varchar null,
	resolucion varchar null,
	vigencia int null,
	solicitante_rectifica varchar(4000) null,
	fecha_reg timestamp null,
	status_reg varchar(2) null
);


-- rug.rug_anotaciones_seg_inc_csg_h definition

-- Drop table

drop table if exists rug.rug_anotaciones_seg_inc_csg_h;

create table rug.rug_anotaciones_seg_inc_csg_h (
	id_anotacion_temp_h int not null,
	id_anotacion_temp int not null,
	id_tramite int null,
	id_tramite_padre int null,
	id_garantia int null,
	id_tipo_tramite int null,
	id_status int null,
	id_usuario int null,
	id_persona_anotacion int null,
	pers_juridica varchar(2) null,
	autoridad_autoriza varchar(4000) null,
	anotacion varchar null,
	resolucion varchar null,
	vigencia int null,
	solicitante_rectifica varchar(4000) null,
	fecha_reg timestamp null,
	status_reg varchar(2) null
);


-- rug.rug_anotaciones_sin_garantia definition

-- Drop table

drop table if exists rug.rug_anotaciones_sin_garantia;

create table rug.rug_anotaciones_sin_garantia (
	id_anotacion int not null,
	autoridad_autoriza varchar(4000) null,
	anotacion varchar null,
	id_persona int null,
	desc_bienes varchar(200) null,
	fecha_reg timestamp null,
	sit_anotacion varchar(2) null,
	id_tramite_temp int not null,
	id_usuario int null,
	status_reg varchar(2) null,
	vigencia_anotacion int null,
	CONSTRAINT rug_anotaciones_sin_garantia_pk PRIMARY KEY (id_anotacion, id_tramite_temp)
);


-- rug.rug_anotaciones_sin_garantia_h definition

-- Drop table

drop table if exists rug.rug_anotaciones_sin_garantia_h;

create table rug.rug_anotaciones_sin_garantia_h (
	id_anotacion int not null,
	autoridad_autoriza varchar(4000) null,
	anotacion varchar null,
	id_persona int null,
	desc_bienes varchar(200) null,
	fecha_reg timestamp null,
	sit_anotacion varchar(2) null,
	id_tramite_temp int null,
	id_usuario int null,
	status_reg varchar(2) null,
	vigencia_anotacion int null
);


-- rug.rug_archivo definition

-- Drop table

drop table if exists rug.rug_archivo;

create table rug.rug_archivo (
	id_archivo int not null,
	id_usuario int not null,
	algoritmo_hash varchar(4000) null,
	nombre_archivo varchar(500) null,
	archivo bytea null,
	tipo_archivo varchar(50) null,
	descripcion varchar(4000) null,
	fecha_reg timestamp not null,
	status_reg varchar(2) null,
	total_exito int null,
	total_no_exito int null
);


-- rug.rug_autoridad definition

-- Drop table

drop table if exists rug.rug_autoridad;

create table rug.rug_autoridad (
	id_autoridad int not null primary key,
	id_tramite_temp int not null,
	id_tramite int null,
	anotacion_juez varchar(4000) null,
	status_reg varchar(2) null,
	fecha_reg timestamp not null
);


-- rug.rug_autoridad_pend definition

-- Drop table

drop table if exists rug.rug_autoridad_pend;

create table rug.rug_autoridad_pend (
	id_autoridad int not null,
	id_tramite_temp int not null,
	id_tramite_temp_nvo int not null,
	anotacion_juez varchar(4000) not null,
	fecha_reg timestamp not null
);


-- rug.rug_bitac_firma_masiva definition

-- Drop table

drop table if exists rug.rug_bitac_firma_masiva;

create table rug.rug_bitac_firma_masiva (
	id_firma_masiva int not null,
	id_tramite_temp int not null,
	fecha_reg timestamp not null,
	id_status int not null
);


-- rug.rug_bitac_tram_bck_081210 definition

-- Drop table

drop table if exists rug.rug_bitac_tram_bck_081210;

create table rug.rug_bitac_tram_bck_081210 (
	id_tramite_temp int null,
	id_status int null,
	fecha_status timestamp null,
	id_paso int null,
	id_tipo_tramite int null,
	fecha_reg timestamp null,
	status_reg varchar(2) null
);


-- rug.rug_bitac_tramites definition

-- Drop table

drop table if exists rug.rug_bitac_tramites;

create table rug.rug_bitac_tramites (
	id_tramite_temp int null,
	id_status int null,
	fecha_status timestamp null,
	id_paso int null,
	id_tipo_tramite int null,
	fecha_reg timestamp null,
	status_reg varchar(2) null
);

CREATE INDEX rug_bitac_tramites_id_tramite_temp_idx ON rug.rug_bitac_tramites USING btree (id_tramite_temp, id_status, status_reg);


-- rug.rug_bitac_tramites_resp definition

-- Drop table

drop table if exists rug.rug_bitac_tramites_resp;

create table rug.rug_bitac_tramites_resp (
	id_tramite_temp int null,
	id_status int null,
	fecha_status timestamp null,
	id_paso int null,
	id_tipo_tramite int null,
	fecha_reg timestamp null,
	status_reg varchar(2) null
);


-- rug.rug_borrado_folios definition

-- Drop table

drop table if exists rug.rug_borrado_folios;

create table rug.rug_borrado_folios (
	id_tramite_temp int null,
	cve_rastreo varchar(1000) null,
	detalle varchar(4000) null,
	documento bytea null,
	status_reg varchar(2) null,
	fh_registro timestamp null
);


-- rug.rug_cancelacion_transmision definition

-- Drop table

drop table if exists rug.rug_cancelacion_transmision;

create table rug.rug_cancelacion_transmision (
	id_cancelacion_transmision int not null,
	id_tramite_temp int not null,
	id_cancelacion int not null,
	id_inscripcion int not null,
	fecha_reg timestamp not null,
	status_reg varchar(2) null
);


-- rug.rug_carga_pool definition

-- Drop table

drop table if exists rug.rug_carga_pool;

create table rug.rug_carga_pool (
	id_archivo int null,
	id_usuario int null,
	id_archivo_firma int null,
	id_archivo_resumen int null,
	id_status int null,
	id_tipo_tramite int null,
	b_tipo_proceso varchar(2) null,
	status_reg varchar(2) null,
	fecha_reg timestamp null,
	id_acreedor int null
);


-- rug.rug_cat_boleta definition

-- Drop table

drop table if exists rug.rug_cat_boleta;

create table rug.rug_cat_boleta (
	id_boleta int not null primary key,
	desc_boleta varchar(500) null,
	id_tipo_tramite int null,
	id_docto int null
);


-- rug.rug_cat_boleta_seccion definition

-- Drop table

drop table if exists rug.rug_cat_boleta_seccion;

create table rug.rug_cat_boleta_seccion (
	id_seccion_boleta int not null primary key,
	desc_seccion_boleta varchar(500) null,
	status_reg varchar(2) null
);


-- rug.rug_cat_busc_palabras definition

-- Drop table

drop table if exists rug.rug_cat_busc_palabras;

create table rug.rug_cat_busc_palabras (
	id_tramite int not null,
	palabra_clave varchar(20) null
);


-- rug.rug_cat_campo_boleta definition

-- Drop table

drop table if exists rug.rug_cat_campo_boleta;

create table rug.rug_cat_campo_boleta (
	id_campo_boleta int not null primary key,
	desc_campo_boleta varchar(500) null,
	cve_campo_boleta varchar(500) null
);


-- rug.rug_cat_mensajes_errores definition

-- Drop table

drop table if exists rug.rug_cat_mensajes_errores;

create table rug.rug_cat_mensajes_errores (
	id_codigo int not null primary key,
	desc_codigo varchar(4000) null,
	tipo_mensaje varchar(3) not null,
	sit_mensaje_error varchar(2) not null
);


-- rug.rug_cat_monedas definition

-- Drop table

drop table if exists rug.rug_cat_monedas;

create table rug.rug_cat_monedas (
	id_moneda int not null primary key,
	desc_moneda varchar(200) null,
	status_reg varchar(2) null,
	simbolo varchar(1) null
);


-- rug.rug_cat_nacionalidades definition

-- Drop table

drop table if exists rug.rug_cat_nacionalidades;

create table rug.rug_cat_nacionalidades (
	id_nacionalidad int not null primary key,
	desc_nacionalidad varchar(200) null,
	cve_pais varchar(5) null,
	status_reg varchar(2) null
);


-- rug.rug_cat_palabra_excluida definition

-- Drop table

drop table if exists rug.rug_cat_palabra_excluida;

create table rug.rug_cat_palabra_excluida (
	palabra varchar(30) null
);


-- rug.rug_cat_palabras definition

-- Drop table

drop table if exists rug.rug_cat_palabras;

create table rug.rug_cat_palabras (
	id_tramite int not null,
	palabra_clave varchar(200) null
);


-- rug.rug_cat_pasos definition

-- Drop table

drop table if exists rug.rug_cat_pasos;

create table rug.rug_cat_pasos (
	id_paso int not null primary key,
	descripcion varchar(100) not null,
	id_tipo_tramite int not null,
	url varchar(100) not null,
	status_reg varchar(2) null
);


-- rug.rug_cat_perfiles definition

-- Drop table

drop table if exists rug.rug_cat_perfiles;

create table rug.rug_cat_perfiles (
	id_perfil int null primary key,
	cve_perfil varchar(50) null,
	desc_perfil varchar(200) not null,
	sit_perfil varchar(2) not null
);


-- rug.rug_cat_status_mails definition

-- Drop table

drop table if exists rug.rug_cat_status_mails;

create table rug.rug_cat_status_mails (
	id_status_mail int not null primary key,
	desc_status_mail varchar(500) null,
	status_reg varchar(2) null
);


-- rug.rug_cat_tipo_bien definition

-- Drop table

drop table if exists rug.rug_cat_tipo_bien;

create table rug.rug_cat_tipo_bien (
	id_tipo_bien int not null primary key,
	desc_tipo_bien varchar(200) null,
	desc_tipo_bien_en varchar(200) null,
	id_padre int null,
	status_reg varchar(2) null
);


-- rug.rug_cat_tipo_correo definition

-- Drop table

drop table if exists rug.rug_cat_tipo_correo;

create table rug.rug_cat_tipo_correo (
	id_tipo_correo int not null primary key,
	desc_correo varchar(200) null,
	asunto_correo varchar(4000) null,
	mensaje_correo varchar null,
	status_reg varchar(2) null
);


-- rug.rug_cat_tipo_docto definition

-- Drop table

drop table if exists rug.rug_cat_tipo_docto;

create table rug.rug_cat_tipo_docto (
	id_docto int not null primary key,
	desc_docto varchar(500) null
);


-- rug.rug_cat_tipo_garantia definition

-- Drop table

drop table if exists rug.rug_cat_tipo_garantia;

create table rug.rug_cat_tipo_garantia (
	id_tipo_garantia int not null primary key,
	desc_tipo_garantia varchar(150) null,
	desc_tipo_garantia_en varchar(100) null,
	status_reg varchar(2) null
);


-- rug.rug_cat_tipo_tramite definition

-- Drop table

drop table if exists rug.rug_cat_tipo_tramite;

create table rug.rug_cat_tipo_tramite (
	id_tipo_tramite int not null primary key,
	descripcion varchar(50) null,
	precio float8 null,
	vigencia_tram int null,
	status_reg varchar(2) null,
	b_carga_masiva int null
);


-- rug.rug_catalogos definition

-- Drop table

drop table if exists rug.rug_catalogos;

create table rug.rug_catalogos (
	id_catalogo int not null primary key,
	desc_catalogo varchar(50) null
);


-- rug.rug_certificaciones definition

-- Drop table

drop table if exists rug.rug_certificaciones;

create table rug.rug_certificaciones (
	id_tramite_cert int not null primary key,
	id_tramite int null,
	id_garantia int null,
	id_tipo_tramite int null,
	fecha_cert timestamp null,
	status_reg varchar(2) null
);


-- rug.rug_contrato definition

-- Drop table

drop table if exists rug.rug_contrato;

create table rug.rug_contrato (
	id_contrato int not null primary key,
	id_garantia_pend int null,
	contrato_num int null,
	fecha_inicio timestamp null,
	fecha_fin timestamp null,
	otros_terminos_contrato varchar null,
	monto_limite float8 null,
	observaciones varchar(4000) null,
	tipo_contrato varchar(4000) null,
	id_tramite_temp int null,
	fecha_reg timestamp null,
	status_reg varchar(2) null,
	id_usuario int null,
	clasif_contrato varchar(2) null
);

comment on table rug.rug_contrato is 'Guarda los contratos generados de tramites en el sistema';
comment on column rug.rug_contrato.id_contrato is 'Identificador del contrato';
comment on column rug.rug_contrato.id_garantia_pend is 'Identificador de la garantia pendiente';
comment on column rug.rug_contrato.contrato_num is 'Numero del contrato';
comment on column rug.rug_contrato.fecha_inicio is 'Fecha de incio del contrato';
comment on column rug.rug_contrato.fecha_fin is 'Fecha de termino del contrato';
comment on column rug.rug_contrato.otros_terminos_contrato is 'Otros terminos del contrato';
comment on column rug.rug_contrato.monto_limite is 'Monto limite del contrato';
comment on column rug.rug_contrato.observaciones is 'Observaciones del contrato';
comment on column rug.rug_contrato.tipo_contrato is 'Descripcion del tipo de contrato';
comment on column rug.rug_contrato.id_tramite_temp is 'Identificador del tramite temporal';
comment on column rug.rug_contrato.fecha_reg is 'Fecha de registro del contrato';
comment on column rug.rug_contrato.status_reg is 'Estatus del registro';
comment on column rug.rug_contrato.id_usuario is 'Identificador del usuario que hizo el contrato';
comment on column rug.rug_contrato.clasif_contrato is 'Campo que tipifica el contrato, segun el expediente de la garantia (fu)= acto o contrato en que se fundamenta la operacion, (ob) = acto o contrato que crea la obligacion garantizada';

-- rug.rug_domicilios definition

-- Drop table

drop table if exists rug.rug_domicilios;

create table rug.rug_domicilios (
	id_domicilio int not null primary key,
	calle varchar(250) null,
	num_exterior varchar(50) null,
	num_interior varchar(50) null,
	id_colonia int null,
	calle_colindante_1 varchar(60) null,
	calle_colindante_2 varchar(60) null,
	calle_posterior varchar(60) null,
	localidad varchar(100) null,
	id_vialidad int null,
	tx_refer_adicional varchar(250) null,
	id_tipo_domicilio int null,
	id_localidad int null
);


-- rug.rug_domicilios_ext definition

-- Drop table

drop table if exists rug.rug_domicilios_ext;

create table rug.rug_domicilios_ext (
	id_domicilio int not null primary key,
	id_pais_residencia int null,
	ubica_domicilio_1 varchar(300) null,
	ubica_domicilio_2 varchar(300) null,
	poblacion varchar(300) null,
	zona_postal varchar(300) null
);


-- rug.rug_domicilios_ext_h definition

-- Drop table

drop table if exists rug.rug_domicilios_ext_h;

create table rug.rug_domicilios_ext_h (
	id_tramite int not null,
	id_parte int not null,
	id_persona int not null,
	id_domicilio int null,
	id_pais_residencia int null,
	ubica_domicilio_1 varchar(300) not null,
	ubica_domicilio_2 varchar(300) null,
	poblacion varchar(300) not null,
	zona_postal varchar(300) null
);


-- rug.rug_domicilios_h definition

-- Drop table

drop table if exists rug.rug_domicilios_h;

create table rug.rug_domicilios_h (
	id_tramite int not null,
	id_parte int not null,
	id_persona int not null,
	id_domicilio int null,
	calle varchar(250) null,
	num_exterior varchar(50) null,
	num_interior varchar(50) null,
	id_colonia int null,
	cve_colonia varchar(10) null,
	nom_colonia varchar(256) null,
	cve_deleg_municip varchar null,
	nom_deleg_municip varchar(256) null,
	cve_estado varchar(6) null,
	nom_estado varchar(256) null,
	codigo_postal varchar(5) null,
	cve_pais varchar(3) null,
	nom_pais varchar(255) null,
	localidad varchar(256) null,
	cve_localidad varchar(10) null,
	id_localidad int null
);

comment on table rug.rug_domicilios_h is 'Historico de domicilios';
comment on column rug.rug_domicilios_h.id_domicilio is 'Identificador del domicilio';
comment on column rug.rug_domicilios_h.calle is 'Nombre de la calle';
comment on column rug.rug_domicilios_h.num_exterior is 'Numero del exterior del domicilio';
comment on column rug.rug_domicilios_h.num_interior is 'Numero interior del domicilio';
comment on column rug.rug_domicilios_h.id_colonia is 'Identificador de la colonia';
comment on column rug.rug_domicilios_h.localidad is 'Descripcion de la localidad';
comment on column rug.rug_domicilios_h.id_localidad is 'Identificador de la localidad';


-- rug.rug_domicilios_h_resp definition

-- Drop table

drop table if exists rug.rug_domicilios_h_resp;

create table rug.rug_domicilios_h_resp (
	id_tramite int not null,
	id_parte int not null,
	id_persona int null,
	id_domicilio int null,
	calle varchar(250) null,
	num_exterior varchar(50) null,
	num_interior varchar(50) null,
	id_colonia int null,
	cve_colonia varchar(10) null,
	nom_colonia varchar(256) null,
	cve_deleg_municip varchar null,
	nom_deleg_municip varchar(256) null,
	cve_estado varchar(6) null,
	nom_estado varchar(256) null,
	codigo_postal varchar(5) null,
	cve_pais varchar(3) null,
	nom_pais varchar(255) null,
	localidad varchar(256) null,
	cve_localidad varchar(10) null,
	id_localidad int null
);


-- rug.rug_firma_doctos definition

-- Drop table

drop table if exists rug.rug_firma_doctos;

create table rug.rug_firma_doctos (
	id_firma int not null primary key,
	id_tramite_temp int null,
	id_usuario_firmo int null,
	xml_co varchar null,
	co_usuairo varchar null,
	certificado_usuario_b64 varchar null,
	firma_usuario_b64 varchar null,
	co_sello varchar null,
	sello_ts_b64 varchar null,
	co_firma_rug varchar null,
	firma_rug_b64 varchar null,
	fecha_reg timestamp null,
	status_reg varchar(2) null,
	certificado_central_b64 varchar null,
	procesado varchar(1) null
);


-- rug.rug_firma_masiva definition

-- Drop table

drop table if exists rug.rug_firma_masiva;

create table rug.rug_firma_masiva (
	id_firma_masiva int not null,
	id_tramite_temp int not null primary key,
	id_archivo int not null,
	fecha_reg timestamp not null,
	status_reg varchar(2) not null
);

CREATE UNIQUE INDEX rug_firma_masiva_id_firma_masiva_idx ON rug.rug_firma_masiva USING btree (id_firma_masiva, id_tramite_temp, id_archivo);


-- rug.rug_folio_control definition

-- Drop table

drop table if exists rug.rug_folio_control;

create table rug.rug_folio_control (
	idfoliocontrol int not null primary key,
	fecha timestamp null,
	letra varchar(1) null
);


-- rug.rug_garantias definition

-- Drop table

drop table if exists rug.rug_garantias;

create table rug.rug_garantias (
	id_garantia int not null primary key,
	id_tipo_garantia int null,
	num_garantia int null,
	desc_garantia varchar null,
	meses_garantia int null,
	id_persona int null,
	id_anotacion int null,
	id_relacion int null,
	relacion_bien int null,
	valor_bienes float8 null,
	tipos_bienes_muebles varchar(800) null,
	ubicacion_bienes varchar(4000) null,
	folio_mercantil varchar(200) null,
	path_doc_garantia varchar(800) null,
	otros_terminos_garantia varchar null,
	fecha_inscr timestamp null,
	fecha_fin_gar timestamp null,
	vigencia int null,
	garantia_certificada varchar(1) null,
	garantia_status varchar(2) null,
	id_ultimo_tramite int null,
	b_ultimo_tramite varchar null,
	monto_maximo_garantizado numeric null,
	id_garantia_pend int null,
	fecha_reg timestamp null,
	status_reg varchar(2) null,
	cambios_bienes_monto varchar(1) null,
	instrumento_publico varchar(4000) null,
	id_moneda int null,
	no_garantia_previa_ot varchar(1) null,
	CONSTRAINT rug_garantias_id_garantia_idx unique (id_garantia, id_ultimo_tramite, garantia_status)
);


-- rug.rug_garantias_h definition

-- Drop table

drop table if exists rug.rug_garantias_h;

create table rug.rug_garantias_h (
	id_registro int null,
	id_garantia int not null,
	id_tipo_garantia int null,
	num_garantia int null,
	desc_garantia varchar null,
	meses_garantia int null,
	id_persona int null,
	id_anotacion int null,
	id_relacion int null,
	relacion_bien int null,
	valor_bienes float8 null,
	tipos_bienes_muebles varchar(800) null,
	ubicacion_bienes varchar(4000) null,
	folio_mercantil varchar(200) null,
	path_doc_garantia varchar(800) null,
	otros_terminos_garantia varchar null,
	fecha_inscr timestamp null,
	fecha_fin_gar timestamp null,
	vigencia int null,
	garantia_certificada varchar(1) null,
	garantia_status varchar(2) null,
	id_ultimo_tramite int null,
	b_ultimo_tramite varchar(1) null,
	monto_maximo_garantizado numeric(20, 2) null,
	fecha_modif_reg timestamp null,
	fecha_reg timestamp null,
	status_reg varchar(2) null,
	id_garantia_pend int null,
	cambios_bienes_monto varchar(1) null,
	instrumento_publico varchar(4000) null,
	id_moneda int null,
	no_garantia_previa_ot varchar(1) null
);

CREATE INDEX rug_garantias_h_id_garantia_idx ON rug.rug_garantias_h USING btree (id_garantia);


-- rug.rug_garantias_pendientes definition

-- Drop table

drop table if exists rug.rug_garantias_pendientes;

create table rug.rug_garantias_pendientes (
	id_garantia_pend int not null primary key,
	id_tipo_garantia int null,
	num_garantia int null,
	desc_garantia varchar null,
	meses_garantia int null,
	id_persona int null,
	id_anotacion int null,
	id_relacion int null,
	relacion_bien int null,
	valor_bienes float8 null,
	tipos_bienes_muebles varchar(800) null,
	ubicacion_bienes varchar(4000) null,
	folio_mercantil varchar(200) null,
	path_doc_garantia varchar(800) null,
	otros_terminos_garantia varchar null,
	fecha_inscr timestamp null,
	fecha_fin_gar timestamp null,
	vigencia int null,
	garantia_certificada varchar(1) null,
	garantia_status varchar(2) null,
	id_ultimo_tramite int null,
	b_ultimo_tramite varchar(1) null,
	monto_maximo_garantizado numeric(22, 2) null,
	id_garantia_modificar int not null,
	cambios_bienes_monto varchar(1) null,
	instrumento_publico varchar(4000) null,
	id_moneda int null,
	no_garantia_previa_ot varchar(1) null
);


-- rug.rug_grupos definition

-- Drop table

drop table if exists rug.rug_grupos;

create table rug.rug_grupos (
	id_grupo int not null primary key,
	id_acreedor int not null,
	desc_grupo varchar(300) null,
	id_persona_crea int not null,
	fh_creacion timestamp not null,
	sit_grupo varchar(2) not null,
	fh_baja timestamp null,
	id_usuario_baja int null
);


-- rug.rug_jobs definition

-- Drop table

drop table if exists rug.rug_jobs;

create table rug.rug_jobs (
	id_job int null primary key,
	job_name varchar(500) null,
	status_job varchar(2) null,
	is_running varchar(5) null,
	last_execution_timestamp timestamp null,
	failure_count int null,
	repeat_interval int null,
	comments varchar(4000) null
);

comment on column rug.rug_jobs.status_job is 'Indicador de que el job está activo, cualquier valor diferente a ac representa inactividad.';
comment on column rug.rug_jobs.repeat_interval is 'Intervalo, el cual se refleja en minutos para los procesos nuevos.';

-- rug.rug_log definition

-- Drop table

drop table if exists rug.rug_log;

create table rug.rug_log (
	id_log int not null primary key,
	objeto varchar(30) not null,
	desc_log varchar(1000) not null,
	fh_registro timestamp not null
);


-- rug.rug_mail_accounts definition

-- Drop table

drop table if exists rug.rug_mail_accounts;

create table rug.rug_mail_accounts (
	id_mail_account int not null primary key,
	desc_uso_cta varchar(4000) null,
	smtp_host varchar(200) null,
	smtp_port varchar(10) null,
	smtp_user_mail varchar(200) null,
	smtp_password varchar(200) null,
	smtp_auth varchar(10) null,
	smtp_ssl_enable varchar(10) null,
	mail_content_type varchar(50) null
);

comment on table rug.rug_mail_accounts is 'Contiene la configuracion de correos';
comment on column rug.rug_mail_accounts.id_mail_account is 'Identificador de la cuenta de correo';
comment on column rug.rug_mail_accounts.desc_uso_cta is 'Descripcion de uso de la cuenta';
comment on column rug.rug_mail_accounts.smtp_host is 'Direccion ip del host del servicio smtp';
comment on column rug.rug_mail_accounts.smtp_port is 'Puerto del host del servicio smtp';
comment on column rug.rug_mail_accounts.smtp_user_mail is 'Cuenta de correo del usuario';
comment on column rug.rug_mail_accounts.smtp_password is 'Contraseña del usuario';
comment on column rug.rug_mail_accounts.smtp_auth is 'Bandera de autenticacion';
comment on column rug.rug_mail_accounts.smtp_ssl_enable is 'Bandera de habilitado';
comment on column rug.rug_mail_accounts.mail_content_type is 'Tipo de texto del contenido';


-- rug.rug_mail_exceptions definition

-- Drop table

drop table if exists rug.rug_mail_exceptions;

create table rug.rug_mail_exceptions (
	id_mail int not null,
	desc_exception varchar null,
	fecha_reg timestamp null
);


comment on column rug.rug_mail_exceptions.id_mail is 'Identificador del mail';
comment on column rug.rug_mail_exceptions.desc_exception is 'Descripcion de la excepcion';
comment on column rug.rug_mail_exceptions.fecha_reg is 'Fecha de registro';

-- rug.rug_mail_pool definition

-- Drop table

drop table if exists rug.rug_mail_pool;

create table rug.rug_mail_pool (
	id_mail int not null primary key,
	id_tipo_correo int null,
	id_mail_account int null,
	destinatario varchar(4000) null,
	destinatario_cc varchar(4000) null,
	destinatario_cco varchar(4000) null,
	asunto varchar(4000) null,
	mensaje varchar null,
	id_status_mail int null,
	fecha_envio timestamp null
);

comment on table rug.rug_mail_pool is 'Tabla donde estan los correos enviados y por enviar';
comment on column rug.rug_mail_pool.id_mail is 'Identificador de mail';
comment on column rug.rug_mail_pool.id_tipo_correo is 'Identificador del tipo de correo';
comment on column rug.rug_mail_pool.id_mail_account is 'Identificador de la cuenta de correo';
comment on column rug.rug_mail_pool.destinatario is 'Destinatario';
comment on column rug.rug_mail_pool.destinatario_cc is 'Destinatario en copia';
comment on column rug.rug_mail_pool.destinatario_cco is 'Destinatario en copia oculta';
comment on column rug.rug_mail_pool.asunto is 'Asunto del correo';
comment on column rug.rug_mail_pool.mensaje is 'Mensaje del correo';
comment on column rug.rug_mail_pool.id_status_mail is 'Identificador del estatus del correo';
comment on column rug.rug_mail_pool.fecha_envio is 'Fecha de envio';


-- rug.rug_nuevo_folio definition

-- Drop table

drop table if exists rug.rug_nuevo_folio;

create table rug.rug_nuevo_folio (
	id_nuevo_folio int not null primary key,
	id_persona int null,
	id_tramite int null,
	id_garantia int null,
	curp varchar(50) null,
	folio_original varchar(200) null,
	folio_nuevo varchar(200) null
);


-- rug.rug_num_series_h definition

-- Drop table

drop table if exists rug.rug_num_series_h;

create table rug.rug_num_series_h (
	id_num_serie_h int not null primary key,
	id_persona int null,
	num_serie varchar(100) null,
	fecha_mov timestamp null
);


-- rug.rug_param_firma definition

-- Drop table

drop table if exists rug.rug_param_firma;

create table rug.rug_param_firma (
	id_tramite_temp int null,
	cadena_original_no_firmada text null,
	cadena_original_firmada text null,
	cadena_original_firmada_se text null,
	timestamp bytea null,
	commit text null,
	fecha_reg timestamp null
);


-- rug.rug_param_pls definition

-- Drop table

drop table if exists rug.rug_param_pls;

create table rug.rug_param_pls (
	id_registro int not null primary key,
	objeto varchar(100) null,
	nom_parametro varchar(100) null,
	valor varchar(4000) null,
	fecha_reg timestamp null,
	status_reg varchar(2) null,
	tipo_parametro varchar(3) null
);


-- rug.rug_parametro_conf definition

-- Drop table

drop table if exists rug.rug_parametro_conf;

create table rug.rug_parametro_conf (
	cve_parametro varchar(100) not null primary key,
	valor_parametro varchar null
);


-- rug.rug_partes definition

-- Drop table

drop table if exists rug.rug_partes;

create table rug.rug_partes (
	id_parte int not null primary key,
	desc_parte varchar(50) null
);


-- rug.rug_perf_usuario_bck_240111 definition

-- Drop table

drop table if exists rug.rug_perf_usuario_bck_240111;

create table rug.rug_perf_usuario_bck_240111 (
	cve_institucion varchar(10) null,
	cve_usuario varchar(256) null,
	cve_perfil varchar(20) null,
	cve_aplicacion varchar(50) null,
	id_persona int null,
	b_bloqueado varchar(1) null
);


-- rug.rug_personas definition

-- Drop table

drop table if exists rug.rug_personas;

create table rug.rug_personas (
	id_persona int not null primary key,
	rfc varchar(20) null,
	id_nacionalidad int null,
	per_juridica varchar(2) not null,
	fh_registro timestamp not null,
	procedencia varchar(3) not null,
	sit_persona varchar(2) not null,
	cve_nacionalidad varchar(3) null,
	id_domicilio int not null unique,
	folio_mercantil varchar(200) null,
	fecha_inscr_cc timestamp null,
	reg_terminado varchar(1) null,
	id_persona_modificar int null,
	e_mail varchar(200) null,
	curp_doc varchar(500) null,
	procesado varchar(1) null,
	nifp varchar(350) null
);


-- rug.rug_personas_fisicas definition

-- Drop table

drop table if exists rug.rug_personas_fisicas;

create table rug.rug_personas_fisicas (
	id_persona int not null primary key,
	nombre_persona varchar(60) not null,
	ap_paterno varchar(60) not null,
	ap_materno varchar(60) null,
	curp varchar(900) null,
	id_calidad_migrat int null,
	id_pais_nacim int null,
	f_nacimiento timestamp null,
	estado_civil varchar(2) null,
	ocupacion_actual varchar(40) null,
	sexo varchar(1) null,
	cve_pais_nacim varchar(3) null,
	cve_estado_nacim varchar(6) null,
	cve_mun_del_nacim varchar null,
	lugar_nac_pers_ext varchar(256) null,
	folio_docto_migrat varchar(20) null,
	cve_escolaridad varchar(6) null,
	num_serie varchar(250) null
);


-- rug.rug_personas_h definition

-- Drop table

drop table if exists rug.rug_personas_h;

create table rug.rug_personas_h (
	id_tramite int not null,
	id_parte int not null,
	id_persona int not null,
	nombre_persona varchar(60) null,
	ap_paterno varchar(60) null,
	ap_materno varchar(60) null,
	razon_social varchar(350) null,
	per_juridica varchar(2) null,
	id_nacionalidad int null,
	rfc varchar(20) null,
	curp varchar(900) null,
	curp_doc varchar(500) null,
	e_mail varchar(200) null,
	folio_mercantil varchar(200) null,
	cve_perfil varchar(50) null,
	desc_parte varchar(50) null,
	tnombre varchar null,
	CONSTRAINT rug_personas_h_pk PRIMARY KEY (id_tramite, id_parte, id_persona)
);


-- rug.rug_personas_h_resp definition

-- Drop table

drop table if exists rug.rug_personas_h_resp;

create table rug.rug_personas_h_resp (
	id_tramite int not null,
	id_parte int not null,
	id_persona int null,
	nombre_persona varchar(60) null,
	ap_paterno varchar(60) null,
	ap_materno varchar(60) null,
	razon_social varchar(350) null,
	per_juridica varchar(2) null,
	id_nacionalidad int null,
	rfc varchar(20) null,
	curp varchar(900) null,
	curp_doc varchar(500) null,
	e_mail varchar(200) null,
	folio_mercantil varchar(200) null,
	cve_perfil varchar(50) null,
	desc_parte varchar(50) null
);


-- rug.rug_personas_morales definition

-- Drop table

drop table if exists rug.rug_personas_morales;

create table rug.rug_personas_morales (
	id_persona int not null primary key,
	razon_social varchar not null,
	siglas_mercantil varchar(20) null,
	id_pais_origen int null,
	imp_cap_soc_fijo numeric null,
	b_consejo_admon varchar null,
	num_acciones int null,
	valor_nominal_acc numeric(24, 6) null,
	f_constitucion timestamp null,
	id_pers_represnte_legal int null,
	b_exclusion_extranjeros varchar(1) null,
	cve_pais_origen varchar(3) null,
	cve_usuario_registro varchar(256) null,
	imp_cap_variable numeric(20, 2) null,
	num_acc_cap_var int null,
	val_nom_acc_cap_var numeric(24, 6) null,
	f_ini_actividad timestamp null,
	nombre_comercial varchar(350) null,
	tipo varchar(2) null
);


-- rug.rug_privilegios definition

-- Drop table

drop table if exists rug.rug_privilegios;

create table rug.rug_privilegios (
	id_privilegio int not null primary key,
	desc_privilegio varchar(200) not null,
	html varchar(4000) null,
	sit_privilegio varchar(2) null,
	id_recurso int null,
	orden int null
);


-- rug.rug_recursos definition

-- Drop table

drop table if exists rug.rug_recursos;

create table rug.rug_recursos (
	id_recurso int not null primary key,
	desc_recurso varchar(500) not null,
	sit_recurso varchar(2) not null
);


-- rug.rug_rel_archivo_firma_masiva definition

-- Drop table

drop table if exists rug.rug_rel_archivo_firma_masiva;

create table rug.rug_rel_archivo_firma_masiva (
	id_rel_arch_firm int not null,
	id_firma_maisva int not null,
	id_archivo int not null,
	fecha_reg timestamp not null,
	status_reg varchar(2) not null
);


-- rug.rug_rel_boleta_campo definition

-- Drop table

drop table if exists rug.rug_rel_boleta_campo;

create table rug.rug_rel_boleta_campo (
	id_boleta int not null,
	id_campo_boleta int not null,
	orden_campo int null,
	id_seccion_boleta int not null,
	orientacion varchar(1) null,
	status_reg varchar(2) null,
	orden_seccion int null,
	id_seccion_padre int null,
	CONSTRAINT rug_rel_boleta_campo_pk PRIMARY KEY (id_boleta, id_seccion_boleta, id_campo_boleta)
);


-- rug.rug_rel_boleta_parte definition

-- Drop table

drop table if exists rug.rug_rel_boleta_parte;

create table rug.rug_rel_boleta_parte (
	id_boleta int not null,
	id_parte int not null,
	id_campo_boleta int not null,
	status_reg varchar(2) null,
	orientacion varchar(1) null,
	orden_campo int null
);


-- rug.rug_rel_boleta_seccion definition

-- Drop table

drop table if exists rug.rug_rel_boleta_seccion;

create table rug.rug_rel_boleta_seccion (
	id_boleta int not null,
	id_seccion int not null,
	orientacion varchar(1) null,
	status_reg varchar(2) null
);


-- rug.rug_rel_gar_tipo_bien definition

-- Drop table

drop table if exists rug.rug_rel_gar_tipo_bien;

create table rug.rug_rel_gar_tipo_bien (
	id_garantia_pend int null,
	id_tipo_bien int null,
	relacion_bien int null
);


-- rug.rug_rel_gar_tipo_bien_aux definition

-- Drop table

drop table if exists rug.rug_rel_gar_tipo_bien_aux;

create table rug.rug_rel_gar_tipo_bien_aux (
	id_garantia_pend int null,
	id_tipo_bien int null,
	relacion_bien int null
);


-- rug.rug_rel_garantia_partes definition

-- Drop table

drop table if exists rug.rug_rel_garantia_partes;

create table rug.rug_rel_garantia_partes (
	id_garantia int not null,
	id_persona int null,
	id_parte int null,
	id_relacion int null,
	fecha_reg timestamp null,
	status_reg varchar(2) null
);


-- rug.rug_rel_grupo_acreedor definition

-- Drop table

drop table if exists rug.rug_rel_grupo_acreedor;

create table rug.rug_rel_grupo_acreedor (
	id_reg int not null,
	id_acreedor int null,
	id_sub_usuario int null,
	id_usuario int null,
	status_reg varchar(2) null,
	fecha_reg timestamp null,
	id_grupo int null
);


-- rug.rug_rel_grupo_perfil definition

-- Drop table

drop table if exists rug.rug_rel_grupo_perfil;

create table rug.rug_rel_grupo_perfil (
	id_grupo int null,
	id_perfil int null
);


-- rug.rug_rel_grupo_privilegio definition

-- Drop table

drop table if exists rug.rug_rel_grupo_privilegio;

create table rug.rug_rel_grupo_privilegio (
	id_relacion int not null,
	id_grupo int not null,
	id_privilegio int not null,
	sit_relacion varchar(2) null
);


-- rug.rug_rel_modifica_acreedor definition

-- Drop table

drop table if exists rug.rug_rel_modifica_acreedor;

create table rug.rug_rel_modifica_acreedor (
	id_tramite_temp int null,
	id_acreedor int null,
	id_acreedor_nuevo int null,
	b_firmado varchar(2) null,
	id_usuario_modifica int null,
	fh_modifica timestamp null,
	status_reg varchar(2) null
);


-- rug.rug_rel_tram_garan definition

-- Drop table

drop table if exists rug.rug_rel_tram_garan;

create table rug.rug_rel_tram_garan (
	id_tramite int not null,
	id_garantia int not null,
	b_tramite_completo varchar(1) null,
	status_reg varchar(2) null,
	fecha_reg timestamp null
);


-- rug.rug_rel_tram_garan_resp definition

-- Drop table

drop table if exists rug.rug_rel_tram_garan_resp;

create table rug.rug_rel_tram_garan_resp (
	id_tramite int null,
	id_garantia int null,
	b_tramite_completo varchar(1) null,
	status_reg varchar(2) null,
	fecha_reg timestamp null
);


-- rug.rug_rel_tram_inc_garan definition

-- Drop table

drop table if exists rug.rug_rel_tram_inc_garan;

create table rug.rug_rel_tram_inc_garan (
	id_garantia_pend int not null,
	id_tramite_temp int not null,
	status_reg varchar(2) null,
	fecha_reg timestamp null
);


-- rug.rug_rel_tram_inc_p_bk_081210 definition

-- Drop table

drop table if exists rug.rug_rel_tram_inc_p_bk_081210;

create table rug.rug_rel_tram_inc_p_bk_081210 (
	id_tramite_temp int null,
	id_persona int null,
	id_parte int not null,
	per_juridica varchar(2) null,
	status_reg varchar(2) null,
	fecha_reg timestamp null
);


-- rug.rug_rel_tram_inc_partes definition

-- Drop table

drop table if exists rug.rug_rel_tram_inc_partes;

create table rug.rug_rel_tram_inc_partes (
	id_tramite_temp int not null,
	id_persona int not null,
	id_parte int not null,
	per_juridica varchar(2) null,
	status_reg varchar(2) null,
	fecha_reg timestamp null
);


-- rug.rug_rel_tram_partes definition

-- Drop table

drop table if exists rug.rug_rel_tram_partes;

create table rug.rug_rel_tram_partes (
	id_tramite int not null,
	id_persona int not null,
	id_parte int not null,
	per_juridica varchar(2) null,
	status_reg varchar(2) null,
	fecha_reg timestamp null
);


-- rug.rug_rel_tram_partes_resp definition

-- Drop table

drop table if exists rug.rug_rel_tram_partes_resp;

create table rug.rug_rel_tram_partes_resp (
	id_tramite int null,
	id_persona int null,
	id_parte int not null,
	per_juridica varchar(2) null,
	status_reg varchar(2) null,
	fecha_reg timestamp null
);


-- rug.rug_rel_usuario_privilegio definition

-- Drop table

drop table if exists rug.rug_rel_usuario_privilegio;

create table rug.rug_rel_usuario_privilegio (
	id_registro int not null,
	cve_perfil varchar(20) null,
	id_privilegio int not null,
	b_bloqueado varchar(1) null
);


-- rug.rug_rep_consultas definition

-- Drop table

drop table if exists rug.rug_rep_consultas;

create table rug.rug_rep_consultas (
	id_consulta int not null,
	tx_consulta varchar null,
	tx_uso_consul varchar(50) null
);


-- rug.rug_rep_param definition

-- Drop table

drop table if exists rug.rug_rep_param;

create table rug.rug_rep_param (
	cve_parametro varchar(10) null,
	tx_parametro varchar(500) null,
	tx_uso_param varchar(50) null
);


-- rug.rug_rep_tipos_cambio definition

-- Drop table

drop table if exists rug.rug_rep_tipos_cambio;

create table rug.rug_rep_tipos_cambio (
	id_moneda int not null,
	f_cambio timestamp not null,
	tipo_cambio numeric(10, 6) null,
	ult_usu_reg varchar(256) null
);


-- rug.rug_secu_perfiles_usuario definition

-- Drop table

drop table if exists rug.rug_secu_perfiles_usuario;

create table rug.rug_secu_perfiles_usuario (
	cve_institucion varchar(10) null,
	cve_usuario varchar(256) null,
	cve_perfil varchar(20) null,
	cve_aplicacion varchar(50) null,
	id_persona int not null,
	b_bloqueado varchar(1) null
);


-- rug.rug_secu_usuarios definition

-- Drop table

drop table if exists rug.rug_secu_usuarios;

create table rug.rug_secu_usuarios (
	cve_institucion varchar(10) null,
	cve_usuario varchar(256) null,
	id_persona int not null,
	passwrd varchar(256) null,
	f_prox_camb_psw timestamp null,
	num_log_invalido int null,
	nom_alias varchar(50) null,
	cve_usu_autenticacion varchar(300) null,
	f_asigna_psw timestamp null,
	f_vence_psw timestamp null,
	num_errores_psw int null,
	preg_recupera_psw varchar(60) null,
	resp_recupera_psw varchar(60) null,
	fh_registro timestamp null,
	fh_ult_actualizacion timestamp null,
	fh_ult_acceso timestamp null,
	fh_baja timestamp null,
	sit_usuario varchar(2) null,
	cve_usuario_padre varchar(256) null,
	cve_acreedor varchar(256) null,
	id_grupo int null,
	b_firmado varchar(2) null
);


-- rug.rug_secu_usuarios_bck_010813 definition

-- Drop table

drop table if exists rug.rug_secu_usuarios_bck_010813;

create table rug.rug_secu_usuarios_bck_010813 (
	cve_institucion varchar(10) null,
	cve_usuario varchar(256) null,
	id_persona int null,
	passwrd varchar(256) null,
	f_prox_camb_psw timestamp null,
	num_log_invalido int null,
	nom_alias varchar(50) null,
	cve_usu_autenticacion varchar(300) null,
	f_asigna_psw timestamp null,
	f_vence_psw timestamp null,
	num_errores_psw int null,
	preg_recupera_psw varchar(60) null,
	resp_recupera_psw varchar(60) null,
	fh_registro timestamp null,
	fh_ult_actualizacion timestamp null,
	fh_ult_acceso timestamp null,
	fh_baja timestamp null,
	sit_usuario varchar(2) null,
	cve_usuario_padre varchar(256) null,
	cve_acreedor varchar(256) null,
	id_grupo int null,
	b_firmado varchar(2) null
);


-- rug.rug_secu_usuarios_bck_240111 definition

-- Drop table

drop table if exists rug.rug_secu_usuarios_bck_240111;

create table rug.rug_secu_usuarios_bck_240111 (
	cve_institucion varchar(10) null,
	cve_usuario varchar(256) null,
	id_persona int null,
	passwrd varchar(256) null,
	f_prox_camb_psw timestamp null,
	num_log_invalido int null,
	nom_alias varchar(50) null,
	cve_usu_autenticacion varchar(300) null,
	f_asigna_psw timestamp null,
	f_vence_psw timestamp null,
	num_errores_psw int null,
	preg_recupera_psw varchar(60) null,
	resp_recupera_psw varchar(60) null,
	fh_registro timestamp null,
	fh_ult_actualizacion timestamp null,
	fh_ult_acceso timestamp null,
	fh_baja timestamp null,
	sit_usuario varchar(2) null,
	cve_usuario_padre varchar(256) null,
	cve_acreedor varchar(256) null,
	id_grupo int null,
	b_firmado varchar(2) null
);


-- rug.rug_tbl_bus_dato_conv definition

-- Drop table

drop table if exists rug.rug_tbl_bus_dato_conv;

create table rug.rug_tbl_bus_dato_conv (
	id int null,
	desc_valor_buscar varchar(255) null,
	desc_valor_reemplaza varchar(255) null
);


-- rug.rug_tbl_busqueda definition

-- Drop table

drop table if exists rug.rug_tbl_busqueda;

create table rug.rug_tbl_busqueda (
	id_tramite int not null,
	desc_garantia varchar null
);


-- rug.rug_telefonos definition

-- Drop table

drop table if exists rug.rug_telefonos;

create table rug.rug_telefonos (
	id_persona int not null,
	clave_pais varchar(20) null,
	telefono varchar(50) null,
	extension varchar(50) null,
	fecha_reg timestamp not null,
	status_reg varchar(2) null
);


-- rug.rug_telefonos_h definition

-- Drop table

drop table if exists rug.rug_telefonos_h;

create table rug.rug_telefonos_h (
	id_tramite int not null,
	id_parte int not null,
	id_persona int not null,
	clave_pais varchar(20) null,
	telefono varchar(50) null,
	extension varchar(50) null,
	fecha_reg timestamp not null,
	status_reg varchar(2) null
);


-- rug.rug_telefonos_h_resp definition

-- Drop table

drop table if exists rug.rug_telefonos_h_resp;

create table rug.rug_telefonos_h_resp (
	id_tramite int not null,
	id_parte int not null,
	id_persona int null,
	clave_pais varchar(20) null,
	telefono varchar(50) null,
	extension varchar(50) null,
	fecha_reg timestamp not null,
	status_reg varchar(2) null
);


-- rug.rug_tramite_rastreo definition

-- Drop table

drop table if exists rug.rug_tramite_rastreo;

create table rug.rug_tramite_rastreo (
	id_tram_ras int null,
	id_acreedor int not null,
	id_tramite_temp int null,
	cve_rastreo varchar(1000) null,
	fh_registro timestamp null,
	status_reg varchar(2) null,
	id_archivo int null
);


-- rug.rug_tramites_reasignados definition

-- Drop table

drop table if exists rug.rug_tramites_reasignados;

create table rug.rug_tramites_reasignados (
	id_acreedor int not null,
	id_tramite_temp int not null,
	status_reg varchar(2) null,
	fecha_reg timestamp null
);


-- rug.rug_usuarios_gpos_h definition

-- Drop table

drop table if exists rug.rug_usuarios_gpos_h;

create table rug.rug_usuarios_gpos_h (
	id_usuario int null,
	id_grupo_origen int null,
	id_grupo_destino int null,
	id_persona_modifica int null,
	status_reg varchar(2) null,
	fecha_reg timestamp null
);


-- rug.status_tramite definition

-- Drop table

drop table if exists rug.status_tramite;

create table rug.status_tramite (
	id_status_tram int not null,
	descrip_status varchar(50) null
);


-- rug.temp123 definition

-- Drop table

drop table if exists rug.temp123;

create table rug.temp123 (
	campo int null
);


-- rug.tramites definition

-- Drop table

drop table if exists rug.tramites;

create table rug.tramites (
	id_tramite int not null,
	id_persona int null,
	id_tipo_tramite int null,
	fech_pre_inscr timestamp null,
	fecha_inscr timestamp null,
	id_status_tram int null,
	fecha_creacion timestamp null,
	id_tramite_temp int null,
	id_paso int null,
	fecha_status timestamp null,
	status_reg varchar(2) null,
	b_carga_masiva int null
);


-- rug.tramites_resp definition

-- Drop table

drop table if exists rug.tramites_resp;

create table rug.tramites_resp (
	id_tramite int null,
	id_persona int null,
	id_tipo_tramite int null,
	fech_pre_inscr timestamp null,
	fecha_inscr timestamp null,
	id_status_tram int null,
	fecha_creacion timestamp null,
	id_tramite_temp int null,
	id_paso int null,
	fecha_status timestamp null,
	status_reg varchar(2) null,
	b_carga_masiva int null
);


-- rug.tramites_rug_incomp definition

-- Drop table

drop table if exists rug.tramites_rug_incomp;

create table rug.tramites_rug_incomp (
	id_tramite_temp int not null,
	id_persona int null,
	id_tipo_tramite int null,
	fech_pre_inscr timestamp null,
	fecha_inscr timestamp null,
	status_reg varchar(2) null,
	id_paso int null,
	id_status_tram int null,
	fecha_status timestamp null,
	b_carga_masiva int null
);


-- rug.tramites_rug_incomp_bck_081210 definition

-- Drop table

drop table if exists rug.tramites_rug_incomp_bck_081210;

create table rug.tramites_rug_incomp_bck_081210 (
	id_tramite_temp int null,
	id_persona int null,
	id_tipo_tramite int null,
	fech_pre_inscr timestamp null,
	fecha_inscr timestamp null,
	status_reg varchar(2) null,
	id_paso int null,
	id_status_tram int null,
	fecha_status timestamp null
);  