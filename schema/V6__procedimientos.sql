


-- procedure rug.fin_vigencia_anotaciones()

drop procedure if exists rug.fin_vigencia_anotaciones;

create or replace procedure rug.fin_vigencia_anotaciones()
language plpgsql
as $procedure$
declare

c_anotaciones cursor is 
select id_anotacion,id_tramite_temp
        from rug_anotaciones_sin_garantia 
        where ADD_MONTHS(fecha_reg,VIGENCIA_ANOTACION) < current_date 
        and sit_anotacion = 'AC';

c_anota_con cursor is
select id_anotacion,id_tramite_temp,id_garantia
        from rug_anotaciones 
        where ADD_MONTHS(fecha_reg,VIGENCIA_ANOTACION) < current_date 
        and status_reg = 'AC';

id_anota int;
id_tram int;
id_garant int;
id_ultimo_tram int;
id_tram_upd int;

begin

    raise info 'buscando anotaciones:';

    open c_anotaciones;
    loop
     fetch c_anotaciones into id_anota,id_tram;
     exit when c_anotaciones%NOTFOUND;

        raise info 'actualizando anotacion:%', id_anota;

        update rug_anotaciones_sin_garantia set sit_anotacion = 'CA', status_reg = 'CA' where id_anotacion = id_anota;

        raise info 'actualizando tramite:%', id_tram;

        update tramites set STATUS_REG = 'CA' where id_tramite_temp = id_tram;

     end loop;
    close c_anotaciones;

    open c_anota_con;
    loop
     fetch c_anota_con into id_anota,id_tram,id_garant;
     exit when c_anota_con%NOTFOUND;

        raise info 'actualizando anotacion con garantia:%', id_anota;

        update rug_anotaciones set status_reg = 'CA' where id_anotacion = id_anota;

        raise info 'actualizando tramite:%', id_tram;

        update tramites set STATUS_REG = 'CA' where id_tramite_temp = id_tram;

        select t.id_tramite_temp 
        into id_ultimo_tram
        from rug_garantias g, tramites t
        where g.id_ultimo_tramite = t.id_tramite
        and id_garantia = id_garant;

        if id_ultimo_tram = id_tram then



            select id_ultimo_tramite 
            into id_tram_upd
            from ( 
                select id_registro, id_ultimo_tramite, ROW_NUMBER() OVER (ORDER BY fecha_reg desc,id_registro desc) rnum
                from rug_garantias_h 
                where id_garantia = id_garant
                and status_reg = 'AC'
                and id_ultimo_tramite <> (select id_tramite from tramites where id_tramite_temp = id_tram)
            ) rg
            where rg.rnum = 1;

            raise info 'actualizando ultimo tramite: % en garantia: %', id_tram, id_garant;

            update rug_garantias set id_ultimo_tramite = id_tram_upd where id_garantia = id_garant;

        end if;

     end loop;
    close c_anota_con;


    COMMIT;

    EXCEPTION

    WHEN OTHERS THEN      
        ROLLBACK;
end;
$procedure$;



-- procedure rug.reg_param_pls

drop procedure if exists rug.reg_param_pls;
create or replace procedure  rug.reg_param_pls 
( 
    peidregistro      in   rug.rug_param_pls.id_registro%type,
    peobjeto          in   rug.rug_param_pls.objeto%type,
    penomparametro    in   rug.rug_param_pls.nom_parametro%type,
    pevalor           in   rug.rug_param_pls.valor%type,
    petipoparametro   in   rug.rug_param_pls.tipo_parametro%type
)
language plpgsql
as $procedure$
declare
pstxresult text;

begin

insert into rug.rug_param_pls
values(peidregistro, peobjeto, penomparametro, pevalor, current_timestamp, 'AC', petipoparametro);     
                                      
      
 exception 
   when others then 
      pstxresult:= substr(sqlstate||':'||sqlerrm,1,250);
      rollback;  
  raise info '%', pstxresult;
end;
$procedure$;


-- procedure rug.reg_param_pls2

drop procedure if exists rug.reg_param_pls2;
create or replace procedure rug.reg_param_pls2 
( 
    peObjeto          IN   rug.rug_param_pls.objeto%TYPE,
    peNomParametro    IN   rug.rug_param_pls.nom_parametro%TYPE,
    peValor           IN   rug.rug_param_pls.valor%TYPE,
    peTipoParametro   IN   rug.rug_param_pls.tipo_parametro%TYPE
)
language plpgsql
as $procedure$
declare
psTxResult text;
--PRAGMA AUTONOMOUS_TRANSACTION;


begin

insert into rug.rug_param_pls
values(nextval('rug.rug_param_pls_seq')::int, peObjeto, peNomParametro, peValor, current_timestamp, 'AC', peTipoParametro);     
                              
      
  exception 
   when others then 
      psTxResult:= substr(sqlstate||':'||sqlerrm,1,3000);
      
      insert into rug.rug_param_pls
      values(nextval('rug.rug_param_pls_seq')::int, peObjeto, peNomParametro,psTxResult , current_timestamp, 'AC', peTipoParametro);   

end;
$procedure$;


-- procedure rug.sp_act_meses_garantia



drop procedure if exists rug.sp_act_meses_garantia;
create or replace procedure rug.sp_act_meses_garantia 
( peidtram      in rug.rug_rel_tram_inc_garan.id_tramite_temp%type,
  peidgarantia  in rug.rug_rel_tram_inc_garan.id_garantia_pend%type,
  pemeses       in rug.rug_garantias.meses_garantia%type,
  psresult      out    integer,   
  pstxresult    out    varchar
 )
language plpgsql
as $procedure$
declare
 vidgarantia int;
 vlgarantiastatus    char(2);
 ex_garantiacancelada  text := 'EXCEPTION';
 
begin

call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_ACT_MESES_GARANTIA', 'peIdTram', peidtram, 'IN');
call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_ACT_MESES_GARANTIA', 'peIdGarantia', peidgarantia, 'IN');
call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_ACT_MESES_GARANTIA', 'peMeses', pemeses, 'IN');

        begin
            select id_garantia_pend
            into vidgarantia
            from rug_rel_tram_inc_garan
            where id_tramite_temp = peidtram
            and   id_garantia_pend = peidgarantia;
            exception
               when no_data_found then
                 raise notice 'EL TRAMITE NO EXISTE';                
        end;
        
         begin
       --valido que la garantia no este cancelada
       select garantia_status
       into vlgarantiastatus
       from rug_garantias
       where id_garantia = peidgarantia;
       
       if vlgarantiastatus in ('CA', 'CR', 'CT') then
        raise notice '%', ex_garantiacancelada;
       end if;
       end;
        
        if vidgarantia is not null  then
           update rug_garantias
           set meses_garantia = pemeses
           where id_garantia = vidgarantia;        
            
        end if;

call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_ACT_MESES_GARANTIA', 'psResult', psresult, 'OUT');
call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_ACT_MESES_GARANTIA', 'psTxResult', pstxresult, 'OUT');        
        
    commit;
    
exception
when others  then 
   psresult := 15;       
    select desc_codigo
    into pstxresult
    from rug_cat_mensajes_errores
    where id_codigo = psresult;          
   raise notice '%', pstxresult;
   rollback;
call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_MODIFICA_GARANTIA', 'psResult', psresult, 'OUT');
call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_MODIFICA_GARANTIA', 'psTxResult', pstxresult, 'OUT');

end;
$procedure$;


-- procedure  rug.sp_act_vm_motor_rug


drop procedure if exists rug.sp_act_vm_motor_rug;
create or replace procedure rug.sp_act_vm_motor_rug() 
language plpgsql
as $procedure$
declare
fecha text;
fecha_fin text;


begin
select to_char(current_timestamp, 'yyyy-mm-dd hh24:mi:ss') into fecha;

    refresh materialized view vm_motor_rug;
    refresh materialized view vm_motor_rug_oper;
    refresh materialized view vm_motor_bienes;
    refresh materialized view vm_motor_deudor;
    refresh materialized view vm_motor_contrato;
    refresh materialized view vm_motor_otorgante;

select to_char(current_timestamp, 'yyyy-mm-dd hh24:mi:ss') into fecha_fin;

insert into bit_carga(
                            id_bit_carga
                            ,descripcion
                            ,inicio
                            ,fin)
                    values(
                            nextval(bit_carga_id_bit_carga_seq)
                            ,'prueba de carga = '||current_timestamp
                            ,fecha
                            ,fecha_fin);
    commit;
end;
$procedure$;




-- procedure rug.sp_agregar_mismo_deudor


drop procedure if exists rug.sp_agregar_mismo_deudor;
create or replace procedure rug.sp_agregar_mismo_deudor ( 
  peidtramite      in rug.rug_rel_tram_inc_garan.id_tramite_temp%type,
  peidotorgante  in rug.rug_rel_tram_inc_garan.id_garantia_pend%type,
  psresult      out    int,   
  pstxresult    out    text
 )
language plpgsql
as $procedure$
declare
/*
primer pl de abrahamcito chulo muajajaja
*/
vlperjuridica char(2);
vlnumpartes   int;
begin
    
  call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_AGREGAR_MISMO_DEUDOR', 'peIdTramite', peidtramite, 'IN');
  call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_AGREGAR_MISMO_DEUDOR', 'peIdOtorgante', peidotorgante, 'IN');

  select per_juridica
  into vlperjuridica
  from rug.rug_personas
  where id_persona = peidotorgante;
  
  select count (*)
  into vlnumpartes
  from rug.rug_rel_tram_inc_partes
  where id_tramite_temp = peidtramite and id_persona = peidotorgante and id_parte = 2;
  
  if vlnumpartes > 0 then
    update rug.rug_rel_tram_inc_partes
    set status_reg = 'AC'
    where id_tramite_temp = peidtramite and id_persona = peidotorgante and id_parte = 2;
  else
   insert into rug.rug_rel_tram_inc_partes
   values (peidtramite , peidotorgante,2, vlperjuridica,'AC', current_timestamp);  
  end if;

  commit;  
  psresult:=0;
  pstxresult:='Todo sin problema.!';
  call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_AGREGAR_MISMO_DEUDOR', 'psresult', psresult, 'OUT');
  call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_AGREGAR_MISMO_DEUDOR', 'pstxresult', pstxresult, 'OUT');
  exception 
  when others then
     raise notice 'Error en la transaccion: %', sqlerrm;
     raise notice 'Se deshacen las modificaciones';
     psresult:=909;
     pstxresult:= substr(sqlcode||':'||sqlerrm,1,250);
     call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_AGREGAR_MISMO_DEUDOR', 'psresult', psresult, 'OUT');
     call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_AGREGAR_MISMO_DEUDOR', 'pstxresult', pstxresult, 'OUT');
     rollback;

end;
$procedure$;




--procedure rug.sp_valida_folio_duplicado


drop procedure if exists rug.sp_valida_folio_duplicado;
create or replace procedure  rug.sp_valida_folio_duplicado 
(
      pe_tipo_persona      in rug.rug_personas.per_juridica%type,
      pe_id_nacionalidad   in rug.rug_personas.id_nacionalidad%type,
      pe_nifp              in rug.rug_personas.nifp%type,
      pe_rfc               in rug.rug_personas.rfc%type,
      pe_curp              in rug.rug_personas.curp_doc%type,
      pe_folio_mercantil   in rug.rug_personas.folio_mercantil%type,
      ps_result            out integer,
      ps_txresult          out text
) 
language plpgsql
as $procedure$
declare
      vlfolioelecexist int; 
      ex_texto    text := 'exception ex_texto';
      vexception int := 0;
    
begin

    begin
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_VALIDA_FOLIO_DUPLICADO', 'PE_TIPO_PERSONA', pe_tipo_persona, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_VALIDA_FOLIO_DUPLICADO', 'PE_TIPO_PERSONA', pe_id_nacionalidad, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_VALIDA_FOLIO_DUPLICADO', 'PE_TIPO_PERSONA', pe_nifp, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_VALIDA_FOLIO_DUPLICADO', 'PE_TIPO_PERSONA', pe_rfc, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_VALIDA_FOLIO_DUPLICADO', 'PE_TIPO_PERSONA', pe_curp, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_VALIDA_FOLIO_DUPLICADO', 'PE_TIPO_PERSONA', pe_folio_mercantil, 'IN');
    end;

    
    if pe_id_nacionalidad = 1 then
    
        if pe_tipo_persona = 'PF' and (pe_curp is not null or trim(pe_curp) <> '') and (pe_folio_mercantil is not null or trim(pe_folio_mercantil) <> '') then

         
         select count(folio_mercantil)
              into vlfolioelecexist
              from rug.rug_personas rper
             where trim(upper(curp_doc)) = trim(upper(pe_curp))
               and trim(upper(folio_mercantil)) = trim(upper(pe_folio_mercantil));
                           
              if vlfolioelecexist = 0 then
                      
                    ps_result := 138;
                    ps_txresult := rug.fn_mensaje_error(ps_result);            
                    ps_txresult := replace(ps_txresult,  '@vlfolioelectronico', pe_folio_mercantil);

                    raise notice '%', ex_texto; 
                    vexception = ;
                                           
              end if;
                
             
       elsif pe_tipo_persona = 'PM' and (pe_rfc is not null or trim(pe_rfc) <> '') and (pe_folio_mercantil is not null or trim(pe_folio_mercantil) <> '')then
                
               
             select count(folio_mercantil)
               into vlfolioelecexist
               from rug.rug_personas
              where trim(upper(rfc)) = trim(upper(pe_rfc))
                and trim(upper(folio_mercantil)) = trim(upper(pe_folio_mercantil));
                           
              if vlfolioelecexist = 0 then
                      
                    ps_result := 138;
                    ps_txresult := rug.fn_mensaje_error(ps_result);            
                    ps_txresult := replace(ps_txresult,  '@vlfolioelectronico', pe_folio_mercantil);

                    raise notice '%', ex_texto; 
                    vexception = 1;
                                           
              end if;

       end if; 
       
   elsif (pe_nifp is not null or trim(pe_nifp) <> '') and (pe_folio_mercantil is not null or trim(pe_folio_mercantil) <> '') then
                      
         select count(folio_mercantil)
              into vlfolioelecexist
              from rug.rug_personas
             where trim(upper(nifp)) = trim(upper(pe_nifp))
               and trim(upper(folio_mercantil)) = trim(upper(pe_folio_mercantil))
               and id_nacionalidad = pe_id_nacionalidad;
                           
              if vlfolioelecexist = 0 then
                          
                    ps_result := 138;
                    ps_txresult := rug.fn_mensaje_error(ps_result);            
                    ps_txresult := replace(ps_txresult,  '@vlfolioelectronico', pe_folio_mercantil);

                    raise notice '%', ex_texto; 
                    vexception = 1;
                                           
              end if;
   end if;
    
    ps_result   := 0;        
    ps_txresult := 'el folio no está asociado.';
 

      
    if vexception = 1  then
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_VALIDA_FOLIO_DUPLICADO', 'psResult', ps_result, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_VALIDA_FOLIO_DUPLICADO', 'psTxResult', ps_txresult, 'OUT');
      rollback;
     end if;
exception

    when others then
      ps_result  := 999;   
      ps_txresult:= substr(sqlcode||':'||sqlerrm,1,250);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_VALIDA_FOLIO_DUPLICADO', 'ps_Result', ps_result, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq')::int, 'SP_VALIDA_FOLIO_DUPLICADO', 'ps_TxResult', ps_txresult, 'OUT');
      rollback; 
end;
$procedure$;




-- procedure rug.sp_genera_folio_electronico


drop procedure if exists rug.sp_genera_folio_electronico;
create or replace procedure rug.sp_genera_folio_electronico (
   psfolioelectronico   out varchar,
   psresult             out integer,
   pstxresult           out varchar
)
language plpgsql
as $procedure$
declare
   contador    int;
   letrasiguiente       char (1);
   vlista      text;
   vinicia     int;
   vfinal      int;
   vcuenta     int;
   vfolioseq   text;

   uno         char (1);
   dos         char (1);
   tres        char (1);
   cuatro      char (1);

   --pragma autonomous_transaction;
begin
   vlista := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0';
   vinicia := null;
   vfinal := null;
   vcuenta := 0;

   call rug.reg_param_pls (nextval('rug.rug_param_pls_id_registro_seq')::int,
                  'SP_GENERA_FOLIO_ELECTRONICO_V2',
                  'Ejecutando',
                  '',
                  'IN');

   select   count ( * ) into vcuenta from rug.rug_folio_control;

   if vcuenta < 4
   then
   
      delete from rug.rug_folio_control;
      
      --si no tiene letra la tabla empieza con a

      insert into rug.rug_folio_control (idfoliocontrol, fecha, letra)
        values   (1, current_timestamp, '0');

      insert into rug.rug_folio_control (idfoliocontrol, fecha, letra)
        values   (2, current_timestamp, '0');

      insert into rug.rug_folio_control (idfoliocontrol, fecha, letra)
        values   (3, current_timestamp, '0');

      insert into rug.rug_folio_control (idfoliocontrol, fecha, letra)
        values   (4, current_timestamp, '0');


     
   end if;

       --trae la letra en la que se quedo
       select   coalesce(letra, '0')
         into   uno
         from   rug.rug_folio_control
        where   idfoliocontrol = 1
   for update;


   --aumenta letra para la siguiente
   vinicia := position(uno in vlista);
   vfinal := vinicia + 1;
 

   uno := trim (substr (vlista, vfinal, 1))::text;

   --dbms_output.put_line('letra_siguiente ' || uno);

   update   rug.rug_folio_control
      set   letra = uno::text
    where   idfoliocontrol = 1;



   select   coalesce(letra, '0')
     into   dos
     from   rug.rug_folio_control
    where   idfoliocontrol = 2 for update;


   if (uno = 'Z')
   then
      --aumenta letra para la siguiente
      vinicia := position(dos in vlista);
      vfinal := vinicia + 1;

      letrasiguiente := trim (substr (vlista, vfinal, 1))::text;

      raise info 'letra_siguiente uno %', letrasiguiente;

      update   rug.rug_folio_control
         set   letra = letrasiguiente::text
       where   idfoliocontrol = 2;

      
   end if;

   select   coalesce(letra, '0')
     into   tres
     from   rug.rug_folio_control
    where   idfoliocontrol = 3 for update;

   if (dos = 'Z' and uno = 'Z')
   then
      --aumenta letra para la siguiente
      vinicia := position (tres in vlista);
      vfinal := vinicia + 1;

      letrasiguiente := trim (substr (vlista, vfinal, 1))::text;

      --dbms_output.put_line('letra_siguiente ' || uno);

      update   rug.rug_folio_control
         set   letra = letrasiguiente::text
       where   idfoliocontrol = 3;

      
   end if;


   select   coalesce(letra, '0')
     into   cuatro
     from   rug.rug_folio_control
    where   idfoliocontrol = 4 for update;

   if (tres = 'Z' and dos = 'Z' and uno = 'Z')
   then
      --aumenta letra para la siguiente
      vinicia := position(cuatro in vlista);
      vfinal := vinicia + 1;

      letrasiguiente := trim (substr (vlista, vfinal, 1))::text;

      --dbms_output.put_line('letra_siguiente ' || uno);

      update   rug.rug_folio_control
         set   letra = letrasiguiente::text
       where   idfoliocontrol = 4;

      
   end if;


   vfolioseq := concat(cuatro, tres, dos, uno);

   psfolioelectronico = concat('R', to_char (current_date, 'yyyymmdd'), vfolioseq)::text;
  

   psresult := 0;
   pstxresult := rug.fn_mensaje_error (psresult);

   call rug.reg_param_pls (nextval('rug.rug_param_pls_id_registro_seq')::int,
                  'SP_GENERA_FOLIO_ELECTRONICO_V2',
                  'psFolioElectronico',
                  psfolioelectronico::text,
                  'OUT');

exception
   when others
   then
      psresult := 999;
      pstxresult = substr (sqlstate || ':' || sqlerrm, 1, 250);

      if sqlstate = '-8177'
      then
         psresult := 8177;
      end if;

     
      call rug.reg_param_pls (nextval('rug.rug_param_pls_id_registro_seq')::int,
                     'SP_GENERA_FOLIO_ELECTRONICO_V2',
                     'psFolioElectronico',
                     psfolioelectronico::text,
                     'OUT');
      call rug.reg_param_pls (nextval('rug.rug_param_pls_id_registro_seq')::int,
                     'SP_GENERA_FOLIO_ELECTRONICO_V2',
                     'psResult',
                     psresult::text,
                     'OUT');
      call rug.reg_param_pls (nextval('rug.rug_param_pls_id_registro_seq')::int,
                     'SP_GENERA_FOLIO_ELECTRONICO_V2',
                     'psTxResult',
                     pstxresult::text,
                     'OUT');
      raise notice '%', pstxresult;
      rollback;
end;
$procedure$;



--procedure rug.sp_modifica_perfil

drop procedure if exists rug.sp_modifica_perfil;
create or replace procedure rug.sp_modifica_perfil
(
    peidpersona     in  int,
    peidgrupo       in  int,
    psresult       out  int,   
    pstxresult     out  text
) 
language plpgsql
as $procedure$
declare


vlidgrupo           int;
vlcveusuario        text;
vlidperfil          int;

--exceptions
ex_errparametro    text := 'exception ex_errparametro';


begin


call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'peIdpersona', peidpersona, 'IN');
call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'peidgrupo', peidgrupo, 'IN');

    if(peidgrupo not in (1,2)) then
        begin
            psresult:= -1;
            pstxresult := 'Error al asignar grupo, solo se puede modificar al grupo Acreedor y/o Ciudadano';
            raise notice '%', ex_errparametro;
           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'psResult', psresult, 'OUT');
           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'psTxResult', pstxresult, 'OUT');    

        end;
    end if;
    
    
    begin
      
         
          select id_grupo, id_perfil
          into vlidgrupo, vlidperfil
          from rug.v_usuario_sesion_rug
         where id_persona =  peidpersona;
         
         
        
        exception 
          when others  then
            psresult:= -1;
            pstxresult := 'El usuario no existe en el sistema o no tiene asignado un grupo Acreedor o Ciudadano';
            raise notice '%', ex_errparametro;          
       call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'psResult', psresult, 'OUT');
       call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'psTxResult', pstxresult, 'OUT');    

    end; 


 begin
        select cve_usuario
          into vlcveusuario
          from rug.rug_secu_usuarios
         where id_persona = peidpersona;
         -- and id_grupo in (1,2);
        
        exception 
          when others  then
            psresult:= -1;
            pstxresult := 'El usuario no existe en el sistema o no tiene asignado un grupo Acreedor o Ciudadano';
            raise notice '%', ex_errparametro;          
       call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'psResult', psresult, 'OUT');
       call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'psTxResult', pstxresult, 'OUT');    

    end; 



if  vlidperfil != 4 and vlidgrupo != 15 then 
    if peidgrupo = 1 then
        begin    
            
            update rug.rug_secu_usuarios
            set cve_acreedor = vlcveusuario, id_grupo = 1
             where cve_usuario = vlcveusuario;
            
            
            update rug.rug_secu_perfiles_usuario
            set cve_perfil = 'ACREEDOR'
             where cve_usuario = vlcveusuario;
        end;
  end if;
    
    
    --cand (vlcveusuario <> 4 or vlcveusuario <> 5 )) then
    if peidgrupo = 2 then
        begin    
            update rug.rug_secu_usuarios
            set cve_acreedor = null, id_grupo = 2
             where cve_usuario = vlcveusuario;
            
            
            update rug.rug_secu_perfiles_usuario
            set cve_perfil = 'CIUDADANO'
            where cve_usuario = vlcveusuario;
        end;
    end if;
        
end if;      
    psresult := 0;
    pstxresult := 'Actualizacion Exitosa';


call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'psResult', psresult, 'OUT');
call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'psTxResult', pstxresult, 'OUT');    
          
     exception 
   when others then
      psresult  := 999;   
      pstxresult:= substr(sqlstate||':'||sqlerrm,1,250);
      rollback;
call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'psResult', psresult, 'OUT');
call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_MODIFICA_PERFIL', 'psTxResult', pstxresult, 'OUT');    

end;
$procedure$;



-- procedure rug.sp_anotac_seg_inc_csg_ins_h

drop procedure if exists rug.sp_anotac_seg_inc_csg_ins_h;
create or replace procedure rug.sp_anotac_seg_inc_csg_ins_h 
(       p_id_anotacion_temp         in    int
      , psresult                    out   int
      , pstxresult                  out   text
)
language plpgsql
as $procedure$
declare
    ex_error            text := 'exception ex_error';
    
begin 

    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ANOTAC_SEG_INC_CSG_INS_H','P_ID_TRAMITE_PADRE', p_id_anotacion_temp, 'IN');
    
    insert into rug.rug_anotaciones_seg_inc_csg_h (
           id_anotacion_temp_h,
           id_anotacion_temp,   id_tramite,             id_tramite_padre, 
           id_garantia,         id_tipo_tramite,        id_status, 
           id_usuario,          id_persona_anotacion,    
           pers_juridica,       autoridad_autoriza,     anotacion, 
           resolucion,          vigencia,               solicitante_rectifica, 
           status_reg) 
    select nextval('rug.rug_anotaciones_seg_inc_csg_h_id_anotacion_temp_h_seq')
         , r.id_anotacion_temp, r.id_tramite,           r.id_tramite_padre, 
           r.id_garantia,       ti.id_tipo_tramite,     ti.id_status_tram, 
           usu.id_persona,      oto.id_persona, --r.id_persona_anotacion, 
           oto.per_juridica,    r.autoridad_autoriza,   r.anotacion, 
           r.resolucion,        r.vigencia,             r.solicitante_rectifica, 
           r.status_reg
      from rug.rug_anotaciones_seg_inc_csg r
     inner join rug.tramites_rug_incomp ti
        on ti.id_tramite_temp = r.id_anotacion_temp
      left join rug.rug_rel_tram_inc_partes oto
        on oto.id_tramite_temp = r.id_anotacion_temp --- otorgante 
       and oto.id_parte = 1
      left join rug.rug_rel_tram_inc_partes usu      --- usuario
        on usu.id_tramite_temp = r.id_anotacion_temp
       and usu.id_parte = 5
     where r.id_anotacion_temp = p_id_anotacion_temp;     
     
   psresult := 0;
   pstxresult := 'Histórico guardado.';     
     
     
   call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ANOTAC_SEG_INC_CSG_INS_H', 'psResult', psresult, 'OUT');
   call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ANOTAC_SEG_INC_CSG_INS_H', 'psTxResult', pstxresult, 'OUT');
   
exception
    when others
    then
        psresult := 999;
        pstxresult := substr (sqlstate || ':' || sqlerrm, 1, 250);
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ANOTAC_SEG_INC_CSG_INS_H', 'psResult', psresult, 'OUT');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ANOTAC_SEG_INC_CSG_INS_H', 'psTxResult', pstxresult, 'OUT');
    
end;
$procedure$;



-- procedure rug.sp_alta_catalogo_palabras


drop procedure if exists rug.sp_alta_catalogo_palabras;
create or replace procedure rug.sp_alta_catalogo_palabras (
   peidtramite       in     int,
   peidtipotramite   in     int,
   psresult             out int,
   pstxresult           out text
)
language plpgsql
as $procedure$
declare
   vldescgarantia     text;
   vlidgarantia       int;  
   vlidtramitetemp    int;
   vlidgarantiapend   int;
begin
   select   id_tramite_temp
     into   vlidtramitetemp
     from   rug.tramites
    where   id_tramite = peidtramite;

   --se borran los tramites de la garantia
   if peidtipotramite in (2, 6, 7, 8
                                 , 23 ) -- /* ggr 23.08.2013   mmsecn2013-82 */
   then
      begin
         select   id_garantia
           into   vlidgarantia
           from   rug.rug_rel_tram_garan
          where   id_tramite = peidtramite;

         if vlidgarantia is not null
         then
            delete from   rug.rug_tbl_busqueda
                  where   id_tramite in (select   id_tramite
                                           from   rug.v_operaciones_garantia
                                          where   id_garantia = vlidgarantia);
         end if;
      exception
         when no_data_found
         then
            raise notice 'El tramite No existe';
      end;
   end if;
   
   --se borran los tramites anotación sin garantia de la búsqueda cuando hay una cancelacion -- /* ggr 27.08.2013   mmsecn2013-81 */
   if peidtipotramite in ( 27 ) 
   then
      begin

        
        delete 
          from   rug.rug_tbl_busqueda
         where   id_tramite = peidtramite
            or   id_tramite in (select id_anotacion_padre
                                  from rug.v_anotacion_tramites 
                                 where id_status_tram = 3
                                   and id_tramite = peidtramite);
      exception
         when no_data_found
         then
            raise notice 'El tramite No existe';
      end;
   end if;

   --se inserta la nueva descripcion a la tabla de busqueda
   if peidtipotramite in (1, 2, 6, 7, 8)
   then
      select   id_garantia_pend
        into   vlidgarantiapend
        from   rug.rug_rel_tram_inc_garan
       where   id_tramite_temp = vlidtramitetemp;

      select   desc_garantia
        into   vldescgarantia
        from   rug.rug_garantias_pendientes
       where   id_garantia_pend = vlidgarantiapend;
       
   elsif peidtipotramite = 3
   then
      select   desc_bienes
        into   vldescgarantia
        from   rug.avisos_prev
       where   id_tramite_temp = vlidtramitetemp;
       
   elsif peidtipotramite = 10
   then
      select   anotacion
        into   vldescgarantia
        from   rug.rug_anotaciones_sin_garantia
       where   id_tramite_temp = vlidtramitetemp;
       
   /* ggr  - 24.04.13  -  mmsecn2013-81   mmsecn2013-82   inicio */       
   elsif peidtipotramite in (28) then
   
      select   anotacion 
        into   vldescgarantia
        from   rug.rug_anotaciones_seg_inc_csg
       where   id_anotacion_temp = vlidtramitetemp;
       
   /* ggr  - 24.04.13  -  mmsecn2013-81  mmsecn2013-82   fin */
   end if;


   insert into rug.rug_tbl_busqueda
     values   (peidtramite, vldescgarantia);

   psresult := 0;
   pstxresult := 'Proceso exitoso';
exception
   when others
   then
      psresult := 999;
      pstxresult := substr (sqlstate || ':' || sqlerrm, 1, 250);
      rollback;
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'),
                     'SP_ALTA_CATALOGO_PALABRAS',
                     'psResult',
                     psresult,
                     'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'),
                     'SP_ALTA_CATALOGO_PALABRAS',
                     'psResult',
                     pstxresult,
                     'OUT');
      raise notice '%', pstxresult;
end;
$procedure$;






-- procedure rug.sp_alta_bitacora_tramite2


drop procedure if exists rug.sp_alta_bitacora_tramite2;
create or replace procedure rug.sp_alta_bitacora_tramite2 
(
  peidtramitetemp            in  rug.rug_bitac_tramites.id_tramite_temp%type,
  peidstatus                 in  rug.rug_bitac_tramites.id_status%type,
  peidpaso                   in  rug.rug_bitac_tramites.id_paso%type,
  pefechacreacion            in  rug.tramites.fecha_creacion%type,
  pebanderafecha             in  char, --bandera que indica si el pl plasma la fecha con el current_timestamp o usa la que manda en pefechacreacion, valores posibles v o f
  psresult                  out  int,
  pstxresult                out  text
)
language plpgsql
as $procedure$
declare

vlbandera               int;
vltramitetempfirmo      int;
vlidusuariofirmo        int;
vldomicilio             int;
vlid_domicilio          int;
vidcancelacion          int;
vlidinscripcion         int;
vltelefono              int;
vlidmoneda              int;
vlcontador              int;
vlidacreedor            int;
vlidacreedornuevo       int;
vlidtramite             int;
vlidtramitetemp         int;
vlidgarantiatemp        int;
vlidgarantiah           int;
vlidgarantia            int;
vlidrelacion            int;
vlidgarantiaanterior    int;
vlidcounttramitetemp    int;
vlidstatustram          int;
vlidpersonatramite12    int;
vlresult                int;
vlidusuario             int;
vlidanotacion           int;
vlcanctrans             int;
vlidgarmodtrans         int;
vlidrelmodtrans         int;
vlacreedororig          int;
vlacreedormodif         int;
vlrelbientrans          int;
vlidpersonah            int;
vlcveperfilusu          text;
vltipopersona           text;
vlgarantiastatus        text;
vltextresult            text;
vlcountstattram         int;
vlidpersona             int;
v_id_tramite_padre      rug.tramites.id_tramite%type;
regtramitesincomp       record;
reggarantiastemp        record;
regincomppartes        record;

regacreedor             record;
ex_errparametro         text := 'exception ex_errparametro';
ex_tramiteterminado     text := 'exception ex_tramiteterminado';
ex_firmacertificado     text := 'exception ex_firmacertificado';

 curspartesicomp cursor is
select   id_tramite,
         id_persona,
         id_parte,
         desc_parte,
         per_juridica,
         nombre,
         nombre_persona,
         ap_paterno_persona,
         ap_materno_persona,
         razon_social,
         folio_mercantil,
         rfc,
         curp,
         id_domicilio,
         calle,
         num_exterior,
         num_interior,
         id_colonia,
         cve_colonia,
         id_localidad,
         cve_localidad,
         cve_deleg_municip,
         nom_deleg_municip,
         cve_estado,
         nom_estado,
         cve_pais,
         nom_pais,
         codigo_postal,
         id_nacionalidad,
         e_mail,
         telefono,
         extension,
         curp_doc,
         localidad,
         nom_colonia,
         id_pais_residencia
  from   rug.v_tramites_incomp_partes
 where   id_tramite = peidtramitetemp;
curspartesicomp_rec  record;
begin

    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'peIdTramiteTemp', peidtramitetemp, 'IN');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'peIdStatus', peidstatus, 'IN');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'peIdPaso', peidpaso, 'IN');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'peFechaCreacion', pefechacreacion, 'IN');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'peBanderaFecha', pebanderafecha, 'IN');

    /* obtiene informacion del registro de tramites incompletos */
    select id_persona, id_tipo_tramite, fech_pre_inscr, fecha_inscr
    into regtramitesincomp.id_persona, regtramitesincomp.id_tipo_tramite, regtramitesincomp.fech_pre_inscr, regtramitesincomp.fecha_inscr
    from rug.tramites_rug_incomp
    where id_tramite_temp= peidtramitetemp;

    select count(*)
    into vlidcounttramitetemp
    from rug.tramites_rug_incomp
    where id_tramite_temp = peidtramitetemp;


    if vlidcounttramitetemp > 0 then

        select id_status_tram
        into vlidstatustram
        from rug.tramites_rug_incomp
        where id_tramite_temp = peidtramitetemp;

        if peidstatus = 3 then

            if peidpaso = 100 then

                update rug.rug_bitac_tramites
                set fecha_status = pefechacreacion
                where id_tramite_temp = peidtramitetemp and id_status = 3;
                commit;
                raise notice '%', ex_firmacertificado;
               raise notice 'FIN';
    psresult := 0;
    pstxresult := rug.fn_mensaje_error(psresult);
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psResult', psresult, 'OUT');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psTxResult', pstxresult, 'OUT');


            else

             if vlidstatustram = 3 then

                 raise notice '%', ex_tramiteterminado;
                psresult   :=11;
    pstxresult := rug.fn_mensaje_error(psresult);
    rollback;
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psResult', psresult, 'OUT');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psTxResult', pstxresult, 'OUT');
    raise notice '%', pstxresult;

             end if;

            end if;

        end if;

    end if;

    if (peidstatus = 3)  then /* operacion terminada, se genera un tramite permanente */
    begin

        vlidtramite:=  nextval('rug.tramites_id_tramite_seq');           /* secuencia de la tabla de tramites */

        /* se da de alta el tramite definitivo  */
        insert into rug.tramites(id_tramite, id_persona, id_tipo_tramite, fech_pre_inscr, fecha_inscr,id_status_tram, fecha_creacion,
                                 id_tramite_temp, id_paso,fecha_status, status_reg)
        values (vlidtramite, regtramitesincomp.id_persona, regtramitesincomp.id_tipo_tramite, regtramitesincomp.fech_pre_inscr,
                regtramitesincomp.fecha_inscr,peidstatus, current_timestamp, peidtramitetemp, peidpaso,current_timestamp, 'AC');

        /* cambia es status de tramite de incompleto a terminado */
        update rug.tramites_rug_incomp
        set status_reg='IN',
            id_status_tram = peidstatus,
            id_paso = peidpaso,
            fecha_status = current_timestamp
        where id_tramite_temp=peidtramitetemp;


        begin

        --open curspartesicomp;
           --loop
              for regincomppartes in curspartesicomp loop
            
                vlidpersona := regincomppartes.id_persona;

                select count(*)
                  into vlcontador
                  from rug.tramites_rug_incomp
                 where id_tramite_temp = peidtramitetemp
                   and id_tipo_tramite = 19;


                if(vlcontador != 0) then

                     select id_acreedor
                       into vlidpersona
                       from rug.rug_rel_modifica_acreedor
                      where id_tramite_temp =  peidtramitetemp
                        and status_reg = 'AC'
                        and b_firmado = 'N';

                end if;


                insert into rug.rug_personas_h
                values(vlidtramite, regincomppartes.id_parte, vlidpersona,
                regincomppartes.nombre_persona, regincomppartes.ap_paterno_persona, regincomppartes.ap_materno_persona,
                regincomppartes.razon_social, regincomppartes.per_juridica, regincomppartes.id_nacionalidad,
                regincomppartes.rfc, regincomppartes.curp, regincomppartes.curp_doc, regincomppartes.email,
                regincomppartes.folio_mercantil, null, regincomppartes.desc_parte
                ,trim(upper(trim(regincomppartes.nombre_persona) || ' ' || trim(regincomppartes.ap_paterno_persona) || ' ' || trim(regincomppartes.ap_materno_persona)) || ' ' || trim(upper(regincomppartes.razon_social)))
                );





                select count(*)
                  into vldomicilio
                  from rug.rug_domicilios
                 where id_domicilio = regincomppartes.id_domicilio;

                if(vldomicilio > 0) then

                    insert into rug.rug_domicilios_h
                    values(vlidtramite, regincomppartes.id_parte, vlidpersona,
                    regincomppartes.id_domicilio, regincomppartes.calle, regincomppartes.num_exterior,
                    regincomppartes.num_interior, regincomppartes.id_colonia, regincomppartes.cve_colonia,
                    regincomppartes.nom_colonia, regincomppartes.cve_deleg_municip, regincomppartes.nom_deleg_municip,
                    regincomppartes.cve_estado, regincomppartes.nom_estado, regincomppartes.codigo_postal, regincomppartes.cve_pais,
                    regincomppartes.nom_pais, regincomppartes.localidad, regincomppartes.cve_localidad, regincomppartes.id_localidad);

                else

                    insert into rug.rug_domicilios_ext_h
                    (select vlidtramite, regincomppartes.id_parte, vlidpersona, id_domicilio, regincomppartes.id_pais_residencia,
                                  ubica_domicilio_1, ubica_domicilio_2, poblacion, zona_postal
                       from rug.rug_domicilios_ext
                      where id_domicilio = regincomppartes.id_domicilio);

                end if;


                insert into rug.rug_telefonos_h
                select vlidtramite, regincomppartes.id_parte, vlidpersona,
                       null, telefono,extension, fecha_reg, status_reg
                from rug.rug_telefonos
                where id_persona =  regincomppartes.id_persona;

            end loop;
        --close curspartesicomp;


           insert into rug.rug_personas_h
           select vlidtramite, 5,  id_persona, nombre_persona, ap_paterno, ap_materno, null, 'PF', 1, rfc, null, null,
           cve_usuario,
           null, cve_perfil, 'USUARIO'
           ,trim(upper(trim(nombre_persona) || ' ' || trim(ap_paterno || ' ' || trim(ap_materno) || ' ' || trim(upper(null))) ))
           from rug.v_usuario_login_rug
           where id_persona = regtramitesincomp.id_persona;


        if ( regtramitesincomp.id_tipo_tramite != 5) then

            if (regtramitesincomp.id_tipo_tramite in (20,21)) then
                vlidusuariofirmo := 0;
            else

                vlcontador := 0;

                select count(*)
                  into vlcontador
                  from rug.rug_firma_masiva
                 where id_tramite_temp = peidtramitetemp;

                 -- para firma masiva se objtiene el tramite de firma masiva para obtener el usuario que firma dicho tramite

                 vltramitetempfirmo := peidtramitetemp;


                 if(vlcontador > 0) then

                    select id_firma_masiva
                      into vltramitetempfirmo
                      from rug.rug_firma_masiva
                     where id_tramite_temp = peidtramitetemp;

                 end if;

                select case when regtramitesincomp.id_tipo_tramite = 21 then 0 else id_usuario_firmo end
                   into vlidusuariofirmo
                   --from doctos_tram_firmados_rug
                  from rug.v_tramites_firma
                  where id_tramite_temp = vltramitetempfirmo;
            end if;


             insert into rug.rug_personas_h
             select vlidtramite, 6,  id_persona, nombre_persona, ap_paterno, ap_materno, null, 'PF', 1, rfc, null, null,
                    cve_usuario, null, cve_perfil, (select desc_parte
                                                      from rug.rug_partes
                                                     where id_parte = 6) desc_parte, 
                    trim(upper(trim(nombre_persona) || ' ' || trim(ap_paterno || ' ' || trim(ap_materno) || ' ' || trim(upper(null))) ))                                
             from rug.v_usuario_login_rug
             where id_persona = vlidusuariofirmo;


        end if;

           vlidacreedor      := null;

        end;

        case

            when regtramitesincomp.id_tipo_tramite=1  then /* inscripcion */ /* entrada id_garantia_pend */
            begin

                /* se obtiene el id_garantia_temp, y lo datos a modificar */
                vlidgarantia:=nextval('rug.garantias_id_garantia_seq');           /* secuencia de la tabla de garantias */
                vlidrelacion:= nextval('rug.rug_rel_garantia_partes_id_relacion_seq');           /* secuencia de la tabla rug_reg_garantia_partes */

                select b.id_tipo_garantia, b.num_garantia, b.desc_garantia, b.meses_garantia, b.id_persona, b.id_anotacion, b.id_relacion,
                       b.relacion_bien, b.valor_bienes, b.tipos_bienes_muebles, b.ubicacion_bienes, b.folio_mercantil, b.path_doc_garantia,
                       b.otros_terminos_garantia, b.fecha_inscr, b.fecha_fin_gar, b.vigencia, b.garantia_certificada, b.garantia_status, b.id_ultimo_tramite,
                       b_ultimo_tramite, b.monto_maximo_garantizado, b.id_garantia_pend, b.id_moneda, b.instrumento_publico, b.cambios_bienes_monto, b.no_garantia_previa_ot
                  into reggarantiastemp.id_tipo_garantia, reggarantiastemp.num_garantia, reggarantiastemp.desc_garantia,
                       reggarantiastemp.meses_garantia, reggarantiastemp.id_persona, reggarantiastemp.id_anotacion, reggarantiastemp.id_relacion,
                       reggarantiastemp.relacion_bien, reggarantiastemp.valor_bienes, reggarantiastemp.tipos_bienes_muebles, reggarantiastemp.ubicacion_bienes,
                       reggarantiastemp.folio_mercantil, reggarantiastemp.path_doc_garantia, reggarantiastemp.otros_terminos_garantia, reggarantiastemp.fecha_inscr,
                       reggarantiastemp.fecha_fin_gar, reggarantiastemp.vigencia, reggarantiastemp.garantia_certificada, reggarantiastemp.garantia_status,
                       reggarantiastemp.id_ultimo_tramite, reggarantiastemp.b_ultimo_tramite, reggarantiastemp.monto_maximo_garantizado, reggarantiastemp.id_garantia_pend,
                       reggarantiastemp.id_moneda, reggarantiastemp.instrumento_publico, reggarantiastemp.cambios_bienes_monto, reggarantiastemp.no_garantia_previa_ot
                  from rug.rug_garantias_pendientes b, rug.rug_rel_tram_inc_garan c
                 where b.id_garantia_pend=c.id_garantia_pend
                   and c.id_tramite_temp=peidtramitetemp;

                insert into rug.rug_garantias
                            (id_garantia,id_tipo_garantia, num_garantia, desc_garantia, meses_garantia, id_persona, id_anotacion, id_relacion,
                             relacion_bien, valor_bienes, tipos_bienes_muebles, ubicacion_bienes, folio_mercantil, path_doc_garantia,
                             otros_terminos_garantia, fecha_inscr, fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                             b_ultimo_tramite, monto_maximo_garantizado, id_garantia_pend, fecha_reg, status_reg, id_moneda, instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot)
                values (vlidgarantia, reggarantiastemp.id_tipo_garantia, reggarantiastemp.num_garantia, reggarantiastemp.desc_garantia,
                        reggarantiastemp.meses_garantia, reggarantiastemp.id_persona, reggarantiastemp.id_anotacion, vlidrelacion,
                        reggarantiastemp.relacion_bien, reggarantiastemp.valor_bienes, reggarantiastemp.tipos_bienes_muebles, reggarantiastemp.ubicacion_bienes,
                        reggarantiastemp.folio_mercantil, reggarantiastemp.path_doc_garantia, reggarantiastemp.otros_terminos_garantia, reggarantiastemp.fecha_inscr,
                        reggarantiastemp.fecha_fin_gar, reggarantiastemp.vigencia, reggarantiastemp.garantia_certificada, reggarantiastemp.garantia_status,
                        vlidtramite, reggarantiastemp.b_ultimo_tramite, reggarantiastemp.monto_maximo_garantizado, reggarantiastemp.id_garantia_pend, current_timestamp, 'AC',
                        reggarantiastemp.id_moneda, reggarantiastemp.instrumento_publico, reggarantiastemp.cambios_bienes_monto,reggarantiastemp.no_garantia_previa_ot);

                insert into rug.rug_rel_tram_garan(id_tramite,id_garantia,b_tramite_completo, status_reg, fecha_reg)
                values( vlidtramite,vlidgarantia, 'S', 'AC', current_timestamp);

                vlidgarantiah:= nextval('rug.rug_garantias_h_id_registro_seq');

                insert into rug.rug_garantias_h(id_registro, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                                          id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                                          ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                                          fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                                          b_ultimo_tramite, monto_maximo_garantizado,fecha_modif_reg, fecha_reg, status_reg, id_garantia_pend, id_moneda, instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot)
                select vlidgarantiah, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                       id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                       ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                       fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                       b_ultimo_tramite, monto_maximo_garantizado, current_timestamp, current_timestamp, 'AC', id_garantia_pend, id_moneda, instrumento_publico, cambios_bienes_monto,rug_garantias.no_garantia_previa_ot
                  from rug.rug_garantias
                 where id_garantia = vlidgarantia;

                begin

                    insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                    select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                      from rug.rug_rel_tram_inc_partes
                     where id_tramite_temp = peidtramitetemp
                       and status_reg = 'AC';

                exception
                  when no_data_found then
                    raise notice 'No Existe personas asociadas al tramite en la tabla RUG.RUG_REL_TRAM_INC_PARTES';
                end;

                insert into rug.rug_rel_garantia_partes(id_garantia, id_persona, id_parte, id_relacion, fecha_reg, status_reg)
                select vlidgarantia, id_persona, id_parte,vlidrelacion, current_timestamp, 'AC'
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp
                   and status_reg = 'AC';

            end; /* case 1 */


            when regtramitesincomp.id_tipo_tramite= 2  then /* anotacion con garantia */
            begin

           raise notice 'Entra al tipo tramite 2';

                /* se obtiene el id_garantia_temp, y lo datos a modificar */

                vlidrelacion:= nextval('rug.rug_rel_garantia_partes_id_relacion_seq');

                select rgp.id_garantia_pend, rgp.id_garantia_modificar, rgp.vigencia
                  into reggarantiastemp.id_garantia_pend, reggarantiastemp.id_garantia_modificar, reggarantiastemp.vigencia
                  from rug.rug_garantias_pendientes rgp
                  left join rug.rug_rel_tram_inc_garan rrl
                    on rgp.id_garantia_pend = rrl.id_garantia_pend
                 where rrl.id_tramite_temp = peidtramitetemp;

                select id_anotacion
                  into vlidanotacion
                  from rug.rug_anotaciones
                 where id_tramite_temp =  peidtramitetemp;

                update rug.rug_garantias a
                   set a.garantia_status='AC',
                       a.fecha_reg = current_timestamp,
                       a.status_reg = 'AC',
                       a.id_ultimo_tramite = vlidtramite,
                       a.id_anotacion = vlidanotacion,
                       a.id_relacion = vlidrelacion
                 where a.id_garantia = reggarantiastemp.id_garantia_modificar;

                /* se inserta en un historico */
                vlidgarantiah:= nextval('rug.rug_garantias_h_id_registro_seq');

                insert into rug.rug_garantias_h(id_registro, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                                id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                                ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                                fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                                b_ultimo_tramite, monto_maximo_garantizado,fecha_modif_reg, fecha_reg, status_reg, id_garantia_pend, id_moneda,
                                instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot)
                select vlidgarantiah, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                       id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                       ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                       fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                       b_ultimo_tramite, monto_maximo_garantizado,current_timestamp, current_timestamp, 'AC', id_garantia_pend, id_moneda, instrumento_publico, cambios_bienes_monto, no_garantia_previa_ot
                  from rug.rug_garantias
                 where id_garantia = reggarantiastemp.id_garantia_modificar;

                insert into rug.rug_rel_tram_garan(id_tramite,id_garantia,b_tramite_completo, status_reg, fecha_reg)
                values( vlidtramite,reggarantiastemp.id_garantia_modificar, 'S', 'AC', current_timestamp);



                begin
                    insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                    select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                      from rug.rug_rel_tram_inc_partes
                     where id_tramite_temp=peidtramitetemp;
                exception
                when no_data_found then
                   raise notice 'No Existe personas asociadas al tramite en la tabla RUG.RUG_REL_TRAM_INC_PARTES';
                end;

                insert into rug.rug_rel_garantia_partes(id_garantia, id_persona, id_parte, id_relacion, fecha_reg, status_reg)
                select reggarantiastemp.id_garantia_modificar, id_persona, id_parte,vlidrelacion, current_timestamp, 'AC'
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp and status_reg = 'AC';

            end;


            when regtramitesincomp.id_tipo_tramite=3  then /* aviso preventivo */
            begin

                insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                from rug.rug_rel_tram_inc_partes
                where id_tramite_temp=peidtramitetemp and status_reg = 'AC';

            end;


            when regtramitesincomp.id_tipo_tramite in (4, 21)  then /* cancelacion  y fin de vigencia*/
            begin

                /* se obtiene el id_garantia_temp, y lo datos a modificar */
                --cambiar query

                vlgarantiastatus := 'CA';

                if(regtramitesincomp.id_tipo_tramite = 21) then
                    vlgarantiastatus := 'FV';
                end if;


                vlidrelacion:= nextval('rug.rug_rel_garantia_partes_id_relacion_seq');

                select rgp.id_garantia_pend, rgp.id_garantia_modificar
                  into reggarantiastemp.id_garantia_pend,
                       reggarantiastemp.id_garantia_modificar
                  from rug.rug_garantias_pendientes rgp
                  left join rug.rug_rel_tram_inc_garan rrl
                    on rgp.id_garantia_pend = rrl.id_garantia_pend
                 where rrl.id_tramite_temp = peidtramitetemp;

                /* se actualiza la garantia final */
                update rug.rug_garantias a
                   set a.garantia_status= vlgarantiastatus, --'CA',
                       a.fecha_reg = current_timestamp,
                       a.status_reg = 'AC',
                       a.id_ultimo_tramite = vlidtramite,
                       a.id_relacion = vlidrelacion
                 where a.id_garantia = reggarantiastemp.id_garantia_modificar;

                /* se inserta en un historico */
                vlidgarantiah:= nextval('rug.rug_garantias_h_id_registro_seq');

                insert into rug.rug_garantias_h(id_registro, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                            id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                            ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                            fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                            b_ultimo_tramite, monto_maximo_garantizado,fecha_modif_reg, fecha_reg, status_reg, id_garantia_pend, id_moneda,
                            instrumento_publico, cambios_bienes_monto, no_garantia_previa_ot)
                select vlidgarantiah, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                       id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                       ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                       fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                       b_ultimo_tramite, monto_maximo_garantizado,current_timestamp, current_timestamp, 'AC', id_garantia_pend,id_moneda,instrumento_publico, cambios_bienes_monto, no_garantia_previa_ot
                  from rug.rug_garantias
                 where id_garantia = reggarantiastemp.id_garantia_modificar;

                insert into rug.rug_rel_tram_garan(id_tramite,id_garantia,b_tramite_completo, status_reg, fecha_reg)
                values( vlidtramite,reggarantiastemp.id_garantia_modificar, 'S', 'AC', current_timestamp);

                begin
                    insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                    select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                      from rug.rug_rel_tram_inc_partes
                     where id_tramite_temp = peidtramitetemp;
                exception
                  when no_data_found then
                    raise notice 'No Existe personas asociadas al tramite en la tabla RUG.RUG_REL_TRAM_INC_PARTES';
                end;

                insert into rug.rug_rel_garantia_partes(id_garantia, id_persona, id_parte, id_relacion, fecha_reg, status_reg)
                select reggarantiastemp.id_garantia_modificar, id_persona, id_parte,vlidrelacion, current_timestamp, 'AC'
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp and status_reg = 'AC';

            end;


            when regtramitesincomp.id_tipo_tramite= 5  then /* certificacion */
            begin
            raise notice 'ENTRO A LA CERTIFICACION';
            end;


            when regtramitesincomp.id_tipo_tramite = 6  then /* rectificacion por error */
            begin

                vlidrelacion:= nextval('rug.rug_rel_garantia_partes_id_relacion_seq');      /* secuencia de la tabla rug_reg_garantia_partes */
                 /* se obtiene el id_garantia_temp, y lo datos a modificar */ --(datos que se modificaron en la pantalla)

                select rgp.id_garantia_pend,rgp.id_tipo_garantia,  rgp.desc_garantia, rgp.id_persona, rgp.relacion_bien,
                       rgp.otros_terminos_garantia,rgp.fecha_inscr,rgp.vigencia,rgp.garantia_status,rgp.id_ultimo_tramite,
                       rgp.monto_maximo_garantizado,rgp.id_garantia_modificar ,rgp.cambios_bienes_monto,rgp.instrumento_publico,rgp.id_moneda,rgp.no_garantia_previa_ot
                  into reggarantiastemp.id_garantia_pend, reggarantiastemp.id_tipo_garantia, reggarantiastemp.desc_garantia,
                       reggarantiastemp.id_persona, reggarantiastemp.relacion_bien, reggarantiastemp.otros_terminos_garantia,
                       reggarantiastemp.fecha_inscr,reggarantiastemp.vigencia, reggarantiastemp.garantia_status,
                       reggarantiastemp.id_ultimo_tramite,reggarantiastemp.monto_maximo_garantizado, reggarantiastemp.id_garantia_modificar,
                       reggarantiastemp.cambios_bienes_monto,reggarantiastemp.instrumento_publico, reggarantiastemp.id_moneda, reggarantiastemp.no_garantia_previa_ot
                  from rug.rug_garantias_pendientes rgp
                  left join rug.rug_rel_tram_inc_garan rrl
                    on rgp.id_garantia_pend = rrl.id_garantia_pend
                 where rrl.id_tramite_temp = peidtramitetemp;


                insert into rug.rug_rel_garantia_partes(id_garantia, id_persona, id_parte, id_relacion, fecha_reg, status_reg)
                select reggarantiastemp.id_garantia_modificar, id_persona, id_parte,vlidrelacion, current_timestamp, 'AC'
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp and status_reg = 'AC';

                 /* se actualiza la garantia final */

                update rug.rug_garantias a
                   set a.id_tipo_garantia           = reggarantiastemp.id_tipo_garantia,
                       a.desc_garantia              = reggarantiastemp.desc_garantia,
                       a.fecha_inscr                = reggarantiastemp.fecha_inscr,
                       a.id_persona                 = reggarantiastemp.id_persona,
                       a.monto_maximo_garantizado   = reggarantiastemp.monto_maximo_garantizado,
                       a.otros_terminos_garantia    = reggarantiastemp.otros_terminos_garantia,
                       a.relacion_bien              = reggarantiastemp.relacion_bien,
                       a.status_reg                 = 'AC',
                       a.fecha_reg                  = current_timestamp,
                       a.vigencia                   = reggarantiastemp.vigencia,
                       a.id_garantia_pend           = reggarantiastemp.id_garantia_pend,
                       a.id_ultimo_tramite          = vlidtramite,
                       a.id_relacion                = vlidrelacion,
                       a.instrumento_publico        = reggarantiastemp.instrumento_publico,
                       a.cambios_bienes_monto       = reggarantiastemp.cambios_bienes_monto,
                       a.id_moneda                  = reggarantiastemp.id_moneda,
                       a.no_garantia_previa_ot      = reggarantiastemp.no_garantia_previa_ot
                   where a.id_garantia = reggarantiastemp.id_garantia_modificar;

                  /* se inserta en un historico */
                   vlidgarantiah:= nextval('rug.rug_garantias_h_id_registro_seq');

                insert into rug.rug_garantias_h(id_registro, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                                    id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                                    ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                                    fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                                    b_ultimo_tramite, monto_maximo_garantizado,fecha_modif_reg, fecha_reg, status_reg, id_garantia_pend, id_moneda,
                                    instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot)
                select vlidgarantiah, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                       id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                       ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                       fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                       b_ultimo_tramite, monto_maximo_garantizado,current_timestamp, current_timestamp, 'AC', id_garantia_pend, id_moneda,instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot
                  from rug.rug_garantias
                 where id_garantia =  reggarantiastemp.id_garantia_modificar;

                insert into rug.rug_rel_tram_garan(id_tramite,id_garantia,b_tramite_completo, status_reg, fecha_reg)
                values( vlidtramite,reggarantiastemp.id_garantia_modificar, 'S', 'AC', current_timestamp);

                begin
                    insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                    select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                      from rug.rug_rel_tram_inc_partes
                     where id_tramite_temp = peidtramitetemp and status_reg = 'AC';
                exception
                    when no_data_found then
                    raise notice 'No Existe personas asociadas al tramite en la tabla RUG.RUG_REL_TRAM_INC_PARTES';
                end;


                update rug.rug_autoridad
                   set anotacion_juez = (
                                            select anotacion_juez
                                              from rug.rug_autoridad_pend
                                             where id_tramite_temp_nvo =  peidtramitetemp)
                 where id_tramite_temp = (
                                            select id_tramite_temp
                                              from rug.rug_autoridad_pend
                                             where id_tramite_temp_nvo =  peidtramitetemp);
            end;


            when regtramitesincomp.id_tipo_tramite= 7  then /* modificacion,   ya existe la garantia final o sea el id_garantia*/
            begin

                vlidrelacion:= nextval('rug.rug_rel_garantia_partes_id_relacion_seq');           /* secuencia de la tabla rug_reg_garantia_partes */

                /* se obtiene el id_garantia_temp, y lo datos a modificar */

                select  rgp.id_garantia_pend, rgp.monto_maximo_garantizado, rgp.otros_terminos_garantia,
                        rgp.relacion_bien, rgp.desc_garantia, rgp.id_garantia_modificar, rgp.id_moneda,
                        rgp.instrumento_publico, rgp.cambios_bienes_monto,rgp.no_garantia_previa_ot
                into reggarantiastemp.id_garantia_pend, reggarantiastemp.monto_maximo_garantizado, reggarantiastemp.otros_terminos_garantia,
                     reggarantiastemp.relacion_bien, reggarantiastemp.desc_garantia, reggarantiastemp.id_garantia_modificar,
                     reggarantiastemp.id_moneda, reggarantiastemp.instrumento_publico, reggarantiastemp.cambios_bienes_monto,reggarantiastemp.no_garantia_previa_ot
                from rug.rug_garantias_pendientes rgp
                left join rug.rug_rel_tram_inc_garan rrl
                on rgp.id_garantia_pend = rrl.id_garantia_pend
                where rrl.id_tramite_temp = peidtramitetemp;

                insert into rug.rug_rel_garantia_partes(id_garantia, id_persona, id_parte, id_relacion, fecha_reg, status_reg)
                select reggarantiastemp.id_garantia_modificar, id_persona, id_parte,vlidrelacion, current_timestamp, 'AC'
                from rug.rug_rel_tram_inc_partes
                where id_tramite_temp = peidtramitetemp and status_reg = 'AC';

                update rug.rug_garantias a
                set a.monto_maximo_garantizado=reggarantiastemp.monto_maximo_garantizado,
                    a.otros_terminos_garantia=reggarantiastemp.otros_terminos_garantia,
                    a.relacion_bien=reggarantiastemp.relacion_bien,
                    a.desc_garantia=reggarantiastemp.desc_garantia, a.status_reg = 'AC', a.fecha_reg = current_timestamp ,
                    a.id_garantia_pend = reggarantiastemp.id_garantia_pend,
                    a.id_ultimo_tramite = vlidtramite,
                    a.id_relacion = vlidrelacion,
                    a.instrumento_publico = reggarantiastemp.instrumento_publico,
                    a.cambios_bienes_monto = reggarantiastemp.cambios_bienes_monto,
                    a.id_moneda = reggarantiastemp.id_moneda,
                    a.no_garantia_previa_ot = reggarantiastemp.no_garantia_previa_ot
                where a.id_garantia = reggarantiastemp.id_garantia_modificar;

                /* se inserta en un historico */
                vlidgarantiah:= nextval('rug.rug_garantias_h_id_registro_seq');

                insert into rug.rug_garantias_h(id_registro, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                                    id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                                    ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                                    fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                                    b_ultimo_tramite, monto_maximo_garantizado,fecha_modif_reg, fecha_reg, status_reg, id_garantia_pend, id_moneda, instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot)

                select vlidgarantiah, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                       id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                       ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                       fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                       b_ultimo_tramite, monto_maximo_garantizado,current_timestamp, current_timestamp, 'AC', id_garantia_pend, id_moneda, instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot
                  from rug.rug_garantias
                 where id_garantia =  reggarantiastemp.id_garantia_modificar;

                insert into rug.rug_rel_tram_garan(id_tramite,id_garantia,b_tramite_completo, status_reg, fecha_reg)
                values( vlidtramite,reggarantiastemp.id_garantia_modificar, 'S', 'AC', current_timestamp);

                begin

                    insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                    select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                      from rug.rug_rel_tram_inc_partes
                     where id_tramite_temp = peidtramitetemp
                       and status_reg = 'AC';

                exception
                    when no_data_found then
                        raise notice 'No Existe personas asociadas al tramite en la tabla RUG.RUG_REL_TRAM_INC_PARTES';
                end;

            end;


            when regtramitesincomp.id_tipo_tramite= 8  then /* transmision */
            begin

                --se quito todas las validaciones para disparar la cancelacion por transmision y la inscripcion por transmision
                -- fecha del cambio: 06/09/2010; responsable: edst
                select rgp.id_garantia_modificar, rgp.id_relacion
                  into vlidgarmodtrans, vlidrelmodtrans
                  from rug.rug_garantias_pendientes rgp,
                       rug.rug_rel_tram_inc_garan rrl
                 where rgp.id_garantia_pend = rrl.id_garantia_pend
                   and rrl.id_tramite_temp = peidtramitetemp;


                /* se inserta en un historico */
                vlidgarantiah:= nextval('rug.rug_garantias_h_id_registro_seq');
                vlidrelacion:= nextval('rug.rug_rel_garantia_partes_id_relacion_seq');           /* secuencia de la tabla rug_reg_garantia_partes */

                select rgp.id_garantia_modificar, rgp.id_garantia_pend
                  into reggarantiastemp.id_garantia_modificar, reggarantiastemp.id_garantia_pend
                  from rug.rug_garantias_pendientes rgp
                  left join rug.rug_rel_tram_inc_garan rrl
                    on rgp.id_garantia_pend = rrl.id_garantia_pend
                 where rrl.id_tramite_temp = peidtramitetemp;

        -- :::message error::: 100:ora-01403: no data found:ora-06512: at "rug.sp_alta_bitacora_tramite2", line 755 :428773
               select relacion_bien
                  into vlrelbientrans
                  from rug.rug_rel_gar_tipo_bien
                 where id_garantia_pend = reggarantiastemp.id_garantia_pend
                   limit 1;
        --  :::message error::: 100:ora-01403: no data found:ora-06512: at "rug.sp_alta_bitacora_tramite2", line 755 :428773

                update rug.rug_garantias
                   set id_relacion = vlidrelacion, id_ultimo_tramite = vlidtramite, b_ultimo_tramite = 'V',
                       id_garantia_pend = reggarantiastemp.id_garantia_pend , relacion_bien = vlrelbientrans,
                       fecha_reg = current_timestamp, status_reg = 'AC'
                 where id_garantia = reggarantiastemp.id_garantia_modificar;

                insert into rug.rug_garantias_h(id_registro, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                                    id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                                    ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                                    fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                                    b_ultimo_tramite, monto_maximo_garantizado,fecha_modif_reg, fecha_reg, status_reg, id_garantia_pend, id_moneda,
                                    instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot)
                select vlidgarantiah, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                                    id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                                    ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                                    fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                                    b_ultimo_tramite, monto_maximo_garantizado,current_timestamp, current_timestamp, 'AC', id_garantia_pend, id_moneda,instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot
                  from rug.rug_garantias
                  where id_garantia = reggarantiastemp.id_garantia_modificar;

                insert into rug.rug_rel_tram_garan(id_tramite,id_garantia,b_tramite_completo, status_reg, fecha_reg)
                values( vlidtramite,reggarantiastemp.id_garantia_modificar, 'S', 'AC', current_timestamp);

                begin
                    insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                    select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                      from rug.rug_rel_tram_inc_partes
                     where id_tramite_temp = peidtramitetemp and status_reg = 'AC';
                exception
                  when no_data_found then
                    raise notice 'No Existe personas asociadas al tramite en la tabla RUG.RUG_REL_TRAM_INC_PARTES';
                end;

                insert into rug.rug_rel_garantia_partes(id_garantia, id_persona, id_parte, id_relacion, fecha_reg, status_reg)
                select reggarantiastemp.id_garantia_modificar, id_persona, id_parte,vlidrelacion, current_timestamp, 'AC'
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp and status_reg = 'AC';

            end;


            when regtramitesincomp.id_tipo_tramite= 9  then /* prorroga o reduccion de vigencia */
            begin

                vlidrelacion:= nextval('rug.rug_rel_garantia_partes_id_relacion_seq');

                /* se obtiene el id_garantia_temp, y lo datos a modificar */

                select rgp.id_garantia_pend, rgp.id_garantia_modificar, rgp.vigencia
                  into reggarantiastemp.id_garantia_pend, reggarantiastemp.id_garantia_modificar, reggarantiastemp.vigencia
                  from rug.rug_garantias_pendientes rgp
                  left join rug.rug_rel_tram_inc_garan rrl
                    on rgp.id_garantia_pend = rrl.id_garantia_pend
                 where rrl.id_tramite_temp = peidtramitetemp;

                       /* se actualiza la garantia final */

                update rug.rug_garantias a
                   set a.vigencia =reggarantiastemp.vigencia,
                       a.status_reg = 'AC',
                       a.fecha_reg = current_timestamp,
                       a.id_garantia_pend = reggarantiastemp.id_garantia_pend,
                       a.id_ultimo_tramite = vlidtramite,
                       a.id_relacion = vlidrelacion
                 where a.id_garantia = reggarantiastemp.id_garantia_modificar;

                /* se inserta en un historico */
                vlidgarantiah:= nextval('rug.rug_garantias_h_id_registro_seq');

                insert into rug.rug_garantias_h(id_registro, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                                        id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                                        ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                                        fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                                        b_ultimo_tramite, monto_maximo_garantizado,fecha_modif_reg, fecha_reg, status_reg, id_garantia_pend, id_moneda,
                                        instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot)
                select vlidgarantiah, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                       id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                       ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                       fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                       b_ultimo_tramite, monto_maximo_garantizado,current_timestamp, current_timestamp, 'AC', id_garantia_pend, id_moneda, instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot
                  from rug.rug_garantias
                 where id_garantia = reggarantiastemp.id_garantia_modificar;

                insert into rug.rug_rel_tram_garan(id_tramite,id_garantia,b_tramite_completo, status_reg, fecha_reg)
                values( vlidtramite,reggarantiastemp.id_garantia_modificar, 'S', 'AC', current_timestamp);

                begin
                    insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                    select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                      from rug.rug_rel_tram_inc_partes
                     where id_tramite_temp=peidtramitetemp;

                exception
                  when no_data_found then
                    raise notice 'No Existe personas asociadas al tramite en la tabla RUG.RUG_REL_TRAM_INC_PARTES';
                end;

                insert into rug.rug_rel_garantia_partes(id_garantia, id_persona, id_parte, id_relacion, fecha_reg, status_reg)
                select reggarantiastemp.id_garantia_modificar, id_persona, id_parte,vlidrelacion, current_timestamp, 'AC'
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp and status_reg = 'AC';

            end;


            when regtramitesincomp.id_tipo_tramite = 10 then /* anotacion sin garantia */
            begin

                vlbandera := 0;

                select count(*)
                  into vlbandera
                  from rug.rug_rel_tram_partes a,
                       rug.rug_rel_tram_inc_partes b
                 where a.id_tramite = vlidtramite
                   and a.id_persona = b.id_persona
                   and a.id_parte = b.id_parte
                   and b.id_tramite_temp = peidtramitetemp
                   and b.status_reg = 'AC';


                call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'vlidtramite', vlidtramite, 'IN');
                call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'vlbandera', vlbandera, 'IN');


                if vlbandera = 0 then

                    insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                    select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                      from rug.rug_rel_tram_inc_partes
                     where id_tramite_temp=peidtramitetemp and status_reg = 'AC';

                end if;

            end;
            when regtramitesincomp.id_tipo_tramite= 11  then /* prorroga o reduccion de vigencia */
            begin
                raise notice 'entro a la consulta';
            end;


            when regtramitesincomp.id_tipo_tramite=12  then /* alta de acreedor representado*/
            begin

                insert into rug.rug_rel_tram_partes
                select vlidtramite, id_persona, id_parte, per_juridica, 'AC', current_timestamp
                from rug.rug_rel_tram_inc_partes
                where id_tramite_temp = peidtramitetemp;

                select id_persona
                into vlidpersonatramite12
                from rug.rug_rel_tram_inc_partes
                where id_tramite_temp = peidtramitetemp;

                update rug.rel_usu_acreedor
                set b_firmado = 'Y', fecha_reg= current_timestamp, status_reg='AC'
                where id_acreedor = vlidpersonatramite12;

                select id_usuario
                into vlidusuario
                from rug.rel_usu_acreedor
                where id_acreedor = vlidpersonatramite12;

                call rug.sp_modifica_perfil(vlidusuario, 1, vlresult, vltextresult);

            end;


            when regtramitesincomp.id_tipo_tramite = 13  then /* cancelacion por transmision */
            begin

                vlidrelacion:= nextval('rug.rug_rel_garantia_partes_id_relacion_seq');


                -- se obtienen los datos de la garntia pendiente
                select rgp.id_garantia_pend, rgp.id_garantia_modificar, rgp.vigencia, rgp.relacion_bien
                  into reggarantiastemp.id_garantia_pend, reggarantiastemp.id_garantia_modificar, reggarantiastemp.vigencia,
                       reggarantiastemp.relacion_bien
                  from rug.rug_garantias_pendientes rgp
                  left join rug.rug_rel_tram_inc_garan rrl
                    on rgp.id_garantia_pend = rrl.id_garantia_pend
                 where rrl.id_tramite_temp = peidtramitetemp;

                -- insertar la relacion de personas de tramites incompletos  a la relacion de garantias partes
                insert into rug.rug_rel_garantia_partes(id_garantia, id_persona, id_parte, id_relacion, fecha_reg, status_reg)
                select reggarantiastemp.id_garantia_modificar, id_persona, id_parte,vlidrelacion, current_timestamp, 'AC'
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp and status_reg = 'AC';

                 -- insertar el tramite incompleto en tramites completos
                insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp and status_reg = 'AC';

                -- cambiar la garantia a cancelacion por transmision (ct)
                update rug.rug_garantias
                   set status_reg = 'AC',
                       fecha_reg = current_timestamp,
                       garantia_status = 'ct',--decode(regtramitesincomp.id_tipo_tramite, 13, 'ct', 'cr'),
                       id_garantia_pend = reggarantiastemp.id_garantia_pend,
                       id_ultimo_tramite = vlidtramite,
                       id_relacion = vlidrelacion,
                       relacion_bien = reggarantiastemp.relacion_bien
                 where id_garantia = reggarantiastemp.id_garantia_modificar;

                -- relacionar el tramite con la garantia
                insert into rug.rug_rel_tram_garan(id_tramite,id_garantia,b_tramite_completo, status_reg, fecha_reg)
                values( vlidtramite, reggarantiastemp.id_garantia_modificar, 'S', 'AC', current_timestamp);

                vlidgarantiah:= nextval('rug.rug_garantias_h_id_registro_seq');

                 -- insertar el cambio en historico
                insert into rug.rug_garantias_h(id_registro, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                                    id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                                    ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                                    fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                                    b_ultimo_tramite, monto_maximo_garantizado,fecha_modif_reg, fecha_reg, status_reg, id_garantia_pend, id_moneda,
                                    instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot)
                select vlidgarantiah, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                                    id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                                    ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                                    fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                                    b_ultimo_tramite, monto_maximo_garantizado,current_timestamp, current_timestamp, 'AC', id_garantia_pend, id_moneda, instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot
                  from rug.rug_garantias
                 where id_garantia = reggarantiastemp.id_garantia_modificar;


                insert into rug.rug_bitac_tramites (id_tramite_temp, id_status,  id_paso,fecha_status,id_tipo_tramite, fecha_reg, status_reg)
                values (peidtramitetemp,3,peidpaso,current_timestamp,regtramitesincomp.id_tipo_tramite, current_timestamp, 'AC');

            end;


            when regtramitesincomp.id_tipo_tramite = 14  then /* alta de usuarios */
            begin

                insert into rug.rug_rel_tram_partes
                select vlidtramite, id_persona, id_parte, per_juridica, 'AC', current_timestamp
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp;


                select id_persona
                  into vlidacreedor
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp
                   and id_parte = 4;

                select id_persona
                into vlidpersonatramite12
                from rug.rug_rel_tram_inc_partes
                where id_tramite_temp = peidtramitetemp
                  and id_parte = 5;

                update rug.rug_secu_usuarios
                   set b_firmado = 'V',
                       fh_registro= current_timestamp,
                       sit_usuario='AC'
                 where id_persona = vlidpersonatramite12;

                update rug.rel_usu_acreedor
                set b_firmado = 'Y'
                where id_usuario = vlidpersonatramite12
                and id_acreedor = vlidacreedor;

                delete from rug.rug_tramites_reasignados 
                 where id_acreedor = vlidacreedor
                   and id_tramite_temp in (select id_tramite_temp
                                             from rug.v_tramites_terminados
                                            where id_persona_login = vlidpersonatramite12
                                              and id_acreedor = vlidacreedor);

                delete from rug.rug_tramites_reasignados
                 where id_acreedor = vlidacreedor
                   and id_tramite_temp in (
                                            select id_tramite_temp
                                              from rug.v_tramites_pendientes
                                             where id_persona_login = vlidpersonatramite12
                                               and id_acreedor = vlidacreedor);


            end;


            when regtramitesincomp.id_tipo_tramite = 15  then /* inscripcion por transmision */
            begin

                ----------   i n s c r i p c i o n   ----------

                vlidgarantia:=nextval('rug.garantias_id_garantia_seq');           /* secuencia de la tabla de tramites */
                vlidrelacion:= nextval('rug.rug_rel_garantia_partes_id_relacion_seq');           /* secuencia de la tabla rug_reg_garantia_partes */


                    -- obtener la inforacion para generar la nueva garantia
                select b.id_tipo_garantia, b.num_garantia, b.desc_garantia, b.meses_garantia, b.id_persona, b.id_anotacion, b.id_relacion,
                       b.relacion_bien, b.valor_bienes, b.tipos_bienes_muebles, b.ubicacion_bienes, b.folio_mercantil, b.path_doc_garantia,
                       b.otros_terminos_garantia, b.fecha_inscr, b.fecha_fin_gar, b.vigencia, b.garantia_certificada, b.garantia_status, b.id_ultimo_tramite,
                       b_ultimo_tramite, b.monto_maximo_garantizado, b.id_garantia_pend, b.id_moneda, b.instrumento_publico, b.cambios_bienes_monto,
                       b.id_garantia_modificar, b.no_garantia_previa_ot
                  into reggarantiastemp.id_tipo_garantia, reggarantiastemp.num_garantia, reggarantiastemp.desc_garantia,
                       reggarantiastemp.meses_garantia, reggarantiastemp.id_persona, reggarantiastemp.id_anotacion, reggarantiastemp.id_relacion,
                       reggarantiastemp.relacion_bien, reggarantiastemp.valor_bienes, reggarantiastemp.tipos_bienes_muebles, reggarantiastemp.ubicacion_bienes,
                       reggarantiastemp.folio_mercantil, reggarantiastemp.path_doc_garantia, reggarantiastemp.otros_terminos_garantia, reggarantiastemp.fecha_inscr,
                       reggarantiastemp.fecha_fin_gar, reggarantiastemp.vigencia, reggarantiastemp.garantia_certificada, reggarantiastemp.garantia_status,
                       reggarantiastemp.id_ultimo_tramite, reggarantiastemp.b_ultimo_tramite, reggarantiastemp.monto_maximo_garantizado, reggarantiastemp.id_garantia_pend,
                       reggarantiastemp.id_moneda, reggarantiastemp.instrumento_publico, reggarantiastemp.cambios_bienes_monto, reggarantiastemp.id_garantia_modificar,reggarantiastemp.no_garantia_previa_ot
                  from rug.rug_garantias_pendientes b, rug.rug_rel_tram_inc_garan c
                 where b.id_garantia_pend = c.id_garantia_pend
                   and c.id_tramite_temp = peidtramitetemp;


                -- insertar la garantia y que el tramite sea por transmision
                update rug.rug_garantias
                   set status_reg = 'AC',
                       fecha_reg = current_timestamp,
                       garantia_status = 'AC',--decode(regtramitesincomp.id_tipo_tramite, 13, 'ct', 'cr'),
                       id_garantia_pend = reggarantiastemp.id_garantia_pend,
                       id_ultimo_tramite = vlidtramite,
                       id_relacion = vlidrelacion,
                       relacion_bien =  reggarantiastemp.relacion_bien
                 where id_garantia = reggarantiastemp.id_garantia_modificar;

                    -- relacionar el tramite con la garantia
                insert into rug.rug_rel_tram_garan(id_tramite,id_garantia,b_tramite_completo, status_reg, fecha_reg)
                values( vlidtramite, reggarantiastemp.id_garantia_modificar, 'S', 'AC', current_timestamp);

                vlidgarantiah:= nextval('rug.rug_garantias_h_id_registro_seq');

                -- guardar el historico
                insert into rug.rug_garantias_h(id_registro, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                                    id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                                    ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                                    fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                                    b_ultimo_tramite, monto_maximo_garantizado,fecha_modif_reg, fecha_reg, status_reg, id_garantia_pend, id_moneda,
                                    instrumento_publico, cambios_bienes_monto,no_garantia_previa_ot)
                select vlidgarantiah, id_garantia, id_tipo_garantia, num_garantia, desc_garantia, meses_garantia,
                       id_persona, id_anotacion, id_relacion, relacion_bien, valor_bienes, tipos_bienes_muebles,
                       ubicacion_bienes, folio_mercantil, path_doc_garantia, otros_terminos_garantia, fecha_inscr,
                       fecha_fin_gar, vigencia, garantia_certificada, garantia_status, id_ultimo_tramite,
                       b_ultimo_tramite, monto_maximo_garantizado, current_timestamp, current_timestamp, 'AC', id_garantia_pend, id_moneda, instrumento_publico, cambios_bienes_monto,rug_garantias.no_garantia_previa_ot
                  from rug.rug_garantias
                 where id_garantia = reggarantiastemp.id_garantia_modificar;

                begin

                    insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                    select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                      from rug.rug_rel_tram_inc_partes
                     where id_tramite_temp = peidtramitetemp
                       and status_reg = 'AC';

                exception
                  when no_data_found then
                    raise notice 'No Existe personas asociadas al tramite en la tabla RUG.RUG_REL_TRAM_INC_PARTES';
                end;

                insert into rug.rug_rel_garantia_partes(id_garantia, id_persona, id_parte, id_relacion, fecha_reg, status_reg)
                select reggarantiastemp.id_garantia_modificar, id_persona, id_parte,vlidrelacion, current_timestamp, 'AC'
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp and status_reg = 'AC';

                insert into rug_bitac_tramites (id_tramite_temp, id_status,  id_paso,fecha_status,id_tipo_tramite, fecha_reg, status_reg)
                 values (peidtramitetemp,3,peidpaso,current_timestamp,15, current_timestamp, 'AC');

            end;


            when regtramitesincomp.id_tipo_tramite = 19  then /* modificacion de acreedor */
            begin

                vlidacreedor      := null;
                vlidacreedornuevo := null;
                vlid_domicilio    := null;
                vldomicilio       := null;
                vltelefono        := null;

                select id_acreedor, id_acreedor_nuevo
                  into vlidacreedor, vlidacreedornuevo
                  from rug.rug_rel_modifica_acreedor
                 where id_tramite_temp =  peidtramitetemp
                   and status_reg = 'AC'
                   and b_firmado = 'N';


                select id_domicilio, per_juridica
                  into  vlid_domicilio, vltipopersona
                  from rug_personas
                 where id_persona = vlidacreedor;


                select per_juridica, nombre_persona, ap_paterno_persona, ap_materno_persona, razon_social, folio_mercantil, rfc, curp, calle,
                       num_exterior, num_interior, id_colonia, id_nacionalidad, email, telefono, extension,  curp_doc, ubica_domicilio_1,
                       ubica_domicilio_2, poblacion,zona_postal, id_domicilio, localidad,id_pais_residencia, id_domicilio
                  into regacreedor.per_juridica, regacreedor.nombre_persona, regacreedor.ap_paterno_persona, regacreedor.ap_materno_persona,
                       regacreedor.razon_social, regacreedor.folio_mercantil, regacreedor.rfc, regacreedor.curp, regacreedor.calle,
                       regacreedor.num_exterior, regacreedor.num_interior, regacreedor.id_colonia, regacreedor.id_nacionalidad, regacreedor.email,
                       regacreedor.telefono, regacreedor.extension, regacreedor.curp_doc, regacreedor.ubica_domicilio_1, regacreedor.ubica_domicilio_2,
                       regacreedor.poblacion, regacreedor.zona_postal, regacreedor.id_domicilio, regacreedor.localidad, regacreedor.id_pais_residencia,
                       regacreedor.id_domicilio
                  from rug.v_tramites_incomp_partes
                 where id_tramite = peidtramitetemp
                   and id_parte = 4;


                update rug_personas
                   set rfc = regacreedor.rfc, id_nacionalidad = regacreedor.id_nacionalidad, per_juridica = regacreedor.per_juridica,
                       folio_mercantil = regacreedor.folio_mercantil, e_mail = regacreedor.email, curp_doc = regacreedor.curp_doc, id_domicilio = regacreedor.id_domicilio
                 where id_persona = vlidacreedor;


                if(regacreedor.per_juridica = 'PF') then

                    if(vltipopersona = 'PF') then

                            update rug_personas_fisicas
                            set nombre_persona = regacreedor.nombre_persona, ap_paterno = regacreedor.ap_paterno_persona,
                                ap_materno = regacreedor.ap_materno_persona, curp = regacreedor.curp
                            where id_persona = vlidacreedor;

                        else

                            insert into rug_personas_fisicas(id_persona, nombre_persona, ap_paterno, ap_materno, curp)
                            values(vlidacreedor, regacreedor.nombre_persona, regacreedor.ap_paterno_persona, regacreedor.ap_materno_persona, regacreedor.curp);

                    end if;

                    delete from rug.rug_personas_morales
                    where id_persona = vlidacreedor;

                else

                    if(vltipopersona = 'pm') then

                        update rug.rug_personas_morales
                        set razon_social = regacreedor.razon_social
                        where id_persona = vlidacreedor;

                    else

                        insert into rug_personas_morales (id_persona, razon_social)
                        values(vlidacreedor, regacreedor.razon_social);


                    end if;

                    delete from rug.rug_personas_fisicas
                    where id_persona = vlidacreedor;


                end if;


                if(trim(regacreedor.ubica_domicilio_1) is null or trim(regacreedor.ubica_domicilio_2) is null or
                   trim(regacreedor.poblacion) is null or trim(regacreedor.zona_postal) is null ) then


                    select count(*)
                      into vldomicilio
                      from rug.rug_domicilios
                     where id_domicilio = vlid_domicilio;

                    if(vldomicilio != 0) then

                        update rug.rug_domicilios
                           set calle = regacreedor.calle, num_exterior = regacreedor.num_exterior, num_interior = regacreedor.num_interior,
                               id_colonia = regacreedor.id_colonia, localidad = regacreedor.localidad
                         where id_domicilio = vlid_domicilio;

                    else

                        insert into rug.rug_domicilios(id_domicilio, calle, num_exterior, num_interior, id_colonia, localidad)
                        values(vlid_domicilio, regacreedor.calle, regacreedor.num_exterior, regacreedor.num_interior, regacreedor.id_colonia, regacreedor.localidad);

                    end if;



                    delete from rug.rug_domicilios_ext
                    where id_domicilio = vlid_domicilio;


                else


                    select count(*)
                      into vldomicilio
                      from rug.rug_domicilios_ext
                     where id_domicilio = vlid_domicilio;


                     if(vldomicilio != 0) then

                        update rug.rug_domicilios_ext
                           set ubica_domicilio_1 = regacreedor.ubica_domicilio_1, ubica_domicilio_2 = regacreedor.ubica_domicilio_2,
                               poblacion = regacreedor.poblacion, zona_postal = regacreedor.zona_postal, id_pais_residencia = regacreedor.id_pais_residencia
                         where id_domicilio = vlid_domicilio;


                     else

                        insert into rug.rug_domicilios_ext(id_domicilio, ubica_domicilio_1, ubica_domicilio_2, poblacion, zona_postal, id_pais_residencia)
                        values(vlid_domicilio, regacreedor.ubica_domicilio_1, regacreedor.ubica_domicilio_2, regacreedor.poblacion, regacreedor.zona_postal, regacreedor.id_pais_residencia);


                     end if;



                    delete from rug.rug_domicilios
                    where id_domicilio = vlid_domicilio;


                end if;


                select count(*)
                  into vltelefono
                  from rug.rug_telefonos
                 where id_persona = vlidacreedor;

                 if(vlidacreedor != 0) then

                    update rug.rug_telefonos
                       set telefono = regacreedor.telefono, extension = regacreedor.extension
                     where id_persona = vlidacreedor;

                 else

                    insert into rug.rug_telefonos(id_persona,  telefono, extension, fecha_reg, status_reg)
                    values(vlidacreedor, regacreedor.telefono, regacreedor.extension, current_timestamp, 'AC');

                 end if;


                 update rug.rug_rel_modifica_acreedor
                    set b_firmado = 'Y', status_reg = 'IN'
                  where id_tramite_temp =  peidtramitetemp
                    and status_reg = 'AC';



                 update rug.rug_rel_modifica_acreedor
                    set status_reg = 'IN'
                  where id_acreedor =  vlidacreedor;


                 update rug.tramites_rug_incomp
                    set status_reg = 'IN', id_status_tram = 7
                  where id_tramite_temp in (select id_tramite_temp from rug.rug_rel_modifica_acreedor
                                            where id_acreedor =  vlidacreedor);


                 update rug.rug_personas
                    set sit_persona = 'IN'
                  where id_persona = vlidacreedornuevo;

            end;

            when regtramitesincomp.id_tipo_tramite = 18 then
            begin
                insert into rug.rug_rel_tram_partes
                select vlidtramite, id_persona, id_parte, per_juridica, 'AC', current_timestamp
                  from rug.rug_rel_tram_inc_partes
                 where id_tramite_temp = peidtramitetemp;

            end;

            when regtramitesincomp.id_tipo_tramite  in(26, 27, 28, 29)  then /* anotacion sin garantia - tramites */ /* ggr 12.14.2013   mmsecn2013-81 */
            begin

                vlbandera := 0;

                select count(*)
                  into vlbandera
                  from rug.rug_rel_tram_partes a,
                       rug.rug_rel_tram_inc_partes b
                 where a.id_tramite = vlidtramite
                   and a.id_persona = b.id_persona
                   and a.id_parte = b.id_parte
                   and b.id_tramite_temp = peidtramitetemp
                   and b.status_reg = 'AC';


                call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'vlidtramite', vlidtramite, 'IN');
                call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'regtramitesincomp.id_tipo_tramite', regtramitesincomp.id_tipo_tramite, 'IN');
                call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'vlbandera', vlbandera, 'IN');


                if vlbandera = 0 then

                    insert into rug.rug_rel_tram_partes(id_tramite, id_persona, id_parte, per_juridica, status_reg, fecha_reg)
                    select vlidtramite,id_persona, id_parte, per_juridica, 'AC', current_timestamp
                      from rug.rug_rel_tram_inc_partes
                     where id_tramite_temp=peidtramitetemp and status_reg = 'AC';

                end if;

                update rug.rug_anotaciones_seg_inc_csg
                   set id_tramite = vlidtramite
                 where id_anotacion_temp = peidtramitetemp;

                call rug.sp_anotac_seg_inc_csg_ins_h(peidtramitetemp, vlresult, vltextresult);


                /** cancela logicamente el tramite padre y hermanos  **/
                if regtramitesincomp.id_tipo_tramite = 27 then


                    /* cancela tramites terminados */

                    select id_tramite_padre
                      into v_id_tramite_padre
                      from rug.rug_anotaciones_seg_inc_csg
                     where id_tramite = vlidtramite;

                    update tramites
                       set status_reg = 'CA'
                     where id_tramite in (select id_tramite
                                            from rug.rug_anotaciones_seg_inc_csg
                                           where id_tramite is not null
                                             and id_tramite_padre = v_id_tramite_padre
                                          )
                        or id_tramite = v_id_tramite_padre
                       and id_tipo_tramite <> 27;



                    /* cancela tramites pendientes */

                    update rug.tramites_rug_incomp
                       set status_reg = 'CA'
                     where id_tramite_temp in (select id_anotacion_temp
                                                 from rug.rug_anotaciones_seg_inc_csg
                                                where id_tramite is null
                                                  and id_tramite_padre = v_id_tramite_padre
                                              );

                end if;

            end;
        else

            null;

        end case;

    end; /* then  fin de alta de tramite nuevo */

    else /*  id_status <> 3 */
        vlidtramite:=peidtramitetemp; /* valor de tramite temporal porque el tramite no es terminado status <>3 */
    end if;

/* insertar en la bitacora de tramites */
    if pebanderafecha not in ('V','F') then
     raise notice '%', ex_errparametro;
        pstxresult:= substr(psresult,1,250);
    rollback;
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psResult', psresult, 'OUT');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psTxResult', pstxresult, 'OUT');
    raise notice '%', pstxresult;
    end if;


    if(regtramitesincomp.id_tipo_tramite in (1,2,6,7,8,3,10
                                              , 27, 28 -- /* ggr 23.08.2013   mmsecn2013-81 */
                                              , 23, 24 ) -- /* ggr 23.08.2013   mmsecn2013-82 */
                                              ) then

        if(peidstatus = 3) then

            call rug.sp_alta_catalogo_palabras(vlidtramite, regtramitesincomp.id_tipo_tramite, vlresult, vltextresult);

            if(vlresult != 0 or vlresult is null) then
                raise notice '%', ex_errparametro;
                   pstxresult:= substr(psresult,1,250);
    rollback;
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psResult', psresult, 'OUT');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psTxResult', pstxresult, 'OUT');
    raise notice '%', pstxresult;
             end if;

        end if;

    end if;

    select count(*)
      into vlcountstattram
      from rug.rug_bitac_tramites
     where id_tramite_temp = peidtramitetemp
       and id_status = 3;

    if vlcountstattram = 0 then

        if pebanderafecha = 'V' then

               select id_persona, id_tipo_tramite, fech_pre_inscr, fecha_inscr
               into regtramitesincomp.id_persona, regtramitesincomp.id_tipo_tramite, regtramitesincomp.fech_pre_inscr, regtramitesincomp.fecha_inscr
               from rug.tramites_rug_incomp
               where id_tramite_temp= peidtramitetemp;


               update rug.rug_bitac_tramites
               set status_reg = 'IN'
               where id_tramite_temp = peidtramitetemp;

               insert into rug.rug_bitac_tramites
               (id_tramite_temp, id_status,  id_paso,fecha_status,id_tipo_tramite, fecha_reg, status_reg)
               values
               (peidtramitetemp,peidstatus,peidpaso,current_timestamp,regtramitesincomp.id_tipo_tramite, current_timestamp, 'AC');

        else
                if pefechacreacion is not null then


                update rug.rug_bitac_tramites
                set status_reg = 'IN'
                where id_tramite_temp = peidtramitetemp;

                 insert into rug.rug_bitac_tramites
             (id_tramite_temp, id_status,  id_paso,fecha_status,id_tipo_tramite, fecha_reg, status_reg)
               values
               (peidtramitetemp,peidstatus,peidpaso,pefechacreacion,regtramitesincomp.id_tipo_tramite, current_timestamp, 'AC');
               else
                   raise notice '%', ex_errparametro;
                      pstxresult:= substr(psresult,1,250);
    rollback;
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psResult', psresult, 'OUT');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psTxResult', pstxresult, 'OUT');
    raise notice '%', pstxresult;
                end if;
        end if;

        update rug.tramites_rug_incomp
        set id_status_tram = peidstatus,
            id_paso = peidpaso,
            status_reg = 'AC',
            fecha_status = current_timestamp
        where id_tramite_temp  = peidtramitetemp;

    elsif vlcountstattram = 1 then

        raise notice '%', ex_tramiteterminado;
       psresult   :=11;
    pstxresult := rug.fn_mensaje_error(psresult);
    rollback;
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psResult', psresult, 'OUT');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psTxResult', pstxresult, 'OUT');
    raise notice '%', pstxresult;

    end if;

--commit;

  psresult := 0;
  pstxresult := rug.fn_mensaje_error(psresult);

  call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psResult', psresult, 'OUT');
  call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psTxResult', pstxresult, 'OUT');



exception     

   when others then
    psresult  := 999;
    pstxresult:= substr(sqlstate||':'||sqlerrm,1,250)||':'||dbms_utility.format_error_backtrace||':'||reggarantiastemp.id_garantia_pend;
    rollback;
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psResult', psresult, 'OUT');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_Alta_Bitacora_Tramite2', 'psTxResult', pstxresult, 'OUT');
    raise notice '%', pstxresult;

end; /* sp_alta_bitacora_tramite */
$procedure$;





-- procedure rug.sp_alta_acreedor_rep


drop procedure if exists rug.sp_alta_acreedor_rep;
create or replace procedure rug.sp_alta_acreedor_rep (
                                peidusuario          in  int,
                                petipopersona        in  text,
                                idtipo               in  text, -- sociedad mercantil 'SM' o otros 'OT'
                                perazonsocial        in  text,
                                perfc                in  text,
                                pecurp               in  text,
                                pefoliomercantil     in  text,
                                pecalle              in  text,
                                penumext             in  text,
                                penumint             in  text,
                                penombre             in  text,
                                peapellidop          in  text,
                                peapellidom          in  text,
                                peidcolonia          in  int,           
                                peidlocalidad        in  int,
                                peidnacionalidad     in  int,
                                pefechainicio        in  date,  -- fecha inicio del contrato
                                pefechafin           in  date,  -- fecha fin del contrato
                                peotrosterm          in  text, -- terminos y condiciones
                                petipocontrato       in  int,
                                peidtramitetemp      in  int,
                                petelefono           in  text,
                                peextension          in  text,   
                                peemail              in  text,
                                pedomiciliouno       in  text,
                                pedomiciliodos       in  text, 
                                pepoblacion          in  text,
                                pezonapostal         in  text,
                                pepaisresidencia     in  int, 
                                pebandera            in  char,  -- true = 1, false = 0
                                peafolexiste         in  char,  -- true = 1, false = 0
                                penifp               in  text,  
                                psresult            out  integer,   
                                pstxresult          out  text,   
                                psfolioelectronico  out  text, 
                                psidpersonainsertar out  int --id de la persona que se va a insertar                                     
                            )
language plpgsql
as $procedure$
declare

vlexiste                int;
vlidpersona             int;
vliddomicilio           int;
vlidtramiterugincom     int;
vlidcontrato            int;
vlnumpartes             int;
vlgrupo                 int;
vlidperfil              int;
vlresult                int;
vlperfil                text;
vltextresult            text;

vlcountcurpexiste       int;
vlcurp                  text;

--variables validacion rfc
vlpsresultvalrfc        int;
vlpstxtresultvalrfc     text;

vlfolioelectronicoexist rug.rug_personas.folio_mercantil%type;
vlfolioelecexist        int;
vlnvofolioelectronico   text;

--variables validacion de curp
vlpsresultvalcurp       int;
vlpstxtresultvalcurp    text;

--variables validacion folio electronico
vlpsresultvalfolio      int;
vlpstxtresultvalfolio   text;

--curp
vlcountcurpregexp int;

ex_error           text := "exception ex_error";
ex_errrfc          text := "exception ex_errrfc";
ex_texto           text := "exception ex_texto";

begin

    begin
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peIdUsuario', peidusuario, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peTipoPersona', petipopersona, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'IdTipo', idtipo, 'IN');     
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peRazonSocial', perazonsocial, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peRFC', perfc, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peCURP', pecurp, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peFolioMercantil', pefoliomercantil, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peCalle', pecalle, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peNumExt', penumext, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peNumInt', penumint, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peNombre', penombre, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peApellidoP', peapellidop, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peApellidoM', peapellidom, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peIdColonia', peidcolonia, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peIdLocalidad', peidlocalidad, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peIdNacionalidad', peidnacionalidad, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peFechaInicio', pefechainicio, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peFechaFin', pefechafin, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peOtrosTerm', peotrosterm, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peTipoContrato', petipocontrato, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peIdTramiteTemp', peidtramitetemp, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peTelefono', petelefono, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peExtension', peextension, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peEmail', peemail, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peDomicilioUno', pedomiciliouno, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peDomicilioDos', pedomiciliodos, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'pePoblacion', pepoblacion, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peZonaPostal', pezonapostal, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'pePaisResidencia', pepaisresidencia, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peBandera', pebandera, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peAfolExiste', peafolexiste, 'IN');
        call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peNIFP', penifp, 'IN');
    end;



    select id_grupo, id_perfil, cve_perfil
      into vlgrupo, vlidperfil, vlperfil
      from rug.v_usuario_sesion_rug
     where id_persona =  peidusuario;

    -- el grupo 1 se asigna a la relacion del usuario con el acreedor
    if(vlidperfil != 4 or vlgrupo != 15) then
        vlgrupo := 1;                        
    end if;

    if vlexiste = 1 then

        psresult := 115;
        raise notice '%', ex_error; 
       pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

    end if;

    --valida que la nacionalidad sea valida
    select count(*)
      into vlresult
      from rug.rug_cat_nacionalidades
     where id_nacionalidad = peidnacionalidad;

    if vlresult = 0 then

        psresult := 19;
        raise notice '%', ex_error;
       pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

    end if;

    -- valida el pais de residencia 
    select count(*)
      into vlresult
      from rug.rug_cat_nacionalidades
     where id_nacionalidad = pepaisresidencia;


    if vlresult = 0 then

        psresult := 117;
        raise notice '%', ex_error;
       pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

    end if;


    -- valida colonia -- nacionalidad mexicana 
    if peidnacionalidad = 1 then

        if peidcolonia > 0 then

            select count(*)
              into vlresult
              from rug.v_se_cat_colonias_rug
             where id_colonia = peidcolonia;

            if vlresult = 0 then

                psresult := 119;
                raise notice '%', ex_error;
               pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

            end if;

        end if;


        if peidlocalidad > 0 then

            select count(*)
              into vlresult
              from rug.v_se_cat_localidades_rug
             where id_localidad = peidlocalidad;

            if vlresult = 0 then

                psresult := 120;
                raise notice '%', ex_error;
               pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

            end if;

        end if;



    end if;

   -- rfc es obligatorio para personas mexicanas menos para sociedad mercantil, persona moral
    if peidnacionalidad = 1 and (perfc is null or perfc = '') and idtipo <> 'SM' and pebandera = 1 then

        vlpsresultvalrfc := 110;
        vlpstxtresultvalrfc := rug.rug.fn_mensaje_error(vlpsresultvalrfc);

        raise notice '%', ex_errrfc;
       psresult := vlpsresultvalrfc;
      pstxresult := vlpstxtresultvalrfc;
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;
    elsif peidnacionalidad = 1 and (perfc is null or perfc = '') and idtipo <> 'SM' and pebandera = 0 then
        vlpsresultvalrfc := 141;
        vlpstxtresultvalrfc := rug.rug.fn_mensaje_error(vlpsresultvalrfc);

        raise notice '%', ex_errrfc;
       psresult := vlpsresultvalrfc;
      pstxresult := vlpstxtresultvalrfc;
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;
    end if;


   --valida rfc
    --rug.sp_valida_rfc(peidnacionalidad, perfc, petipopersona, vlpsresultvalrfc, vlpstxtresultvalrfc);

    if vlpsresultvalrfc <> 0 then
        raise notice '%', ex_errrfc;
       psresult := vlpsresultvalrfc;
      pstxresult := vlpstxtresultvalrfc;
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;
    end if; 


   -- validaciones
    if peidusuario is null or petipopersona is null then

        psresult := 13;
        raise notice '%', ex_error;
       pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

    end if;

    select count(*) 
      into vlnumpartes
      from rug.rug.rug_rel_tram_inc_partes
     where id_tramite_temp = peidtramitetemp and id_parte = 4 and status_reg = 'AC';

    if vlnumpartes > 0 then

        psresult   :=29;
        raise notice '%', ex_error;
       pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

    end if;

    -- validacion del folio electronicos en persona moral mexicana, ot
    if petipopersona = 'PM' and idtipo = 'OT' and  (perfc is not null or trim(perfc) <> '') and peidnacionalidad = 1 and  pebandera = 1 then

      if pefoliomercantil is not null or trim(pefoliomercantil) <> '' then 

        call rug.sp_valida_folio_duplicado(petipopersona, peidnacionalidad, penifp, perfc, pecurp, pefoliomercantil, vlpsresultvalfolio, vlpstxtresultvalfolio);

        if vlpsresultvalfolio <> 0 then

            psresult := vlpsresultvalfolio;
            pstxresult := vlpstxtresultvalfolio;
            raise notice '%', ex_error;
           pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

        end if;

        select count(folio_mercantil)
          into vlfolioelecexist
          from rug.rug_personas
         where upper(rfc) = perfc
           and folio_mercantil is not null;


                if vlfolioelecexist > 0 then

                select folio_mercantil
                  into vlfolioelectronicoexist
                 from ( 
                        select folio_mercantil, fh_registro
                          from rug.rug_personas
                         where upper(rfc) = perfc
                           and folio_mercantil is not null
                         order by fh_registro desc limit 1)b;

                    if vlfolioelectronicoexist <> nvl(pefoliomercantil, '-1') then

                        if vlfolioelectronicoexist is not null or trim(vlfolioelectronicoexist) = '' then

                            raise notice '% - %', pefoliomercantil, perfc;
                            psresult   := 134;
                            pstxresult := rug.rug.fn_mensaje_error(psresult);            
                            pstxresult := replace(pstxresult, '@vlfolioelectronico', vlfolioelectronicoexist);
                            pstxresult := replace(pstxresult, '@vlrfc', perfc);

                            raise notice '%', ex_texto;
                           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peidusuario', peidusuario, 'OUT');
                           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
                           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
                           rollback;

                        end if;

                    end if;

               --elsif pebandera = 1 then   
               else 

                select count(folio_mercantil)
                  into vlfolioelecexist
                  from rug.rug_personas
                 where upper(folio_mercantil) = pefoliomercantil
                   and folio_mercantil is not null;

                           if vlfolioelecexist > 0 then

                                psresult   := 128;
                                pstxresult := rug.rug.fn_mensaje_error(psresult);            
                                pstxresult := replace(pstxresult, '@folio', pefoliomercantil);

                                raise notice '%', ex_texto;
                               call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peidusuario', peidusuario, 'OUT');
                           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
                           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
                           rollback;

                           elsif pefoliomercantil is null or trim(pefoliomercantil) <> '' then 

                                call rug.sp_genera_folio_electronico(vlnvofolioelectronico, vlpsresultvalfolio, vlpstxtresultvalfolio);

                                    if vlpsresultvalfolio <> 0 then
                                          psresult := vlpsresultvalfolio;
                                          pstxresult := vlpstxtresultvalfolio;
                                          raise notice '%', ex_error;
                                         pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;
                                    end if;
                           end if;

               end if;

      elsif (pefoliomercantil is null or trim(pefoliomercantil) = '') and pebandera = 1 then

            call rug.sp_genera_folio_electronico(vlnvofolioelectronico, vlpsresultvalfolio, vlpstxtresultvalfolio);

            if vlpsresultvalfolio <> 0 then
                  psresult := vlpsresultvalfolio;
                  pstxresult := vlpstxtresultvalfolio;
                  raise notice '%', ex_error;
                 pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;
            end if;           

      end if;

    else
         if (perfc is null or trim(perfc) = '') and (pefoliomercantil is not null or trim(pefoliomercantil) <> '') and  petipopersona = 'OT' then

                                psresult   := 135;
                                pstxresult := rug.rug.fn_mensaje_error(psresult);            

                                raise notice '%', ex_error;
                               pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

         end if;
    end if;

 --validaciones para persona moral, sociedad mercantil y bandera 1
 if petipopersona = 'PM' and idtipo = 'SM' and  (pefoliomercantil is null or trim(pefoliomercantil) = '') and peidnacionalidad = 1 and pebandera = 1 then

    psresult   := 142;
    pstxresult := rug.rug.fn_mensaje_error(psresult);            

    raise notice '%', ex_error;
   pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

 end if;

 --validaciones para persona fisica
 if petipopersona = 'PF' then

        --validar nombre
        --  penombre, peapellidop, peapellidom, pecurp

        if(penombre is null or trim(penombre) <> '') then

            psresult := 79;    
            raise notice '%', ex_error;
           pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

        end if;


        if(peapellidop is null or trim(peapellidop) <> ''
        ) then

            psresult := 80;    
            raise notice '%', ex_error;
           pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

        end if;


        if (peidnacionalidad = 1) then

            if(trim(pecurp) <> '' or pecurp is not null) then

                call rug.sp_valida_curp(pecurp, vlpsresultvalcurp, vlpstxtresultvalcurp);

                if vlpsresultvalcurp <> 0 then

                    psresult := vlpsresultvalcurp;                    
                    raise notice '%', ex_error;
                   pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

                end if;  

                vlcurp := upper(pecurp);                                       

                select count(*)
                  into vlcountcurpexiste
                  from rug.rug_personas_fisicas a , rug.rug_personas b
                 where upper(a.curp) = vlcurp
                   and a.id_persona = b.id_persona
                   and b.sit_persona != 'BF';


                -- valida que el curp no tenga folio asociado para persona fisicas
                if vlpsresultvalcurp = 0 then

                    select count(a.folio_mercantil)
                      into vlfolioelecexist
                      from rug_personas a,
                           rug_personas_fisicas b
                     where a.id_persona = b.id_persona
                       and a.id_nacionalidad = 1
                       and b.curp = vlcurp
                       and a.folio_mercantil != case when pefoliomercantil = '' then '' else pefoliomercantil end;

                    if vlfolioelecexist > 0 then

                        psresult := 138;
                        pstxresult := rug.rug.fn_mensaje_error(psresult);            
                        pstxresult := replace(pstxresult,  '@vlfolioelectronico', pefoliomercantil);


                        raise notice '%', ex_texto;
                       call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peidusuario', peidusuario, 'OUT');
                           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
                           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
                           rollback;
                    else
                            if (pefoliomercantil is null or trim (pefoliomercantil) = '') and pebandera = 1 then 

                               call rug.sp_genera_folio_electronico(vlnvofolioelectronico, vlpsresultvalfolio, vlpstxtresultvalfolio);

                                    if vlpsresultvalfolio <> 0 then
                                          psresult := vlpsresultvalfolio;
                                          pstxresult := vlpstxtresultvalfolio;
                                          raise notice '%', ex_error;
                                         pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;
                                    end if;
                            else

                                call rug.sp_valida_folio_duplicado(petipopersona, peidnacionalidad, penifp, perfc, pecurp, pefoliomercantil, vlpsresultvalfolio, vlpstxtresultvalfolio);


                                if vlpsresultvalfolio <> 0 then

                                    psresult := vlpsresultvalfolio;
                                    pstxresult := vlpstxtresultvalfolio;
                                    raise notice '%', ex_error;
                                   pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

                                end if; 

                            end if;

                    end if;


              end if;        

            else

              if (vlpsresultvalcurp is null or trim(vlpsresultvalcurp) = '') and (pefoliomercantil is not null or trim (pefoliomercantil) <> '') and pebandera = 0  then

                    psresult := 146;
                    pstxresult := rug.fn_mensaje_error(psresult);            

                    raise notice '%', ex_error;  
                   pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

              elsif (vlpsresultvalcurp is null or trim(vlpsresultvalcurp) = '') and pebandera = 1 then

                    psresult := 65;
                    pstxresult := rug.fn_mensaje_error(psresult);            

                    raise notice '%', ex_error;   
                   pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

              end if;    

            end if;

        --else
            --sp_genera_folio_electronico(vlnvofolioelectronico, vlpsresultvalfolio, vlpstxtresultvalfolio);                
        end if;        

    end if;      


   -- validacion del folio electronicos en persona moral y fisica extranjera


     if ((perfc is not null or trim(perfc) <> '') or (penifp is not null or trim(penifp) <> '') )and peidnacionalidad <> 1  then

     raise notice 'Persona extranjera!';

        if petipopersona = 'PF' then
             select count(folio_mercantil)
              into vlfolioelecexist
              from rug_personas
             where upper(rfc) = perfc
               and id_nacionalidad = peidnacionalidad
               and folio_mercantil is not null;
        else 
            select count(folio_mercantil)
              into vlfolioelecexist
              from rug_personas
             where upper(nifp) = penifp
               and id_nacionalidad = peidnacionalidad
               and folio_mercantil is not null;
        end if;               

                raise notice 'vlfolioelecexist %', vlfolioelecexist;

                if vlfolioelecexist > 0 then

                    if petipopersona = 'PF' then
                        select folio_mercantil
                          into vlfolioelectronicoexist
                         from ( 
                                select folio_mercantil, fh_registro
                                  from rug_personas
                                 where upper(rfc) = perfc
                                    
                                   and folio_mercantil is not null
                                 order by fh_registro desc limit 1)b;
                    else
                                select folio_mercantil
                                  into vlfolioelectronicoexist
                                 from ( 
                                        select folio_mercantil, fh_registro
                                          from rug_personas
                                         where upper(nifp) = penifp
                                           
                                           and folio_mercantil is not null
                                         order by fh_registro desc limit 1)c;
                     end if;


                 if vlfolioelectronicoexist <> nvl(pefoliomercantil, '-1') then

                     if vlfolioelectronicoexist is not null or trim(vlfolioelectronicoexist) = '' then

      --------------------------------validacion de bandera acreedores extranjeros
                      if peafolexiste <> 1 then
                                psresult   := 137;
                                pstxresult := rug.fn_mensaje_error(psresult);            
                                pstxresult := replace(pstxresult, '@vlfolioelectronico', vlfolioelectronicoexist);

                                if  petipopersona = 'PF' then
                                    pstxresult := replace(pstxresult, '@vlnif', perfc);
                                else 
                                    pstxresult := replace(pstxresult, '@vlnif', penifp);
                                end if;

                                raise notice '%', ex_texto;  
                               call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'peidusuario', peidusuario, 'OUT');
                           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
                           call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
                           rollback;
                        end if;
                   end if;
      --------------------------------validacion de bandera acreedores extranjeros                

                  end if;

               else

               raise notice 'pefoliomercantil=%', pefoliomercantil;
                if (pefoliomercantil is null or trim (pefoliomercantil) = '') and pebandera = 1 then  
                    raise notice 'generafolio!!!!!';

                   call rug.sp_genera_folio_electronico(vlnvofolioelectronico, vlpsresultvalfolio, vlpstxtresultvalfolio);

                   raise notice 'generado :%', vlnvofolioelectronico;

                        if vlpsresultvalfolio <> 0 then

                              psresult := vlpsresultvalfolio;
                              pstxresult := vlpstxtresultvalfolio;
                              raise notice '%', ex_error;
                             pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;
                        end if; 

                elsif petipopersona = 'PM' and (penifp is not null or trim(penifp) <> '') and (pefoliomercantil is not null or trim(pefoliomercantil) <> '') then

                    call rug.sp_valida_folio_duplicado(petipopersona, peidnacionalidad, penifp, perfc, pecurp, pefoliomercantil, vlpsresultvalfolio, vlpstxtresultvalfolio);


                    if vlpsresultvalfolio <> 0 then

                            psresult := vlpsresultvalfolio;
                            pstxresult := vlpstxtresultvalfolio;
                            raise notice '%', ex_error;
                           pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

                    end if;
                end if;  
               end if;
     else


          if (penifp is null or trim(penifp) = '') and peidnacionalidad <> 1 and ((pefoliomercantil is null or trim(pefoliomercantil) ='') or (pefoliomercantil is not null or trim(pefoliomercantil) <> ''))  and pebandera = 1 and petipopersona = 'PM'   then
                psresult   := 140;
                pstxresult := rug.fn_mensaje_error(psresult);            

                raise notice '%', ex_error;
               pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;
          elsif  (penifp is null or trim(penifp) = '') and peidnacionalidad <> 1 and (pefoliomercantil is not null or trim(pefoliomercantil) <> '') and pebandera = 0 and petipopersona = 'PM' then
                psresult   := 144;
                pstxresult := rug.fn_mensaje_error(psresult);            

                raise notice '%', ex_error;
               pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

          --persona fisica y extranjera
          elsif petipopersona = 'PF' and peidnacionalidad <> 1 and (pefoliomercantil is null or trim(pefoliomercantil) = '')  then

               select count(folio_mercantil)
                 into vlfolioelecexist
                 from rug_personas
                where folio_mercantil = pefoliomercantil
                  and id_nacionalidad = peidnacionalidad;

                   if vlfolioelecexist = 0 and pebandera = 1 then

                        call rug.sp_genera_folio_electronico(vlnvofolioelectronico, vlpsresultvalfolio, vlpstxtresultvalfolio);

                        if vlpsresultvalfolio <> 0 then
                              psresult := vlpsresultvalfolio;
                              pstxresult := vlpstxtresultvalfolio;
                              raise notice '%', ex_error;
                             pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;
                        end if; 

                   end if;

          elsif petipopersona = 'PF' and peidnacionalidad <> 1 and (pefoliomercantil is not null or trim(pefoliomercantil) <> '')  then

               select count(folio_mercantil)
                 into vlfolioelecexist
                 from rug_personas
                where folio_mercantil = pefoliomercantil
                  and id_nacionalidad = peidnacionalidad;

                   if vlfolioelecexist =  0 then
                        psresult := 145;
                        pstxresult := rug.fn_mensaje_error(psresult);            

                        raise notice '%', ex_error;  
                       pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;
                   end if;

          end if;

     end if;     


    vliddomicilio := seq_rug_id_domicilio.nextval;

    if(pepaisresidencia != 1) then

        insert into rug.rug_domicilios_ext(id_domicilio, id_pais_residencia,ubica_domicilio_1, ubica_domicilio_2, poblacion, zona_postal)
        values(vliddomicilio, pepaisresidencia, pedomiciliouno, pedomiciliodos, pepoblacion, pezonapostal);

    else            

        insert into rug.rug_domicilios (id_domicilio, calle, num_exterior, num_interior, id_colonia, id_localidad)
        values   (vliddomicilio, pecalle, penumext, penumint, decode(peidcolonia, -1, 0,peidcolonia), decode(peidlocalidad,-1,0,peidlocalidad));

    end if;                


    vlidpersona:= seq_rug_id_persona.nextval;    

    --raise notice 'asignacion de folio');
    --raise notice 'vlnvofolioelectronico :' || vlnvofolioelectronico);
    --raise notice 'pefoliomercantil :' || pefoliomercantil);
    --raise notice 'peafolexiste :' || peafolexiste);

    if(pefoliomercantil = '' or pefoliomercantil is null) then
    --raise notice 'if folio mercantil null');
            if vlfolioelecexist > 0 then
                psfolioelectronico := vlfolioelectronicoexist;
            else
                psfolioelectronico := vlnvofolioelectronico;
            end if;
    else    
        psfolioelectronico := pefoliomercantil;        
    end if;



    insert into rug_personas (id_persona, rfc, id_nacionalidad, per_juridica, fh_registro, procedencia, sit_persona,
                                 cve_nacionalidad, id_domicilio, folio_mercantil, fecha_inscr_cc, reg_terminado, e_mail, curp_doc, nifp)
    values   (vlidpersona, perfc, peidnacionalidad, petipopersona, trunc(current_timestamp), 'nal', 'AC', null, vliddomicilio, psfolioelectronico, null, 'N', peemail, pecurp, penifp);

    psidpersonainsertar := vlidpersona; 

    insert into rug_telefonos
    values(vlidpersona, null, petelefono, peextension, current_timestamp, 'AC'); 


    if(upper(petipopersona) = 'PM') then


        if perazonsocial is null or perazonsocial = '' then 

            psresult := 77;
            raise notice '%', ex_error;
           pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

        end if;


        insert into rug_personas_morales (id_persona, razon_social, tipo)
        values   (vlidpersona, perazonsocial, idtipo);


    elsif (upper(petipopersona) = 'PF') then


        if penombre is null or penombre = '' then

            psresult := 79;
            raise notice '%', ex_error;
           pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

        end if;


        if peapellidop is null or peapellidop = '' then

            psresult := 80;
            raise notice '%', ex_error;
           pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

        end if;


        insert into rug_personas_fisicas (id_persona, nombre_persona, ap_paterno, ap_materno, curp)
        values   (vlidpersona, penombre, peapellidop, peapellidom, pecurp);

    end if;

    --vlidtramiterugincom:= seq_tram_incomp.nextval;


    insert into rug.rel_usu_acreedor
    values (peidusuario, vlidpersona, 'N', current_timestamp, 'AC');


    insert into rug.rug_rel_grupo_acreedor
    values(nextval('rug.rug_rel_grupo_acreedor_id_reg_seq'), vlidpersona, peidusuario, peidusuario, 'AC', current_timestamp, vlgrupo) ;


    vlidcontrato := nextval('rug.rug_contrato_id_contrato_seq');


    insert into rug.rug_contrato (id_contrato, fecha_inicio, fecha_fin, otros_terminos_contrato, tipo_contrato, 
                        id_tramite_temp, fecha_reg, status_reg, id_usuario)
    values(vlidcontrato, pefechainicio, pefechafin, peotrosterm, petipocontrato, peidtramitetemp, current_timestamp, 'AC', peidusuario);


    insert into rug.rug_rel_tram_inc_partes
    values (peidtramitetemp, vlidpersona, 4, petipopersona, 'AC', current_timestamp);


    call rug.sp_alta_bitacora_tramite2(peidtramitetemp, 5, 0, current_timestamp, 'F', vlresult, vltextresult);

    if vlresult != 0 then

        psresult   := vlresult;
        pstxresult := vltextresult;            

        raise notice '%', ex_error;
       pstxresult := rug.fn_mensaje_error(psresult);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

    end if;

    rollback;


    psresult   :=0;        
    pstxresult :='Actualizacion finalizada satisfactoriamente';

    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psfolioelectronico', psfolioelectronico, 'OUT');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
    call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');    


exception

when others then
      psresult  := 999;   
      pstxresult:= substr(sqlstate||':'||sqlerrm,1,250);
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psResult', psresult, 'OUT');
      call rug.reg_param_pls(nextval('rug.rug_param_pls_id_registro_seq'), 'SP_ALTA_ACREEDOR_REP', 'psTxResult', pstxresult, 'OUT');
      rollback;

end;
$procedure$;