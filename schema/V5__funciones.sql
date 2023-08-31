
--------------------------------------------------------
--  DDL for Function FN_BORRA_SIN_CON_GARANTIA
--------------------------------------------------------
drop function if exists rug.fn_borra_sin_con_garantia;
  create or replace function rug.fn_borra_sin_con_garantia (p_descripcion text)
returns text
language plpgsql
as $function$
declare 
v_descripcion text;
begin

 --   rug.rug_cat_tipo_tramite

    v_descripcion := replace( 
                        replace(
                            replace(
                              replace(
                                 replace(
                                    replace(p_descripcion, 'CON GARANTÍA', '')
                                    , 'SIN GARANTÍA', '')
                                 , 'con garantía', '')
                              , 'sin garantía', '')
                            , 'con Garantía', '')
                         , 'sin Garantía', '');

    return v_descripcion;                         
                        
    
end;
$function$;


--------------------------------------------------------
--  DDL for Function FN_CALCULA_FECHA_GMT
--------------------------------------------------------

drop function if exists rug.fn_calcula_fecha_gmt;
  create or replace function rug.fn_calcula_fecha_gmt ()
/******
    función que retorna la fecha con base en el horario de greenwich, 

******/
returns date
language plpgsql
as $function$

declare   
    v_fecha timestamp;
begin 

    
    select current_timestamp + interval '6 hour' into v_fecha;
      
    return v_fecha;
end;
$function$;

--------------------------------------------------------
--  DDL for Function FN_CONCATENA_FOLIO_ACREEDOR
--------------------------------------------------------

drop function if exists rug.fn_concatena_folio_acreedor();
  create or replace function rug.fn_concatena_folio_acreedor (peidfirmamasiva int)
   returns text
language plpgsql
as $function$
declare
   vlfolio1         text;
   vlfolio2         text;
   vlcantidad       int;
   vlidtipotramite  int;
   
begin


    select count(*)
      into vlcantidad
      from rug.rug_firma_masiva
     where id_firma_masiva = peidfirmamasiva;
     
     
     
    select distinct b.id_tipo_tramite
      into vlidtipotramite    
      from rug.rug_firma_masiva a,
           rug.tramites_rug_incomp b
     where a.id_tramite_temp = b.id_tramite_temp;
     
     
     
    if vlidtipotramite = 12 then
                 
            select folio_mercantil 
              into vlfolio1
              from (
                    select rfm.id_tramite_temp, rp.folio_mercantil
                      from rug.rug_firma_masiva rfm,
                           rug.rug_rel_tram_inc_partes rtp,
                           rug.rug_personas rp
                     where 1 = 1
                       and rtp.id_parte = 4
                       and rp.id_persona = rtp.id_persona
                       and rtp.id_tramite_temp = rfm.id_tramite_temp
                       and rfm.id_firma_masiva = peidfirmamasiva
                       order by 1
                   )b limit 1;


            if vlcantidad > 1 then
           
            
                 select folio_mercantil
                   into vlfolio2
                   from (
                            select rfm.id_tramite_temp, rp.folio_mercantil
                              from rug.rug_firma_masiva rfm,
                                   rug.rug_rel_tram_inc_partes rtp,
                                   rug.rug_personas rp
                             where 1 = 1
                               and rtp.id_parte = 4
                               and rp.id_persona = rtp.id_persona
                               and rtp.id_tramite_temp = rfm.id_tramite_temp
                               and rfm.id_firma_masiva = peidfirmamasiva
                               order by 1
                         )b limit 1;                
                  
                if vlfolio1 = '' or vlfolio1 is null then
                
                    vlfolio1 := vlfolio2;
                
                elsif vlfolio2 = '' or vlfolio2 is null then
                
                    vlfolio1 := vlfolio1;
                
                else
                
                    vlfolio1 := vlfolio1 || ' ... ' || vlfolio2;
                            
                end if;         
                
                
            
            end if;
    
    
    else
    
    
         select cve_rastreo 
           into vlfolio1
           from (
                  select b.cve_rastreo
                    from rug.rug_firma_masiva a,
                         rug.rug_tramite_rastreo b
                   where a.id_tramite_temp = b.id_tramite_temp
                     and id_firma_masiva = 364151
                       order by a.id_tramite_temp
                )b limit 2;
                
         if vlcantidad > 1 then       
          
             select cve_rastreo
               into vlfolio2
               from (
                      select b.cve_rastreo
                        from rug.rug_firma_masiva a,
                             rug.rug_tramite_rastreo b
                       where a.id_tramite_temp = b.id_tramite_temp
                         and id_firma_masiva = 364151
                           order by a.id_tramite_temp desc
                    )b limit 2;

            vlfolio1 := vlfolio1 || ' ... ' || vlfolio2;              
                    
         end if;
                
                               
    
    
    end if;
       

    return vlfolio1;

end;
$function$;
 


--------------------------------------------------------
--  DDL for Function FN_EXISTE_ANOTACION_SG_TERMINA
--------------------------------------------------------
drop function if exists rug.fn_existe_anotacion_sg_termina();
  create or replace function rug.fn_existe_anotacion_sg_termina 
(p_id_tramite_padre int)
returns int
language plpgsql
as $function$
declare
    v_cont int := 0;
begin
    
    select count(*)
      into v_cont
      from rug.rug_anotaciones_sin_garantia a
     inner join rug.tramites t
        on t.id_tramite_temp = a.id_tramite_temp
     where t.id_tipo_tramite = 10
       and t.id_status_tram = 3
       and t.id_tramite = p_id_tramite_padre;

    return v_cont;
end;
$function$;


--------------------------------------------------------
--  DDL for Function FN_EXISTE_USUARIO
--------------------------------------------------------
drop function if exists rug.fn_existe_usuario();
  create or replace function rug.fn_existe_usuario 
(p_id_usuario int)
returns int
language plpgsql
as $function$
declare
    v_cont int := 0;
begin
    
    select count(*)
      into v_cont
      from rug.rug_personas_fisicas p
     where p.id_persona = p_id_usuario;       

    return v_cont;

end;
$function$;


--------------------------------------------------------
--  DDL for Function FN_LOB_REPLACE_ALL
--------------------------------------------------------
-- verificar en el back --

/*
CREATE OR REPLACE FUNCTION instr4(p_str VARCHAR, p_substr VARCHAR, 
     p_start INT, p_occurrence INT)
  RETURNS int AS $$
  DECLARE
    v_str   VARCHAR DEFAULT p_str;
    v_pos0  INT DEFAULT 0;
    v_pos   INT DEFAULT 0;
    v_found INT DEFAULT p_occurrence;
  BEGIN
    IF p_start >= 1 THEN
      v_str = SUBSTR(p_str, p_start);
      v_pos0 = p_start;
    END IF;
 
    WHILE 1=1 LOOP
	-- Find the next occurrence
	v_pos = POSITION(p_substr IN v_str);
 
	-- Nothing found
	IF v_pos IS NULL OR v_pos = 0 THEN
	  RETURN v_pos;
	END IF;
 
	-- The required occurrence found
	IF v_found = 1 THEN
	  EXIT;
	END IF;
 
	-- Prepare to find another one occurrence
	v_found := v_found - 1;
        v_pos0 := v_pos0 + v_pos;
	v_str := SUBSTR(v_str, v_pos);
    END LOOP;
 
    RETURN v_pos0 + v_pos;
  END;
  $$ LANGUAGE plpgsql STRICT IMMUTABLE;



  
  create or replace function rug.fn_lob_replace_all(
          i_lob text, 
          i_what text, 
          i_with text,
          i_offset int default 1,
          i_nth int default 1
        ) 
        return text
        language plpgsql
        as $function$
        declare
          vl_lob text;
          o_lob  text;
          vlindex  int[];
          l_lob  int[];
          l_what int[];
          l_with int[];
begin
  if   i_lob is null
    or i_what is null
    or i_offset < 1
    or i_offset > loread(openlo,18446744073709551615)
    or i_nth < 1
    or i_nth > loread(openlo,18446744073709551615)
  then
    return null;
  end if;

vl_lob := i_lob;

loop
      vlindex  := coalesce( instr4( vl_lob, i_what, i_offset, i_nth), 0 );
      
      -- dbms_output.put_line('vlindex ' || vlindex);
      
      l_lob  := length( vl_lob );
      l_what := length( i_what );
      l_with := coalesce(length(i_with), 0 );
    
      dbms_lob.createtemporary( o_lob, false );
      if vlindex > 0 then
        if vlindex > 1 then
          dbms_lob.copy( o_lob, vl_lob, vlindex-1, 1, 1 );
        end if;
    
        if l_with > 0 then
          dbms_lob.append( o_lob, i_with ); 
        end if;
    
        if vlindex + l_what <= l_lob then
          dbms_lob.copy( o_lob, vl_lob, l_lob - vlindex - l_what + 1, vlindex + l_with, vlindex + l_what );
        end if;
      else
        dbms_lob.append( o_lob, vl_lob );
      end if;
      
      vl_lob := o_lob;
  
  exit when (vlindex <= 0);
  end loop;  
  
  return o_lob;

end fn_lob_replace_all;
  
 */ 
  

--------------------------------------------------------
--  DDL for Function FN_MENSAJE_ERROR
--------------------------------------------------------
drop function if exists rug.fn_mensaje_error();
  create or replace function rug.fn_mensaje_error(peidmensajeerror int)
returns text 
language plpgsql
as $function$
declare

vldescmensajeerror text;
      
    begin
	    
	    if peidmensajeerror is null then
raise invalid_parameter_value using message = 'parametro obligatorio peidmensajeerror no esta informado';
end if;

       select desc_codigo 
       into vldescmensajeerror
       from rug.rug_cat_mensajes_errores
       where id_codigo = peidmensajeerror;
      
      if vldescmensajeerror is null then
      vldescmensajeerror = 'CODIGO DE MENSAJE DE ERROR NO ENCONTRADO';
     end if;
    return vldescmensajeerror;
end;
 $function$;


--------------------------------------------------------
--  DDL for Function FN_PERSONA_TRAMITE
--------------------------------------------------------
 
  drop function if exists rug.fn_persona_tramite();
  create or replace function rug.fn_persona_tramite (peidtramite int, peidparte int)    
returns int
language plpgsql
as $function$
declare
 
 vlidpersonaret int :=0; 
    
begin
	
	if peidtramite is null then
raise invalid_parameter_value using message = 'parametro obligatorio peidtramite no esta informado';
end if;

if peidparte is null then
raise invalid_parameter_value using message = 'parametro obligatorio peidparte no esta informado';
end if;

    if peidparte in (4,5) then
             
               select id_persona
               into vlidpersonaret
               from rug.rug_rel_tram_inc_partes
               where id_tramite_temp = peidtramite
               and id_parte = peidparte;
        
    elsif peidparte = 6 then
              
               select id_persona
               into vlidpersonaret
               from rug.tramites_rug_incomp
               where id_tramite_temp = peidtramite;
    end if;
    return vlidpersonaret;  
end;
 $function$;
 


--------------------------------------------------------
--  DDL for Function FN_QUITA_ACENTOS
--------------------------------------------------------

drop function if exists rug.fn_quita_acentos();
 create or replace function rug.fn_quita_acentos (pecadena text)
   returns text
   language plpgsql
   as $function$
   declare

  vlcadresult      text;
  vlcadorig          text;

 begin
    vlcadresult := trim(pecadena);
    
  --asignacion de variables
   if pecadena is not null then
   
        vlcadorig := trim(pecadena);
        --valida caracteres especiales
    --    vlcadorig := vlcadfin;
      
        -- MAYÚSCULAS
        -- acento del castellano ´
        vlCadOrig:= REPLACE(vlCadOrig, 'Á', 'A');
        vlCadOrig:= REPLACE(vlCadOrig, 'É', 'E');
        vlCadOrig:= REPLACE(vlCadOrig, 'Í', 'I');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ó', 'O');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ú', 'U');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ý', 'Y');
        
        -- diéresis :
        vlCadOrig:= REPLACE(vlCadOrig, 'Ä', 'A');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ë', 'E');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ï', 'I');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ö', 'O');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ü', 'U');
        
        -- caret ^
        vlCadOrig:= REPLACE(vlCadOrig, 'Â', 'A'); 
        vlCadOrig:= REPLACE(vlCadOrig, 'Ê', 'E');
        vlCadOrig:= REPLACE(vlCadOrig, 'Î', 'I');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ô', 'O');
        vlCadOrig:= REPLACE(vlCadOrig, 'Û', 'U');
        
        -- acento grave `
        vlCadOrig:= REPLACE(vlCadOrig, 'À', 'A'); 
        vlCadOrig:= REPLACE(vlCadOrig, 'È', 'E');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ì', 'I');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ò', 'O');
        vlCadOrig:= REPLACE(vlCadOrig, 'Ù', 'U');
        
        -- tilde
        vlCadOrig:= REPLACE(vlCadOrig, 'Ã', 'A');
        vlCadOrig:= REPLACE(vlCadOrig, 'Õ', 'O');

        -- MINÚSCULAS
        -- acento del castellano ´
        vlCadOrig:= REPLACE(vlCadOrig, 'á', 'a');
        vlCadOrig:= REPLACE(vlCadOrig, 'é', 'e');
        vlCadOrig:= REPLACE(vlCadOrig, 'í', 'i');
        vlCadOrig:= REPLACE(vlCadOrig, 'ó', 'o');
        vlCadOrig:= REPLACE(vlCadOrig, 'ú', 'u');
        vlCadOrig:= REPLACE(vlCadOrig, 'ý', 'y');
        
        -- diéresis :
        vlCadOrig:= REPLACE(vlCadOrig, 'ä', 'a');
        vlCadOrig:= REPLACE(vlCadOrig, 'ë', 'e');
        vlCadOrig:= REPLACE(vlCadOrig, 'ï', 'i');
        vlCadOrig:= REPLACE(vlCadOrig, 'ö', 'o');
        vlCadOrig:= REPLACE(vlCadOrig, 'ü', 'u');
        vlCadOrig:= REPLACE(vlCadOrig, 'ÿ', 'y');
        
        -- caret ^
        vlCadOrig:= REPLACE(vlCadOrig, 'â', 'a');
        vlCadOrig:= REPLACE(vlCadOrig, 'ê', 'e');
        vlCadOrig:= REPLACE(vlCadOrig, 'î', 'i');
        vlCadOrig:= REPLACE(vlCadOrig, 'ô', 'o');
        vlCadOrig:= REPLACE(vlCadOrig, 'û', 'u');
        
        -- acento grave `
        vlCadOrig:= REPLACE(vlCadOrig, 'à', 'a');
        vlCadOrig:= REPLACE(vlCadOrig, 'è', 'e');
        vlCadOrig:= REPLACE(vlCadOrig, 'ì', 'i');
        vlCadOrig:= REPLACE(vlCadOrig, 'ò', 'o');
        vlCadOrig:= REPLACE(vlCadOrig, 'ù', 'u');
        
        -- tilde
        vlCadOrig:= REPLACE(vlCadOrig, 'ã', 'a');
        vlCadOrig:= REPLACE(vlCadOrig, 'õ', 'o');
        
        vlCadOrig:= REPLACE(vlCadOrig, '`', '');
        vlCadOrig:= REPLACE(vlCadOrig, '´', '');
        vlCadOrig:= REPLACE(vlCadOrig, '^', '');
        vlCadOrig:= REPLACE(vlCadOrig, '~', '');


        vlcadresult := vlcadorig;
       else
       end if;

    return vlcadresult;

end;
$function$;
 
 
 
 
--------------------------------------------------------
--  DDL for Function FN_REP_RES_WRD_FOR_CONTAINS
--------------------------------------------------------

create domain clob as text;
drop function if exists rug.fn_rep_res_wrd_for_contains();
  create or replace function rug.fn_rep_res_wrd_for_contains (pe_clob text)
returns text 
language plpgsql
as $function$
declare
  vl_clob   text;
  vlcadena  text;
 
 crugtblbusdatoconv cursor is
    select desc_valor_buscar, desc_valor_reemplaza from rug.rug_tbl_bus_dato_conv;
 
 
begin
  vl_clob := pe_clob;
  for r in crugtblbusdatoconv
  loop

      if (r.desc_valor_reemplaza is null) then
        vlcadena := null;
      else
        vlcadena := 'ASHGASHG';
      end if;

      vl_clob := rug.fn_lob_replace_all(
                  i_lob    => vl_clob,
                  i_what   => r.desc_valor_buscar,
                  i_with   => vlcadena||r.desc_valor_reemplaza||vlcadena,
                  i_offset => 1,
                  i_nth    => 1
           );
  end loop;
  return upper(vl_clob);
end;
$function$;


--------------------------------------------------------
--  DDL for Function FN_VALIDA_PERSONA
--------------------------------------------------------
drop function if exists rug.fn_valida_persona();
  create or replace function rug.fn_valida_persona(p_id_persona text)      
returns int
language plpgsql
as $function$
declare
    v_cont          int := 0;
    --v_pers_juri     rug.rug_personas.per_juridica%type;
    
begin
    if p_id_persona is null then
raise invalid_parameter_value using message = 'parametro obligatorio p_id_persona no esta informado';
end if;
    select count(*)
      into v_cont
      from rug.rug_personas p
     where p.id_persona = p_id_persona;
    
    return v_cont;
    
 
exception
    when others then
        return 0;    

end;
$function$;


--------------------------------------------------------
--  DDL for Function FN_VALIDA_TIPO_TRAMITE
--------------------------------------------------------
drop function if exists rug.fn_valida_tipo_tramite();
  create or replace function rug.fn_valida_tipo_tramite( idtramitetemporal int, idtipotramite int)
    returns boolean
language plpgsql
as $function$
declare

    t_tram      int;
    valido      boolean;
   
begin
	
	if idtipotramite is null then
raise invalid_parameter_value using message = 'parametro obligatorio idtipotramite no esta informado';
end if;

    if idtramitetemporal is null then
raise invalid_parameter_value using message = 'parametro obligatorio idtramitetemporal no esta informado';
end if;

    valido := true;

    -- obtener el id de tramite temporal --
    select id_tipo_tramite
      into t_tram
      from rug.tramites_rug_incomp
     where id_tramite_temp = idtramitetemporal;
    
    -- comparar con el id recibido por la funcion --
    if t_tram <> idtipotramite then
     
       valido := false;
        
    end if;

    return valido;

end;
$function$;


--------------------------------------------------------
--  DDL for Function FNACREEDORESXFECHA
--------------------------------------------------------
drop function if exists rug.fnacreedoresxfecha();
  create or replace function rug.fnacreedoresxfecha (fecha date) returns int 
  language plpgsql
  as $function$
  declare 
vltotal1  int;
vltotal2  int;
vltotal3  int;
begin
 vltotal1:=0;
 vltotal2:=0;
 vltotal3:=0;
  --- se suman los que tienen rfc
  select /*+rule*/  
         count(contador)
  --into vltotal1      
  from ( select /*+rule*/ 
                  1 contador  
           from ( select /*+rule*/ 
                         min(case when id_perfil = 4 then 1
                         when id_perfil = 2 then 2
                         when id_perfil = 1 then 3 end) as tipo_perfil,
                         rfc_acreedor
                  from rug.v_rep_base_acreedores
                  where regexp_substr(rfc_acreedor,  '^aaa[0|1]{6}') is null
                  and to_date(fecha_status)= fecha
                  group by rfc_acreedor
                ) t1,
                ( select /*+rule*/ 
                         id_acreedor,
                         case when id_perfil = 4 then 1
                         when id_perfil = 2 then 2
                         when id_perfil = 1 then 3 end as tipo_perfil,
                         rfc_acreedor
                  from rug.v_rep_base_acreedores
                ) t2               
           where t1.rfc_acreedor=t2.rfc_acreedor
           and t1.tipo_perfil=t2.tipo_perfil       
           group by   t1.tipo_perfil, t1.rfc_acreedor
       )b;
  --- se suman los que no tienen rfc o tienen rfc generico
  select /*+rule*/  
         count(contador)
  into vltotal2      
  from ( select /*+rule*/ 
                  1 contador
         from rug.v_rep_base_acreedores
         where (regexp_substr(rfc_acreedor,'^aaa[0|1]{6}') is not null
                or rfc_acreedor is null)
         and to_date(fecha_status)= fecha
         group by trim(nombre_acreedor)
       )c ;

  vltotal3 := vltotal1+ vltotal2;
--select * from rug.v_rep_base_acreedores where id_acreedor = 3621  
   return vltotal3;

   exception
     when no_data_found then
       return null;
     when others then
       return null;
end;
 $function$;
 


 
 
 --------------------------------------------------------
--  DDL for Function RUG_ACENTOS
--------------------------------------------------------
  drop function if exists rug.rug_acentos();
  create or replace function rug.rug_acentos(pecadena text)
   returns text
   language plpgsql
   as $function$
   declare


  vlcadresult      text;
  vlcadorig          text;

 begin
    vlcadresult := upper(trim(pecadena));
  --asignacion de variables
   if pecadena is not null then
        vlcadorig := upper(trim(pecadena));
        --valida caracteres especiales
    --    vlcadorig := vlcadfin;
        vlCadOrig:= REPLACE(vlCadOrig, 'A', 'A');
        vlCadOrig:= REPLACE(vlCadOrig, 'E', 'E');
        vlCadOrig:= REPLACE(vlCadOrig, 'I', 'I');
        vlCadOrig:= REPLACE(vlCadOrig, 'O', 'O');
        vlCadOrig:= REPLACE(vlCadOrig, 'U', 'U');
        vlCadOrig:= REPLACE(vlCadOrig, 'A', 'A');
        vlCadOrig:= REPLACE(vlCadOrig, 'E', 'E');
        vlCadOrig:= REPLACE(vlCadOrig, 'I', 'I');
        vlCadOrig:= REPLACE(vlCadOrig, 'O', 'O');
        vlCadOrig:= REPLACE(vlCadOrig, 'U', 'U');
        vlCadOrig:= REPLACE(vlCadOrig, 'A', 'A');
        vlCadOrig:= REPLACE(vlCadOrig, 'E', 'E');
        vlCadOrig:= REPLACE(vlCadOrig, 'I', 'I');
        vlCadOrig:= REPLACE(vlCadOrig, 'O', 'O');
        vlCadOrig:= REPLACE(vlCadOrig, 'U', 'U');

        vlCadOrig:= REPLACE(vlCadOrig, 'a', 'A');
        vlCadOrig:= REPLACE(vlCadOrig, 'e', 'E');
        vlCadOrig:= REPLACE(vlCadOrig, 'i', 'I');
        vlCadOrig:= REPLACE(vlCadOrig, 'o', 'O');
        vlCadOrig:= REPLACE(vlCadOrig, 'u', 'U');
        vlCadOrig:= REPLACE(vlCadOrig, 'a', 'A');
        vlCadOrig:= REPLACE(vlCadOrig, 'e', 'E');
        vlCadOrig:= REPLACE(vlCadOrig, 'i', 'I');
        vlCadOrig:= REPLACE(vlCadOrig, 'o', 'O');
        vlCadOrig:= REPLACE(vlCadOrig, 'u', 'U');
        vlCadOrig:= REPLACE(vlCadOrig, 'a', 'A');
        vlCadOrig:= REPLACE(vlCadOrig, 'e', 'E');
        vlCadOrig:= REPLACE(vlCadOrig, 'i', 'I');
        vlCadOrig:= REPLACE(vlCadOrig, 'o', 'O');
        vlCadOrig:= REPLACE(vlCadOrig, 'u', 'U');
        --vlCadOrig:= REPLACE(vlCadOrig, ''', '');
        vlCadOrig:= REPLACE(vlCadOrig, '`', '');

        vlcadresult := vlcadorig;
    end if;

    return vlcadresult;

 exception
   when others then
    return vlcadresult;
end;
$function$;
 
 
--------------------------------------------------------
--  DDL for Function FNCONCATOTORGANTE
--------------------------------------------------------

drop function if exists rug.fnconcatotorgante();
 create or replace function rug.fnconcatotorgante(
                      peidtramite      int,
                      peopcion         int     --- 1 para nombre de otorgante, 2 para folio  mercantil del otorgante
                                                  --- 3 para nombre de otorgante incompleto
                                                  --- 5 para curp		--fr
                      )
returns text 
language plpgsql
as $function$
declare

    vlnombreotorgante       text;
    vlnombreotorganteaux    text;    
    
    vlnombreotorgantet       text;
    vlnombreotorganteauxt    text;    

    
    vlfoliootorgante       text;
    vlfoliootorganteaux    text;  
    
    vlfoliootorgantet       text;
    vlfoliootorganteauxt    text;

    vlcurpotorgantet       text;					--fr
    vlcurpotorganteauxt    text;					--fr
    
    vlseparador             text;

   
    cursconcatenaotorgante cursor is
    select case when 
                   rrtp.per_juridica =
                   'PF' then
                   (select      rug_acentos (upper (trim (nombre_persona)))
                             || ' '
                             || rug_acentos (upper (trim (ap_paterno)))
                             || ' '
                             || rug_acentos (upper (trim (ap_materno)))
                      from   rug.rug_personas_h
                     where   id_persona = rrtp.id_persona
                       and rrtp.id_tramite = id_tramite
                     and id_parte = 1)
                     when 
                   rrtp.per_juridica =
                   'PM' then
                   (select   rug_acentos (upper (trim (razon_social)))
                      from   rug.rug_personas_h
                     where   id_persona = rrtp.id_persona
                       and rrtp.id_tramite = id_tramite
                     and id_parte = 1)
                end as
                   nombre
      from rug.rug_rel_tram_partes rrtp  
     where id_tramite = cpeidtramite
       and id_parte = 1
       and status_reg = 'AC'
     order by rrtp.id_persona asc;
     
       cursconcatenaotorgantetemp cursor is       
        select case when 
                   rrtp.per_juridica =
                       'PF' then
                       (select      rug_acentos (upper (trim (nombre_persona)))
                                 || ' '
                                 || rug_acentos (upper (trim (ap_paterno)))
                                 || ' '
                                 || rug_acentos (upper (trim (ap_materno)))
                          from   rug.rug_personas_fisicas
                         where   id_persona = rrtp.id_persona)
                         when 
                   rrtp.per_juridica =
                       'PM' then
                       (select   rug_acentos (upper (trim (razon_social)))
                          from   rug.rug_personas_morales
                         where   id_persona = rrtp.id_persona)
                    end as nombre
          from rug.rug_rel_tram_inc_partes rrtp  
         where id_tramite_temp = cpeidtramite
           and id_parte = 1
           and status_reg = 'AC'
         order by rrtp.id_persona asc;
         
            
    cursconcatenafoliomercantil cursor is
    select rug_acentos(upper (trim (rp.folio_mercantil)))
      from rug.rug_rel_tram_partes rrtp, rug.rug_personas_h rp  
     where rp.id_tramite = cpeidtramite
       and rrtp.id_tramite = rp.id_tramite
       and rp.id_persona = rrtp.id_persona 
       and rrtp.id_parte = 1
       and rrtp.id_parte = rp.id_parte
       and rrtp.status_reg = 'AC'
     order by rrtp.id_persona asc; 
          
    cursconcatenafoliomercantilt cursor is    
    select rug_acentos (upper (trim (rp.folio_mercantil)))
      from rug.rug_rel_tram_inc_partes rrtp, rug.rug_personas rp  
     where id_tramite_temp = cpeidtramite
       and rp.id_persona = rrtp.id_persona 
       and id_parte = 1       
       and status_reg = 'AC'
     order by rrtp.id_persona asc; 
 
     cursconcatenacurp cursor is			--fr
    select rug_acentos (upper (trim (rp.curp)))					
      from rug.rug_rel_tram_partes rrtp, rug.rug_personas_h rp  
     where rp.id_tramite = cpeidtramite
       and rrtp.id_tramite = rp.id_tramite
       and rp.id_persona = rrtp.id_persona 
       and rrtp.id_parte = 1
       and rrtp.id_parte = rp.id_parte
       and rrtp.status_reg = 'AC'
     order by rrtp.id_persona asc;      					--/fr
   

begin
    

--   reg_param_pls(seq_rug_param_pls.nextval, 'fnconcatotorgante', 'peidtramite', peidtramite, 'in');
--   reg_param_pls(seq_rug_param_pls.nextval, 'fnconcatotorgante', 'peopcion', peopcion, 'in');
    

    vlseparador := '<br>';



    if (peopcion = 1) then
        begin
                loop
                    fetch cursconcatenaotorgante into vlnombreotorgante;
                    exit when cursconcatenaotorgante%notfound;
                         
                    vlnombreotorganteaux := concat(vlnombreotorganteaux, vlnombreotorgante || vlseparador);                    
                        
                end loop;
        end;
    end if;    
    
    if(peopcion = 2) then
        begin    
                loop
                    fetch cursconcatenafoliomercantil into vlfoliootorgante;
                    exit when cursconcatenafoliomercantil%notfound;                    
                    vlfoliootorganteaux := concat(vlfoliootorganteaux, vlfoliootorgante || vlseparador);
                        
                end loop;
            
            vlnombreotorganteaux := vlfoliootorganteaux;
            
        end;    
    end if;
    
    
     if (peopcion = 3) then
        begin
                loop
                    fetch cursconcatenaotorgantetemp into vlnombreotorgantet;
                    exit when cursconcatenaotorgantetemp%notfound;
                         
                    vlnombreotorganteauxt := concat(vlnombreotorganteauxt, vlnombreotorgantet || vlseparador);                    
                        
                end loop;
            
            vlnombreotorganteaux := vlnombreotorganteauxt;                     
            
        end;
    end if;    
    
    
     if(peopcion = 4) then
        begin    
                loop
                    fetch cursconcatenafoliomercantilt into vlfoliootorgantet;
                    exit when cursconcatenafoliomercantilt%notfound;                    
                    vlfoliootorganteauxt := concat(vlfoliootorganteauxt, vlfoliootorgantet || vlseparador);
                        
                end loop;
            
            vlnombreotorganteaux := vlfoliootorganteauxt;
            
        end;    
    end if;

     if (peopcion = 5) then							--fr
        begin
                loop
                    fetch cursconcatenacurp into vlcurpotorgantet;
                    exit when cursconcatenacurp%notfound;
                    vlcurpotorganteauxt := concat(vlcurpotorganteauxt, vlcurpotorgantet || vlseparador);                                            
                end loop;           
            vlnombreotorganteaux := vlcurpotorganteauxt;                     
        end;
    end if;									--/fr
    
    
    return substr(vlnombreotorganteaux, 0, length(vlnombreotorganteaux) - length(vlseparador));
            
end;
 $function$;
 
 
--------------------------------------------------------
--  DDL for Function FNCONCATOTORGANTE_TEST
--------------------------------------------------------

 drop function if exists rug.fnconcatotorgante_test();
  create or replace function rug.fnconcatotorgante_test(peidtramite integer, peopcion integer)
 returns text
 language plpgsql
as $function$
--return clob

declare

    vcadenareturn           text;
    
    vlnombreotorgante       text;
    vlnombreotorganteaux    text;    
    
    vlnombreotorgantet       text;
    vlnombreotorganteauxt    text;    

    
    vlfoliootorgante       text;
    vlfoliootorganteaux    text;  
    
    vlfoliootorgantet       text;
    vlfoliootorganteauxt    text;

    vlcurpotorgantet       text;                    --fr
    vlcurpotorganteauxt    text;                    --fr
    
    vlseparador             text;

   
    cursconcatenaotorgante cursor is
    select case when 
                   rrtp.per_juridica =
                   'PF' then
                   (select      rug.rug_acentos(upper (trim (nombre_persona)))
                             || ' '
                             || rug.rug.rug_acentos(upper (trim (ap_paterno)))
                             || ' '
                             || rug.rug_acentos(upper (trim (ap_materno)))
                      from   rug.rug_personas_h
                     where   id_persona = rrtp.id_persona
                       and rrtp.id_tramite = id_tramite
                     and id_parte = 1)
                     when rrtp.per_juridica =
                   'PM' then
                   (select   rug.rug_acentos(upper (trim (razon_social)))
                      from   rug.rug_personas_h
                     where   id_persona = rrtp.id_persona
                       and rrtp.id_tramite = id_tramite
                     and id_parte = 1)
                end as
                   nombre
      from rug.rug_rel_tram_partes rrtp  
     where id_tramite = cpeidtramite
       and id_parte = 1
       and status_reg = 'AC'
     order by rrtp.id_persona asc;
     
       cursconcatenaotorgantetemp cursor is       
        select case when
                       rrtp.per_juridica=
                       'PF' then
                       (select      rug.rug_acentos (upper (trim (nombre_persona)))
                                 || ' '
                                 || rug.rug_acentos (upper (trim (ap_paterno)))
                                 || ' '
                                 || rug.rug_acentos (upper (trim (ap_materno)))
                          from   rug.rug_personas_fisicas
                         where   id_persona = rrtp.id_persona)
                         when rrtp.per_juridica=
                       'PM' then
                       (select   rug.rug_acentos (upper (trim (razon_social)))
                          from   rug.rug_personas_morales
                         where   id_persona = rrtp.id_persona)
                    end as nombre
          from rug.rug_rel_tram_inc_partes rrtp  
         where id_tramite_temp = cpeidtramite
           and id_parte = 1
           and status_reg = 'AC'
         order by rrtp.id_persona asc;
         
            
    cursconcatenafoliomercantil cursor is
    select rug.rug_acentos (upper (trim (rp.folio_mercantil)))
      from rug.rug_rel_tram_partes rrtp, rug.rug_personas_h rp  
     where rp.id_tramite = cpeidtramite
       and rrtp.id_tramite = rp.id_tramite
       and rp.id_persona = rrtp.id_persona 
       and rrtp.id_parte = 1
       and rrtp.id_parte = rp.id_parte
       and rrtp.status_reg = 'AC'
     order by rrtp.id_persona asc; 
          
    cursconcatenafoliomercantilt cursor is    
    select rug.rug_acentos (upper (trim (rp.folio_mercantil)))
      from rug.rug_rel_tram_inc_partes rrtp, rug.rug_personas rp  
     where id_tramite_temp = cpeidtramite
       and rp.id_persona = rrtp.id_persona 
       and id_parte = 1       
       and status_reg = 'AC'
     order by rrtp.id_persona asc; 
 
     cursconcatenacurp cursor is            --fr
    select rug.rug_acentos (upper (trim (rp.curp)))                    
      from rug.rug_rel_tram_partes rrtp, rug.rug_personas_h rp  
     where rp.id_tramite = cpeidtramite
       and rrtp.id_tramite = rp.id_tramite
       and rp.id_persona = rrtp.id_persona 
       and rrtp.id_parte = 1
       and rrtp.id_parte = rp.id_parte
       and rrtp.status_reg = 'AC'
     order by rrtp.id_persona asc;                          --/fr
   

begin
    

--   reg_param_pls(seq_rug_param_pls.nextval, 'fnconcatotorgante', 'peidtramite', peidtramite, 'in');
--   reg_param_pls(seq_rug_param_pls.nextval, 'fnconcatotorgante', 'peopcion', peopcion, 'in');
    

    vlseparador := '<br>';



    if (peopcion = 1) then
        begin
            open cursconcatenaotorgante;
                loop
                    fetch cursconcatenaotorgante into vlnombreotorgante;
                    exit when cursconcatenaotorgante%notfound;
                        if (nvl(length(vlnombreotorganteaux),0) < 3500) then                          
                            vlnombreotorganteaux := concat(vlnombreotorganteaux, vlnombreotorgante || vlseparador);
                        end if;      
                        
                end loop;
            close cursconcatenaotorgante;
        end;
    end if;    
    
    if(peopcion = 2) then
        begin    
            open cursconcatenafoliomercantil;
                loop
                    fetch cursconcatenafoliomercantil into vlfoliootorgante;
                    exit when cursconcatenafoliomercantil%notfound;                    
                    vlfoliootorganteaux := concat(vlfoliootorganteaux, vlfoliootorgante || vlseparador);
                        
                end loop;
            close cursconcatenafoliomercantil;
            
            vlnombreotorganteaux := vlfoliootorganteaux;
            
        end;    
    end if;
    
    
     if (peopcion = 3) then
        begin
            open cursconcatenaotorgantetemp;
                loop
                    fetch cursconcatenaotorgantetemp into vlnombreotorgantet;
                    exit when cursconcatenaotorgantetemp%notfound;
                         
                    vlnombreotorganteauxt := concat(vlnombreotorganteauxt, vlnombreotorgantet || vlseparador);                    
                        
                end loop;
            close cursconcatenaotorgantetemp;
            
            vlnombreotorganteaux := vlnombreotorganteauxt;                     
            
        end;
    end if;    
    
    
     if(peopcion = 4) then
        begin    
            open cursconcatenafoliomercantilt;
                loop
                    fetch cursconcatenafoliomercantilt into vlfoliootorgantet;
                    exit when cursconcatenafoliomercantilt%notfound;                    
                    vlfoliootorganteauxt := concat(vlfoliootorganteauxt, vlfoliootorgantet || vlseparador);
                        
                end loop;
            close cursconcatenafoliomercantilt;
            
            vlnombreotorganteaux := vlfoliootorganteauxt;
            
        end;    
    end if;

     if (peopcion = 5) then                            --fr
        begin
            open cursconcatenacurp;
                loop
                    fetch cursconcatenacurp into vlcurpotorgantet;
                    exit when cursconcatenacurp%notfound;
                    vlcurpotorganteauxt := concat(vlcurpotorganteauxt, vlcurpotorgantet || vlseparador);                                            
                end loop;
            close cursconcatenacurp;            
            vlnombreotorganteaux := vlcurpotorganteauxt;                     
        end;
    end if;                                    --/fr
    
    
    vcadenareturn := substr(vlnombreotorganteaux, 0, length(vlnombreotorganteaux) - length(vlseparador));
    return vcadenareturn;
            
end;
$function$;



--------------------------------------------------------
--  DDL for Function FNDPSWENCRYPT
--------------------------------------------------------

create extension pgcrypto;   -- INSTALACION DE EXTENSION PGCRYPTO


  drop function if exists rug.fndpswencrypt();
  create or replace function rug.fndpswencrypt(bytea)
 returns text
 language plpgsql
as $function$
begin
    select encode(digest($1, 'sha1'), 'hex');
   end;
$function$;

--------------------------------------------------------
--  DDL for Function FNOBTMSGERR
--------------------------------------------------------


drop function if exists rug.fnobtmsgerr();
create or replace function rug.fnobtmsgerr(peidcodigo integer)
 returns character varying
 language plpgsql
as $function$
declare
vldescerror           rug.rug_cat_mensajes_errores.desc_codigo%type;

begin

   vldescerror       := null;

   begin
      --select initcap(desc_codigo) into vldescerror
      select desc_codigo
      into vldescerror
      from rug.rug_cat_mensajes_errores
      where id_codigo = peidcodigo;
      exception when no_data_found then
            vldescerror := 'no se encontro el mensaje seleccionado';
            --sp_log('funobtmsgerr',peidcodigo||' - '||substr(sqlcode||'-'||sqlerrm,1,1000));
   end;

   return vldescerror;

exception
   when others then
      return null;
      --sp_log('funobtmsgerr',substr(sqlcode||'-'||sqlerrm,1,1000));

end;
 $function$;

 


--------------------------------------------------------
--  DDL for Function FNOTORGANTE
--------------------------------------------------------

drop function if exists rug.fnotorgante();
  create or replace function rug.fnotorgante(vid_garantia integer, vid_tramite integer)
 returns text
 language plpgsql
as $function$
  declare
    v_nombre text := null; 
begin

  begin
          select  ap_paterno || ' ' || ap_materno || ' ' || nombre_persona || ' ' || razon_social as otorgante 
            into v_nombre 
        from  v_operaciones_garantia a, 
              tramites b,
              rug.rug_personas_h c 
        where a.id_garantia = vid_garantia
        and   a.id_tipo_tramite = 8        
        and   b.id_tramite = a.id_tramite 
        and   c.id_persona = b.id_persona 
        and   c.id_tramite = b.id_tramite
        order by a.fecha_creacion limit 1;

  exception when others then 
        v_nombre := ''; 
  end; 
  return v_nombre; 
end;
$function$;


--------------------------------------------------------
--  DDL for Function FNOTORGANTE_T
--------------------------------------------------------

drop function if exists rug.fnotorgante_t();
  create or replace function rug.fnotorgante_t(vid_garantia integer, vid_tramite integer)
 returns text
 language plpgsql
as $function$
  declare
    v_nombre text; 
begin

  begin
          select  ap_paterno || ' ' || ap_materno || ' ' || nombre_persona || ' ' || razon_social as otorgante 
            into v_nombre 
        from  v_operaciones_garantia a, 
              tramites b,
              rug.rug_personas_h c 
        where a.id_garantia = vid_garantia
        and   a.id_tipo_tramite = 8        
        and   b.id_tramite = a.id_tramite         
        and   c.id_tramite = b.id_tramite
        and   c.id_parte = 2 
        order by a.fecha_creacion limit 1;

  exception when others then 
        v_nombre := ''; 
  end; 
  return v_nombre; 
end;   
$function$;


--------------------------------------------------------
--  DDL for Function FNVALIDAFECHAS
--------------------------------------------------------

drop function if exists rug.fnvalidafechas();
  create or replace function rug.fnvalidafechas(peidgarantia integer, peidtramitetemp integer)
 returns integer
 language plpgsql
as $function$

declare

--vlfechagarantia     date;
--vlfechatramite      date;

vltramitetemgar     int;
vltramitetem        int;
vlresultado         int;

   
--reg_param_pls(seq_rug_param_pls.nextval, 'fnvalidamodificaotorgante', 'peidgarantia', peidgarantia, 'in');
--reg_param_pls(seq_rug_param_pls.nextval, 'fnvalidamodificaotorgante', 'peidtramitetemp', peidtramitetemp, 'in');

   begin
 
                
        select id_tramite_temp
          into vltramitetem
          from rug_bitac_tramites
        where id_tramite_temp = peidtramitetemp
        and status_reg = 'AC';

                 
        select   id_tramite_temp
          into   vltramitetemgar
          from   (  select   id_tramite_temp
                      from   v_tramites_terminados
                     where   id_garantia = peidgarantia
                  order by   1 desc)b
         limit 1;
           
        if(vltramitetem <= vltramitetemgar)then
            vlresultado := 0;
        else
            vlresultado := 1;
        end if;

   return vlresultado;

end; 
 $function$;



--------------------------------------------------------
--  DDL for Function FNVALIDAMODIFICAOTORGANTE
--------------------------------------------------------
drop function if exists rug.fnvalidamodificaotorgante();
  create or replace function rug.fnvalidamodificaotorgante(peidgarantia integer, peidtramitetemp integer)
 returns integer
 language plpgsql
as $function$
declare

vlpartegarantia     int;
vlpartetramite      int;
vlresultado         int;


begin
   
--reg_param_pls(seq_rug_param_pls.nextval, 'fnvalidamodificaotorgante', 'peidgarantia', peidgarantia, 'in');
--reg_param_pls(seq_rug_param_pls.nextval, 'fnvalidamodificaotorgante', 'peidtramitetemp', peidtramitetemp, 'in');

   begin
   
             /* 
        select   distinct id_persona
          into   vlpartegarantia        
          from   rug_rel_garantia_partes
         where   id_garantia = peidgarantia 
           and   id_parte = 1
           and   status_reg = 'ac';
           */
        select   rpp.id_persona
          into   vlpartegarantia
          from         rug_rel_garantia_partes rpp
                    inner join
                       rug.rug_garantias rgg
                    on rpp.id_relacion = rgg.id_relacion
                 inner join
                    rug.rug_personas rep
                 on rpp.id_persona = rep.id_persona
         where   rpp.id_garantia = peidgarantia 
           and   rpp.id_parte = 1
           and   rpp.status_reg = 'AC';   


        select   distinct id_persona
          into   vlpartetramite
          from   rug.rug_rel_tram_inc_partes
         where   id_tramite_temp = peidtramitetemp 
           and   id_parte = 1 
           and   status_reg = 'AC';
           
                      
        if(vlpartegarantia = vlpartetramite)then
            vlresultado := 0;
        else
            vlresultado := 1;
        end if;
        
        
   
   end;

   return vlresultado;

end; 
 $function$;

 
 


--------------------------------------------------------
--  DDL for Function FREPACREEDORES
--------------------------------------------------------

  drop function if exists rug.frepacreedores();
  create or replace function rug.frepacreedores(fecha date)
 returns refcursor
 language plpgsql
as $function$
declare 
    vlrefcursor refcursor; 
begin

open vlrefcursor for

select id_acreedor,
       nombre_acreedor,
       per_juridica,
       tipo_perfil,
       case when tipo_perfil= 1 then 'FEDATARIO'
            when tipo_perfil= 2 then 'ACREEDOR'
            when tipo_perfil= 3 then 'CUIDADANO' end as desc_tipo_perfil,
       rfc_acreedor
from ( select t1.id_acreedor,
              per.nombre_acreedor ,
              per.per_juridica,
              t1.tipo_perfil,
              per.rfc_acreedor
        from  (select /*+rule*/ 
                      min(id_acreedor) id_acreedor,
                      case when id_perfil = 4 then 1
                           when id_perfil = 2 then 2
                           when id_perfil = 1 then 3 end as tipo_perfil,
                      rfc_acreedor
               from rug.v_rep_base_acreedores
               where regexp_substr(rfc_acreedor,  '^AAA[0|1]{6}') is null
               and rfc_acreedor is not null
               and (fecha_status)::date <= fecha
               group by rfc_acreedor, tipo_perfil
               ) t1,
               rug.v_rep_base_acreedores per               
       where t1.id_acreedor=per.id_acreedor
       union all
       select min(id_acreedor) id_acreedor,
              trim(nombre_acreedor) nombre_persona,
              max(per_juridica) per_juridica,
              min(case when id_perfil = 4 then 1
              when id_perfil = 2 then 2
              when id_perfil = 1 then 3 end) as tipo_perfil,        
              max(rfc_acreedor) rfc_acreedor
       from rug.v_rep_base_acreedores
       where (regexp_substr(rfc_acreedor,  '^AAA[0|1]{6}') is not null
              or rfc_acreedor is null)
              and (fecha_status)::date <= fecha
       group by trim(nombre_acreedor)
     )b;



       
  return vlrefcursor;     

   exception
     when no_data_found then
       return null;
     when others then
       return null;
end;
$function$;

 



  --GRANT EXECUTE ON "RUG"."FREPACREEDORES" TO "FENIXSOA";

--------------------------------------------------------
--  DDL for Function RUG_CARACTER_ESP
--------------------------------------------------------
drop function if exists rug.rug_caracter_esp();
  create or replace function rug.rug_caracter_esp(pecadena text)
 returns text
 language plpgsql
as $function$
declare

  vlcadresult      text;
  vlcadorig          text;

 begin
    vlcadresult := upper(trim(pecadena));
  --asignacion de variables
   if pecadena is not null then
        vlcadorig := upper(trim(pecadena));
        --valida caracteres especiales
    --    vlcadorig := vlcadfin;
        vlCadOrig:= REPLACE(vlCadOrig, '|', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '°', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '!', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '"', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '#', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '$', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '%', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '&', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '/', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '(', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, ')', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '=', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '?', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '''', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '\', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '¿', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '¡', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '´', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '+', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '*', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '~', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '{', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '^', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '[', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '}', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, ']', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '`', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, ',', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, ';', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '.', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, ':', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '-', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '_', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '  ', ' ');
        vlCadOrig:= REPLACE(vlCadOrig, '   ', ' ');
               
        
        vlcadresult := vlcadorig;
    end if;

    return vlcadresult;

 exception
   when others then
    
    return ' ';
end;
$function$;

--------------------------------------------------------
--  DDL for Function SPLIT_TEM
--------------------------------------------------------

drop function if exists rug.split_tem();
  create or replace function rug.split_tem(p_list text)
 returns text
 language plpgsql
as $function$
declare
   -- l_idx    pls_integer;
    l_list    text := p_list;
    l_value   text := 'rug.t_palabras'; -- varchar2(32767);
begin

           
        l_list := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(l_list, ',', ' '), '.', ' '), CHR(10), ' '), CHR(13), ' '),CHR(09), ' ');
        
            return l_list;
end;
$function$;

 
 
--------------------------------------------------------
--  DDL for Function SPLITCADENA
--------------------------------------------------------


SELECT split_part('--Criti-an--', '--', 2);

  /*CREATE OR REPLACE FUNCTION "RUG"."SPLITCADENA" (peCADENA IN VARCHAR2,
                      peCaracter IN varchar2)
 RETURN t_Palabras
 IS
  vlCadena     VARCHAR2(4000);
  vlPosEspacio integer;
  vlIndice     integer;
  vlPalabras   t_Palabras;
 BEGIN
    vlIndice     := 0;
    vlCadena     := peCADENA;
    vlPalabras(0):= vlCadena;
    vlPosEspacio:=INSTR(vlCadena, peCaracter);
    WHILE vlPosEspacio!= 0 LOOP
          vlPalabras(vlIndice) := TRIM(SUBSTR(vlCadena, 1, vlPosEspacio - 1));
          vlCadena := SUBSTR(vlCadena,  vlPosEspacio + 1);
          vlIndice := vlIndice + 1;
          vlPosEspacio := INSTR(vlCadena, peCaracter);
          IF (vlPosEspacio= 0) AND (LENGTH(vlCadena)<> 0) THEN
              vlPosEspacio:=LENGTH(vlCadena)+1;
          END IF;
    END LOOP;

    RETURN  vlPalabras;
 END SPLITCadena;
 
 */


--------------------------------------------------------
--  DDL for Function SQUIRREL_GET_ERROR_OFFSET
--------------------------------------------------------

drop function if exists rug.squirrel_get_error_offset();
  create or replace function rug.squirrel_get_error_offset(query text)
 returns int
 language plpgsql
 as $function$
declare
l_status        int;
begin          
	begin          execute query;
exception                  
when others then SELECT oid into l_status FROM pg_authid;
end;          

return l_status; 
end;
$function$;


--------------------------------------------------------
--  DDL for Function TIPO_BIEN_GARANTIA
--------------------------------------------------------
drop function if exists rug.tipo_bien_garantia();
  create or replace function rug.tipo_bien_garantia (peidgarantia  rug.rug_garantias.id_garantia%type, pelongitud int) --cantidad  de caracteres a devolver)
returns text
language plpgsql
as $function$
declare

    vltipobienes text;
    vldescerror text;
    vllongitudcadena int;
    
    cursgarantia cursor is
    select distinct rgg.id_garantia, rgn.desc_tipo_bien
    from rug.rug_garantias rgg
    inner join rug_rel_gar_tipo_bien rgt
    on rgg.relacion_bien = rgt.relacion_bien
    inner join rug_cat_tipo_bien rgn
    on rgt.id_tipo_bien = rgn.id_tipo_bien
    where rgg.id_garantia = peidgarantia;
    
    vlidgarania rug.rug_garantias.id_garantia%type;
    vldesctipobien rug.rug_cat_tipo_bien.desc_tipo_bien%type;
    
begin

 
   begin
      --select initcap(desc_codigo) into vldescerror
       begin
       
       ------dbms_output.put_line(1);
       
       open cursgarantia;
        
       loop fetch cursgarantia into vlidgarania, vldesctipobien;
       exit when cursgarantia%notfound;
        
       vltipobienes :=  vldesctipobien || '. ' || vltipobienes;
       
       end loop;
       
       close cursgarantia;
       
       if pelongitud <> 0 then
       
           vllongitudcadena := length(vltipobienes);
           
           if vllongitudcadena > 85 then
           
           vltipobienes := substr(vltipobienes, 0, 85);
           vltipobienes := vltipobienes || '...';
           
           end if;
       
       end if;
                   
       vltipobienes:= nvl(vltipobienes, '   '); 
       
       ------ dbms_output.put_line(vltipobienes);
       
       end;
      
      
      exception when no_data_found then
            vldescerror := 'no se encontro el la garantia solicitada';            
            --sp_log('funobtmsgerr',14||' - '||substr(sqlcode||'-'||sqlerrm,1,1000));
   end;
   
      

--   if(substr(vltipobienes, length(trim(vltipobienes)),1) = ',' ) then
--   
--        vltipobienes := substr(vltipobienes, 0, length(trim(vltipobienes)) - 1);
--   
--   end if;
  
   
   --reg_param_pls(seq_rug_param_pls.nextval, 'tipo_bien_garantia', 'vltipobienes', vltipobienes, 'out');
   
   

   return vltipobienes;
   

exception
   when others then
      --sp_log('funobtmsgerr',substr(sqlcode||'-'||sqlerrm,1,1000));
      return null;
      

end;
$function$;


--------------------------------------------------------
--  DDL for Function TIPO_BIEN_GARANTIA_H
--------------------------------------------------------

drop function if exists rug.tipo_bien_garantia_h();
  create or replace function rug.tipo_bien_garantia_h (
                                                   peidgarantia     rug.rug_garantias.id_garantia%type,
                                                   peidtramite      rug.rug_garantias.id_ultimo_tramite%type,
                                                   pelongitud       int --cantidad  de caracteres a devolver
                                                   )
returns text 
language plpgsql
as $function$

declare
    vltipobienes text;
    vldescerror text;
    vllongitudcadena int;
    
    cursgarantia cursor is
    select rgg.id_garantia, rgn.desc_tipo_bien
    from rug_garantias_h rgg
    inner join rug_rel_gar_tipo_bien rgt
    on rgg.relacion_bien = rgt.relacion_bien
    and rgg.id_garantia_pend = rgt.id_garantia_pend
    inner join rug_cat_tipo_bien rgn
    on rgt.id_tipo_bien = rgn.id_tipo_bien
    where rgg.id_garantia = peidgarantia
    and rgg.id_ultimo_tramite = peidtramite;
    
    vlidgarania rug.rug_garantias.id_garantia%type;
    vldesctipobien rug.rug_cat_tipo_bien.desc_tipo_bien%type;
    
begin

 
   begin
      --select initcap(desc_codigo) into vldescerror
       begin
       
       ------dbms_output.put_line(1);
       
       open cursgarantia;
        
       loop fetch cursgarantia into vlidgarania, vldesctipobien;
       exit when cursgarantia%notfound;
        
       vltipobienes :=  vldesctipobien || '. ' || vltipobienes;
       
       end loop;
       
       close cursgarantia;
       
       if pelongitud <> 0 then
       
           vllongitudcadena := length(vltipobienes);
           
           if vllongitudcadena > 85 then
           
           vltipobienes := substr(vltipobienes, 0, 85);
           vltipobienes := vltipobienes || '...';
           
           end if;
       
       end if;
                   
       vltipobienes:= nvl(vltipobienes, '   '); 
       
       ------ dbms_output.put_line(vltipobienes);
       
       end;
      
      
      exception when no_data_found then
            vldescerror := 'no se encontro la garantia solicitada';            
            --sp_log('funobtmsgerr',14||' - '||substr(sqlcode||'-'||sqlerrm,1,1000));
      --reg_param_pls(seq_rug_param_pls.nextval, 'tipo_bien_garantia_h', 'vltipobienes', vldescerror, 'out');
   end;
   
      

--   if(substr(vltipobienes, length(trim(vltipobienes)),1) = ',' ) then
--   
--        vltipobienes := substr(vltipobienes, 0, length(trim(vltipobienes)) - 1);
--   
--   end if;
   
   
   --reg_param_pls(seq_rug_param_pls.nextval, 'tipo_bien_garantia_h', 'vltipobienes', vltipobienes, 'out');
   
   

   return vltipobienes;
   

exception
   when others then
      return null;
      --p_log('funobtmsgerr',substr(sqlcode||'-'||sqlerrm,1,1000));

end;
$function$;


--------------------------------------------------------
--  DDL for Function VALIDA_MAIL
--------------------------------------------------------

drop function if exists rug.valida_mail();
  create or replace function rug.valida_mail (l_user_name in text) -- 0 correcto 1 incorrecto
  returns int
  language plpgsql
  as $function$
  declare
  l_dot_pos    int;
  l_at_pos     int;
  l_str_length int;
begin
  l_dot_pos    := position('.' in l_user_name);
  l_at_pos     :=position('@' in l_user_name);
  l_str_length := length(l_user_name);
  if ((l_dot_pos = 0) or (l_at_pos = 0) or (l_dot_pos = l_at_pos + 1) or
     (l_at_pos = 1) or (l_at_pos = l_str_length) or
     (l_dot_pos = l_str_length))
  then
    return 1;
  end if;
  if position('.' in substr(l_user_name,l_at_pos)) = 0 then
    return 1;
  end if;
  return 0;
end;
$function$;


--------------------------------------------------------
--  DDL for Function XMLISWELLFORMED
--------------------------------------------------------

drop function if exists rug.xmliswellformed();
 create or replace function rug.xmliswellformed(p_xml text)
 returns integer
 language plpgsql
as $function$
  declare
     l_xml  text;
   begin
     l_xml := xmlparse(content p_xml);
     return 1;
   exception
     when others then
      return 0;
   end;
  $function$;




