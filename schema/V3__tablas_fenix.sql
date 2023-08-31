

create schema fenix authorization postgres;


create table fenix.emp_edos_habilitados_fenix (
	cve_pais varchar(3) NULL,
	cve_estado varchar(6) NULL,
	f_habilitacion timestamp NULL
);