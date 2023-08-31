

create or replace view rug.v_acreedores_fisicos as 
select pfis.nombre_persona || ' ' || pfis.ap_paterno || ' ' || pfis.ap_materno
               as nombre,
            r_per.folio_mercantil,
            r_per.rfc
     from   rug.rug_personas r_per
            inner join rug.rug_personas_fisicas pfis on r_per.id_persona = pfis.id_persona
    where   r_per.per_juridica = 'PF';

-- view v_acreedores_fisicos  


create or replace view rug.v_acreedores_morales as 
select rpm.razon_social as nombre, rper.folio_mercantil, rper.rfc
     from      rug.rug_personas_morales rpm
            inner join
               rug.rug_personas rper
            on rper.id_persona = rpm.id_persona
    where   rper.per_juridica = 'PM';

-- view v_acreedores_morales  


create or replace view rug.v_anotacion_con_garantia as select   ra.id_garantia,
            ra.autoridad_autoriza,
            ra.anotacion,
            ra.id_tramite_temp,
            ra.id_usuario,
            rg.id_moneda,
            ra.vigencia_anotacion,
            rcm.desc_moneda
     from   rug.rug_anotaciones ra, rug.rug_garantias rg, rug.rug_cat_monedas rcm
    where   rg.id_garantia = ra.id_garantia and rcm.id_moneda = rg.id_moneda;

-- view v_anotacion_con_garantia  


create or replace view rug.v_anotacion_con_garantia_firma as 
select  ra.id_tramite_temp,
            ra.id_anotacion,
            ra.anotacion,
            ra.autoridad_autoriza,
            rg.vigencia,
            rg.id_tipo_garantia,
            rctg.desc_tipo_garantia,
            rg.fecha_reg,
            rg.monto_maximo_garantizado,
            rg.otros_terminos_garantia,
            rg.tipos_bienes_muebles,
            rg.desc_garantia desc_bienes_muebles,
            rg.ubicacion_bienes,
            rg.fecha_inscr fecha_celeb_acto,
            rp.id_persona,
            rp.rfc,
            rp.folio_mercantil,
            rp.id_domicilio,
            rp.per_juridica,
            case when rp.per_juridica = 'PF' then
            (select      f.nombre_persona
                         || ' '
                         || f.ap_paterno
                         || ' '
                         || f.ap_materno
                  from   rug.rug_personas_fisicas f
                 where   f.id_persona = rp.id_persona)
                 when rp.per_juridica = 'PM' then
               (select   m.razon_social
                  from   rug.rug_personas_morales m
                 where   m.id_persona = rp.id_persona
            ) end as
               nombre,
            rrtp.id_parte,
            rpar.desc_parte,
            rg.id_moneda,
            rcm.desc_moneda
     from   rug.rug_anotaciones ra,
            rug.rug_rel_tram_garan rrtg,
            rug.rug_garantias rg,
            rug.rug_rel_tram_partes rrtp,
            rug.rug_personas rp,
            rug.rug_partes rpar,
            rug.rug_cat_tipo_garantia rctg,
            rug.tramites_rug_incomp tri,
            rug.rug_cat_monedas rcm
    where       rctg.id_tipo_garantia = rg.id_tipo_garantia
            and rcm.id_moneda = rg.id_moneda
            and rpar.id_parte = rrtp.id_parte
            and rp.id_persona = rrtp.id_persona
            and rrtp.id_tramite = rrtg.id_tramite
            and rrtg.id_garantia = ra.id_garantia
            and rg.id_garantia = ra.id_garantia
            and tri.id_tramite_temp = ra.id_tramite_temp
            and tri.id_status_tram = 5;


-- view v_anotacion_con_garantia_firma  



create or replace view rug.v_anotacion_firma as 
select tri.id_tramite_temp as id_tramite_temp,                        --anotacion con garantia
          tpp.descripcion as desc_tramite_temp,
          ra.anotacion,
          ra.autoridad_autoriza,
          ra.vigencia_anotacion,
          rgg.vigencia as vigencia_garantia,
          ra.id_garantia,
          rct.desc_tipo_garantia,
          rgg.monto_maximo_garantizado,
          rgg.otros_terminos_garantia,
          rrb.id_tipo_bien,
          rgg.tipos_bienes_muebles,
          rgg.desc_garantia as desc_bienes_muebles,
          rgg.ubicacion_bienes,
          rgg.fecha_inscr as fecha_celeb_acto,
          null id_persona,
          null per_juridica,
          null nombre_otorgante,
          null ap_paterno_otorgante,
          null ap_materno_otorgante,
          null razon_social_otorgante,
          null rfc,
          null folio_mercantil,
          null curp,
          null desc_parte,
          rgg.id_moneda,
          rcm.desc_moneda
     from rug.tramites_rug_incomp tri,
          rug.rug_cat_tipo_tramite tpp,
          rug.rug_anotaciones ra,
          rug.rug_garantias rgg,
          rug.rug_rel_gar_tipo_bien rrb,
          rug.rug_cat_tipo_garantia rct,
          rug.rug_cat_monedas rcm
    where     tri.id_tramite_temp = ra.id_tramite_temp
          and tri.id_tipo_tramite = tpp.id_tipo_tramite
          and rcm.id_moneda = rgg.id_moneda
          and ra.id_garantia = rgg.id_garantia
          --and rgg.relacion_bien = rrb.relacion_bien
          and rgg.id_garantia_pend = rrb.id_garantia_pend
          and rgg.id_tipo_garantia = rct.id_tipo_garantia
   union all
   select trix.id_tramite_temp as id_tramite_temp,                        --anotacion sin garantia
          tpp.descripcion as desc_tramite_temp,
          rasg.anotacion,
          rasg.autoridad_autoriza,
          rasg.vigencia_anotacion,
          null vigencia_garantia,
          null id_garantia,
          null desc_tipo_garantia,
          null monto_maximo_garantizado,
          null otros_terminos_garantia,
          null id_tipo_bien,
          null tipos_bienes_muebles,
          null desc_bienes_muebles,
          null ubicacion_bienes,
          null fecha_celeb_acto,
          rasg.id_persona,
          rpp.per_juridica,
          (select nombre_persona
                           from rug.rug_personas_fisicas
                          where id_persona = rasg.id_persona)
             as nombre_otorgante,
          (select ap_paterno
                           from rug.rug_personas_fisicas
                          where id_persona = rasg.id_persona)
             as ap_paterno_otorgante,
          (select ap_materno
                           from rug.rug_personas_fisicas
                          where id_persona = rasg.id_persona)
             as ap_materno_otorgante,
          (select razon_social
                           from rug.rug_personas_morales
                          where id_persona = rasg.id_persona)
             as razon_social_otorgante,
          rpp.rfc,
          rpp.folio_mercantil,
          (select curp
                           from rug.rug_personas_fisicas
                          where id_persona = rasg.id_persona)
             curp,
          rpa.desc_parte,
          0 as id_moneda,
          'NO APLICA' desc_moneda
     from rug.tramites_rug_incomp trix,
          rug.rug_anotaciones_sin_garantia rasg,
          rug.rug_cat_tipo_tramite tpp,
          rug.rug_personas rpp,
          rug.rug_rel_tram_inc_partes tti,
          rug.rug_partes rpa
    where     trix.id_tramite_temp = rasg.id_tramite_temp
          and trix.id_tipo_tramite = tpp.id_tipo_tramite
          and rasg.id_persona = rpp.id_persona
          and trix.id_tramite_temp = tti.id_tramite_temp
          and tti.id_parte = rpa.id_parte
          and tti.status_reg = 'AC';

-- view v_anotacion_firma  



create or replace view rug.v_anotacion_sin_garantia as select   ann.id_tramite_temp,
            ann.id_anotacion,
            ann.autoridad_autoriza,
            ann.id_persona,
            rpp.per_juridica,
            rpp.folio_mercantil,
            rpp.rfc,
            rpf.curp,
            ann.anotacion,
            rpp.id_nacionalidad,
            rpf.nombre_persona,
            rpf.ap_paterno,
            rpf.ap_materno,
            rpm.razon_social,
            ann.vigencia_anotacion
     from               rug.rug_anotaciones_sin_garantia ann
                     left join
                        rug.rug_personas rpp
                     on ann.id_persona = rpp.id_persona
                  left join
                     rug.rug_personas_fisicas rpf
                  on ann.id_persona = rpf.id_persona
               left join
                  rug.rug_personas_morales rpm
               on ann.id_persona = rpm.id_persona
            inner join
               rug.rug_bitac_tramites rbt
            on rbt.id_tramite_temp = ann.id_tramite_temp
               and rbt.id_status = 5;


-- view v_anotacion_sin_garantia  



create or replace view rug.v_anotacion_tram_cancelacion as select t.id_tramite
         , ta.id_anotacion_temp
         , ta.id_tramite_padre
         , t.id_tipo_tramite
         , t.id_status_tram
         , ta.id_garantia
      from rug.rug_anotaciones_seg_inc_csg ta
     inner join rug.tramites t
        on t.id_tramite_temp = ta.id_anotacion_temp
       and t.id_tipo_tramite in (23, 27)  
       and t.status_reg = 'AC';

-- view v_anotacion_tram_cancelacion  



create or replace view rug.v_autoridad as 
select id_autoridad, id_tramite_temp, anotacion_juez 
from rug.rug_autoridad;

-- view v_autoridad  



create or replace view rug.v_autoridad_tramite as 
select   t.id_tramite,
            t.id_tramite_temp,
            t.id_tipo_tramite,
            ra.id_autoridad,
            ra.anotacion_juez
     from   rug.tramites t, rug.rug_autoridad ra
    where   ra.id_tramite_temp = t.id_tramite_temp;

-- view v_autoridad_tramite  



create or replace view rug.v_aviso_preventivo as select   a.id_tramite_temp,
            b.per_juridica,
            b.rfc,
            b.folio_mercantil,
            a.desc_bienes,
            a.id_usuario
     from   rug.rug_personas b, rug.avisos_prev a
    where   a.id_persona = b.id_persona;

-- view v_aviso_preventivo  

 

create or replace view rug.v_aviso_preventivo_firma as select   tri.id_tramite_temp,
            ap.id_persona,
            case when rpp.per_juridica = 'PF' then rpf.nombre_persona
            else null end as nombre,
            case when rpp.per_juridica = 'PF' then rpf.ap_paterno
            else null end as apellido_paterno,
            case when rpp.per_juridica = 'PF' then rpf.ap_materno
            else null end as apellido_materno,
            case when rpp.per_juridica = 'PM' then rpm.razon_social
            else null end as razon_social,
            rcn.desc_nacionalidad as nacionalidad,
            rpp.per_juridica,
            rpp.folio_mercantil,
            rpp.rfc,
            case when rpp.per_juridica = 'PF' then rpf.curp
            else null end as curp,
            ap.desc_bienes
     from   rug.avisos_prev ap,
            rug.tramites_rug_incomp tri,
            rug.rug_personas rpp,
            rug.rug_cat_nacionalidades rcn,
            rug.rug_personas_fisicas rpf,
            rug.rug_personas_morales rpm 
    where       tri.id_tramite_temp = ap.id_tramite_temp
            and rpp.id_persona = ap.id_persona
            and rpp.id_nacionalidad = rcn.id_nacionalidad
            and rpp.id_persona = rpf.id_persona 
            and tri.id_status_tram = 5
            and rpm.id_persona = rpp.id_persona 
            and tri.id_tramite_temp not in
                     (select   id_tramite_temp from rug.tramites);

-- view v_aviso_preventivo_firma  




create or replace view rug.v_boleta_estructura as select   rrbc.id_boleta,
              rcbo.desc_boleta,
              rrbc.id_campo_boleta,
              rccb.desc_campo_boleta,
              rccb.cve_campo_boleta,
              rrbc.orden_campo,
              rrbc.orientacion,
              rrbc.id_seccion_boleta,
              rcbs.desc_seccion_boleta,
              rrbc.orden_seccion,
              rrbc.id_seccion_padre,
              (select   desc_seccion_boleta
                 from   rug.rug_cat_boleta_seccion
                where   id_seccion_boleta = rrbc.id_seccion_padre)
                 as idseccionpadre
       from   rug.rug_rel_boleta_campo rrbc,
              rug.rug_cat_campo_boleta rccb,
              rug.rug_cat_boleta_seccion rcbs,
              rug.rug_cat_boleta rcbo,
              rug.rug_rel_boleta_seccion rrbs
      where       rrbc.id_campo_boleta = rccb.id_campo_boleta
              and rrbc.id_boleta = rcbo.id_boleta
              and rcbs.id_seccion_boleta = rrbc.id_seccion_boleta
              and rrbc.id_boleta = rrbs.id_boleta
              and rrbs.id_seccion = rrbc.id_seccion_boleta
              and rrbc.orientacion in ('H', 'V')
              and rrbc.status_reg = 'AC'
              and rrbs.status_reg = 'AC'
   order by   rrbc.orden_seccion, rrbc.orden_campo;


-- view v_boleta_estructura  



create or replace view rug.v_boleta_estructura_partes as select   rrbp.id_boleta,
            rrbp.id_parte,
            rrbp.id_campo_boleta,
            rccb.desc_campo_boleta,
            rccb.cve_campo_boleta,
            rrbp.orientacion,
            rrbp.orden_campo
     from   rug.rug_rel_boleta_parte rrbp, rug.rug_cat_campo_boleta rccb
    where   rrbp.id_campo_boleta = rccb.id_campo_boleta
            and rrbp.status_reg = 'AC';

-- view v_boleta_estructura_partes  



create or replace view rug.v_cancelacion_transmision as select   rct.id_tramite_temp,
            rtt.id_tipo_tramite,
            rtt.descripcion as tipo_tramite,
            rct.id_cancelacion,
            rct.id_inscripcion
     from         rug.rug_cancelacion_transmision rct
               inner join
                  rug.tramites_rug_incomp tri
               on rct.id_tramite_temp = tri.id_tramite_temp
            inner join
               rug.rug_cat_tipo_tramite rtt
            on tri.id_tipo_tramite = rtt.id_tipo_tramite;

-- view v_cancelacion_transmision  



create or replace view rug.v_catalogo_carga_masiva as 
select ctt.id_tipo_tramite, ctt.descripcion
       from rug.rug_cat_tipo_tramite ctt
      where ctt.b_carga_masiva = 1 and ctt.status_reg = 'AC'
   order by 1;

-- view v_catalogo_carga_masiva  





create or replace view rug.v_datos_contratos as 
select  rcn.id_contrato,
            rcn.id_tramite_temp,
            rcn.tipo_contrato,
            rcn.fecha_inicio as fecha_celeb_contrato,
            rcn.fecha_fin,
            rcn.otros_terminos_contrato
     from   rug.rug_contrato rcn;

-- view v_datos_contratos  




create or replace view rug.v_datos_garantias as 
select   rgg.id_garantia_pend as id_garantia,
            rct.desc_tipo_garantia as tipo_garantia,
            case
               when ttr.id_tipo_tramite in (4, 9, 8)
               then
                  (select   fecha_inscr
                     from   rug.rug_garantias
                    where   id_garantia = rgg.id_garantia_modificar)
               else
                  rgg.fecha_inscr
            end
               as fecha_celeb_acto,
            case
               when ttr.id_tipo_tramite in (4, 9, 8)
               then
                  (select   monto_maximo_garantizado
                     from   rug.rug_garantias
                    where   id_garantia = rgg.id_garantia_modificar)
               else
                  rgg.monto_maximo_garantizado
            end
               as monto_maximo_garantizado,
            case
               when ttr.id_tipo_tramite in (4, 9, 8)
               then
                  (select   otros_terminos_garantia
                     from   rug.rug_garantias
                    where   id_garantia = rgg.id_garantia_modificar)
               else
                  rgg.otros_terminos_garantia
            end
               as otros_terminos,
            case
               when ttr.id_tipo_tramite in (4, 9, 8)
               then
                  (select   desc_garantia
                     from   rug.rug_garantias
                    where   id_garantia = rgg.id_garantia_modificar)
               else
                  rgg.desc_garantia
            end
               as desc_bienes_muebles,
            rri.id_tramite_temp,
            rtm.descripcion as desc_tramite_temp,
            case
               when ttr.id_tipo_tramite in (4, 8)
               then
                  (select   vigencia
                     from   rug.rug_garantias
                    where   id_garantia = rgg.id_garantia_modificar)
               else
                  rgg.vigencia
            end
               as vigencia,
            rgg.id_moneda,
            rcm.desc_moneda
     from                 rug.rug_garantias_pendientes rgg
                        left join
                           rug.rug_cat_tipo_garantia rct
                        on rgg.id_tipo_garantia = rct.id_tipo_garantia
                     left join
                        rug.rug_cat_monedas rcm
                     on rcm.id_moneda = rgg.id_moneda
                  left join
                     rug.rug_rel_tram_inc_garan rri
                  on rgg.id_garantia_pend = rri.id_garantia_pend
               left join
                  rug.tramites_rug_incomp ttr
               on ttr.id_tramite_temp = rri.id_tramite_temp
            left join
               rug.rug_cat_tipo_tramite rtm
            on ttr.id_tipo_tramite = rtm.id_tipo_tramite
    where   rgg.id_garantia_pend not in
                  (select   id_garantia_pend
                     from   rug.rug_garantias
                    where   id_garantia_pend is not null)
            and ttr.status_reg = 'AC'
            and ttr.id_status_tram = 5;

-- view v_datos_garantias  



create or replace view rug.v_detalle_contr_garan_basico as select rgg.id_garantia,
          rgg.id_tipo_garantia,
          rcg.desc_tipo_garantia as tipo_garantia,
          rgg.fecha_inscr as fecha_celeb_acto,
          rcn.monto_limite,
          rgg.otros_terminos_garantia as otros_terminos_garantia,
          rgg.desc_garantia as desc_bienes_muebles,
          rcn.tipo_contrato,
          rcn.fecha_inicio as fecha_celeb_contrato,
          rcn.otros_terminos_contrato as otros_terminos_contrato,
          rgg.vigencia,
          rgg.relacion_bien,
          ren.id_tipo_bien,
          rtn.desc_tipo_bien,
          rcn.id_tramite_temp
     from rug.rug_garantias rgg
          left join rug.rug_contrato rcn
             on rgg.id_garantia = rcn.id_garantia_pend
          inner join rug.rug_cat_tipo_garantia rcg
             on rgg.id_tipo_garantia = rcg.id_tipo_garantia
          inner join rug.rug_rel_gar_tipo_bien ren
             --on rgg.relacion_bien = ren.relacion_bien
             on rgg.id_garantia_pend = ren.id_garantia_pend
          inner join rug.rug_cat_tipo_bien rtn
             on ren.id_tipo_bien = rtn.id_tipo_bien;

-- view v_detalle_contr_garan_basico  


            

create or replace view rug.v_detalle_garantia as select   rgh.id_ultimo_tramite as id_tramite,
            rgh.id_garantia,
            rgh.id_tipo_garantia,
            rct.desc_tipo_garantia as tipo_garantia,
            rgh.fecha_inscr as fecha_celeb_acto,
            rgh.fecha_fin_gar as fecha_fin_acto,
            rgh.monto_maximo_garantizado as monto_limite,
            rgh.otros_terminos_garantia,
            rgh.desc_garantia as desc_bienes_muebles,
            rcn.tipo_contrato,
            rcn.fecha_inicio as fecha_celeb_contrato,
            rcn.fecha_fin as fecha_fin_ob,
            rcn.otros_terminos_contrato,
            rgh.vigencia,
            rgh.relacion_bien,
            rcn.id_contrato,
            rgh.cambios_bienes_monto,
            rgh.instrumento_publico,
            rgh.id_moneda,
            rcm.desc_moneda,
            rcn.clasif_contrato,
            rgh.no_garantia_previa_ot
     from            rug.rug_garantias_h rgh
                  inner join
                     rug.rug_cat_tipo_garantia rct
                  on rgh.id_tipo_garantia = rct.id_tipo_garantia
               left join
                  rug.rug_contrato rcn
               on rgh.id_garantia_pend = rcn.id_garantia_pend
            left join
               rug.rug_cat_monedas rcm
            on rcm.id_moneda = rgh.id_moneda
    where   rgh.garantia_status in ('AC', 'CA', 'CT', 'FV');

-- view v_detalle_garantia  




create or replace view rug.v_detalle_tramite_masivo as select   rfm.id_firma_masiva,
            rfm.id_tramite_temp,
            rtr.cve_rastreo,
            t.id_tramite,
            rg.id_garantia,
            rbt.fecha_status,
            t.id_tipo_tramite,
            rg.vigencia,
               rpf.nombre_persona
            || ' '
            || rpf.ap_paterno
            || ' '
            || rpf.ap_materno
               nombre_usuario
     from   rug.rug_firma_masiva rfm,
            rug.rug_tramite_rastreo rtr,
            rug.tramites t,
            rug.rug_garantias_h rg,
            rug.rug_bitac_tramites rbt,
            rug.rug_personas_fisicas rpf
    where       rtr.id_tramite_temp = rfm.id_tramite_temp
            and t.id_tramite_temp = rfm.id_tramite_temp
            and rg.id_ultimo_tramite = t.id_tramite
            and rbt.id_tramite_temp = rfm.id_tramite_temp
            and rpf.id_persona = t.id_persona
            and rbt.id_status = 3
            and t.id_tipo_tramite != 2
            and rbt.status_reg = 'AC'
   union all
   select   rfm.id_firma_masiva,
            rfm.id_tramite_temp,
            rtr.cve_rastreo,
            t.id_tramite,
            0 id_garantia,
            rbt.fecha_status,
            t.id_tipo_tramite,
            15 vigencia,
               rpf.nombre_persona
            || ' '
            || rpf.ap_paterno
            || ' '
            || rpf.ap_materno
               nombre_usuario
     from   rug.tramites t,
            rug.rug_tramite_rastreo rtr,
            rug.rug_firma_masiva rfm,
            rug.rug_bitac_tramites rbt,
            rug.rug_personas_fisicas rpf,
            rug.avisos_prev ap
    where       rfm.id_tramite_temp = rtr.id_tramite_temp
            and rfm.id_tramite_temp = t.id_tramite_temp
            and rbt.id_tramite_temp = rfm.id_tramite_temp
            and rpf.id_persona = t.id_persona
            and ap.id_tramite_temp = rfm.id_tramite_temp
            and rbt.id_status = 3
            and rbt.status_reg = 'AC'
   union all
   select   rfm.id_firma_masiva,
            rfm.id_tramite_temp,
            rtr.cve_rastreo,
            t.id_tramite,
            0 id_garantia,
            rbt.fecha_status,
            t.id_tipo_tramite,
            asg.vigencia_anotacion vigencia,
               rpf.nombre_persona
            || ' '
            || rpf.ap_paterno
            || ' '
            || rpf.ap_materno
               nombre_usuario
     from   rug.tramites t,
            rug.rug_tramite_rastreo rtr,
            rug.rug_firma_masiva rfm,
            rug.rug_bitac_tramites rbt,
            rug.rug_personas_fisicas rpf,
            rug.rug_anotaciones_sin_garantia asg
    where       rfm.id_tramite_temp = rtr.id_tramite_temp
            and rfm.id_tramite_temp = t.id_tramite_temp
            and rbt.id_tramite_temp = rfm.id_tramite_temp
            and rpf.id_persona = t.id_persona
            and asg.id_tramite_temp = rfm.id_tramite_temp
            and rbt.id_status = 3
            and rbt.status_reg = 'AC'
   union all
   select   rfm.id_firma_masiva,
            rfm.id_tramite_temp,
            rtr.cve_rastreo,
            t.id_tramite,
            rg.id_garantia,
            rbt.fecha_status,
            t.id_tipo_tramite,
            ra.vigencia_anotacion vigencia,
               rpf.nombre_persona
            || ' '
            || rpf.ap_paterno
            || ' '
            || rpf.ap_materno
               nombre_usuario
     from   rug.rug_firma_masiva rfm,
            rug.rug_tramite_rastreo rtr,
            rug.tramites t,
            rug.rug_garantias rg,
            rug.rug_bitac_tramites rbt,
            rug.rug_personas_fisicas rpf,
            rug.rug_anotaciones ra
    where       rtr.id_tramite_temp = rfm.id_tramite_temp
            and t.id_tramite_temp = rfm.id_tramite_temp
            and ra.id_tramite_temp = t.id_tramite_temp
            and rg.id_ultimo_tramite = t.id_tramite
            and rbt.id_tramite_temp = rfm.id_tramite_temp
            and rpf.id_persona = t.id_persona
            and rbt.id_status = 3
            and rbt.status_reg = 'AC';


-- view v_detalle_tramite_masivo  






create or replace view rug.v_domicilios_h as 
select   rdh.id_tramite,
            rdh.id_parte,
            rdh.id_persona,
               rdh.calle
            || ' '
            || rdh.num_exterior
            || ' '
            || rdh.num_interior
            || ' '
            || rdh.nom_colonia
            || ' '
            || rdh.nom_deleg_municip
            || ' C.P. '
            || rdh.codigo_postal
            || ', '
            || rdh.nom_estado
               as domicilio,
            1 id_pais_residencia
     from   rug.rug_domicilios_h rdh
   union all
   select   reh.id_tramite,
            reh.id_parte,
            reh.id_persona,
               reh.ubica_domicilio_2
            || ' '
            || reh.ubica_domicilio_1
            || ' '
            || reh.poblacion
            || ' '
            || reh.zona_postal
               as domicilio,
            reh.id_pais_residencia
     from   rug.rug_domicilios_ext_h reh;


-- view v_domicilios_h  





create or replace view rug.v_firma_doctos as select fd.id_firma,
          fm.id_tramite_temp,
          fd.id_usuario_firmo,
          fd.xml_co,
          fd.co_usuairo,
          fd.certificado_usuario_b64,
          fd.firma_usuario_b64,
          fd.co_sello,
          fd.sello_ts_b64,
          fd.co_firma_rug,
          fd.firma_rug_b64,
          fd.fecha_reg,
          fd.status_reg,
          fd.certificado_central_b64,
          fd.procesado
     from    rug.rug_firma_doctos fd
          inner join
             rug.rug_firma_masiva fm
          on fd.id_tramite_temp = fm.id_firma_masiva
   union all
   select id_firma,
          id_tramite_temp,
          id_usuario_firmo,
          xml_co,
          co_usuairo,
          certificado_usuario_b64,
          firma_usuario_b64,
          co_sello,
          sello_ts_b64,
          co_firma_rug,
          firma_rug_b64,
          fecha_reg,
          status_reg,
          certificado_central_b64,
          procesado
     from rug.rug_firma_doctos fd
    where fd.id_tramite_temp not in
             (select id_tramite_temp from rug.rug_firma_masiva);


-- view v_firma_doctos  



create or replace view rug.v_firma_masiva_acreedores as select   rfm.id_firma_masiva,
            (select   count ( * )
               from   rug.rug_firma_masiva
              where   id_firma_masiva = rfm.id_firma_masiva)
               as total_acreedores,
            rfm.id_archivo,
            rbt.fecha_status,
            tri.id_persona as id_usuario
     from         rug.tramites_rug_incomp tri
               inner join
                  rug.rug_firma_masiva rfm
               on rfm.id_tramite_temp = tri.id_tramite_temp
            inner join
               rug.rug_bitac_tramites rbt
            on rfm.id_firma_masiva = rbt.id_tramite_temp
    where       tri.status_reg = 'AC'
            and tri.id_status_tram = 3
            and tri.id_tipo_tramite = 12
            and rbt.id_status = 3
            and rbt.status_reg = 'AC';

-- view v_firma_masiva_acreedores  





create or replace view rug.v_garantias_bienes as select rgh.id_garantia,
            ggt.id_tipo_bien,
            bnt.desc_tipo_bien,
            rgh.relacion_bien
       from rug.rug_garantias_h rgh,
            rug.rug_rel_gar_tipo_bien ggt,
            rug.rug_cat_tipo_bien bnt
      where rgh.id_garantia_pend = ggt.id_garantia_pend
            --and rgh.relacion_bien = ggt.relacion_bien
            and ggt.id_tipo_bien = bnt.id_tipo_bien
            and rgh.garantia_status = 'AC'
   group by rgh.id_garantia,
            ggt.id_tipo_bien,
            bnt.desc_tipo_bien,
            rgh.relacion_bien
   order by id_garantia;

-- view v_garantias_bienes  




create or replace view rug.v_garantias_bienes_pendientes as select   distinct rgg.id_garantia_pend,
                       ggt.id_tipo_bien,
                       bnt.desc_tipo_bien,
                       ggt.relacion_bien
       from         rug.rug_garantias_pendientes rgg
                 inner join
                    rug.rug_rel_gar_tipo_bien ggt
                 on rgg.id_garantia_pend = ggt.id_garantia_pend
              inner join
                 rug.rug_cat_tipo_bien bnt
              on ggt.id_tipo_bien = bnt.id_tipo_bien
      where   rgg.garantia_status = 'AC'
   order by   id_garantia_pend;

-- view v_garantias_bienes_pendientes  




create or replace view rug.v_garantias_pend_bienes as 
select rgp.id_garantia_pend, ggt.id_tipo_bien, bnt.desc_tipo_bien
     from         rug.rug_garantias_pendientes rgp
               inner join
                  rug.rug_rel_gar_tipo_bien ggt
               on rgp.id_garantia_pend = ggt.id_garantia_pend
            inner join
               rug.rug_cat_tipo_bien bnt
            on ggt.id_tipo_bien = bnt.id_tipo_bien;

-- view v_garantias_pend_bienes  



create or replace view rug.v_garantias_validacion as select   rgp.id_garantia_pend,
            rgp.id_tipo_garantia,
            rct.desc_tipo_garantia as tipo_garantia,
            rgp.fecha_inscr as fecha_celeb_acto,
            rgp.monto_maximo_garantizado as monto_limite,
            rgp.otros_terminos_garantia,
            rgp.desc_garantia as desc_bienes_muebles,
            rcn.tipo_contrato,
            rcn.fecha_inicio as fecha_celeb_contrato,
            rcn.otros_terminos_contrato,
            rgp.vigencia,
            rgp.relacion_bien,
            rgp.cambios_bienes_monto,
            rgp.instrumento_publico,
            rcn.fecha_fin fecha_fin_contrato,
            rgp.id_moneda,
            rcm.desc_moneda,
            rgp.no_garantia_previa_ot
     from            rug.rug_garantias_pendientes rgp
                  inner join
                     rug.rug_cat_tipo_garantia rct
                  on rgp.id_tipo_garantia = rct.id_tipo_garantia
               inner join
                  rug.rug_contrato rcn
               on rcn.id_garantia_pend = rgp.id_garantia_pend
            left join
               rug.rug_cat_monedas rcm
            on rcm.id_moneda = rgp.id_moneda;

-- view v_garantias_validacion  




create or replace view rug.v_garantia_acreedor_rep as select   a.id_garantia,
            a.id_persona,
            case when b.per_juridica = 'PF' then
               (select      nombre_persona
                         || ' '
                         || ap_paterno
                         || ' '
                         || ap_materno
                  from   rug.rug_personas_fisicas
                 where   id_persona = a.id_persona)
               when b.per_juridica = 'PM' then
               (select   razon_social
                  from   rug.rug_personas_morales
                 where   id_persona = a.id_persona) end as nombre_acreedor,
            b.per_juridica as persona_juridica
     from   rug.rug_rel_garantia_partes a, rug.rug_personas b, rug.rug_garantias c
    where       a.id_persona = b.id_persona
            and c.id_garantia = a.id_garantia
            and c.id_relacion = a.id_relacion
            and a.id_parte = 4
            and a.status_reg = 'AC';

-- view v_garantia_acreedor_rep  




create or replace view rug.v_garantia_contratos as select   tri.id_tramite,
            tri.id_tramite_temp,
            tri.id_tipo_tramite,
            rctt.descripcion,
            rtg.id_garantia,
            rco.tipo_contrato,
            rco.fecha_inicio as fecha_celeb,
            rco.fecha_fin as fecha_terminacion,
            rco.otros_terminos_contrato,
            rco.clasif_contrato
     from            rug.rug_contrato rco
                  inner join
                     rug.tramites tri
                  on rco.id_tramite_temp = tri.id_tramite_temp
               inner join
                  rug.rug_rel_tram_garan rtg
               on tri.id_tramite = rtg.id_tramite
            inner join
               rug.rug_cat_tipo_tramite rctt
            on rctt.id_tipo_tramite = tri.id_tipo_tramite
    where   tri.id_tipo_tramite in (1, 2, 4, 6, 7, 8, 9, 13, 15, 16, 17)
            and rco.clasif_contrato = 'FU';

-- view v_garantia_contratos  


create or replace view rug.v_garantia_contr_basico as select rgg.id_garantia,
          rgg.id_tipo_garantia,
          rcg.desc_tipo_garantia as tipo_garantia,
          rgg.fecha_inscr as fecha_celeb_acto,
          rcn.monto_limite,
          rgg.otros_terminos_garantia as otros_terminos_garantia,
          rgg.desc_garantia as desc_bienes_muebles,
          rcn.tipo_contrato,
          rcn.fecha_inicio as fecha_celeb_contrato,
          rcn.otros_terminos_contrato as otros_terminos_contrato,
          rgg.vigencia,
          rgg.relacion_bien,
          ren.id_tipo_bien,
          rtn.desc_tipo_bien,
          rcn.id_tramite_temp,
          rgg.id_moneda,
          rcm.desc_moneda
     from rug.rug_garantias rgg
          left join rug.rug_contrato rcn
             on rgg.id_garantia_pend = rcn.id_garantia_pend
          inner join rug.rug_cat_tipo_garantia rcg
             on rgg.id_tipo_garantia = rcg.id_tipo_garantia
          inner join rug.rug_rel_gar_tipo_bien ren
             --on rgg.relacion_bien = ren.relacion_bien
             on rgg.id_garantia_pend = ren.id_garantia_pend
          inner join rug.rug_cat_tipo_bien rtn
             on ren.id_tipo_bien = rtn.id_tipo_bien
          left join rug.rug_cat_monedas rcm on rcm.id_moneda = rgg.id_moneda
    where rgg.garantia_status = 'AC';


-- view rug.v_garantia_contr_basico  



create or replace view rug.v_garantia_contr_firma as select   tti.id_tramite_temp,
            rcn.id_contrato,
            rcn.tipo_contrato,
            rcn.fecha_inicio as fecha_celeb_contrato,
            rcn.fecha_fin,
            rcn.otros_terminos_contrato
     from         rug.tramites_rug_incomp tti
               inner join
                  rug.rug_rel_tram_inc_garan ttg
               on tti.id_tramite_temp = ttg.id_tramite_temp
            inner join
               rug.rug_contrato rcn
            on ttg.id_garantia_pend = rcn.id_garantia_pend
    where   tti.id_status_tram = 5;


-- view v_garantia_contr_firma  



create or replace view rug.v_garantia_contr_inscripcion as select   a.id_garantia,
            a.id_tipo_garantia,
            a.tipo_garantia,
            a.fecha_celeb_acto,
            a.monto_limite,
            a.otros_terminos_garantia,
            a.desc_bienes_muebles,
            a.tipo_contrato,
            a.fecha_celeb_contrato,
            a.otros_terminos_contrato,
            a.vigencia,
            a.relacion_bien,
            a.id_tipo_bien,
            a.desc_tipo_bien,
            a.id_tramite_temp,
            a.id_moneda,
            rcm.desc_moneda
     from   rug.v_garantia_contr_basico a,
            rug.tramites_rug_incomp b,
            rug.rug_cat_monedas rcm
    where       a.id_tramite_temp = b.id_tramite_temp
            and rcm.id_moneda = a.id_moneda
            and b.id_tipo_tramite = 1
            and id_status_tram <> 3;

-- view v_garantia_contr_inscripcion  



create or replace view rug.v_garantia_inscripcion_partes as select   a.id_garantia_pend,
            b.id_persona,
            b.id_tramite_temp,
            case when c.per_juridica = 'PF' then (select   nombre_persona
                             from   rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               as nombre,
            case when c.per_juridica = 'PF' then (select   ap_paterno
                             from   rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               as apellido_paterno,
            case when c.per_juridica = 'PF' then (select   ap_materno
                             from   rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               apellido_materno,
            case when c.per_juridica = 'PM' then (select   razon_social
                             from   rug.rug_personas_morales
                            where   id_persona = b.id_persona) else
                    null end
               as razon_social,
            d.desc_parte,
            c.per_juridica,
            c.folio_mercantil,
            c.rfc
     from   rug.rug_rel_tram_inc_garan a,
            rug.rug_rel_tram_inc_partes b,
            rug.rug_personas c,
            rug.rug_partes d
    where       a.id_tramite_temp = b.id_tramite_temp
            and c.id_persona = b.id_persona
            and b.id_parte = d.id_parte
            and a.id_garantia_pend not in
                     (select   id_garantia_pend from rug.rug_garantias);

-- view v_garantia_inscripcion_partes  







create or replace view rug.v_garantia_modif_partes as select   a.id_garantia,
            a.id_persona,
            c.desc_parte,
            b.per_juridica,
            case when b.per_juridica = 'PF' then (select   nombre_persona
                             from   rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               as nombre,
            case when b.per_juridica = 'PF' then (select   ap_paterno
                             from   rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               as apellido_paterno,
            case when b.per_juridica = 'PF' then (select   ap_materno
                             from   rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               apellido_materno,
            case when b.per_juridica = 'PM' then (select   razon_social
                             from   rug.rug_personas_morales
                            where   id_persona = b.id_persona) else
                    null end
               as razon_social,
            b.folio_mercantil,
            b.rfc
     from   rug.rug_rel_garantia_partes a,
            rug.rug_personas b,
            rug.rug_partes c,
            rug.rug_garantias d
    where       d.id_relacion = a.id_relacion
            and a.id_persona = b.id_persona
            and a.id_parte = c.id_parte;

-- view v_garantia_modif_partes  






create or replace view rug.v_garantia_partes as select   rrp.id_tramite,
            rrg.id_garantia,
            rrp.id_persona,
            rrp.id_parte,
            rgp.desc_parte,
            rrp.per_juridica,
            case when rrp.per_juridica = 'PF' then
               (select      nombre_persona
                         || ' '
                         || ap_paterno
                         || ' '
                         || ap_materno
                  from   rug.rug_personas_fisicas
                 where   id_persona = rrp.id_persona)
               when rrp.per_juridica = 'PM' then
               (select   razon_social
                  from   rug.rug_personas_morales
                 where   id_persona = rrp.id_persona)
            end
               as nombre,
            per.e_mail,
            rt.clave_pais,
            rt.telefono,
            rt.extension,
            per.folio_mercantil,
            per.rfc
     from                  rug.rug_rel_tram_partes rrp
                        inner join
                           rug.rug_personas per
                        on rrp.id_persona = per.id_persona
                     left join
                        rug.rug_telefonos rt
                     on per.id_persona = rt.id_persona
                  inner join
                     rug.rug_partes rgp
                  on rgp.id_parte = rrp.id_parte
               inner join
                  rug.rug_rel_tram_garan rrg
               on rrp.id_tramite = rrg.id_tramite
            inner join
               rug.rug_garantias rgg
            on rgg.id_garantia = rrg.id_garantia
    where   rrp.status_reg = 'AC';

-- view v_garantia_partes  





create or replace view rug.v_garantia_recerr_partes as select   a.id_garantia,
            a.id_persona,
            c.desc_parte,
            b.per_juridica,
            case when b.per_juridica = 'PF' then (select   nombre_persona
                             from   rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               as nombre,
            case when b.per_juridica = 'PF' then (select   ap_paterno
                             from   rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               as apellido_paterno,
            case when b.per_juridica = 'PF' then (select   ap_materno
                             from   rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               apellido_materno,
            case when b.per_juridica = 'PM' then (select   razon_social
                             from   rug.rug_personas_morales
                            where   id_persona = b.id_persona) else
                    null end
               as razon_social,
            b.folio_mercantil,
            b.rfc
     from   rug.rug_rel_garantia_partes a,
            rug.rug_personas b,
            rug.rug_partes c,
            rug.rug_garantias d
    where       d.id_relacion = a.id_relacion
            and a.id_persona = b.id_persona
            and a.id_parte = c.id_parte;

-- view v_garantia_recerr_partes  






create or replace view rug.v_garantia_transmision_partes as select   a.id_garantia,
            a.id_persona,
            c.desc_parte,
            b.per_juridica,
            case when b.per_juridica = 'PF' then (select   nombre_persona
                             from  rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               as nombre,
            case when b.per_juridica = 'PF' then (select   ap_paterno
                             from  rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               as apellido_paterno,
            case when b.per_juridica = 'PF' then (select   ap_materno
                             from  rug.rug_personas_fisicas
                            where   id_persona = b.id_persona) else
                    null end
               apellido_materno,
            case when b.per_juridica = 'PM' then (select   razon_social
                             from   rug.rug_personas_morales
                            where   id_persona = b.id_persona) else
                    null end
               as razon_social,
            b.folio_mercantil,
            b.rfc
     from   rug.rug_rel_garantia_partes a,
            rug.rug_personas b,
            rug.rug_partes c,
            rug.rug_garantias d
    where       d.id_relacion = a.id_relacion
            and a.id_persona = b.id_persona
            and a.id_parte = c.id_parte;

-- view v_garantia_transmision_partes  



create or replace view rug.v_garantia_utram as select   htt.id_garantia,
            htp.fecha_creacion as fecha_inscripcion,
            htt.id_ultimo_tramite as id_tramite,
            htt.id_tipo_tramite,
            rct.descripcion,
            htt.fecha_creacion,
            hpp.fecha_creacion as fecha_ultimo
     from            (select   rgh.id_garantia,
                               rgh.id_ultimo_tramite,
                               tr.id_tipo_tramite,
                               tr.fecha_creacion
                        from   rug.rug_garantias_h rgh, rug.tramites tr
                       where   rgh.id_ultimo_tramite = tr.id_tramite) htt
                  inner join
                     (select   rgh.id_garantia,
                               rgh.id_ultimo_tramite,
                               tr.fecha_creacion,
                               rgh.otros_terminos_garantia,
                               rgh.desc_garantia
                        from   rug.rug_garantias_h rgh, rug.tramites tr
                       where   rgh.id_ultimo_tramite = tr.id_tramite
                               and tr.id_tipo_tramite = 1) htp
                  on htt.id_garantia = htp.id_garantia
               inner join
                  (select   rg.id_garantia,
                            rg.id_ultimo_tramite,
                            tr.fecha_creacion
                     from      rug.rug_garantias rg
                            inner join
                               rug.tramites tr
                            on rg.id_ultimo_tramite = tr.id_tramite) hpp
               on htt.id_garantia = hpp.id_garantia
            inner join
               rug.rug_cat_tipo_tramite rct
            on htt.id_tipo_tramite = rct.id_tipo_tramite;

-- view v_garantia_utram  




create or replace view rug.v_gar_t_bien_firma as select   rrgt.id_garantia_pend id_garantia,
            rctb.desc_tipo_bien,
            vdg.id_tramite_temp
     from         rug.rug_rel_gar_tipo_bien rrgt
               left join
                  rug.rug_cat_tipo_bien rctb
               on rrgt.id_tipo_bien = rctb.id_tipo_bien
            left join
               rug.v_datos_garantias vdg
            on rrgt.id_garantia_pend = vdg.id_garantia;

-- view v_gar_t_bien_firma  




create or replace view rug.v_grupos as select   rg.id_acreedor,
              rg.id_persona_crea,
              rg.id_grupo,
              rg.desc_grupo,
              rp.id_privilegio,
              rp.desc_privilegio,
              rp.html,
              case
                 when rp.id_privilegio in (11, 12, 13, 15, 18) then 0
                 else 1
              end
                 visibles
       from   rug.rug_grupos rg,rug.rug_privilegios rp, rug.rug_rel_grupo_privilegio rrgp
      where       rp.id_privilegio = rrgp.id_privilegio
              and rrgp.id_grupo = rg.id_grupo
              and rg.sit_grupo = 'AC'
              and rp.sit_privilegio = 'AC'
              and rrgp.sit_relacion = 'AC'
   order by   rg.id_grupo, rp.id_privilegio;

-- view v_grupos  




create or replace view rug.v_gtia_cancelada as select   date(rbt.fecha_status) as fecha_cancel, t.id_tramite
     from   rug.rug_bitac_tramites rbt,
            rug.tramites t,
            rug.rug_rel_tram_partes rrt
    where       rbt.id_tramite_temp = t.id_tramite_temp
            and t.id_tipo_tramite = 4
            and rbt.id_status = 3
            and rrt.id_tramite = t.id_tramite
            and rrt.id_parte = 4
            and rbt.status_reg = 'AC';

-- view v_gtia_cancelada  




create or replace view rug.v_mail_pool_pendiente as select rmp.id_mail,
    rmp.id_tipo_correo,
    rmp.id_mail_account,
    rmp.destinatario,
    rmp.destinatario_cc,
    rmp.destinatario_cco,
    rmp.asunto,
    rmp.mensaje,
    rmp.id_status_mail,
    rcs.desc_status_mail,
    rmp.fecha_envio,
    rma.desc_uso_cta,
    rma.smtp_host,
    rma.smtp_port,
    rma.smtp_user_mail,
    rma.smtp_password,
    rma.smtp_auth,
    rma.smtp_ssl_enable,
    rma.mail_content_type
  from rug.rug_mail_pool rmp,
    rug.rug_mail_accounts rma,
    rug.rug_cat_status_mails rcs,
    (select id_tipo_correo, (case id_tipo_correo 
  when 1 then 1 when 2 then 7 when 3 then 8 when 4 then 11 when 5 then 2 when 6 then 4 when 7 then 5 when 8 then 6 when 9 then 10
  when 10 then 9 when 15 then 3 else 12
  end) prioridad from rug.rug_cat_tipo_correo) tabla_prioridad
  where rmp.id_mail_account = rma.id_mail_account
  and rmp.id_status_mail    = rcs.id_status_mail
  and tabla_prioridad.id_tipo_correo = rmp.id_tipo_correo
  and rmp.id_status_mail    = 1
  order by tabla_prioridad.prioridad asc;

-- view v_mail_pool_pendiente  




create or replace view rug.v_operaciones_garantia as select   t.id_tramite,
                      rg.id_garantia,
                      rg.desc_garantia,
                      tri.id_tipo_tramite,
                      rctt.descripcion,
                      t.fecha_creacion
               from   rug.rug_garantias_h rg
              inner join rug.rug_rel_tram_garan rrtg
                 on   rrtg.id_tramite = rg.id_ultimo_tramite
              inner join rug.tramites t
                 on   t.id_tramite = rrtg.id_tramite
              -- ggr 11042013 - mmescn2013-81  /* inicio */
--              inner join rug.tramites_rug_incomp tri
--                 on   t.id_tramite_temp = tri.id_tramite_temp
              inner join ( select ti.id_tramite_temp
                                , ti.id_tipo_tramite
                                , ti.id_status_tram
                             from rug.tramites_rug_incomp ti 
                           union
                           select tai.id_anotacion_temp
                                , ti.id_tipo_tramite
                                , ti.id_status_tram
                             from rug.rug_anotaciones_seg_inc_csg tai
                            inner join rug.tramites_rug_incomp ti
                               on ti.id_tramite_temp = tai.id_anotacion_temp
                            where tai.status_reg = 'AC'
                              and ti.status_reg = 'AC' 
                         ) tri
                 on   t.id_tramite_temp = tri.id_tramite_temp
               -- ggr 11042013 - mmescn2013-81  /* fin */
              inner join rug.rug_cat_tipo_tramite rctt
                 on   t.id_tipo_tramite = rctt.id_tipo_tramite
              where   tri.id_status_tram = 3
           order by   t.id_tramite desc;

-- view v_operaciones_garantia  




create or replace view rug.v_operaciones_pendientes as select   tram.id_persona,
              rctt.id_tipo_tramite,
              rctt.descripcion,
              rctt.precio,
              coalesce (tram.cantidad, 0) as cantidad,
              coalesce (tram.cantidad * rctt.precio, 0) as total
       from   (select * -- ggr 11042013 - mmescn2013-81
                 from ( -- ggr 11042013 - mmescn2013-81
                         select   tri.id_persona,
                                  tri.id_tipo_tramite,
                                  count ( * ) as cantidad
                           from   rug.tramites_rug_incomp tri, rug.rug_bitac_tramites rbt
                          where   rbt.id_tramite_temp = tri.id_tramite_temp
                                  and tri.id_tramite_temp not in
                                           (select   tra.id_tramite_temp
                                              from   rug.tramites tra
                                             where   tra.id_tramite_temp = tri.id_tramite_temp
                                            )
                                  and rbt.id_status = 2
                        group by   tri.id_persona, tri.id_tipo_tramite
                        -- order by   2
                      -- ggr 11042013 - mmescn2013-81 inicio
                      union 
                      select ti.id_persona as id_usuario
                           , ti.id_tipo_tramite
                           , count(*) as cantidad
                        from rug.rug_anotaciones_seg_inc_csg ta
                       inner join rug.tramites_rug_incomp ti
                          on ti.id_tramite_temp = ta.id_anotacion_temp
                       where ti.id_status_tram = 5
                         and ta.id_anotacion_temp not in
                                   ( select t.id_tramite_temp
                                       from rug.tramites t  
                                      where t.id_tramite_temp = ta.id_anotacion_temp 
                                   ) 
                       group by ti.id_persona, ti.id_tipo_tramite
                       -- ggr 11042013 - mmescn2013-81 fin
               ) as b order by 2 -- ggr 11042013 - mmescn2013-81
               ) tram,
              rug.rug_cat_tipo_tramite rctt
      where   tram.id_tipo_tramite = rctt.id_tipo_tramite
        and   rctt.status_reg = 'AC' --  ggr 11042013 - mmescn2013-81
   order by   2;


-- view v_operaciones_pendientes  





create or replace view rug.v_partes_garantia as select   rrtg.id_tramite,
            rrt.id_garantia,
            rrt.id_persona,
            rrt.id_parte,
            rgp.desc_parte,
            per.per_juridica,
            case when per.per_juridica = 'PF' then
               (select      nombre_persona
                         || ' '
                         || ap_paterno
                         || ' '
                         || ap_materno
                  from  rug.rug_personas_fisicas
                 where   id_persona = rrt.id_persona)
               when per.per_juridica =  'PM' then
               (select   razon_social
                  from   rug.rug_personas_morales
                 where   id_persona = rrt.id_persona)
            end
               as nombre,
            per.folio_mercantil,
            per.rfc
     from            rug.rug_rel_garantia_partes rrt
                  inner join
                     rug.rug_personas per
                  on rrt.id_persona = per.id_persona
               inner join
                  rug.rug_partes rgp
               on rrt.id_parte = rgp.id_parte
            inner join
               rug.rug_rel_tram_garan rrtg
            on rrtg.id_garantia = rrt.id_garantia;

-- view v_partes_garantia  




create or replace view rug.v_privilegios as select   id_privilegio,
            desc_privilegio,
            html,
            sit_privilegio,
            id_recurso,
            orden
     from  rug.rug_privilegios
    where   id_privilegio not in
                  (2, 5, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 23, 25,
                  22, 36, 31, 34, 45, 50, 35, 37, 38, 39, 40, 41, 42, 43,44, 51);

-- view v_privilegios  



drop function if exists rug.add_months;
  create or replace function add_months(start timestamp, months int) returns date 
  language plpgsql
  as $function$
declare f_fin date;
begin
  select (start + (months || ' months')::INTERVAL)::date into f_fin;
return f_fin;
  end;
$function$;

-- function rug.add_months




create or replace view rug.v_prorroga as select rgh.id_garantia,
          t.id_tramite,
          vig.fecha_status fecha_inicio,
          add_months (vig.fecha_status, rgh.vigencia) as fecha_fin,
          rgh.vigencia,
          rbc.fecha_status fecha_tramite
     from rug.rug_garantias_h rgh,
          rug.tramites t,
          rug.rug_bitac_tramites rbc,
          (select rrtg.id_garantia, rbb.fecha_status
             from rug.rug_rel_tram_garan rrtg,
                  rug.tramites tt,
                  rug.rug_bitac_tramites rbb
            where     tt.id_tramite = rrtg.id_tramite
                  and tt.id_tramite_temp = rbb.id_tramite_temp
                  and rbb.id_status = 3
                  and tt.id_tipo_tramite = 1) vig
    where     rgh.id_ultimo_tramite = t.id_tramite
          and rbc.id_tramite_temp = t.id_tramite_temp
          and rbc.id_status = 3
          and vig.id_garantia = rgh.id_garantia;

-- view v_prorroga  




create or replace view rug.v_rep_personas as select  /*+index(f)*/ id_persona,
            nombre_persona || ' ' || ap_paterno || ' ' || ap_materno
               nombre_persona
        ,   num_serie        -- ggr 26.04.2013 mmescn2013-80
     from   rug.rug_personas_fisicas f
   union all
   select  /*+index(m)*/ id_persona, razon_social nombre_persona
        ,   null -- ggr 26.04.2013 mmescn2013-80
     from   rug.rug_personas_morales m;

-- view v_rep_personas  




create or replace view rug.v_rep_pers_acr_aut as select   rsu.id_persona,
            rpf.nombre_persona,
            rpf.ap_paterno,
            rpf.ap_materno,
            rsu.cve_usuario,
            rpu.cve_perfil,
            (  select   concat (max(telefono), (case when extension is null then ''
            when extension is not null then concat( ' EXT ', extension)end ))
                 from   rug.rug_telefonos
                where   id_persona = rpf.id_persona
             group by   id_persona, rug_telefonos.extension)
               telefono
     from   rug.rug_personas_fisicas rpf,
            rug.rug_secu_usuarios rsu,
            rug.rug_secu_perfiles_usuario rpu
    where       rpf.id_persona = rsu.id_persona
            and rsu.id_persona = rpu.id_persona
            and cve_perfil in ('ACREEDOR', 'AUTORIDAD');

-- view v_rep_pers_acr_aut  



create or replace view rug.v_rep_tram_persona as select   id_persona,
              --   id_acreedor,
              fecha,
              sum (case when tipo = 1 then 1 else 0 end) as total_tramites,
              sum (case when tipo = 2 then 1 else 0 end) as garantias_inscritas,
              sum (case when tipo = 3 then 1 else 0 end) as avisos_preventivos,
              sum (case when tipo = 4 then 1 else 0 end) as modificaciones,
              sum (case when tipo = 5 then 1 else 0 end) as transmisiones,
              sum (case when tipo = 6 then 1 else 0 end) as rectificacion_por_error,
              sum (case when tipo = 7 then 1 else 0 end) as renovaciones,
              sum (case when tipo = 8 then 1 else 0 end) as cancelaciones,
              sum (case when tipo = 9 then 1 else 0 end) as anotaciones,
              sum (case when tipo = 10 then 1 else 0 end) as alta_acreedor,
              sum (case when tipo = 11 then 1 else 0 end) as certificaciones
       from   (select   1 tipo, t.id_persona, date (rbt.fecha_status) fecha -- solicitudes
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where   t.id_tipo_tramite in
                              (1, 3, 7, 8, 6, 9, 4, 2, 10, 12, 5)
                        and rbt.id_tramite_temp = t.id_tramite_temp
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   2 tipo, t.id_persona, date (rbt.fecha_status) fecha -- solicitudes
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 1
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   3 tipo, t.id_persona, date (rbt.fecha_status) fecha -- avisos
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 3
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   4 tipo, t.id_persona, date (rbt.fecha_status) fecha -- avisos
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 7
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   5 tipo, t.id_persona, date (rbt.fecha_status) fecha -- transmisiones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 8
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   6 tipo, t.id_persona, date (rbt.fecha_status) fecha -- rect x error
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 6
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   7 tipo, t.id_persona, date (rbt.fecha_status) fecha -- renovaciones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 9
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   8 tipo, t.id_persona, date (rbt.fecha_status) fecha -- cancelaciones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 4
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   9 tipo, t.id_persona, date (rbt.fecha_status) fecha -- anotaciones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite in (2, 10)
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   10 tipo, t.id_persona, date (rbt.fecha_status) fecha -- alta acreedor
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 12
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   11 tipo, t.id_persona, date (rbt.fecha_status) fecha -- certificaciones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 5
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC')b
   group by   id_persona, fecha;

-- view v_rep_tram_persona  




create or replace view rug.v_rep_tram_usu_acreedor as select   id_persona,
              id_acreedor,
              fecha,
               sum (case when tipo = 1 then 1 else 0 end) as total_tramites,
              sum (case when tipo = 2 then 1 else 0 end) as garantias_inscritas,
              sum (case when tipo = 3 then 1 else 0 end) as avisos_preventivos,
              sum (case when tipo = 4 then 1 else 0 end) as modificaciones,
              sum (case when tipo = 5 then 1 else 0 end) as transmisiones,
              sum (case when tipo = 6 then 1 else 0 end) as rectificacion_por_error,
              sum (case when tipo = 7 then 1 else 0 end) as renovaciones,
              sum (case when tipo = 8 then 1 else 0 end) as cancelaciones,
              sum (case when tipo = 9 then 1 else 0 end) as anotaciones,
              sum (case when tipo = 10 then 1 else 0 end) as alta_acreedor,
              sum (case when tipo = 11 then 1 else 0 end) as certificaciones
       from   (select   1 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha          -- solicitudes
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where   rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite in
                                 (1, 3, 7, 8, 6, 9, 4, 2, 10, 12)
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   1 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha      -- certificaciones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_certificaciones rc,
                        rug.tramites t2,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 5
                        and rbt.id_status = 3
                        and rc.id_tramite_cert = t.id_tramite
                        and rc.id_tramite = t2.id_tramite
                        and rrt.id_tramite = t2.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   2 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha          -- solicitudes
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 1
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   3 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha               -- avisos
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 3
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   4 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha               -- avisos
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 7
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   5 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha        -- transmisiones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 8
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   6 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha         -- rect x error
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 6
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   7 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha         -- renovaciones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 9
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   8 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha        -- cancelaciones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 4
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   9 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha          -- anotaciones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite in (2, 10)
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   10 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha        -- alta acreedor
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 12
                        and rbt.id_status = 3
                        and rrt.id_tramite = t.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC'
               union all
               select   11 tipo,
                        t.id_persona,
                        rrt.id_persona id_acreedor,
                        date (rbt.fecha_status) fecha      -- certificaciones
                 from   rug.rug_bitac_tramites rbt,
                        rug.tramites t,
                        rug.rug_certificaciones rc,
                        rug.tramites t2,
                        rug.rug_rel_tram_partes rrt
                where       rbt.id_tramite_temp = t.id_tramite_temp
                        and t.id_tipo_tramite = 5
                        and rbt.id_status = 3
                        and rc.id_tramite_cert = t.id_tramite
                        and rc.id_tramite = t2.id_tramite
                        and rrt.id_tramite = t2.id_tramite
                        and rrt.id_parte = 4
                        and rbt.status_reg = 'AC')b
   group by   id_persona, id_acreedor, fecha;

-- view v_rep_tram_usu_acreedor  




create or replace view rug.v_resultado_firma_archivo as 
select rrafm.id_archivo, rrafm.id_firma_maisva, ra.archivo
     from rug.rug_rel_archivo_firma_masiva rrafm, rug.rug_archivo ra
    where rrafm.id_archivo = ra.id_archivo;


-- view v_resultado_firma_archivo  




create or replace view rug.v_rug_certificaciones as select   id_tramite_cert,
            id_tramite,
            id_garantia,
            id_tipo_tramite,
            fecha_cert,
            status_reg
     from   rug.rug_certificaciones;

-- view v_rug_certificaciones  



create or replace view rug.v_rug_doctos_firmados as select   dtg.id_tramite_temp,
            tri.id_tramite,
            dtg.cadena_orig_firmada,
            dtg.fh_registro,
            dtg.fh_ult_actualizacion,
            dtg.cadena_orig_no_firmada,
            dtg.cadena_orig_firmada_se,
            dtg.timestamp_se,
            tri.id_tipo_tramite
     from      rug.doctos_tram_firmados_rug dtg
            inner join
               rug.tramites tri
            on dtg.id_tramite_temp = tri.id_tramite_temp;

-- view v_rug_doctos_firmados  




create or replace view rug.v_tramites_firma as select   b.id_tramite,
            a.id_tramite_temp,
            case when a.id_tramite_temp = null then null else 'RUG_FIRMA_DOCTOS' end as
               nombre_tabla,
            id_usuario_firmo
     from   rug.v_firma_doctos a, rug.tramites b
    where   a.id_tramite_temp = b.id_tramite_temp
   union all
   select   b.id_tramite,
            a.id_tramite_temp,
            case when a.id_tramite_temp = null then null else 'RUG_FIRMA_DOCTOS' end as
               nombre_tabla,
            id_usuario_firmo
     from   rug.doctos_tram_firmados_rug a, rug.tramites b
    where   a.id_tramite_temp = b.id_tramite_temp;

-- view v_tramites_firma  





create or replace view rug.v_tramites_mail_vigencia as select   tra.id_tramite_temp,
            tra.id_tramite,
            tra.id_tipo_tramite,
            rga.id_garantia,
            to_char (
               to_date (
                  to_char (
                     add_months (
                        case when usr.nombre_tabla = 'RUG_FIRMA_DOCTOS' then
                                date(rbb.fecha_status) - 6 / 24 else 
                                date(rbb.fecha_status) end,
                        rga.vigencia
                     ),
                     'dd/mm/yyyy hh24:mi'
                  ),
                  'dd/mm/yyyy hh24:mi'
               )
               + 1 / (24 * 60),
               'dd/mm/yyyy hh24:mi'
            )
               fecha_term,
            usr.usuario_mail,
            acr.acreedor,
            acr.acreedor_mail,
            0 id_anotacion
     from   rug.rug_garantias_h rgh,
            rug.tramites tra,
            rug.rug_bitac_tramites rbb,
            (select   id_garantia, vigencia
               from   rug.rug_garantias
              where   garantia_status = 'AC') rga,
            (select   a.id_tramite_temp,
                      b.cve_usuario usuario_mail,
                      a.nombre_tabla
               from   rug.v_tramites_firma a, rug.rug_secu_usuarios b
              where   id_usuario_firmo = b.id_persona) usr,
            (select   id_tramite,
                      e_mail acreedor_mail,
                      case part.per_juridica
                         when 'PF'
                         then
                            (select   trim(initcap(   nombre_persona
                                                   || ' '
                                                   || ap_paterno
                                                   || ' '
                                                   || ap_materno))
                               from  rug.rug_personas_fisicas
                              where   id_persona = part.id_persona)
                         when 'PM'
                         then
                            (select   razon_social
                               from   rug.rug_personas_morales
                              where   id_persona = part.id_persona)
                      end
                         acreedor
               from   rug.rug_rel_tram_partes part, rug.rug_personas per
              where       1 = 1     --                 and id_tramite = 593160
                      and id_parte = 4
                      and part.id_persona = per.id_persona) acr
    where       rgh.id_ultimo_tramite = tra.id_tramite
            and tra.id_tramite = acr.id_tramite
            and rbb.id_tramite_temp = usr.id_tramite_temp
            and tra.id_tramite_temp = rbb.id_tramite_temp
            and rgh.id_garantia = rga.id_garantia
            and tra.id_tipo_tramite = 1
            and rbb.id_status = 3
            and rbb.status_reg = 'AC'
            and to_char (add_months (rbb.fecha_status, rga.vigencia),
                         'dd/mm/yyyy') = to_char (current_date + 15, 'dd/mm/yyyy') -- 5 dias antes se envia el correo
   union all
   select   rasg.id_tramite_temp,
            t.id_tramite,
            t.id_tipo_tramite,
            0 id_garantia,
            to_char (
               to_date (
                  to_char (
                     add_months (
                        case when usr.nombre_tabla ='RUG_FIRMA_DOCTOS' then
                                date(rbt.fecha_status) - 6 / 24 else
                                date(rbt.fecha_status) end,
                        rasg.vigencia_anotacion
                     ),
                     'dd/mm/yyyy hh24:mi'
                  ),
                  'dd/mm/yyyy hh24:mi'
               )
               + 1 / (24 * 60),
               'dd/mm/yyyy hh24:mi'
            )
               fecha_term,
            usr.usuario_mail,
            '' acreedor,
            '' acreedor_mail,
            rasg.id_anotacion
     from   rug.rug_anotaciones_sin_garantia rasg,
            rug.tramites t,
            rug.rug_personas_h rph,
            rug.rug_bitac_tramites rbt,
            (select   a.id_tramite_temp,
                      b.cve_usuario usuario_mail,
                      a.nombre_tabla,
                      a.id_usuario_firmo
               from   rug.v_tramites_firma a, rug.rug_secu_usuarios b
              where   id_usuario_firmo = b.id_persona) usr
    where       t.id_tramite_temp = rasg.id_tramite_temp
            and rph.id_tramite = t.id_tramite
            and rbt.id_tramite_temp = rasg.id_tramite_temp
            and rph.id_tramite = t.id_tramite
            and rph.id_persona = usr.id_usuario_firmo
            and rbt.id_tramite_temp = usr.id_tramite_temp
            and t.id_tipo_tramite = 10
            and rph.id_parte = 6
            and rbt.id_status = 3
            and rbt.status_reg = 'AC'
            and to_char (
                  add_months (rbt.fecha_status, rasg.vigencia_anotacion),
                  'dd/mm/yyyy'
               ) = to_char (current_date + 15, 'dd/mm/yyyy')
   union all
   select   ra.id_tramite_temp,
            t.id_tramite,
            t.id_tipo_tramite,
            rg.id_garantia,
            to_char (
               to_date (
                  to_char (
                     add_months (
                        case when usr.nombre_tabla = 'RUG_FIRMA_DOCTOS' then
                                date(rbt.fecha_status) - 6 / 24 else
                                date(rbt.fecha_status) end, ra.vigencia_anotacion
                        
                     ),
                     'dd/mm/yyyy hh24:mi'
                  ),
                  'dd/mm/yyyy hh24:mi'
               )
               + 1 / (24 * 60),
               'dd/mm/yyyy hh24:mi'
            )
               fecha_term,
            usr.usuario_mail,
            '' acreedor,
            '' acreedor_mail,
            ra.id_anotacion
     from   rug.rug_anotaciones ra,
            rug.tramites t,
            rug.rug_personas_h rph,
            rug.rug_bitac_tramites rbt,
            (select   a.id_tramite_temp,
                      b.cve_usuario usuario_mail,
                      a.nombre_tabla,
                      a.id_usuario_firmo
               from   rug.v_tramites_firma a, rug.rug_secu_usuarios b
              where   id_usuario_firmo = b.id_persona) usr,
            rug.rug_garantias rg
    where       t.id_tramite_temp = ra.id_tramite_temp
            and rph.id_tramite = t.id_tramite
            and rg.id_anotacion = ra.id_anotacion
            and rbt.id_tramite_temp = ra.id_tramite_temp
            and rph.id_tramite = t.id_tramite
            and rph.id_persona = usr.id_usuario_firmo
            and rbt.id_tramite_temp = usr.id_tramite_temp
            and t.id_tipo_tramite = 2
            and rph.id_parte = 6
            and rbt.id_status = 3
            and rbt.status_reg = 'AC'
            and to_char (
                  add_months (rbt.fecha_status, ra.vigencia_anotacion),
                  'dd/mm/yyyy'
               ) = to_char (current_date + 15, 'dd/mm/yyyy');

-- view v_tramites_mail_vigencia  



create or replace view rug.v_tramites_pendientes_acreedor as select   tri.id_persona,
            rrtip.id_persona as id_acreedor,
            tri.id_tramite_temp,
            tri.id_tipo_tramite,
            tri.id_status_tram
     from   rug.tramites_rug_incomp tri, rug.rug_rel_tram_inc_partes rrtip
    where       tri.id_tramite_temp = rrtip.id_tramite_temp
            and tri.id_status_tram not in (3, 7)
            and rrtip.status_reg = 'AC'
            and tri.id_tipo_tramite != 12
            and rrtip.id_parte = 4;


-- view v_tramites_pendientes_acreedor  



create or replace view rug.v_tramites_reasignados as select   rta.id_acreedor,
            tri.id_persona as id_sub_usuario,
            rta.id_tramite_temp,
               rpf.nombre_persona
            || ' '
            || rpf.ap_paterno
            || ' '
            || rpf.ap_materno
               as nombre_subusuario,
            tri.id_tipo_tramite,
            rct.descripcion as desc_tipo_tramite,
            tri.id_status_tram,
            stt.descrip_status,
            rss.url,
            rbb.fecha_status,
            rrt.id_garantia_pend,
            rgp.desc_garantia,
            rgp.id_garantia_modificar
     from   rug.rug_tramites_reasignados rta,
            rug.rug_personas_fisicas rpf,
            rug.rug_cat_tipo_tramite rct,
            rug.status_tramite stt,
            rug.rug_bitac_tramites rbb,
                     rug.tramites_rug_incomp tri
                  left outer join
                     rug.rug_cat_pasos rss
                  on tri.id_paso = rss.id_paso
               left join
                  rug.rug_rel_tram_inc_garan rrt
               on tri.id_tramite_temp = rrt.id_tramite_temp
            left join
               rug.rug_garantias_pendientes rgp
            on rrt.id_garantia_pend = rgp.id_garantia_pend
    where       rta.id_tramite_temp = tri.id_tramite_temp
            and tri.id_persona = rpf.id_persona
            and tri.id_tipo_tramite = rct.id_tipo_tramite
            and tri.id_status_tram = stt.id_status_tram
            and rta.id_tramite_temp = rbb.id_tramite_temp
            and rbb.status_reg = 'AC'
            and tri.status_reg = 'AC';

-- view v_tramites_reasignados  




create or replace view rug.v_tramites_terminados2 as select   tram.id_tramite,
            tram.id_tipo_tramite,
            gtt.descripcion,                        /* rug.rug_cat_tipo_tramite */
            tram.fech_pre_inscr,
            tram.fecha_inscr,
            relt.id_garantia,                     /* reg_rel_tram_inc_garan */
            rtp.id_persona,                        /*rug_rel_tram_inc_partes*/
            rtp.per_juridica,
            case when
               rtp.per_juridica = 'PF' then 
               (select      nombre_persona
                         || ' '
                         || ap_paterno
                         || ' '
                         || ap_materno
                  from  rug.rug_personas_fisicas
                 where   id_persona = rtp.id_persona)
               when rtp.per_juridica = 'PM' then
               (select   razon_social
                  from   rug.rug_personas_morales
                 where   id_persona = rtp.id_persona)
            end 
               as nombre,
            rgp.folio_mercantil,                            /* rug.rug_personas */
            tram.id_status_tram,
            stt.descrip_status,                           /* status_tramite */
            gtt.precio,                             /* rug.rug_cat_tipo_tramite */
            rbb.fecha_status,
            null,
            tram.id_persona as id_persona_login,           /* rug_cat_pasos */
            tram.id_tramite_temp,
            rtp.id_parte,
            case when rtp.id_parte = 1 then (select   rfc
                                        from   rug.rug_personas
                                       where   id_persona = rtp.id_persona)end as
               rfc,
            (select   id_persona
               from   rug.rug_rel_tram_partes
              where   id_tramite = tram.id_tramite and id_parte = 4)
               id_acreedor
     from   rug.tramites tram,
            rug.rug_cat_tipo_tramite gtt,
            rug.rug_rel_tram_garan relt,
            rug.rug_rel_tram_partes rtp,
            rug.rug_personas rgp,
            rug.status_tramite stt,
            rug.rug_bitac_tramites rbb
    where       tram.id_tipo_tramite = gtt.id_tipo_tramite
            and tram.id_tramite = relt.id_tramite
            and tram.id_tramite = rtp.id_tramite
            and rtp.id_parte = 1
            and rgp.id_persona = rtp.id_persona
            and stt.id_status_tram = tram.id_status_tram
            and tram.id_tramite_temp = rbb.id_tramite_temp
            and rbb.id_status = 3
            and relt.status_reg = 'AC'
            and rgp.sit_persona = 'AC'
   union all
   select   tram.id_tramite,
            tram.id_tipo_tramite,
            gtt.descripcion,                        /* rug.rug_cat_tipo_tramite */
            tram.fech_pre_inscr,
            tram.fecha_inscr,
            0 id_garantia,                        /* reg_rel_tram_inc_garan */
            rtp.id_persona,                        /*rug_rel_tram_inc_partes*/
            rtp.per_juridica,
            case when
               rtp.per_juridica = 'PF' then
               (select      nombre_persona
                         || ' '
                         || ap_paterno
                         || ' '
                         || ap_materno
                  from  rug.rug_personas_fisicas
                 where   id_persona = rtp.id_persona)
               when
               rtp.per_juridica = 'PM' then
               (select   razon_social
                  from   rug.rug_personas_morales
                 where   id_persona = rtp.id_persona)
            end
               as nombre,
            rgp.folio_mercantil,                            /* rug.rug_personas */
            tram.id_status_tram,
            stt.descrip_status,                           /* status_tramite */
            gtt.precio,                             /* rug.rug_cat_tipo_tramite */
            rbb.fecha_status,
            null,
            tram.id_persona as id_persona_login,           /* rug_cat_pasos */
            tram.id_tramite_temp,
            rtp.id_parte,
            case when rtp.id_parte = 1 then (select   rfc
                                        from   rug.rug_personas
                                       where   id_persona = rtp.id_persona)end as
               rfc,
            (select   id_persona
               from   rug.rug_rel_tram_partes
              where   id_tramite = tram.id_tramite and id_parte = 4)
               id_acreedor
     from   rug.tramites tram,
            rug.rug_cat_tipo_tramite gtt,
            rug.rug_rel_tram_partes rtp,
            rug.rug_personas rgp,
            rug.status_tramite stt,
            rug.rug_bitac_tramites rbb
    where       tram.id_tipo_tramite = gtt.id_tipo_tramite
            and tram.id_tramite = rtp.id_tramite
            and rtp.id_parte = 1
            and rgp.id_persona = rtp.id_persona
            and tram.id_status_tram = 3
            and stt.id_status_tram = tram.id_status_tram
            and tram.id_tramite_temp = rbb.id_tramite_temp
            and rbb.id_status = 3
            and tram.status_reg = 'AC'
            and rgp.sit_persona = 'AC'
            and gtt.id_tipo_tramite in (10, 3, 11, 5);


-- view v_tramites_terminados2  




create or replace view rug.v_tramites_term_partes as select rtp.id_tramite id_tramite,
          rtp.id_persona,
          rtp.id_parte,
          rgp.desc_parte,
          rtp.per_juridica,
          case when
             rtp.per_juridica =
             'PF' then (select    nombre_persona
                           || ' '
                           || ap_paterno
                           || ' '
                           || ap_materno
                      from rug.rug_personas_fisicas
                     where id_persona = rtp.id_persona)
             when
             rtp.per_juridica = 'PM' then (select razon_social
                      from rug.rug_personas_morales
                     where id_persona = rtp.id_persona)end
             as nombre,
          rpp.folio_mercantil,
          rpp.rfc,
          rpp.curp_doc curp
     from rug.rug_rel_tram_partes rtp
          inner join rug.rug_partes rgp
             on rtp.id_parte = rgp.id_parte
          inner join rug.rug_personas rpp
             on rtp.id_persona = rpp.id_persona
    where rtp.status_reg = 'AC';


-- view v_tramites_term_partes  



create or replace view rug.v_tramites_term_vigencia as select   tra.id_tramite_temp,
            tra.id_tipo_tramite,
            rga.id_garantia,
            to_char (
               to_date (
                  to_char (
                     add_months (
                        case when vtf.nombre_tabla=
                                'RUG_FIRMA_DOCTOS' then
                                date(rbb.fecha_status) - 6 / 24 else
                                rbb.fecha_status end,
                        rga.vigencia
                     ),
                     'dd/mm/yyyy hh24:mi'
                  ),
                  'dd/mm/yyyy hh24:mi'
               )
               + 1 / (24 * 60),
               'dd/mm/yyyy hh24:mi'
            )
     from   rug.rug_garantias_h rgh,
            rug.tramites tra,
            rug.rug_bitac_tramites rbb,
            (select   id_garantia, vigencia
               from   rug.rug_garantias
              where   garantia_status = 'AC') rga,
            rug.v_tramites_firma vtf
    where       rgh.id_ultimo_tramite = tra.id_tramite
            and tra.id_tramite_temp = rbb.id_tramite_temp
            and rgh.id_garantia = rga.id_garantia
            and tra.id_tipo_tramite = 1
            and rbb.id_status = 3
            and rbb.status_reg = 'AC'
            and tra.id_tramite_temp = vtf.id_tramite_temp
            and add_months (rbb.fecha_status, rga.vigencia) < current_date;

-- view v_tramites_term_vigencia  



create or replace view rug.v_tramite_anotacion_juez as select   t.id_tramite,
            t.id_tramite_temp,
            t.id_persona,
            t.id_tipo_tramite,
            rctt.descripcion,
            ra.anotacion_juez,
            ra.fecha_reg
     from   rug.rug_autoridad ra, rug.tramites t, rug.rug_cat_tipo_tramite rctt
    where   ra.id_tramite_temp = t.id_tramite_temp
            and rctt.id_tipo_tramite = t.id_tipo_tramite;

-- view v_tramite_anotacion_juez  



create or replace view rug.v_tram_temp_acreedor_rep as select   rrtip.id_tramite_temp,
            rrtip.id_persona,
            rp.per_juridica,
            case when
               rp.per_juridica =
               'PF' then
               (select      nombre_persona
                         || ' '
                         || ap_paterno
                         || ' '
                         || ap_materno
                  from  rug.rug_personas_fisicas
                 where   id_persona = rp.id_persona)
               when
               rp.per_juridica = 'PM' then
               (select   razon_social
                  from   rug.rug_personas_morales
                 where   id_persona = rp.id_persona) end
            
               as nombre_acreedor
     from   rug.rug_rel_tram_inc_partes rrtip, rug.rug_personas rp
    where   rrtip.id_persona = rp.id_persona and rrtip.id_parte = 4;

-- view v_tram_temp_acreedor_rep  



create or replace view rug.v_usuarios_acreedores as select   tri.id_tramite_temp,
            rua.id_acreedor,
            tri.id_persona id_usuario_login,
            rua.id_usuario id_subusuario,
            rsu.cve_usuario,
               rpf.nombre_persona
            || ' '
            || rpf.ap_paterno
            || ' '
            || rpf.ap_materno
               nombre_completo,
            rpf.nombre_persona,
            rpf.ap_paterno,
            rpf.ap_materno,
            rp.rfc,
            rspu.cve_perfil,
            rrga.id_grupo,
            rg.desc_grupo,
            rua.b_firmado,
            rsu.sit_usuario status_cuenta,
            rrga.status_reg status_rel
     from   rug.rel_usu_acreedor rua,
            rug.rug_rel_grupo_acreedor rrga,
            rug.rug_rel_tram_inc_partes rrti,
            rug.rug_rel_tram_inc_partes rrti2,
            rug.tramites_rug_incomp tri,
            rug.rug_secu_usuarios rsu,
            rug.rug_secu_perfiles_usuario rspu,
           rug.rug_personas_fisicas rpf,
            rug.rug_personas rp,
            rug.rug_grupos rg
    where       rua.id_acreedor = rrga.id_acreedor
            and rrga.id_grupo = rg.id_grupo
            and rua.id_usuario = rrga.id_sub_usuario
            and rua.id_acreedor = rrti.id_persona
            and rrti.id_parte = 4
            and rua.id_usuario = rrti2.id_persona
            and rrti2.id_parte = 5
            and rsu.id_persona = rua.id_usuario
            and rspu.id_persona = rsu.id_persona
            and rpf.id_persona = rsu.id_persona
            and rp.id_persona = rsu.id_persona
            and tri.id_tramite_temp = rrti.id_tramite_temp
            and tri.id_tramite_temp = rrti2.id_tramite_temp
            and rrga.id_usuario = tri.id_persona
            and tri.id_tipo_tramite = 14
            and rrti.status_reg = 'AC'
            and rrti2.status_reg = 'AC';

-- view v_usuarios_acreedores  



create or replace view rug.v_usuarios_acreedor_all as select   rsu.id_persona,
            rsu.cve_usuario e_mail,
            rpf.nombre_persona,
            rpf.ap_paterno,
            rpf.ap_materno,
            rp.rfc
     from   rug.rug_secu_usuarios rsu, rug.rug_personas rp, rug.rug_personas_fisicas rpf
    where   rsu.id_persona = rp.id_persona and rpf.id_persona = rp.id_persona;

-- view v_usuarios_acreedor_all  



create or replace view rug.v_usuarios_all as select   /*+index(rsu) index(rp) index(rpf) index (rspu) */
lower (rsu.cve_usuario) as e_mail,
            rcp.id_perfil,
            rspu.cve_perfil,
            rsu.passwrd,
            rsu.id_persona,
               rpf.nombre_persona
            || ' '
            || rpf.ap_paterno
            || ' '
            || rpf.ap_materno
               nombre_completo,
            rpf.nombre_persona,
            rpf.ap_paterno,
            rpf.ap_materno,
            rp.rfc,
            rsu.preg_recupera_psw,
            rsu.id_grupo,
            rg.desc_grupo,
            rsu.cve_usuario_padre,
            rsu.cve_acreedor,
            rsu.sit_usuario
     from   rug.rug_secu_usuarios rsu,
            rug.rug_personas rp,
           rug.rug_personas_fisicas rpf,
            rug.rug_secu_perfiles_usuario rspu,
            rug.rug_grupos rg,
            rug.rug_cat_perfiles rcp
    where       rsu.id_persona = rp.id_persona
            and rsu.id_persona = rpf.id_persona
            and rsu.cve_usuario = rspu.cve_usuario
            and rspu.cve_perfil = rcp.cve_perfil
            and rg.id_grupo = rsu.id_grupo
            and rp.sit_persona = 'AC'
            and rspu.b_bloqueado = 'F';


-- view v_usuarios_all  




create or replace view rug.v_usuario_acreedor as select   rua.id_acreedor,
            rua.id_usuario,
            rpf.nombre_persona,
            rpf.ap_paterno,
            rpf.ap_materno,
            rp.rfc,
            rp.e_mail,
            rt.telefono,
            rt.extension,
            rsu.sit_usuario,
            rua.b_firmado
     from   rug.rel_usu_acreedor rua,
            rug.rug_secu_usuarios rsu,
            rug.rug_personas rp,
           rug.rug_personas_fisicas rpf,
            rug.rug_telefonos rt
    where       rua.id_usuario = rsu.id_persona
            and rp.id_persona = rsu.id_persona
            and rpf.id_persona = rsu.id_persona
            and rt.id_persona = rsu.id_persona
            and rp.sit_persona = 'AC'
            and rsu.sit_usuario = 'AC'
            and rua.status_reg = 'AC';


-- view v_usuario_acreedor  




create or replace view rug.v_usuario_acreedor_grupos as select   rrga.id_acreedor,
              rrga.id_sub_usuario,
              rspu.cve_perfil,
              rsu.cve_usuario,
              rrga.id_grupo,
              rrgp.id_privilegio,
              rp.desc_privilegio,
              rp.html,
              rp.id_recurso,
              rp.orden,
              rsu.sit_usuario,
              case
                 when rrgp.id_privilegio in (11, 12, 13, 15, 18) then 0
                 else 1
              end
                 visibles,
              case when 
                 rpp.per_juridica=
                 'PF' then
                 (select      f.nombre_persona
                           || ' '
                           || f.ap_paterno
                           || ' '
                           || f.ap_materno
                    from  rug.rug_personas_fisicas f
                   where   f.id_persona = rpp.id_persona)
                 when 
                 rpp.per_juridica=
                 'PM' then
                 (select   m.razon_social
                    from   rug.rug_personas_morales m
                   where   m.id_persona = rpp.id_persona)
              end as
                 nombre_acreedor
       from   rug.rug_secu_usuarios rsu,
              rug.rug_grupos rg,
             rug.rug_privilegios rp,
              rug.rug_rel_grupo_privilegio rrgp,
              rug.rug_rel_grupo_acreedor rrga,
              rug.rug_personas rpp,
              rug.rug_secu_perfiles_usuario rspu,
              rug.rel_usu_acreedor rua
      where       rspu.id_persona = rsu.id_persona
              and rua.id_usuario = rsu.id_persona
              and rua.id_acreedor = rrga.id_acreedor
              and rua.b_firmado = 'Y'
              and rsu.id_persona = rrga.id_sub_usuario
              and rg.id_grupo = rrgp.id_grupo
              and rp.id_privilegio = rrgp.id_privilegio
              and rrga.id_grupo = rrgp.id_grupo
              and rpp.id_persona = rrga.id_acreedor
              and rrga.status_reg = 'AC'
              and rrgp.sit_relacion = 'AC'
              and rrgp.id_privilegio not in (25, 31)
   order by   id_acreedor, id_grupo, id_privilegio;

-- view v_usuario_acreedor_grupos  



create or replace view rug.v_usuario_firma as select   tri.id_tramite_temp,
            tri.id_persona as usuario_login,
            rsu.cve_usuario as cve_usuario_login,
            rpf.nombre_persona as nombre_usuario_login,
            rpf.ap_paterno as ap_paterno_login,
            rpf.ap_materno as ap_materno_login,
            rri.id_persona,
            case when rri.per_juridica=
                    'PF' then (select   nombre_persona
                             from  rug.rug_personas_fisicas
                            where   id_persona = rri.id_persona)else
                    null end
               as nombre_subusuario,
            case when rri.per_juridica=
                    'PF' then (select   ap_paterno
                             from  rug.rug_personas_fisicas
                            where   id_persona = rri.id_persona) else
                    null end
               as apellido_paterno_subusuario,
            case when rri.per_juridica=
                    'PF' then (select   ap_materno
                             from  rug.rug_personas_fisicas
                            where   id_persona = rri.id_persona) else
                    null end
               as apellido_materno_subusuario,
            case when rri.per_juridica=
                    'PF' then 
               (select   rcn.desc_nacionalidad
                  from   rug.rug_personas rpp, rug.rug_cat_nacionalidades rcn
                 where   rpp.id_nacionalidad = rcn.id_nacionalidad
                         and rpp.id_persona = rri.id_persona) else
               null
            end
               as nacionalidad,
            case when rri.per_juridica=
                    'PF' then 
               (select   rsu.cve_usuario
                  from   rug.rug_personas rpp, rug.rug_secu_usuarios rsu
                 where   rpp.id_persona = rsu.id_persona
                         and rpp.id_persona = rri.id_persona) else
               null
            end
               as cve_usuario_sub,
            case when rri.per_juridica=
                    'PF' then 
               (select   rgu.desc_grupo
                  from   rug.rug_personas rpp,
                         rug.rug_secu_usuarios rsu,
                         rug.rug_grupos rgu
                 where       rpp.id_persona = rsu.id_persona
                         and rsu.id_grupo = rgu.id_grupo
                         and rpp.id_persona = rri.id_persona) else
               null
            end
               as grupo_usuario_sub
     from   rug.tramites_rug_incomp tri,
            rug.rug_secu_usuarios rsu,
           rug.rug_personas_fisicas rpf,
            rug.rug_rel_tram_inc_partes rri
    where       tri.id_persona = rpf.id_persona
            and tri.id_persona = rsu.id_persona
            and tri.id_tramite_temp = rri.id_tramite_temp
            and tri.id_tipo_tramite = 14
            and tri.id_status_tram = 5;


-- view v_usuario_firma  





create or replace view rug.v_usuario_firma_todos as select   tri.id_tramite_temp,
            tri.id_status_tram,
            stt.descrip_status,
            tri.id_persona as usuario_login,
            rsu.cve_usuario as cve_usuario_login,
            rpf.nombre_persona as nombre_usuario_login,
            rpf.ap_paterno as ap_paterno_login,
            rpf.ap_materno as ap_materno_login,
            rri.id_persona,
            case when rri.per_juridica=
                    'PF' then (select   nombre_persona
                             from  rug.rug_personas_fisicas
                            where   id_persona = rri.id_persona) else
                    null end
               as nombre_subusuario,
            case when rri.per_juridica=
                    'PF' then (select   ap_paterno
                             from  rug.rug_personas_fisicas
                            where   id_persona = rri.id_persona) else
                    null end
               as apellido_paterno_subusuario,
            case when rri.per_juridica=
                    'PF' then (select   ap_materno
                             from  rug.rug_personas_fisicas
                            where   id_persona = rri.id_persona) else
                    null end
               as apellido_materno_subusuario,
            case when rri.per_juridica=
                    'PF' then 
               (select   rcn.desc_nacionalidad
                  from   rug.rug_personas rpp, rug.rug_cat_nacionalidades rcn
                 where   rpp.id_nacionalidad = rcn.id_nacionalidad
                         and rpp.id_persona = rri.id_persona) else
               null
            end
               as nacionalidad,
            case when rri.per_juridica=
                    'PF' then 
               (select   rsu.cve_usuario
                  from   rug.rug_personas rpp, rug.rug_secu_usuarios rsu
                 where   rpp.id_persona = rsu.id_persona
                         and rpp.id_persona = rri.id_persona) else
               null
            end
               as cve_usuario_sub,
            case when rri.per_juridica=
                    'PF' then 
               (select   rgu.desc_grupo
                  from   rug.rug_personas rpp,
                         rug.rug_secu_usuarios rsu,
                         rug.rug_grupos rgu
                 where       rpp.id_persona = rsu.id_persona
                         and rsu.id_grupo = rgu.id_grupo
                         and rpp.id_persona = rri.id_persona) else
               null
            end
               as grupo_usuario_sub
     from   rug.tramites_rug_incomp tri,
            rug.rug_secu_usuarios rsu,
           rug.rug_personas_fisicas rpf,
            rug.rug_rel_tram_inc_partes rri,
            rug.status_tramite stt
    where       tri.id_persona = rpf.id_persona
            and tri.id_persona = rsu.id_persona
            and tri.id_tramite_temp = rri.id_tramite_temp
            and tri.id_status_tram = stt.id_status_tram
            and tri.id_tipo_tramite = 14;

-- view v_usuario_firma_todos  



create or replace view rug.v_usuario_login_rug as select   lower (rsu.cve_usuario),
            rspu.cve_perfil,
            rsu.passwrd,
            rsu.id_persona,
               rpf.nombre_persona
            || ' '
            || rpf.ap_paterno
            || ' '
            || rpf.ap_materno
               nombre_completo,
            rpf.nombre_persona,
            rpf.ap_paterno,
            rpf.ap_materno,
            rsu.preg_recupera_psw,
            rsu.id_grupo,
            rg.desc_grupo,
            rsu.cve_usuario_padre,
            rsu.cve_acreedor,
            rsu.sit_usuario,
            rp.rfc
     from   rug.rug_secu_usuarios rsu,
            rug.rug_personas rp,
           rug.rug_personas_fisicas rpf,
            rug.rug_secu_perfiles_usuario rspu,
            rug.rug_grupos rg
    where       rp.id_persona = rsu.id_persona
            and rpf.id_persona = rsu.id_persona
            and rspu.cve_usuario = rsu.cve_usuario
            and rg.id_grupo = rsu.id_grupo
            and rp.sit_persona = 'AC'
            and rsu.sit_usuario = 'AC'
            and rspu.b_bloqueado = 'F';

-- view v_usuario_login_rug  



create or replace view rug.v_usuario_sesion_rug as select   lower (rsu.cve_usuario),
            rcp.id_perfil,
            rspu.cve_perfil,
            rsu.passwrd,
            rsu.id_persona,
               rpf.nombre_persona
            || ' '
            || rpf.ap_paterno
            || ' '
            || rpf.ap_materno
               nombre_completo,
            rpf.nombre_persona,
            rpf.ap_paterno,
            rpf.ap_materno,
            rp.rfc,
            rsu.preg_recupera_psw,
            rsu.id_grupo,
            rg.desc_grupo,
            rsu.cve_usuario_padre,
            rsu.cve_acreedor,
            rsu.sit_usuario,
            rpf.num_serie
     from   rug.rug_secu_usuarios rsu,
            rug.rug_personas rp,
           rug.rug_personas_fisicas rpf,
            rug.rug_secu_perfiles_usuario rspu,
            rug.rug_grupos rg,
            rug.rug_cat_perfiles rcp
    where       rp.id_persona = rsu.id_persona
            and rpf.id_persona = rsu.id_persona
            and rspu.cve_usuario = rsu.cve_usuario
            and rspu.cve_perfil = rcp.cve_perfil
            and rg.id_grupo = rsu.id_grupo
            and rp.sit_persona = 'AC'
            and rspu.b_bloqueado = 'F';

-- view v_usuario_sesion_rug  



create or replace view rug.v_boleta_anotacion as select   s.id_tramite,
            s.vigencia_anotacion,
            to_char (rbb.fecha_status, 'dd/mm/yyyy - hh24:mi:ss')
            || case when  (select   count ( * )
                           from   rug.v_firma_doctos
                          where   id_tramite_temp = s.id_tramite_temp) =
                       1 then ' * ZULU GMT / UTC' else
                       ' * HORA CENTRAL MEXICO, D.F.' end
               as fecha_creacion,
            s.id_usuario,
            s.nombre_usuario,
            s.anotacion,
            s.resolucion,
            s.autoridad_instruye,
            s.perfil,
            s.folio_otorgante
     from      (select   t.id_tramite,
                         cast (rasg.vigencia_anotacion as varchar (10))
                         || ' MESES'
                            vigencia_anotacion,
                         t.id_persona as id_usuario,
                            rph.nombre_persona
                         || ' '
                         || rph.ap_paterno
                         || ' '
                         || rph.ap_materno
                            as nombre_usuario,
                         rasg.anotacion,
                         null as resolucion,   -- mmescn2013-81 ggr 26/08/2013
                         rasg.autoridad_autoriza as autoridad_instruye,
                         rph.cve_perfil as perfil,
                         (select   distinct rpp.folio_mercantil
                            from   rug.rug_personas rpp, rug.rug_rel_tram_partes rrt
                           where       rpp.id_persona = rrt.id_persona
                                   and rrt.id_parte = 1
                                   and rrt.id_tramite = t.id_tramite)
                            as folio_otorgante,
                         t.id_tramite_temp
                  from   rug.tramites t,
                         rug.rug_personas_h rph,
                         rug.rug_anotaciones_sin_garantia rasg
                 where       rph.id_tramite = t.id_tramite
                         and rasg.id_tramite_temp = t.id_tramite_temp
                         and t.id_tipo_tramite = 10
                         and rph.id_parte = 5
                union all
                select   t.id_tramite,
                         cast (rasg.vigencia_anotacion as varchar (10))
                         || ' MESES'
                            vigencia_anotacion,
                         t.id_persona as id_usuario,
                            rph.nombre_persona
                         || ' '
                         || rph.ap_paterno
                         || ' '
                         || rph.ap_materno,
                         rasg.anotacion,
                         null as resolucion,   -- mmescn2013-81 ggr 26/08/2013
                         rasg.autoridad_autoriza,
                         rph.cve_perfil,
                         (select   distinct rpp.folio_mercantil
                            from   rug.rug_personas rpp, rug.rug_rel_tram_partes rrt
                           where       rpp.id_persona = rrt.id_persona
                                   and rrt.id_parte = 1
                                   and rrt.id_tramite = t.id_tramite),
                         t.id_tramite_temp
                  from   rug.rug_personas_h rph, rug.tramites t, rug.rug_anotaciones rasg
                 where       rph.id_tramite = t.id_tramite
                         and rasg.id_tramite_temp = t.id_tramite_temp
                         and rph.id_parte = 5
                union all
                /* mmescn2013-81 ggr 23/08/2013 inicio*/
                select   t.id_tramite,
                         cast (a.vigencia as varchar (10)) || ' MESES',
                         t.id_persona,
                            p.nombre_persona
                         || ' '
                         || p.ap_paterno
                         || ' '
                         || p.ap_materno,
                         a.anotacion,
                         a.resolucion,
                         a.autoridad_autoriza,
                         p.cve_perfil,
                         (select   distinct rpp.folio_mercantil
                            from   rug.rug_personas rpp, rug.rug_rel_tram_partes rrt
                           where       rpp.id_persona = rrt.id_persona
                                   and rrt.id_parte = 1
                                   and rrt.id_tramite = t.id_tramite),
                         t.id_tramite_temp
                  from         rug.rug_anotaciones_seg_inc_csg a
                            inner join
                               rug.tramites t
                            on t.id_tramite_temp = a.id_anotacion_temp
                         inner join
                            rug.rug_personas_h p
                         on p.id_tramite = t.id_tramite and p.id_parte = 5 /* mmescn2013-81 ggr 23/08/2013 fin*/
                                                                          ) s
            inner join
               rug.rug_bitac_tramites rbb
            on rbb.id_tramite_temp = s.id_tramite_temp
    where   rbb.id_status = 3;

-- view v_boleta_anotacion  
-- this object may have dependency on other objects, kindly check it after migration.



create or replace view rug.v_detalle_aviso_prev as select tri.id_tramite,
          avp.desc_bienes,
          avp.id_usuario,
          (select    f.nombre_persona
                  || ' '
                  || f.ap_paterno
                  || ' '
                  || f.ap_materno
             from rug.rug_personas_h f
            where     f.id_persona = avp.id_usuario
                  and id_tramite = tri.id_tramite
                  and f.id_parte = 6)
             as nombre_usuario,
          to_char (rbb.fecha_status, 'dd/mm/yyyy - hh24:mi:ss')
          || case when (select count (*)
                         from rug.v_firma_doctos
                        where id_tramite_temp = tri.id_tramite_temp)=
                     1 then ' * ZULU GMT / UTC' else
                     ' * HORA CENTRAL CIUDAD DE MEXICO' end 
             as fecha_creacion,
          rsu.cve_perfil as perfil,
          '15 DIAS NATURALES IMPRORROGABLES ',
          coalesce (rua.anotacion_juez, 'N/A'),
          (select rpp.folio_mercantil
             from rug.rug_personas rpp, rug.rug_rel_tram_partes rrt
            where     rpp.id_persona = rrt.id_persona
                  and rrt.id_parte = 1
                  and rrt.id_tramite = tri.id_tramite)
     from rug.avisos_prev avp
          inner join rug.tramites tri
             on avp.id_tramite_temp = tri.id_tramite_temp
          inner join rug.rug_bitac_tramites rbb
             on tri.id_tramite_temp = rbb.id_tramite_temp
          inner join rug.rug_secu_perfiles_usuario rsu
             on avp.id_usuario = rsu.id_persona
          left join rug.rug_autoridad rua
             on avp.id_tramite_temp = rua.id_tramite_temp
    where rbb.id_status in (3, 10) 
    --restriccion de los 15 dias habiles en avisos preventivos. sitah - 2018/04/24
    and rbb.status_reg = 'AC' 
    and rbb.fecha_status > current_date - 15;

-- view v_detalle_aviso_prev  
-- this object may have dependency on other objects, kindly check it after migration.



create or replace view rug.v_garantias_contr_modif as select   a.id_garantia,
            a.id_tipo_garantia,
            a.tipo_garantia,
            a.fecha_celeb_acto,
            a.monto_limite,
            a.otros_terminos_garantia,
            a.desc_bienes_muebles,
            a.tipo_contrato,
            a.fecha_celeb_contrato,
            a.otros_terminos_contrato,
            a.vigencia,
            a.relacion_bien,
            a.id_tipo_bien,
            a.desc_tipo_bien,
            a.id_tramite_temp,
            a.id_moneda,
            rcm.desc_moneda
     from   rug.v_garantia_contr_basico a,
            rug.tramites_rug_incomp b,
            rug.rug_cat_monedas rcm
    where       a.id_tramite_temp = b.id_tramite_temp
            and rcm.id_moneda = a.id_moneda
            and b.id_tipo_tramite = 7                       /* modificacion */
            and b.id_status_tram <> 3;

-- view v_garantias_contr_modif  
-- this object may have dependency on other objects, kindly check it after migration.



create or replace view rug.v_garantias_contr_recerr as select   a.id_garantia,
            a.id_tipo_garantia,
            a.tipo_garantia,
            a.fecha_celeb_acto,
            a.monto_limite,
            a.otros_terminos_garantia,
            a.desc_bienes_muebles,
            a.tipo_contrato,
            a.fecha_celeb_contrato,
            a.otros_terminos_contrato,
            a.vigencia,
            a.relacion_bien,
            a.id_tipo_bien,
            a.desc_tipo_bien,
            a.id_tramite_temp,
            a.id_moneda,
            rcm.desc_moneda
     from   rug.v_garantia_contr_basico a,
            rug.tramites_rug_incomp b,
            rug.rug_cat_monedas rcm
    where       a.id_tramite_temp = b.id_tramite_temp
            and a.id_moneda = rcm.id_moneda
            and b.id_tipo_tramite = 6            /* rectificacion por error */
            and b.id_status_tram <> 3;

-- view v_garantias_contr_recerr  
-- this object may have dependency on other objects, kindly check it after migration.



create or replace view rug.v_garantias_contr_trasmision as select   a.id_garantia,
            a.id_tipo_garantia,
            a.tipo_garantia,
            a.fecha_celeb_acto,
            a.monto_limite,
            a.otros_terminos_garantia,
            a.desc_bienes_muebles,
            a.tipo_contrato,
            a.fecha_celeb_contrato,
            a.otros_terminos_contrato,
            a.vigencia,
            a.relacion_bien,
            a.id_tipo_bien,
            a.desc_tipo_bien,
            a.id_tramite_temp,
            a.id_moneda,
            rcm.desc_moneda
     from   rug.v_garantia_contr_basico a,
            rug.tramites_rug_incomp b,
            rug.rug_cat_monedas rcm
    where       a.id_tramite_temp = b.id_tramite_temp
            and rcm.id_moneda = a.id_moneda
            and b.id_tipo_tramite = 8                         /* trasmision */
            and b.id_status_tram <> 3;

-- view v_garantias_contr_trasmision  
-- this object may have dependency on other objects, kindly check it after migration.

create or replace view institucional.v_se_cat_tipos_vialidad    -- PROVIENE DEL EXQUEMA INSTITUCIONAL
(id_tipo_vialidad,cve_idioma,desc_tipo_vialidad,desc_corta_tipo_via,b_ref_calles_oblig,sit_tipo_vialidad)
as
select   vial.id_tipo_vialidad,
            --       initcap(desc_tipo_vialidad) as desc_tipo_vialidad,
            des.cve_idioma,
            des.desc_tipo_vialidad,
            vial.desc_corta_tipo_via,
            vial.b_ref_calles_oblig,                       --calles_referencia
            vial.sit_tipo_vialidad
     from   institucional.se_cat_tipos_vialidad vial, institucional.se_cat_tip_vialidad_desc des
    where   vial.id_tipo_vialidad = des.id_tipo_vialidad;
            
            

    
    --------------------------------------------------------------------------
    
    create or replace view fenix.v_emp_edos_habilitados_fenix  -- ESQUEMA FENIX
(cve_pais,cve_estado,f_habilitacion)
as
select cve_pais, cve_estado, f_habilitacion
   from fenix.emp_edos_habilitados_fenix
   where f_habilitacion is not null;
  

    create or replace view institucional.v_se_cat_estados   -- ESQUEMA INSTITUCIONAL
(cve_pais,cve_estado,desc_estado,b_habilitado_fenix,id_estado,sit_estado)
as
select   ce.cve_pais,
              ce.cve_estado,
              --       initcap (ce.desc_estado) as desc_estado
              ce.desc_estado,
              case when ef.cve_pais is null then 'F' else 'V' end as b_habilitado_fenix,
              id_estado,
              sit_estado
       from   institucional.se_cat_estados ce, fenix.v_emp_edos_habilitados_fenix ef
      where   ce.cve_pais = ef.cve_pais and ce.cve_estado = ef.cve_estado
   order by   ce.cve_pais, ce.desc_estado;
    

    create or replace view institucional.v_se_cat_municip_deleg   -- ESQUEMA INSTITUCIONAL
(cve_pais,cve_estado,desc_estado,cve_municip_deleg,f_inicio_vigencia,f_fin_vigencia,desc_municip_deleg,sit_municip_deleg)
as
select   mun.cve_pais,
            mun.cve_estado,
            edos.desc_estado,
            mun.cve_municip_deleg,
            mun.f_inicio_vigencia,
            mun.f_fin_vigencia,
            mun.desc_municip_deleg,
            mun.sit_municip_deleg
     from   institucional.se_cat_municip_deleg mun, institucional.v_se_cat_estados edos
    where   mun.desc_municip_deleg not like '%INCONSISTENTE%'
            and edos.cve_pais = mun.cve_pais
            and edos.cve_estado = mun.cve_estado;

----------------------------------------------------------------------------------------------------------


create or replace view rug.v_domicilios as select   rd.id_domicilio id_domicilio,
            (rd.calle) calle,
            (rd.num_exterior) num_exterior,
            (rd.num_interior) num_interior,
            scc.id_colonia id_colonia,
            scc.cve_colonia cve_colonia,
            scc.desc_colonia nom_colonia,
              case when (coalesce(scl.id_localidad, 0)) = 0 
              then scc.cve_municip_deleg
              else scl.cve_municip_deleg end as cve_deleg_municip,
            case when (coalesce (scl.id_localidad, 0))= 0
              then scmd1.desc_municip_deleg
              else scmd2.desc_municip_deleg end as nom_deleg_municip,
            case when (coalesce (scl.id_localidad, 0)) = 0
                  then scc.cve_estado 
                  else scl.cve_estado end as cve_estado,
            case when (coalesce (scl.id_localidad, 0)) = 0
                  then sce1.desc_estado
                  else sce2.desc_estado end as nom_estado,
            case when (coalesce (scl.id_localidad, 0)) = 0
            then scc.codigo_postal
            else scl.codigo_postal end as codigo_postal,
            scp.cve_pais,
            (scp.desc_pais) nom_pais,
            scl.id_localidad id_localidad,
            scl.cve_localidad cve_localidad,
            (scl.desc_localidad) localidad,
            rd.id_vialidad id_vialidad,
            (sctv.desc_tipo_vialidad) vialidad,
            (tx_refer_adicional) referencia,
            '' ubica_domicilio_1,
            '' ubica_domicilio_2,
            '' poblacion,
            '' zona_postal,
            1 id_pais_residencia
     from   rug.rug_domicilios rd,
            institucional.se_cat_paises scp,
            institucional.se_cat_colonias scc,
            institucional.se_cat_municip_deleg scmd2,
            institucional.se_cat_estados sce2,
            institucional.se_cat_localidades scl,
            institucional.se_cat_municip_deleg scmd1,
            institucional.se_cat_estados sce1,
            institucional.v_se_cat_tipos_vialidad sctv
    where       scp.cve_pais = 'MEX'
            and scc.id_colonia = rd.id_colonia
            and scl.id_localidad = rd.id_localidad
            and sctv.id_tipo_vialidad = rd.id_vialidad
            and sce1.cve_pais = 'MEX'
            and sce1.cve_estado= scc.cve_estado
            and sce2.cve_pais = 'MEX'
            and sce2.cve_estado = scl.cve_estado
            and scmd1.cve_pais = 'MEX'
            and scmd1.cve_estado = scc.cve_estado
            and scmd1.cve_municip_deleg = scc.cve_municip_deleg
            and scmd2.cve_pais = 'MEX'
            and scmd2.cve_estado = scl.cve_estado
            and scmd2.cve_municip_deleg = scl.cve_municip_deleg
   union all
   select   rde.id_domicilio id_domicilio,
            '' calle,
            '' num_exterior,
            '' num_interior,
            0 id_colonia,
            '' cve_colonia,
            '' nom_colonia,
            0 cve_deleg_municip,
            '' nom_deleg_municip,
            '' cve_estado,
            '' nom_estado,
            '' codigo_postal,
            '' cve_pais,
            '' nom_pais,
            0 id_localidad,
            '' cve_localidad,
            '' localidad,
            0 id_vialidad,
            '' vialidad,
            '' referencia,
            rde.ubica_domicilio_1,
            rde.ubica_domicilio_2,
            rde.poblacion,
            rde.zona_postal,
            rde.id_pais_residencia
     from   rug.rug_domicilios_ext rde;

-- view rug.v_domicilios  




create or replace view rug.v_acreedor_rep_firma as select   tri.id_tramite_temp,
            tri.id_persona as usuario_login,
            rsu.cve_usuario as cve_usuario_login,
            rpf.nombre_persona as nombre_usuario_login,
            rpf.ap_paterno as ap_paterno_login,
            rpf.ap_materno as ap_materno_login,
            rrt.id_persona,
            rrt.per_juridica,
            case when rrt.per_juridica =
                    'PF' then (select   nombre_persona
                             from  rug.rug_personas_fisicas
                            where   id_persona = rrt.id_persona) else
                    null end
               as nombre_acreedor,
            case when rrt.per_juridica =
                    'PF' then (select   ap_paterno
                             from  rug.rug_personas_fisicas
                            where   id_persona = rrt.id_persona) else
                    null end
               as apellido_paterno_acreedor,
            case when rrt.per_juridica =
                    'PF' then (select   ap_materno
                             from  rug.rug_personas_fisicas
                            where   id_persona = rrt.id_persona) else
                    null end
               as apellido_materno_acreedor,
            case when rrt.per_juridica =
                    'PM' then (select   razon_social
                             from   rug.rug_personas_morales
                            where   id_persona = rrt.id_persona) else
                    null end
               as razon_social_acreedor,
            rpp.folio_mercantil,
            rpp.rfc,
            case when rrt.per_juridica =
                    'PF' then (select   curp
                             from  rug.rug_personas_fisicas
                            where   id_persona = rrt.id_persona) else
                    null end
               as curp,
            vdm.id_domicilio,
            vdm.calle,
            '' calle_colindante_1,
            '' calle_colindante_2,
            '' as localidad,
            vdm.num_exterior,
            vdm.num_interior,
            vdm.id_colonia,
            vdm.nom_colonia as desc_colonia,
            vdm.id_localidad,
            vdm.localidad as desc_localidad,
            vdm.cve_estado,
            vdm.cve_pais,
            vdm.cve_deleg_municip,
            vdm.codigo_postal,
            rcc.id_contrato,
            rcc.fecha_inicio,
            rcc.fecha_fin,
            rcc.otros_terminos_contrato,
            rcc.tipo_contrato,
            '' as firmado,
            vdm.nom_estado as desc_estado,
            vdm.nom_pais as desc_pais,
            vdm.nom_deleg_municip as desc_municip_deleg,
            vdm.id_pais_residencia,
            (select   desc_nacionalidad
               from   rug.rug_cat_nacionalidades
              where   id_nacionalidad = vdm.id_pais_residencia)
               pais_residencia,
            vdm.ubica_domicilio_1,
            vdm.ubica_domicilio_2,
            vdm.poblacion,
            vdm.zona_postal,
            case when tri.id_tipo_tramite=
                    12 then
                    'V'
                    when tri.id_tipo_tramite=
                    19 then
                    'F' end as
               b_nuevo
     from   rug.tramites_rug_incomp tri,
           rug.rug_personas_fisicas rpf,
            rug.rug_secu_usuarios rsu,
            rug.rug_rel_tram_inc_partes rrt,
            rug.rug_personas rpp,
            rug.rug_contrato rcc,
            rug.v_domicilios vdm
    where       rpf.id_persona = tri.id_persona
            and tri.id_persona = rsu.id_persona
            and tri.id_tramite_temp = rrt.id_tramite_temp
            and rrt.id_persona = rpp.id_persona
            and rpp.id_domicilio = vdm.id_domicilio
            and tri.id_tramite_temp = rcc.id_tramite_temp
            and rpp.id_domicilio = vdm.id_domicilio
            and tri.id_status_tram = 5
            and tri.id_tipo_tramite in (12, 19);

-- view v_acreedor_rep_firma  

           
           create or replace function rug.fn_borra_sin_con_garantia(  
        p_descripcion  varchar
)
 RETURNS text
 LANGUAGE plpgsql
AS $function$

DECLARE
	
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
$function$
;


create or replace view rug.v_anotacion_sg_tramites_hist as select h.id_anotacion_temp_h as num_operacion
         , h.id_anotacion_temp
         , h.id_tramite
         , h.id_tramite_padre
         , h.id_garantia
         , h.id_tipo_tramite
         , rug.fn_borra_sin_con_garantia(tt.descripcion) as descripcion
         , h.id_status
         , st.descrip_status as status
         , h.id_usuario
         , h.id_persona_anotacion
         , h.pers_juridica
         , h.autoridad_autoriza
         , h.anotacion
         , h.resolucion
         , h.vigencia
         , h.solicitante_rectifica
         , h.fecha_reg
         , h.status_reg
      from rug.rug_anotaciones_seg_inc_csg_h h
     inner join rug.rug_cat_tipo_tramite tt
        on tt.id_tipo_tramite = h.id_tipo_tramite
     inner join rug.status_tramite st
        on st.id_status_tram = h.id_status
     order by h.fecha_reg desc;

-- view v_anotacion_sg_tramites_hist  



create or replace view rug.v_anotacion_sin_garantia_firma as select   rbt.id_tramite_temp,
            rasg.id_persona,
            case when 
               rp.per_juridica=
               'PF' then
               (select      f.nombre_persona
                         || ' '
                         || f.ap_paterno
                         || ' '
                         || f.ap_materno
                  from  rug.rug_personas_fisicas f
                 where   f.id_persona = rp.id_persona)
               when 
               rp.per_juridica= 'PM' then
               (select   m.razon_social
                  from   rug.rug_personas_morales m
                 where   m.id_persona = rp.id_persona)
            end as
               nombre,
            rp.per_juridica,
            rp.rfc,
            rasg.id_anotacion,
            rasg.anotacion,
            rasg.autoridad_autoriza,
            (rd.calle || ' ' || rd.num_exterior || ' ' || rd.num_interior)
               domicilio,
            vd.id_colonia,
            vd.nom_colonia,
            vd.id_localidad,
            vd.localidad,
            vd.nom_deleg_municip,
            vd.cve_estado,
            vd.nom_estado,
            vd.codigo_postal,
            vd.cve_pais,
            vd.nom_pais
     from   rug.rug_bitac_tramites rbt,
            rug.rug_anotaciones_sin_garantia rasg,
            rug.tramites_rug_incomp tri,
            rug.rug_personas rp,
            rug.rug_domicilios rd,
            rug.v_domicilios vd
    where       rbt.id_tramite_temp = rasg.id_tramite_temp
            and tri.id_tramite_temp = rasg.id_tramite_temp
            and tri.id_persona = rasg.id_persona
            and rp.id_persona = rasg.id_persona
            and rd.id_domicilio = rp.id_domicilio
            and vd.id_domicilio = rp.id_domicilio
            and rbt.id_status = 5
            and rasg.id_tramite_temp not in
                     (select   id_tramite_temp
                        from   rug.tramites
                       where   id_tramite_temp = rasg.id_tramite_temp);

-- view v_anotacion_sin_garantia_firma  



create or replace view rug.v_anotacion_tramites as select t.id_tramite,t.id_tramite_temp,t.id_anotacion_padre,t.id_anotacion,t.id_garantia,t.id_tipo_tramite,t.descripcion,t.id_status_tram,t.descrip_status,t.id_usuario,t.usuario,t.id_persona,t.per_juridica,t.folio_mercantil,t.rfc,t.curp,t.id_nacionalidad,t.nombre_persona,t.ap_paterno,t.ap_materno,t.razon_social,t.autoridad_autoriza,t.anotacion,t.resolucion,t.vigencia_anotacion,t.solicitante_rectifica,t.fecha_status,t.fecha_inscripcion
      from  
         ( select   t.id_tramite,
                    r.id_anotacion_temp as id_tramite_temp,
                    r.id_tramite_padre as id_anotacion_padre,
                    r.id_anotacion_temp as id_anotacion,
                    r.id_garantia,
                    ti.id_tipo_tramite,
                    rug.fn_borra_sin_con_garantia(tt.descripcion) as descripcion,
                    ti.id_status_tram,
                    st.descrip_status,
                    usu.id_persona as id_usuario,
                    pf.nombre_persona || ' ' || pf.ap_paterno || ' ' || pf.ap_materno  as usuario,
                    pa.id_persona id_persona,
                    pa.per_juridica,
                    pp.folio_mercantil,
                    pp.rfc,
                    pfa.curp,
                    pp.id_nacionalidad,
                    pfa.nombre_persona,
                    pfa.ap_paterno,
                    pfa.ap_materno,
                    pm.razon_social,
                    r.autoridad_autoriza,
                    r.anotacion,
                    r.resolucion,
                    r.vigencia as vigencia_anotacion,
                    r.solicitante_rectifica,
                    to_char(h.fecha_reg, 'dd/mm/yyyy') as fecha_status,
                    to_char(bt.fecha_reg, 'dd/mm/yyyy') as fecha_inscripcion
             from   rug.rug_anotaciones_seg_inc_csg r
            inner join rug.tramites_rug_incomp ti
               on   ti.id_tramite_temp = r.id_anotacion_temp
            inner join rug.rug_rel_tram_inc_partes usu
               on   usu.id_tramite_temp = r.id_anotacion_temp
              and   usu.id_parte = 5
            inner join rug.rug_personas_fisicas pf
               on   pf.id_persona = usu.id_persona
             left join rug.rug_rel_tram_inc_partes pa
               on   pa.id_tramite_temp = r.id_anotacion_temp
              and   pa.id_parte = 1
             left join rug.rug_personas pp
               on   pp.id_persona = pa.id_persona
             left join rug.rug_personas_fisicas pfa
               on   pfa.id_persona = pa.id_persona
             left join rug.rug_personas_morales pm
               on   pm.id_persona = pa.id_persona
            inner join rug.rug_cat_tipo_tramite tt
               on   tt.id_tipo_tramite = ti.id_tipo_tramite
            inner join rug.status_tramite st
               on   st.id_status_tram = ti.id_status_tram
             left join rug.tramites t
               on   t.id_tramite_temp = r.id_anotacion_temp 
            inner join (select max(his.fecha_reg) as fecha_reg, his.id_anotacion_temp
                          from rug.rug_anotaciones_seg_inc_csg_h his
                         group by his.id_anotacion_temp) h
               on   h.id_anotacion_temp = r.id_anotacion_temp
            inner join rug.rug_bitac_tramites bt
               on   bt.id_tramite_temp = r.id_anotacion_temp
              and   bt.id_status = 0
            where   ti.id_tipo_tramite in (26, 27, 28, 29
                                          ,22, 23, 24, 25) -- ggr   07/05/13   mmsecn2013-82
              and   r.status_reg = 'AC' 
           union all
           select   t.id_tramite,
                    null as id_tramite_temp,
                    null as id_anotacion_padre,
                    null as id_anotacion,
                    null as id_garantia,
                    t.id_tipo_tramite,
                    rug.fn_borra_sin_con_garantia(tt.descripcion) as descripcion,
                    t.id_status_tram,
                    st.descrip_status,
                    t.id_persona as id_usuario,
                    pf.nombre_persona || ' ' || pf.ap_paterno || ' ' || pf.ap_materno  as usuario,
                    pa.id_persona,
                    pa.per_juridica,
                    pp.folio_mercantil,
                    pp.rfc,
                    pfa.curp,
                    pp.id_nacionalidad,
                    pfa.nombre_persona,
                    pfa.ap_paterno,
                    pfa.ap_materno,
                    pm.razon_social,
                    r.autoridad_autoriza,
                    r.anotacion,
                    null as resolucion,
                    r.vigencia_anotacion,
                    null as solicitante_rectifica,
                    to_char(t.fecha_status, 'dd/mm/yyyy') as fecha_status,
                    to_char(bt.fecha_reg, 'dd/mm/yyyy') as fecha_inscripcion
             from   rug.tramites t
            inner join rug.tramites_rug_incomp ti
               on   ti.id_tramite_temp = t.id_tramite_temp
            inner join rug.rug_anotaciones_sin_garantia r
               on   r.id_tramite_temp = t.id_tramite_temp
             left join rug.rug_personas_fisicas pf
               on   pf.id_persona = t.id_persona
             left join rug.rug_rel_tram_partes pa
               on   pa.id_tramite = t.id_tramite
              and   pa.id_parte = 1
             left join rug.rug_personas pp
               on   pp.id_persona = pa.id_persona
             left join rug.rug_personas_fisicas pfa
               on   pfa.id_persona = pa.id_persona
             left join rug.rug_personas_morales pm
               on   pm.id_persona = pa.id_persona
            inner join rug.rug_bitac_tramites bt
               on   bt.id_tramite_temp = t.id_tramite_temp 
              and   bt.id_status = 0
            inner join rug.rug_cat_tipo_tramite tt
               on   tt.id_tipo_tramite = t.id_tipo_tramite
            inner join rug.status_tramite st
               on   st.id_status_tram = t.id_status_tram
            where   t.id_tipo_tramite = 10
              and   t.status_reg = 'AC'
           union all
           select   t.id_tramite,
                    null as id_tramite_temp,
                    null as id_anotacion_padre,
                    null as id_anotacion,
                    r.id_garantia as id_garantia,
                    t.id_tipo_tramite,
                    rug.fn_borra_sin_con_garantia(tt.descripcion) as descripcion,
                    t.id_status_tram,
                    st.descrip_status,
                    t.id_persona as id_usuario,
                    pf.nombre_persona || ' ' || pf.ap_paterno || ' ' || pf.ap_materno  as usuario,
                    pa.id_persona,
                    pa.per_juridica,
                    pp.folio_mercantil,
                    pp.rfc,
                    pfa.curp,
                    pp.id_nacionalidad,
                    pfa.nombre_persona,
                    pfa.ap_paterno,
                    pfa.ap_materno,
                    pm.razon_social,
                    r.autoridad_autoriza,
                    r.anotacion,
                    null as resolucion,
                    r.vigencia_anotacion,
                    null as solicitante_rectifica,
                    to_char(t.fecha_status, 'dd/mm/yyyy') as fecha_status,
                    to_char(bt.fecha_reg, 'dd/mm/yyyy') as fecha_inscripcion
             from   rug.tramites t
            inner join rug.tramites_rug_incomp ti
               on   ti.id_tramite_temp = t.id_tramite_temp
            inner join rug.rug_anotaciones r
               on   r.id_tramite_temp = t.id_tramite_temp
             left join rug.rug_personas_fisicas pf
               on   pf.id_persona = t.id_persona
             left join rug.rug_rel_tram_partes pa
               on   pa.id_tramite = t.id_tramite
              and   pa.id_parte = 1
             left join rug.rug_personas pp
               on   pp.id_persona = pa.id_persona
             left join rug.rug_personas_fisicas pfa
               on   pfa.id_persona = pa.id_persona
             left join rug.rug_personas_morales pm
               on   pm.id_persona = pa.id_persona
            inner join rug.rug_bitac_tramites bt
               on   bt.id_tramite_temp = t.id_tramite_temp 
              and   bt.id_status = 0
            inner join rug.rug_cat_tipo_tramite tt
               on   tt.id_tipo_tramite = t.id_tipo_tramite
            inner join rug.status_tramite st
               on   st.id_status_tram = t.id_status_tram
            where   t.id_tipo_tramite = 2
              and   t.status_reg = 'AC'
        ) t
   order by t.id_tramite_temp desc;

-- view v_anotacion_tramites  


  
create or replace view rug.v_busqueda_folio_e_pf as select rp.id_persona,
          rpar.id_parte,
          rpar.desc_parte,
          rp.per_juridica,
          rpf.nombre_persona,
          rpf.ap_paterno,
          rpf.ap_materno,
          rp.folio_mercantil,
          rpf.curp,
          rp.rfc,
          vd.id_domicilio,
          vd.calle,
          vd.num_exterior,
          vd.num_interior,
          vd.id_colonia,
          vd.cve_colonia,
          vd.id_localidad,
          vd.cve_localidad,
          vd.cve_deleg_municip,
          vd.nom_deleg_municip,
          vd.cve_estado,
          vd.nom_estado,
          vd.cve_pais,
          vd.nom_pais,
          rcn.id_nacionalidad,
          rcn.desc_nacionalidad as nacionalidad,
          rrtip.status_reg status
     from rug.rug_rel_tram_inc_partes rrtip,
          rug.rug_personas rp,
         rug.rug_personas_fisicas rpf,
          rug.rug_partes rpar,
          rug.v_domicilios vd,
          rug.rug_cat_nacionalidades rcn
    where     rrtip.status_reg in ('AC', 'IN')
          and rp.sit_persona in ('AC', 'IN')
          and rp.id_persona = rrtip.id_persona
          and rpf.id_persona = rrtip.id_persona
          and rpar.id_parte = rrtip.id_parte
          and vd.id_domicilio = rp.id_domicilio
          and rcn.id_nacionalidad = rp.id_nacionalidad
          and rrtip.id_parte in (1, 3, 4)
   union all
   select rp.id_persona,
          rpar.id_parte,
          rpar.desc_parte,
          rp.per_juridica,
          rpf.nombre_persona,
          rpf.ap_paterno,
          rpf.ap_materno,
          rp.folio_mercantil,
          rpf.curp,
          rp.rfc,
          vd.id_domicilio,
          vd.calle,
          vd.num_exterior,
          vd.num_interior,
          vd.id_colonia,
          vd.cve_colonia,
          vd.id_localidad,
          vd.cve_localidad,
          vd.cve_deleg_municip,
          vd.nom_deleg_municip,
          vd.cve_estado,
          vd.nom_estado,
          vd.cve_pais,
          vd.nom_pais,
          rcn.id_nacionalidad,
          rcn.desc_nacionalidad,
          rrtip.status_reg status
     from rug.rug_rel_tram_partes rrtip,
          rug.rug_personas rp,
         rug.rug_personas_fisicas rpf,
          rug.rug_partes rpar,
          rug.v_domicilios vd,
          rug.rug_cat_nacionalidades rcn
    where     rrtip.status_reg in ('AC', 'IN')
          and rp.sit_persona in ('AC', 'IN')
          and rp.id_persona = rrtip.id_persona
          and rpf.id_persona = rrtip.id_persona
          and rpar.id_parte = rrtip.id_parte
          and vd.id_domicilio = rp.id_domicilio
          and rcn.id_nacionalidad = rp.id_nacionalidad
          and rrtip.id_parte in (1, 3, 4);

-- view v_busqueda_folio_e_pf  


CREATE EXTENSION unaccent;
         
create or replace view rug.v_busqueda_tramite_base as select rg.id_ultimo_tramite as id_tramite,             -- 6,457       5,904
          t.id_tipo_tramite as id_tipo_tramite,
          htp.fecha_creacion,
          case
             when t.id_tipo_tramite not in (1, 15, 16) then 'INSCRIPCION'
             else upper((trim(unaccent(rctt.descripcion))))
          end
             as descripcion,
          rg.id_garantia garantia
     from rug.tramites t,
          rug.rug_garantias rg,
          rug.rug_rel_tram_garan rrtg,
          rug.rug_cat_tipo_tramite rctt,
          (select rgh.id_garantia,
                  rgh.id_ultimo_tramite,
                  rbb.fecha_status as fecha_creacion
             from rug.rug_garantias_h rgh, rug.tramites tr, rug.rug_bitac_tramites rbb
            where     rgh.id_ultimo_tramite = tr.id_tramite
                  and rbb.id_tramite_temp = tr.id_tramite_temp
                  and tr.id_tipo_tramite = 1
                  and rbb.id_status = 3
                  and rbb.status_reg = 'AC') htp
    where     rrtg.id_garantia = rg.id_garantia
          and rrtg.id_tramite = t.id_tramite
          and rctt.id_tipo_tramite = t.id_tipo_tramite
          and rg.id_ultimo_tramite = t.id_tramite
          and t.id_tipo_tramite in (1, 8, 7, 6, 15, 9, 2)
          and rg.id_garantia = htp.id_garantia
          and rg.garantia_status in ('AC', 'CA', 'CT', 'CR')
          and t.status_reg = 'AC'
   union all
   -- aviso
   select t.id_tramite,
          t.id_tipo_tramite,
          t.fecha_creacion,
          rctt.descripcion,
          0 id_garantia
     from (select tri.id_tramite_temp,
                  tri.id_tramite,
                  rbb.fecha_status as fecha_creacion,
                  tri.id_tipo_tramite
             from rug.avisos_prev avp, rug.tramites tri, rug.rug_bitac_tramites rbb
            where     avp.id_tramite_temp = tri.id_tramite_temp
                  and avp.id_tramite_temp = rbb.id_tramite_temp
                  and rbb.id_status = 3
                  and rbb.status_reg = 'AC'
                  and tri.status_reg = 'AC') t,
          rug.avisos_prev ap,
          rug.rug_cat_tipo_tramite rctt
    where rctt.id_tipo_tramite = t.id_tipo_tramite
          and ap.id_tramite_temp = t.id_tramite_temp
          --restriccion de los dias de vigencia. 2018/04/24
          and t.fecha_creacion > current_date  - 15
   union all
   -- anotacion
   select t.id_tramite,
          t.id_tipo_tramite,
          t.fecha_creacion,
          rug.fn_borra_sin_con_garantia (
             upper((trim(unaccent(rctt.descripcion))))),
          t.id_tramite as id_garantia
     from (select tri.id_tramite_temp,
                  tri.id_tramite,
                  rbb.fecha_status as fecha_creacion,
                  tri.id_tipo_tramite
             from rug.rug_anotaciones_sin_garantia rasg,
                  rug.tramites tri,
                  rug.rug_bitac_tramites rbb
            where     rasg.id_tramite_temp = tri.id_tramite_temp
                  and rasg.id_tramite_temp = rbb.id_tramite_temp
                  and rbb.id_status = 3
                  and rbb.status_reg = 'AC'
                  and tri.status_reg = 'AC') t,
          rug.rug_anotaciones_sin_garantia rasg,
          rug.rug_cat_tipo_tramite rctt
    where     t.id_tramite_temp = rasg.id_tramite_temp
          and rctt.id_tipo_tramite = t.id_tipo_tramite
          and t.id_tipo_tramite = 10
   --- trámites de anotación sin garantía ---
   /* ggr  - 16.04.13  -  mmsecn2013-81  inicio */
   union all
   select t.id_tramite,
          t.id_tipo_tramite,
          bt.fecha_status,
          rug.fn_borra_sin_con_garantia (
             upper((trim(unaccent(ctt.descripcion))))),
          coalesce (ta.id_tramite_padre, 0) as id_garantia
     /* ggr  - 25.04.13  -  mmsecn2013-82   */
     from rug.tramites t
          inner join rug.rug_anotaciones_seg_inc_csg ta
             on ta.id_anotacion_temp = t.id_tramite_temp
          inner join rug.rug_bitac_tramites bt
             on     bt.id_tramite_temp = t.id_tramite_temp
                and bt.id_status = 3
                and bt.status_reg = 'AC'
          inner join rug.rug_cat_tipo_tramite ctt
             on ctt.id_tipo_tramite = t.id_tipo_tramite
    where t.id_tipo_tramite in (26, 27, 28, 29, 22, 23, 24, 25) /* ggr  - 25.04.13  -  mmsecn2013-82   */
                                                               and t.status_reg = 'AC';

-- view v_busqueda_tramite_base  



create or replace view rug.v_busqueda_tramite_fv as select rg.id_ultimo_tramite as id_tramite,             -- 6,457       5,904
          t.id_tipo_tramite as id_tipo_tramite,
          htp.fecha_creacion,
          case
             when t.id_tipo_tramite not in (1, 15, 16) then 'INSCRIPCION'
             else upper((trim(unaccent(rctt.descripcion))))
          end
             as descripcion,
          rg.id_garantia garantia,rg.garantia_status
     from rug.tramites t,
          rug.rug_garantias rg,
          rug.rug_rel_tram_garan rrtg,
          rug.rug_cat_tipo_tramite rctt,
          (select rgh.id_garantia,
                  rgh.id_ultimo_tramite,
                  rbb.fecha_status as fecha_creacion
             from rug.rug_garantias_h rgh, rug.tramites tr, rug.rug_bitac_tramites rbb
            where     rgh.id_ultimo_tramite = tr.id_tramite
                  and rbb.id_tramite_temp = tr.id_tramite_temp
                  and tr.id_tipo_tramite = 1
                  and rbb.id_status = 3
                  and rbb.status_reg = 'AC') htp
    where     rrtg.id_garantia = rg.id_garantia
          and rrtg.id_tramite = t.id_tramite
          and rctt.id_tipo_tramite = t.id_tipo_tramite
          and rg.id_ultimo_tramite = t.id_tramite
          and t.id_tipo_tramite in (1,2,4,6, 7, 8, 9, 15, 21)
          and rg.id_garantia = htp.id_garantia
          and rg.garantia_status in ('AC', 'CA', 'CT', 'CR','FV')
          and t.status_reg = 'AC';

-- view v_busqueda_tramite_fv  


-- funcion clave_rastreo

create or replace function rug.fn_folio_cve_rastreo (peidfirmamasiva int, peopcion int)
   returns varchar
    language plpgsql
AS $function$
declare
   vlfolio1         varchar;
   vlfolio2         varchar;
   vlcantidad       int;
   vlidtipotramite  int;
   
begin


    select count(*) --1
      into vlcantidad
      from rug.rug_firma_masiva
     where id_firma_masiva = peidfirmamasiva;
    
     
    select distinct b.id_tipo_tramite
      into vlidtipotramite    -- 1
      from rug.rug_firma_masiva a,
           rug.tramites_rug_incomp b
     where a.id_tramite_temp = b.id_tramite_temp
       and a.id_firma_masiva = peidfirmamasiva;
     
     
     
    if vlidtipotramite = 12 then
    
        
        if peopcion = 0 then
                     
            select rfc 
              into vlfolio1
              from (
                    select rfm.id_tramite_temp, rp.rfc
                      from rug.rug_firma_masiva rfm,
                           rug.rug_rel_tram_inc_partes rtp,
                           rug.rug_personas rp
                     where 1 = 1
                       and rtp.id_parte = 4
                       and rp.id_persona = rtp.id_persona
                       and rtp.id_tramite_temp = rfm.id_tramite_temp
                       and rp.rfc is not null
                       and rfm.id_firma_masiva = peidfirmamasiva
                       order by 1
                   )b limit 1;

            
            if vlcantidad > 1 then
           
            
                 select rfc
                   into vlfolio2
                   from (
                            select rfm.id_tramite_temp, rp.rfc
                              from rug.rug_firma_masiva rfm,
                                   rug.rug_rel_tram_inc_partes rtp,
                                   rug.rug_personas rp
                             where 1 = 1
                               and rtp.id_parte = 4
                               and rp.id_persona = rtp.id_persona
                               and rtp.id_tramite_temp = rfm.id_tramite_temp
                               and rp.rfc is not null
                               and rfm.id_firma_masiva = peidfirmamasiva
                               order by 1 desc
                         )c limit 1;
                  
                if vlfolio1 = '' or vlfolio1 is null then
                
                    vlfolio1 := vlfolio2;
                
                elsif vlfolio2 = '' or vlfolio2 is null then
                
                    vlfolio1 := vlfolio1;
                
                else
                
                    vlfolio1 := vlfolio1 || ' ... ' || vlfolio2;
                            
                end if;         
                
                
            
            end if;
                    
            
        elsif peopcion = 1 then
                              
             select nombre 
               into vlfolio1
               from (select rfm.id_tramite_temp, rp.id_persona, case when rp.per_juridica= 'PF' then (select nombre_persona || ' ' || ap_paterno || ' ' || ap_materno
                                                                                                  from rug.rug_personas_fisicas
                                                                                                 where id_persona = rp.id_persona) when rp.per_juridica= 'PM' then (select razon_social 
                                                                                                                                             from rug.rug_personas_morales
                                                                                                                                            where id_persona = rp.id_persona)end as nombre
                      from rug.rug_firma_masiva rfm,
                           rug.rug_rel_tram_inc_partes rtp,
                           rug.rug_personas rp
                     where 1 = 1
                       and rtp.id_parte = 4
                       and rp.id_persona = rtp.id_persona
                       and rtp.id_tramite_temp = rfm.id_tramite_temp
                       and rp.rfc is not null
                       and rfm.id_firma_masiva = peidfirmamasiva
                       order by 1
                   )d limit 1;


            if vlcantidad > 1 then
                
            
                 select nombre
                   into vlfolio2
                   from (select rfm.id_tramite_temp, rp.id_persona, case when rp.per_juridica= 'PF' then (select nombre_persona || ' ' || ap_paterno || ' ' || ap_materno
                                                                                                      from rug.rug_personas_fisicas
                                                                                                     where id_persona = rp.id_persona) when rp.per_juridica= 'PM' then  (select razon_social 
                                                                                                                                                 from rug.rug_personas_morales
                                                                                                                                                where id_persona = rp.id_persona)end as nombre
                              from rug.rug_firma_masiva rfm,
                                   rug.rug_rel_tram_inc_partes rtp,
                                   rug.rug_personas rp
                             where 1 = 1
                               and rtp.id_parte = 4
                               and rp.id_persona = rtp.id_persona
                               and rtp.id_tramite_temp = rfm.id_tramite_temp
                               and rp.rfc is not null
                               and rfm.id_firma_masiva = peidfirmamasiva
                               order by 1 desc
                         )e limit 1;
                  
                if vlfolio1 = '' or vlfolio1 is null then
                
                    vlfolio1 := vlfolio2;
                
                elsif vlfolio2 = '' or vlfolio2 is null then
                
                    vlfolio1 := vlfolio1;
                
                else
                
                    vlfolio1 := vlfolio1 || ' ... ' || vlfolio2;
                            
                end if;         
            
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
                     and id_firma_masiva = peidfirmamasiva
                       order by a.id_tramite_temp
                )f limit 1;
                
         if vlcantidad > 1 then       
          
             select cve_rastreo
               into vlfolio2
               from (
                      select b.cve_rastreo
                        from rug.rug_firma_masiva a,
                             rug.rug_tramite_rastreo b
                       where a.id_tramite_temp = b.id_tramite_temp
                         and id_firma_masiva = peidfirmamasiva
                           order by a.id_tramite_temp desc
                    )g limit 1;

            vlfolio1 := vlfolio1 || ' ... ' || vlfolio2;              
                    
         end if;
                
                               
    
    
    end if;
       

    return vlfolio1;

end;  
$function$;




create or replace view rug.v_carga_masiva_acreedores as select   distinct rfm.id_firma_masiva,
                     tri.id_persona id_usuario,
                     ra.nombre_archivo,
                     rug.fn_folio_cve_rastreo (rfm.id_firma_masiva, 1) nombre,
                     rug.fn_folio_cve_rastreo (rfm.id_firma_masiva, 0) rfc,
                     ra1.total_exito,
                     ra1.total_no_exito
     from   rug.rug_firma_masiva rfm,
            rug.rug_archivo ra,
            rug.tramites_rug_incomp tri,
            rug.tramites_rug_incomp tri1,
            rug.rug_carga_pool rcp,
            rug.rug_archivo ra1
    where       rfm.id_tramite_temp = tri.id_tramite_temp
            and rfm.id_firma_masiva = tri1.id_tramite_temp
            and rcp.id_archivo_firma = rfm.id_archivo
            and rcp.id_archivo = ra1.id_archivo
            and tri1.id_status_tram = 5
            and tri.id_tipo_tramite = 12
            and ra.id_archivo = rfm.id_archivo
            and rfm.status_reg = 'AC'
            and tri.id_status_tram = 5;

-- view v_carga_masiva_acreedores  

           

          
           
           
create or replace view rug.v_carga_masiva_pendiente_firma as select distinct
          rfm.id_firma_masiva,
          tri.id_tipo_tramite,
          ctt.descripcion tipo_tramite,
          tri.id_persona id_usuario,
          ra.nombre_archivo,
          rug.fn_folio_cve_rastreo (rfm.id_firma_masiva, 0) clave_rastreo,
          ra1.total_exito,
          ra1.total_no_exito,
          ra.fecha_reg fecha_status
     from rug.rug_firma_masiva rfm,
          rug.rug_archivo ra,
          rug.tramites_rug_incomp tri,
          rug.tramites_rug_incomp tri1,
          rug.rug_cat_tipo_tramite ctt,
          rug.rug_carga_pool rcp,
          rug.rug_archivo ra1
    where     rfm.id_tramite_temp = tri.id_tramite_temp
          and ctt.id_tipo_tramite = tri.id_tipo_tramite
          and rcp.id_archivo_firma = rfm.id_archivo
          and rcp.id_archivo = ra1.id_archivo
          and tri.id_tipo_tramite != 12
          and ra.id_archivo = rfm.id_archivo
          and rfm.status_reg = 'AC'
          and tri.id_status_tram = 5
          and tri1.id_tramite_temp = rfm.id_firma_masiva
          and tri1.id_status_tram = 5;

-- view v_carga_masiva_pendiente_firma  


-- funcion tipo_bien_garantia_h

create or replace function rug.tipo_bien_garantia_h (
                                                   peidgarantia     int,
                                                   peidtramite      int,
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
    from rug.rug_garantias_h rgg
    inner join rug.rug_rel_gar_tipo_bien rgt
    on rgg.relacion_bien = rgt.relacion_bien
    and rgg.id_garantia_pend = rgt.id_garantia_pend
    inner join rug.rug_cat_tipo_bien rgn
    on rgt.id_tipo_bien = rgn.id_tipo_bien
    where rgg.id_garantia = peidgarantia
    and rgg.id_ultimo_tramite = peidtramite;
    
    
begin

 
   --begin
      --select initcap(desc_codigo) into vldescerror
       --begin
       
       ------dbms_output.put_line(1);
       
       for r in cursgarantia
        
       loop 
       vltipobienes :=  concat(r.desc_tipo_bien || '. ');
       end loop;
       
       
       if pelongitud <> 0 then
       
           vllongitudcadena := length(vltipobienes);
           
           if vllongitudcadena > 85 then
           
           vltipobienes := substr(vltipobienes, 0, 85);
           vltipobienes := vltipobienes || '...';
           
           end if;
       
       end if;
                   
       vltipobienes:= coalesce(vltipobienes, '   '); 
       
       ------ dbms_output.put_line(vltipobienes);
      
   
   
      

--   if(substr(vltipobienes, length(trim(vltipobienes)),1) = ',' ) then
--   
--        vltipobienes := substr(vltipobienes, 0, length(trim(vltipobienes)) - 1);
--   
--   end if;
   
   
   

   return vltipobienes;
 
end;
  $function$;
         
create or replace view rug.v_detalle_boleta as select tri.id_tramite,
          rgm.id_garantia,
          rctt.descripcion as tipo_tramite,
          rtg.desc_tipo_garantia as tipo_garantia,
          substr (to_char (htp.fecha_inscr, 'dd/mm/yyyy - hh24:mi:ss'),
                  0,
                  10)
             as fecha_acto_convenio,
          '$ ' || htp.monto_maximo_garantizado || ' ' || rcm.desc_moneda
             as monto_maximo_garantizado,
          htp.otros_terminos_garantia,
          rug.tipo_bien_garantia_h (rgm.id_garantia, tri.id_tramite, 0)
             as tipos_bienes_garantia,
          htp.desc_garantia,
          cast (htp.vigencia as varchar (5)) || ' MESES' as vigencia,
          tri.id_persona as id_usuario,
          (select nombre_persona || ' ' || ap_paterno || ' ' || ap_materno
             from rug.rug_personas_fisicas
            where id_persona = tri.id_persona)
             as nombre_usuario,
          rsu.cve_usuario,
          rspu.cve_perfil,
          to_char (htt.fecha_status, 'dd/mm/yyyy - hh24:mi:ss')
             as fecha_creacion
     from rug.rug_cat_monedas rcm,
                                     rug.tramites tri
                                  inner join
                                     rug.rug_cat_tipo_tramite rctt
                                  on tri.id_tipo_tramite =
                                        rctt.id_tipo_tramite
                               inner join
                                  rug.rug_rel_tram_garan rgm
                               on tri.id_tramite = rgm.id_tramite
                            inner join
                               rug.rug_garantias rgt
                            on rgm.id_garantia = rgt.id_garantia
                         inner join
                            rug.rug_cat_tipo_garantia rtg
                         on rgt.id_tipo_garantia = rtg.id_tipo_garantia
                      inner join
                         rug.rug_bitac_tramites rbb
                      on tri.id_tramite_temp = rbb.id_tramite_temp
                   inner join
                      rug.rug_secu_usuarios rsu
                   on rsu.id_persona = tri.id_persona
                inner join
                   rug.rug_secu_perfiles_usuario rspu
                on rspu.cve_usuario = rsu.cve_usuario
             inner join
                (select rgh.id_garantia,
                        rgh.id_ultimo_tramite,
                        rbb.fecha_status,
                        rgh.id_moneda
                   from rug.rug_garantias_h rgh,
                        rug.tramites tr,
                        rug.rug_bitac_tramites rbb
                  where     rgh.id_ultimo_tramite = tr.id_tramite
                        and rbb.id_tramite_temp = tr.id_tramite_temp
                        and tr.id_tipo_tramite = 1
                        and rbb.id_status = 3) htt
             on rgm.id_garantia = htt.id_garantia
          inner join
             (select rgh.id_garantia,
                     rgh.id_ultimo_tramite,
                     rgh.id_tipo_garantia,
                     rgh.fecha_inscr,
                     rgh.monto_maximo_garantizado,
                     rgh.desc_garantia,
                     rgh.otros_terminos_garantia,
                     rgh.vigencia,
                     rgh.id_moneda
                from rug.rug_garantias_h rgh, rug.tramites tr
               where rgh.id_ultimo_tramite = tr.id_tramite) htp
          on rgm.id_garantia = htp.id_garantia
    where     rbb.id_status = 3
          and tri.id_tramite = htp.id_ultimo_tramite
          and rcm.id_moneda = htp.id_moneda;

-- view v_detalle_boleta  


create or replace function rug.fnconcatotorgante(
                      peidtramite      int,
                      peopcion         int)     --- 1 para nombre de otorgante, 2 para folio  mercantil del otorgante
                                                  --- 3 para nombre de otorgante incompleto
                                                  --- 5 para curp		--fr
returns text 
LANGUAGE plpgsql
AS $function$
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
                   rrtp.per_juridica = 'PM' then
                   (select   rug_acentos (upper (trim (razon_social)))
                      from   rug.rug_personas_h
                     where   id_persona = rrtp.id_persona
                       and rrtp.id_tramite = id_tramite
                     and id_parte = 1)
                end as
                   nombre
      from rug.rug_rel_tram_partes rrtp  
     where id_tramite = peidtramite
       and id_parte = 1
       and status_reg = 'AC'
     order by rrtp.id_persona asc;
     
       cursconcatenaotorgantetemp cursor is       
        select case when
                       rrtp.per_juridica=
                       'PF' then
                       (select      rug_acentos (upper (trim (nombre_persona)))
                                 || ' '
                                 || rug_acentos (upper (trim (ap_paterno)))
                                 || ' '
                                 || rug_acentos (upper (trim (ap_materno)))
                          from  rug.rug_personas_fisicas
                         where   id_persona = rrtp.id_persona)
                       when
                       rrtp.per_juridica=
                       'PM' then
                       (select   rug_acentos (upper (trim (razon_social)))
                          from   rug.rug_personas_morales
                         where   id_persona = rrtp.id_persona)
                    end as nombre
          from rug.rug_rel_tram_inc_partes rrtp  
         where id_tramite_temp = peidtramite
           and id_parte = 1
           and status_reg = 'AC'
         order by rrtp.id_persona asc;
         
            
    cursconcatenafoliomercantil cursor is
    select rug_acentos(upper (trim (rp.folio_mercantil))) as folio_mercantil
      from rug.rug_rel_tram_partes rrtp, rug.rug_personas_h rp  
     where rp.id_tramite = peidtramite
       and rrtp.id_tramite = rp.id_tramite
       and rp.id_persona = rrtp.id_persona 
       and rrtp.id_parte = 1
       and rrtp.id_parte = rp.id_parte
       and rrtp.status_reg = 'AC'
     order by rrtp.id_persona asc; 
          
    cursconcatenafoliomercantilt cursor is    
    select rug_acentos (upper (trim (rp.folio_mercantil))) as folio_mercantil
      from rug.rug_rel_tram_inc_partes rrtp, rug.rug_personas rp  
     where id_tramite_temp = peidtramite
       and rp.id_persona = rrtp.id_persona 
       and id_parte = 1       
       and status_reg = 'AC'
     order by rrtp.id_persona asc; 
 
     cursconcatenacurp cursor is			--fr
    select rug_acentos (upper (trim (rp.curp))) as curp					
      from rug.rug_rel_tram_partes rrtp, rug.rug_personas_h rp  
     where rp.id_tramite = peidtramite
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



    if peopcion = 1 then
        
            for r in cursconcatenaotorgante
                loop
                                         
                vlnombreotorganteaux := concat(r.nombres || vlseparador); 
                return vlcurpotorganteauxt;
	end loop;
    end if;    
    
    if(peopcion = 2) then
            
            for r2 in cursconcatenafoliomercantil
                loop
                                    
                    vlfoliootorganteaux := concat(r2.folio_mercantil || vlseparador);
                        
                return vlcurpotorganteauxt;        
                end loop;
    end if;    
    
    
     if (peopcion = 3) then
        
            for r3 in cursconcatenaotorgantetemp
                loop
                                             
                    vlnombreotorganteauxt := concat(r3.nombre || vlseparador);                    
                        
                return vlcurpotorganteauxt;        
                end loop;
    end if;     
    
    
     if(peopcion = 4) then
            
            for r4 in cursconcatenafoliomercantilt
                loop
                                     
                    vlfoliootorganteauxt := concat(r4.folio_mercantil || vlseparador);
                        
                return vlcurpotorganteauxt;        
                end loop;
    end if;     

     if (peopcion = 5) then							--fr
        
            for r5 in cursconcatenacurp
                loop
                    
                    vlcurpotorganteauxt := concat(r5.curp || vlseparador);                                            
                return vlcurpotorganteauxt;        
                end loop;
    end if;							--/fr
    
    
   -- return substr(vlnombreotorganteaux, 0, length(vlnombreotorganteaux) - length(vlseparador));
            
end;
$function$;



create or replace view rug.v_detalle_boleta_nuevo as select   tri.id_tramite,
            rgm.id_garantia,
            tri.id_tipo_tramite,
            rctt.descripcion as tipo_tramite,
            rtg.desc_tipo_garantia as tipo_garantia,
            to_char (htp.fecha_inscr, 'dd/mm/yyyy') as fecha_acto_convenio,
            '$ ' || htp.monto_maximo_garantizado || ' ' || rcm.desc_moneda
               as monto_maximo_garantizado,
            htp.otros_terminos_garantia,
            rug.tipo_bien_garantia_h (rgm.id_garantia, tri.id_tramite, 0)
               as tipos_bienes_garantia,
            htp.desc_garantia,
            cast (htp.vigencia as varchar) || ' MESES' as vigencia,
            usu.id_usuario_firmo id_usuario,
            usu.nombre_usuario,
            usu.cve_usuario,
            usu.cve_perfil,
            to_char (htt.fecha_status, 'dd/mm/yyyy - hh24:mi:ss')
            || case when (select   count ( * )
                           from   rug.v_firma_doctos
                          where   id_tramite_temp = tri.id_tramite_temp)=
                       1 then ' * ZULU GMT / UTC' else
                       ' * HORA CENTRAL DE CIUDAD DE MEXICO' end
               as fecha_creacion,
            case when
               (select   cambios_bienes_monto
                  from   rug.rug_garantias_h
                 where   id_garantia = rgm.id_garantia
                         and id_ultimo_tramite = tri.id_tramite) =
               'V' then
               'SI' else
               'NO' end
            as cambios_bienes_monto,           --decode (rgt.cambios_bienes_monto, 'v', 'si', 'no'),

            rgt.instrumento_publico,
            rgc.tipo_contrato,
            to_char (rgc.fecha_inicio, 'dd/mm/yyyy') as fecha_inicio_contrato,
            to_char (rgc.fecha_fin, 'dd/mm/yyyy') as fecha_fin_contrato,
            rgc.otros_terminos_contrato,
            case when tri.id_tipo_tramite =
                    2 then (select   autoridad_autoriza
                          from   rug.rug_anotaciones
                         where   id_tramite_temp = tri.id_tramite_temp) else
                    coalesce (rua.anotacion_juez, 'N/A')end
               as anotacion_juez,
            rzx.tipo_contrato as tipo_contrato_fu,
            to_char (rzx.fecha_inicio, 'dd/mm/yyyy')
               as fecha_inicio_contrato_fu,
            to_char (rzx.fecha_fin, 'dd/mm/yyyy') as fecha_fin_contrato_fu,
            rzx.otros_terminos_contrato as otros_terminos_contrato_fu,
            case when tri.id_tipo_tramite=
                    2 then (select   anotacion
                          from   rug.rug_anotaciones
                         where   id_tramite_temp = tri.id_tramite_temp)else
                    'N/A' end as contenido_resol,
            replace (rug.fnconcatotorgante (tri.id_tramite, 2), '<br>', ', ') as
               folio_otorgante,
               rtg.id_tipo_garantia,
               case when 
               (select   no_garantia_previa_ot
                  from   rug.rug_garantias_h
                 where   id_garantia = rgm.id_garantia
                         and id_ultimo_tramite = tri.id_tramite)=
               'V' then 'SI' else 'NO'
            end as no_garantia_previa_ot       --decode (rgt.no_garantia_previa_ot, 'v', 'si', 'no'),

     from   rug.rug_cat_monedas rcm,
                                             rug.tramites tri
                                          inner join
                                             rug.rug_cat_tipo_tramite rctt
                                          on tri.id_tipo_tramite =
                                                rctt.id_tipo_tramite
                                       inner join
                                          rug.rug_rel_tram_garan rgm
                                       on tri.id_tramite = rgm.id_tramite
                                    inner join
                                       rug.rug_garantias rgt
                                    on rgm.id_garantia = rgt.id_garantia
                                 inner join
                                    rug.rug_bitac_tramites rbb
                                 on tri.id_tramite_temp = rbb.id_tramite_temp
                              inner join
                                 (select   b.id_tramite,
                                           a.id_usuario_firmo,
                                           c.cve_usuario,
                                           c.cve_perfil,
                                           (   d.nombre_persona
                                            || ' '
                                            || d.ap_paterno
                                            || ' '
                                            || d.ap_materno)
                                              as nombre_usuario
                                    from   rug.v_firma_doctos a,
                                           rug.tramites b,
                                           rug.rug_secu_perfiles_usuario c,
                                          rug.rug_personas_fisicas d
                                   where   a.id_tramite_temp =
                                              b.id_tramite_temp
                                           and b.id_status_tram = 3
                                           and c.id_persona =
                                                 a.id_usuario_firmo
                                           and d.id_persona =
                                                 a.id_usuario_firmo
                                  union all
                                  select   b.id_tramite,
                                           coalesce (a.id_usuario_firmo,
                                                b.id_persona)
                                              id_usuario_firmo,
                                           c.cve_usuario,
                                           c.cve_perfil,
                                           (   d.nombre_persona
                                            || ' '
                                            || d.ap_paterno
                                            || ' '
                                            || d.ap_materno)
                                              as nombre_usuario
                                    from   rug.doctos_tram_firmados_rug a,
                                           rug.tramites b,
                                           rug.rug_secu_perfiles_usuario c,
                                          rug.rug_personas_fisicas d
                                   where   a.id_tramite_temp =
                                              b.id_tramite_temp
                                           and b.id_status_tram = 3
                                           and d.id_persona =
                                                 coalesce (a.id_usuario_firmo,
                                                      b.id_persona)
                                           and d.id_persona = c.id_persona)
                                 usu
                              on tri.id_tramite = usu.id_tramite
                           inner join
                              (select   rgh.id_garantia,
                                        rgh.id_ultimo_tramite,
                                        rbb.fecha_status,
                                        rgh.id_moneda
                                 from   rug.rug_garantias_h rgh,
                                        rug.tramites tr,
                                        rug.rug_bitac_tramites rbb
                                where   rgh.id_ultimo_tramite = tr.id_tramite
                                        and rbb.id_tramite_temp =
                                              tr.id_tramite_temp
                                        and rbb.id_status = 3
                                        and rbb.status_reg = 'AC') htt
                           on rgm.id_garantia = htt.id_garantia
                        inner join
                           (select   rgh.id_garantia,
                                     rgh.id_ultimo_tramite,
                                     rgh.id_tipo_garantia,
                                     rgh.fecha_inscr,
                                     rgh.monto_maximo_garantizado,
                                     rgh.desc_garantia,
                                     rgh.otros_terminos_garantia,
                                     rgh.vigencia,
                                     rgh.id_moneda
                              from   rug.rug_garantias_h rgh, rug.tramites tr
                             where   rgh.id_ultimo_tramite = tr.id_tramite
                                     and tr.id_tipo_tramite != 2
                            union all
                            select   rgh.id_garantia,
                                     rgh.id_ultimo_tramite,
                                     rgh.id_tipo_garantia,
                                     rgh.fecha_inscr,
                                     rgh.monto_maximo_garantizado,
                                     rgh.desc_garantia,
                                     rgh.otros_terminos_garantia,
                                     ra.vigencia_anotacion vigencia,
                                     rgh.id_moneda
                              from   rug.rug_garantias_h rgh,
                                     rug.tramites tr,
                                     rug.rug_anotaciones ra
                             where   rgh.id_ultimo_tramite = tr.id_tramite
                                     and ra.id_tramite_temp =
                                           tr.id_tramite_temp
                                     and ra.id_garantia = rgh.id_garantia
                                     and tr.id_tipo_tramite in (2)) htp
                        on rgm.id_garantia = htp.id_garantia
                     inner join
                        rug.rug_cat_tipo_garantia rtg
                     on htp.id_tipo_garantia = rtg.id_tipo_garantia
                  left join
                     (select   id_tramite_temp,
                               tipo_contrato,
                               fecha_inicio,
                               fecha_fin,
                               otros_terminos_contrato
                        from   rug.rug_contrato
                       where   clasif_contrato = 'OB') rgc
                  on tri.id_tramite_temp = rgc.id_tramite_temp
               left join
                  rug.rug_autoridad rua
               on tri.id_tramite_temp = rua.id_tramite_temp
            left join
               (select   id_tramite_temp,
                         tipo_contrato,
                         fecha_inicio,
                         fecha_fin,
                         otros_terminos_contrato
                  from   rug.rug_contrato
                 where   clasif_contrato = 'FU') rzx
            on tri.id_tramite_temp = rzx.id_tramite_temp
    where       rbb.id_status = 3
            and rbb.status_reg = 'AC'
            and tri.id_tramite = htp.id_ultimo_tramite
            and tri.id_tramite = htt.id_ultimo_tramite
            and rcm.id_moneda = htp.id_moneda;

-- view v_detalle_boleta_nuevo  


create or replace function  rug.fn_valida_mismo_otorgante (peidtramite int, 
                                                          peidpersona int)
   returns text
   language plpgsql
as $function$
declare
   vlcountpartes     int;
   vlidotorgante     int;
   vlcountdeudores   int;
   vlresultado       text;
begin

      select   count (rrt.id_persona)
        into   vlcountpartes
        from   rug.rug_rel_tram_partes rrt
       where   id_tramite = peidtramite 
         and   id_persona = peidpersona
         and   id_parte in (1, 2); 

      if vlcountpartes < 2
      then
         vlresultado := 'NO';
      else
      
         select   id_persona
           into   vlidotorgante
           from   rug.rug_rel_tram_partes
          where   id_tramite = peidtramite
            and   id_persona = peidpersona 
            and   id_parte = 1;

         select   count(id_persona)
           into   vlcountdeudores
           from   rug.rug_rel_tram_partes
          where       id_tramite = peidtramite
                  and id_parte = 2
                  and id_persona = vlidotorgante;

         if vlcountdeudores = 0
         then
            vlresultado := 'NO';
         else
           vlresultado := 'SI';   
         end if;
      end if;

   return vlresultado;
   end;
  $function$;



           
create or replace view rug.v_detalle_boleta_partes as select rph.id_tramite as id_tramite,
          rph.id_persona as id_persona,
          rph.id_parte as id_parte,
          rph.per_juridica as per_juridica,
          coalesce (
             rph.razon_social,
             (   rph.nombre_persona
              || ' '
              || rph.ap_paterno
              || ' '
              || rph.ap_materno))
             as nombre_parte,
          rph.folio_mercantil as folio_electronico,
          rph.rfc as rfc,
          rph.e_mail as e_mail,
          rth.telefono as telefono,
          rth.extension as extension,
          rcn.desc_nacionalidad as nacionalidad,
          vdh.domicilio as domicilio,
          rug.fn_valida_mismo_otorgante (rph.id_tramite, rph.id_persona)
     from rug.rug_personas_h rph
          left join rug.rug_telefonos_h rth
             on     rph.id_persona = rth.id_persona
                and rph.id_tramite = rth.id_tramite
                and rph.id_parte = rth.id_parte
          left join rug.v_domicilios_h vdh
             on     rph.id_persona = vdh.id_persona
                and rph.id_tramite = vdh.id_tramite
                and rph.id_parte = vdh.id_parte
          left join rug.rug_cat_nacionalidades rcn
             on rph.id_nacionalidad = rcn.id_nacionalidad;

-- view v_detalle_boleta_partes  
 
            


    

create or replace view rug.v_domicilio_partes as select   distinct
            rpp.id_persona,
            rdm.calle,
            rdm.num_exterior,
            rdm.num_interior,
            rdm.nom_colonia desc_colonia,
            rgn.desc_nacionalidad as nacionalidad,
            rdm.localidad,
            rdm.codigo_postal,
            rdm.nom_estado desc_estado,
            rdm.nom_pais desc_pais,
            (select   desc_municip_deleg
               from   institucional.v_se_cat_municip_deleg
              where   cve_estado = rdm.cve_estado
                      and cve_municip_deleg = rdm.cve_deleg_municip)
               as desc_municip_deleg,
            rdm.id_pais_residencia,
            rdm.ubica_domicilio_1,
            rdm.ubica_domicilio_2,
            rdm.poblacion,
            rdm.zona_postal
     from         rug.rug_personas rpp
               inner join
                  rug.v_domicilios rdm
               on rpp.id_domicilio = rdm.id_domicilio
            left join
               rug.rug_cat_nacionalidades rgn
            on rpp.id_nacionalidad = rgn.id_nacionalidad;

-- view v_domicilio_partes  



create or replace view rug.v_garantia_partes_firma as select   ttr.id_tramite_temp,
            rrf.nombre_persona as nombre,
            rrf.ap_paterno as apellido_paterno,
            rrf.ap_materno as apellido_materno,
            rrm.razon_social,
            rgp.desc_parte,
            rrp.per_juridica,
            rrp.folio_mercantil,
            rrp.rfc,
            rrf.curp,
            rdm.calle,
            rdm.num_exterior,
            rdm.num_interior,
            vdm.desc_colonia,
            vdm.nacionalidad,
            vdm.localidad,
            vdm.codigo_postal,
            vdm.desc_estado,
            vdm.desc_pais,
            vdm.desc_municip_deleg,
            vdm.id_pais_residencia,
            (select   desc_nacionalidad
               from   rug.rug_cat_nacionalidades
              where   id_nacionalidad = vdm.id_pais_residencia)
               pais_residencia,
            vdm.ubica_domicilio_1,
            vdm.ubica_domicilio_2,
            vdm.poblacion,
            vdm.zona_postal
     from                        rug.tramites_rug_incomp ttr
                              left join
                                 rug.rug_rel_tram_inc_partes rri
                              on ttr.id_tramite_temp = rri.id_tramite_temp
                           inner join
                              rug.rug_partes rgp
                           on rri.id_parte = rgp.id_parte
                        left join
                           rug.rug_personas rrp
                        on rri.id_persona = rrp.id_persona
                     left join
                       rug.rug_personas_fisicas rrf
                     on rri.id_persona = rrf.id_persona
                  left join
                     rug.rug_personas_morales rrm
                  on rri.id_persona = rrm.id_persona
               left outer join
                  rug.rug_domicilios rdm
               on rrp.id_domicilio = rdm.id_domicilio
            left outer join
               rug.v_domicilio_partes vdm
            on rri.id_persona = vdm.id_persona
    where   rri.status_reg = 'AC'
            and ttr.id_tramite_temp not in
                     (select   id_tramite_temp
                        from   rug.tramites
                       where   id_tramite_temp is not null)
            and ttr.id_status_tram = 5;

-- view v_garantia_partes_firma  


-- VISTA INOPERABLE POR USER_JOBS ---
/*           
create or replace view rug.v_jobs_usuario as select  j.job as id
      ,  r.id_job_db
      ,  r.descripcion
      ,  r.job_name as job
      ,  case when r.status_job = 'AC' then
                'ACTIVO' else 'INACTIVO' end as estado
      ,  r.repeat_interval as periodicidad
      ,  j.last_date as ult_ejecucion
      ,  j.last_date as prox_ejecucion
--      ,  replace(
--            replace(upper(j.interval), 'sysdate+','')
--            , 'sysdate +','') as quebrado
--      , replace(lower(j.interval ), 'sysdate', j.last_date ) as a
   from  user_jobs j
  inner join rug.rug_jobs r
     on  r.id_job_db = j.job
  where  log_user = 'RUG'
    and  r.job_name = 'SP_CADUCIDAD_AVISOS_PREV'
    and  r.id_job_db is not null;
*/
-- view v_jobs_usuario  



-- TABLA EN ESQUEMA INFRA --

create or replace view rug.v_preg_recupera_psw as select   preg.id_pregunta, idi.cve_idioma, idi.descripcion as tx_pregunta
       from   infra.secu_preg_recupera_psw preg,
              infra.secu_preg_rec_psw_desc idi
      where   preg.id_pregunta = idi.id_pregunta
   order by   preg.id_pregunta, idi.cve_idioma;

-- view v_preg_recupera_psw  


create or replace view rug.v_rep_base_acreedores as select
        /*+index(rb.rug_bitac_tramites_idx_01 , rt.rug_rel_tram_partes_pk), index (t) , index (per) */
 rb.id_tramite_temp,
            rb.fecha_status,
            rb.fecha_reg,
            rb.status_reg,
            t.id_tramite,
            t.id_persona id_persona_alta,
            t.fech_pre_inscr,
            t.fecha_inscr,
            t.fecha_creacion,
            rt.id_persona id_acreedor,
            per.nombre_persona nombre_acreedor,
            p.rfc rfc_acreedor,
            vu.e_mail e_mail_persona_alta,
            vu.id_perfil,
            vu.cve_perfil,
            vu.id_grupo,
            vu.desc_grupo,
            p.per_juridica
     from   rug.rug_bitac_tramites rb,
            rug.tramites t,
            rug.rug_rel_tram_partes rt,
            rug.v_rep_personas per,
            rug.rug_personas p,
            rug.v_usuarios_all vu
    where   rb.id_tramite_temp = t.id_tramite_temp
            and rb.id_status = 3
            and rb.status_reg = 'AC'
            and rb.id_tipo_tramite = 12
            and rt.id_tramite = t.id_tramite
            and rt.id_persona = per.id_persona
            and rt.id_parte = 4
            and rt.id_persona = p.id_persona
            and  t.id_persona = vu.id_persona
            and upper (per.nombre_persona) not like '%PRUEBA%'
            and not (regexp_like ( (select   tx_parametro
                                      from   rug.rug_rep_param
                                     where   cve_parametro = 'USUARIOS'),
                                  '''' || vu.e_mail || ''''))
            /*   and vu.e_mail not in ('adminrug','hjimenez@verasoft.mx','isisnatalia.ir@gmail.com','anaid375@hotmail.com'
          ,'jmedellin@verasoft.mx','jcsavage13@hotmail.com', 'lagaq@hotmail.com', 'myg2504@hotmail.com',
         'flaviolmendoza@gmail.com', 'ecastillo12@hotmail.com', 'janboker@gmail.com')*/
            --and regexp_substr(p.rfc,  '^aaa[0-9]+') is null
            -- and p.rfc is not null
            and rt.id_persona <> 3626
;

-- view v_rep_base_acreedores  




create or replace view rug.v_tramites_terminados (id_tramite, id_tipo_tramite, descripcion, fech_pre_inscr, fecha_inscr, id_garantia, id_status_tram, descrip_status, precio, fecha_status, url, id_persona_login, id_tramite_temp, id_acreedor, tramite_reasignado) as 
  select   tram.id_tramite,
              tram.id_tipo_tramite,
              gtt.descripcion,
              tram.fech_pre_inscr,
              tram.fecha_inscr,
              relt.id_garantia,
              tram.id_status_tram,
              stt.descrip_status,
              gtt.precio,
              rbb.fecha_status,
              null as url,
              case when tram.id_persona = 0 then tt.id_persona else tram.id_persona end
                 as id_persona_login,
              tram.id_tramite_temp,
              (select   id_persona
                 from   rug.rug_rel_tram_partes
              where   id_tramite = tram.id_tramite and id_parte = 4)
               id_acreedor,
              case when (select   count ( * )
                          from   rug.rug_tramites_reasignados
                         where   id_tramite_temp = tram.id_tramite_temp)=
                      0 then 'F' else
                      'V' end as
                 tramite_reasignado
  from   rug.tramites tram
  inner join rug.rug_cat_tipo_tramite gtt on tram.id_tipo_tramite = gtt.id_tipo_tramite
  inner join rug.status_tramite stt on tram.id_status_tram = stt.id_status_tram
  inner join rug.rug_bitac_tramites rbb on tram.id_tramite_temp = rbb.id_tramite_temp and rbb.id_status = 3
  inner join rug.rug_rel_tram_garan relt on tram.id_tramite = relt.id_tramite and relt.status_reg = 'AC'
  inner join rug.rug_rel_tram_garan rrtg on relt.id_garantia = rrtg.id_garantia
  inner join rug.tramites tt on tt.id_tramite = rrtg.id_tramite and tt.id_tipo_tramite = 1
  where   tram.status_reg = 'AC'
union all
  select   tram.id_tramite,
            tram.id_tipo_tramite,
            case  
                when tram.id_tipo_tramite in (26, 27, 28, 29) then
                    rug.fn_borra_sin_con_garantia(gtt.descripcion)
                else
                    gtt.descripcion
            end as tipo_tramite,
            tram.fech_pre_inscr,
            tram.fecha_inscr,
            0 id_garantia,
            tram.id_status_tram,
            stt.descrip_status,
            gtt.precio,
            rbb.fecha_status,
            null,
            tram.id_persona as id_persona_login,
            tram.id_tramite_temp,
            (select   id_persona
               from   rug.rug_rel_tram_partes
              where   id_tramite = tram.id_tramite and id_parte = 4)
               id_acreedor,
            case when (select   count ( * )
                        from   rug.rug_tramites_reasignados
                       where   id_tramite_temp = tram.id_tramite_temp) =
                    0 then 'F' else
                    'V' end as
               tramite_reasignado
  from   rug.tramites tram
  inner join rug.rug_cat_tipo_tramite gtt on tram.id_tipo_tramite = gtt.id_tipo_tramite and gtt.id_tipo_tramite in (10, 3, 11, 5, 26, 27, 28, 29)
  inner join rug.rug_rel_tram_partes rtp on tram.id_tramite = rtp.id_tramite and rtp.id_parte = 1
  inner join rug.status_tramite stt on stt.id_status_tram = tram.id_status_tram
  inner join rug.rug_bitac_tramites rbb on rbb.id_tramite_temp = tram.id_tramite_temp and rbb.id_status = 3
  where   (tram.id_status_tram = 3 or tram.id_status_tram =  10)
  and (tram.status_reg = 'AC' or tram.status_reg = 'CA');
 

-- VISTA NO OPERABLE --
create or replace view rug.v_rep_garantias as select   rg.id_garantia,
              desc_tipo_garantia,
              coalesce (monto_maximo_garantizado, 0) monto,
              desc_moneda,
              rg.id_moneda,
              vtt.fecha_status,
              rg.status_reg,
              vrpaa.cve_usuario,
              vrpaa.cve_perfil,
              vtt.id_acreedor,
              rg.id_ultimo_tramite,
              coalesce ( (select   vrp.nombre_persona
                       from   rug.v_rep_personas vrp
                      where   vrp.id_persona = vtt.id_acreedor),
                   'SIN ACREEDOR')
                 nombre_acreedor,
              garantia_status
       from   rug.rug_garantias rg,
              rug.rug_cat_tipo_garantia rc,
              rug.rug_cat_monedas rm,
              rug.rug_rel_tram_garan rrtm,
              rug.v_tramites_terminados vtt,
              rug.v_rep_pers_acr_aut vrpaa
      where       rg.id_tipo_garantia = rc.id_tipo_garantia
              and rg.id_moneda = rm.id_moneda
              and rrtm.id_garantia = rg.id_garantia
              and rrtm.status_reg = 'AC'
              and vtt.id_tramite = rrtm.id_tramite
              and vtt.id_tipo_tramite = 1
              and vrpaa.id_persona = vtt.id_persona_login
   group by   rg.id_garantia,
              desc_tipo_garantia,
              coalesce (monto_maximo_garantizado, 0),
              desc_moneda,
              rg.id_moneda,
              vtt.fecha_status,
              rg.status_reg,
              vtt.id_acreedor,
              rg.id_ultimo_tramite,
              vrpaa.cve_usuario,
              vrpaa.cve_perfil,
              garantia_status;

-- view v_rep_garantias  


create or replace view rug.v_rep_solicitud_gtias as select   fecha,
              sum (case when tipo = 1 then 1 else 0 end) solicitudes,
              sum (case when tipo = 2 then 1 else 0 end) garantias_inscritas,
              sum (case when tipo = 3 then 1 else 0 end) avisos_preventivos,
              sum (case when tipo = 4 then 1 else 0 end) modificaciones,
              sum (case when tipo = 5 then 1 else 0 end) transmisiones,
              sum (case when tipo = 6 then 1 else 0 end) rectificacion_por_error,
              sum (case when tipo = 7 then 1 else 0 end) renovaciones,
              sum (case when tipo = 8 then 1 else 0 end) cancelaciones,
              sum (case when tipo = 9 then 1 else 0 end) anotaciones,
              sum (case when tipo = 10 then 1 else 0 end) alta_acreedor, --gabriela quevedo 10032011
              sum (case when tipo = 11 then 1 else 0 end) certificaciones,
              sum (case when tipo = 12 then 1 else 0 end) usuarios_ciudadanos,
              sum (case when tipo = 14 then 1 else 0 end) usuarios_acreedores,
              sum (case when tipo = 13 then 1 else 0 end) usuarios_autoridades,
              sum (case when tipo = 2 then 1 when tipo = 8 then -1 else 0 end) inscripciones_activas
       from   (select   1 tipo, (fecha_status)::date as fecha, 0 total -- solicitudes
                 from   rug.rug_bitac_tramites
                where   id_tipo_tramite in (1, 3, 7, 8, 6, 9, 4, 2, 10, 12, 5) -- gabriela quevedo 06122010
                        and id_status = 3         -- gabriela quevedo 06122010
                        and status_reg = 'AC'     -- gabriela quevedo 06122010
               union all
               select   2 tipo, (fecha_status)::date, 0 total      --garantias
                 from   rug.rug_bitac_tramites
                where       id_tipo_tramite = 1
                        and status_reg = 'AC'
                        and id_status = 3
               union all
               select   3 tipo, (fecha_status)::date, 0 total --avisos preventivos
                 from   rug.rug_bitac_tramites
                where       id_tipo_tramite = 3
                        and status_reg = 'AC'
                        and id_status = 3
               union all
               select   4 tipo, (fecha_status)::date, 0 total -- modificaciones
                 from   rug.rug_bitac_tramites
                where       id_tipo_tramite = 7
                        and status_reg = 'AC'
                        and id_status = 3
               union all
               select   5 tipo, (fecha_status)::date, 0 total -- transmisiones,
                 from   rug.rug_bitac_tramites
                where       id_tipo_tramite = 8
                        and status_reg = 'AC'
                        and id_status = 3
               union all
               select   6 tipo, (fecha_status)::date, 0 total -- rectificacion_por_error,
                 from   rug.rug_bitac_tramites
                where       id_tipo_tramite = 6
                        and status_reg = 'AC'
                        and id_status = 3
               union all
               select   7 tipo, (fecha_status)::date, 0 total -- renovaciones,
                 from   rug.rug_bitac_tramites
                where       id_tipo_tramite = 9
                        and status_reg = 'AC'
                        and id_status = 3
               union all
               select   8 tipo, (fecha_status)::date, 0 total -- cancelaciones
                 from   rug.rug_bitac_tramites
                where       id_tipo_tramite = 4
                        and status_reg = 'AC'
                        and id_status = 3
               union all
               select   9 tipo, (fecha_status)::date, 0 total   -- anotaciones
                 from   rug.rug_bitac_tramites
                where       id_tipo_tramite in (2, 10)
                        and status_reg = 'AC'
                        and id_status = 3
               union all
                 --  --gabriela quevedo 10032011
                 select   10 tipo, (min (fecha_status)::date) fecha, 0 total
                   from   rug.v_rep_base_acreedores
                  where   regexp_substr (rfc_acreedor, '^aaa[0|1]{6}') is null
                          and rfc_acreedor is not null
               group by   rfc_acreedor
               union all
                 select   10 tipo, (min (fecha_status)::date) fecha, 0 total
                   from   rug.v_rep_base_acreedores
                  where   (regexp_substr (rfc_acreedor, '^aaa[0|1]{6}') is not null
                           or rfc_acreedor is null)
               group by   trim (nombre_acreedor)
               union all
               -- gabriela quevedo 06122010
               select   11 tipo, (fecha_status)::date as fecha, 0 total -- certificaciones
                 from   rug.rug_bitac_tramites
                where       id_tipo_tramite = 5
                        and id_status = 3
                        and status_reg = 'AC'
               /*
               select   11 tipo, trunc (fecha_cert)    -- ciiudadanos  count (
                 from   rug.rug_certificaciones
                 */
               union all
               select   12 tipo, (rsu.fh_registro)::date, 0 total -- ciiudadanos
                 from   rug.rug_secu_perfiles_usuario rsp,
                        rug.rug_secu_usuarios rsu
                where   rsp.id_persona = rsu.id_persona
                        and rsp.cve_perfil = 'CIUDADANO'
                        and rsu.fh_registro >=
                              to_date ('07/10/2010', 'dd/mm/yyyy')
               union all
               select   13 tipo, (rsu.fh_registro)::date, 0 total -- autoridades
                 from   rug.rug_secu_perfiles_usuario rsp,
                        rug.rug_secu_usuarios rsu
                where   rsp.id_persona = rsu.id_persona
                        and rsp.cve_perfil = 'AUTORIDAD'
                        and rsu.fh_registro >=
                              to_date ('07/10/2010', 'dd/mm/yyyy')
               union all
               select   14 tipo, (rsu.fh_registro)::date, 0 total -- acreedores
                 from   rug.rug_secu_perfiles_usuario rsp,
                        rug.rug_secu_usuarios rsu
                where   rsp.id_persona = rsu.id_persona
                        and rsp.cve_perfil = 'ACREEDOR'
                        and rsu.fh_registro >=
                              to_date ('07/10/2010', 'dd/mm/yyyy'))b
   group by   fecha;

-- view v_rep_solicitud_gtias  



--------------------------------------------------------
--  DDL for Function FNCONCATIDTRAMITE
--------------------------------------------------------


drop function if exists rug.fnconcatidtramite();
  create or replace function rug.fnconcatidtramite(peidtramite int,
                                                   pecaracter char,
                                                   peprocess int)
returns text 
language plpgsql
as $function$
declare
    vltramitesconcat text;
    vlidtramiteind   int;
    vlfirmadoscount  int;
    vldiferentesfirma  int;
    vlerror          char;
    
    curstramitesfirmamasiva cursor is
    select id_tramite_temp
    from rug.rug_firma_masiva
    where id_firma_masiva = cpeidtramite and status_reg = 'AC';
    
    
begin
    
   vlerror := 'F';

   select count(rfm.id_tramite_temp)
   into vlfirmadoscount
   from rug.rug_firma_masiva rfm,
        rug.doctos_tram_firmados_rug dct
   where rfm.id_tramite_temp = dct.id_tramite_temp       
   and rfm.id_firma_masiva = peidtramite;
   
   select count(rfm.id_tramite_temp)
   into vldiferentesfirma
   from rug.rug_firma_masiva rfm,
   rug.tramites_rug_incomp tri
   where rfm.id_tramite_temp = tri.id_tramite_temp
   and rfm.id_firma_masiva = peidtramite
   and tri.id_status_tram not in (5,3);
       
   
   if vlfirmadoscount > 0 or vldiferentesfirma > 0 then
   
    vlerror := 'V';
   
    if vlfirmadoscount > 0 then 
        
        vltramitesconcat := 'ER1';
        
    elsif vldiferentesfirma > 0 then   
    
        vltramitesconcat := 'ER2';
    
    end if;
    
   else
   
       begin
            loop 
            FETCH curstramitesfirmamasiva INTO vlIdTramiteInd;
                EXIT WHEN cursTramitesFirmaMasiva%NOTFOUND;
                    vlTramitesConcat := CONCAT(vlTramitesConcat, vlIdTramiteInd || peCaracter);
            end loop; 
         close  curstramitesfirmamasiva;
                            
       end;    
   
   end if;
 
   if peprocess = 1 and vlerror = 'V' then
    
    return null;
    
    elsif (peprocess = 1 and vlerror = 'F') or (peprocess = 0) then
    
    return substr(vltramitesconcat, 0, length(vltramitesconcat)-1);
    
   end if;

exception
   when others then
      
   -- reg_param_pls(seq_rug_param_pls.nextval, 'fnconcatidtramite', 'exception', substr(sqlcode||':'||sqlerrm,1,250), 'out');      
    return null;
end; 
 $function$;


-------------------------------------------------------

create or replace view rug.v_rug_firma_masiva as select rfm.id_firma_masiva,
            rug.fnconcatidtramite (rfm.id_firma_masiva, '|', 1) as tramites_ids,
            rfm.id_archivo,
            (rfm.fecha_reg)::date fecha_reg,
            ra.algoritmo_hash,
            (select archivo
               from rug.rug_archivo
              where id_archivo = rfm.id_archivo)
               archivo,
            0 id_tipo_tramite,
            case when
               substring(rug.fnconcatidtramite (rfm.id_firma_masiva, '|', 0), 2) =
               'ER' then 1 else
               0 end as id_error,
            case when
               substring (rug.fnconcatidtramite (rfm.id_firma_masiva, '|', 0), 3) =
               'ER1' then 'EL PAQUETE CONTIENE TRAMITES FIRMADOS'
               when
               substring (rug.fnconcatidtramite (rfm.id_firma_masiva, '|', 0), 3) =
               'ER2' then 'EL PAQUETE CONTIENE TRAMITES FUERA DE STATUS' end as desc_error
       from rug.rug_firma_masiva rfm, rug.rug_archivo ra
      where     rfm.id_archivo = ra.id_archivo
            and rfm.id_archivo <> 0
            and rfm.status_reg = 'AC'
   group by rfm.id_firma_masiva,
            rfm.id_archivo,
            (rfm.fecha_reg)::date,
            ra.algoritmo_hash
   union all
   select rfm.id_firma_masiva,
          (rfm.id_tramite_temp)::text,
          rfm.id_archivo,
          (rfm.fecha_reg)::date fecha_reg,
          null algoritmo_hash,
          null archivo,
          (select id_tipo_tramite
             from rug.tramites_rug_incomp
            where id_tramite_temp = rfm.id_tramite_temp)
          + 200,
          case when (select id_status_tram
                      from rug.tramites_rug_incomp
                     where id_tramite_temp = rfm.id_tramite_temp) =
                  3 then 1 end,
          case when (select id_status_tram
                      from rug.tramites_rug_incomp
                     where id_tramite_temp = rfm.id_tramite_temp) =
                  3 then 'EL TRAMITE YA HA SIDO TERMINADO' end
     from rug.rug_firma_masiva rfm
    where rfm.id_archivo = 0 and rfm.status_reg = 'AC';

-- view v_rug_firma_masiva  



create or replace view rug.v_se_cat_colonias_rug as select   id_colonia,
              cve_pais,
              cve_estado,
              cve_municip_deleg,
              cve_colonia,
              desc_colonia,
              codigo_postal,
              desc_colonia || ' ' || codigo_postal desc_colonia_cp,
              f_inicio_vigencia,
              f_fin_vigencia,
              tipo_asentamiento,
              tipo_asentamiento_cd,
              sit_colonia
       from   institucional.se_cat_colonias
      where       f_fin_vigencia > current_date
              and upper (desc_colonia) not like upper ('otra no especificada%')
              and upper (desc_colonia) not like upper ('%inconsistente%')
   order by   cve_estado, cve_municip_deleg, desc_colonia;

-- view v_se_cat_colonias_rug  



create or replace view rug.v_se_cat_estados_rug as select   ce.cve_pais,
              ce.cve_estado,
              ce.desc_estado,
              id_estado,
              sit_estado
       from   institucional.se_cat_estados ce
   order by   ce.cve_pais, ce.desc_estado;

-- view v_se_cat_estados_rug  



create or replace view rug.v_se_cat_localidades_rug as select   id_localidad,
              cve_pais,
              cve_estado,
              cve_municip_deleg,
              cve_localidad,
              initcap (desc_localidad) as desc_localidad,
              codigo_postal,
              initcap (desc_localidad) || ' ' || codigo_postal
                 desc_localidad_cp,
              f_inicio_vigencia,
              f_fin_vigencia,
              tipo_asentamiento,
              tipo_asentamiento_cd,
              cve_temp,
              sit_localidad
       from   institucional.se_cat_localidades
      where   upper (desc_localidad) not like upper ('otra no especificada%')
              and f_fin_vigencia > current_timestamp
   order by   cve_estado,
              cve_municip_deleg,
              desc_localidad,
              codigo_postal;

-- view v_se_cat_localidades_rug  



create or replace view rug.v_se_cat_municip_deleg_rug as select   mun.cve_pais,
            mun.cve_estado,
            edos.desc_estado,
            mun.cve_municip_deleg,
            mun.f_inicio_vigencia,
            mun.f_fin_vigencia,
            mun.desc_municip_deleg,
            mun.sit_municip_deleg
     from   institucional.se_cat_municip_deleg mun, rug.v_se_cat_estados_rug edos
    where       mun.desc_municip_deleg not like '%INCONSISTENTE%'
            and edos.cve_pais = mun.cve_pais
            and edos.cve_estado = mun.cve_estado;

-- view v_se_cat_municip_deleg_rug  



create or replace view rug.v_tramites_incomp_partes as select rtp.id_tramite_temp id_tramite,
          rtp.id_persona,
          rtp.id_parte,
          rgp.desc_parte,
          rtp.per_juridica,
          case when
             rtp.per_juridica =
             'PF' then (select    nombre_persona
                           || ' '
                           || ap_paterno
                           || ' '
                           || ap_materno
                      from rug.rug_personas_fisicas
                     where id_persona = rtp.id_persona)
                     when
             rtp.per_juridica =
             'PM' then (select razon_social
                      from rug.rug_personas_morales
                     where id_persona = rtp.id_persona) end
             as nombre,
          case when rpp.per_juridica=
                  'PF'then (select nombre_persona
                           from rug.rug_personas_fisicas
                          where id_persona = rtp.id_persona)
                          else
                  null end
             as nombre_persona,
          case when rpp.per_juridica=
                  'PF' then (select ap_paterno
                           from rug.rug_personas_fisicas
                          where id_persona = rtp.id_persona) else
                  null end
             as ap_paterno_persona,
          case when rpp.per_juridica=
                  'PF' then (select ap_materno
                           from rug.rug_personas_fisicas
                          where id_persona = rtp.id_persona) else
                  null end
             as ap_materno_persona,
          case when rpp.per_juridica=
                  'PM' then (select razon_social
                           from rug.rug_personas_morales
                          where id_persona = rtp.id_persona) else
                  null end
             as razon_social,
          rpp.folio_mercantil,
          rpp.rfc,
          case when rpp.per_juridica=
                  'PF' then (select curp
                           from rug.rug_personas_fisicas
                          where id_persona = rtp.id_persona) else
                  null end
             as curp,
          rpp.id_domicilio,
          vd.calle,
          vd.num_exterior,
          vd.num_interior,
          vd.id_colonia,
          vd.cve_colonia,
          vd.id_localidad,
          vd.cve_localidad,
          vd.cve_deleg_municip,
          vd.nom_deleg_municip,
          vd.cve_estado,
          vd.nom_estado,
          vd.cve_pais,
          vd.nom_pais,
          vd.codigo_postal,
          rpp.id_nacionalidad,
          rcn.desc_nacionalidad,
          rpp.e_mail,
          rtt.telefono,
          rtt.extension,
          rpp.curp_doc,
          vd.localidad,
          vd.nom_colonia,
          vd.id_pais_residencia,
          vd.ubica_domicilio_1,
          vd.ubica_domicilio_2,
          vd.poblacion,
          vd.zona_postal,
          case when rpp.per_juridica=
                  'PM' then (select tipo
                           from rug.rug_personas_morales
                          where id_persona = rtp.id_persona) else
                  null end
             as tipo_sociedad
     from rug.rug_rel_tram_inc_partes rtp
          inner join rug.rug_partes rgp
             on rtp.id_parte = rgp.id_parte
          inner join rug.rug_personas rpp
             on rtp.id_persona = rpp.id_persona
          left join rug.v_domicilios vd
             on vd.id_domicilio = rpp.id_domicilio
          inner join rug.rug_telefonos rtt
             on rtp.id_persona = rtt.id_persona
          inner join rug.rug_cat_nacionalidades rcn
             on rcn.id_nacionalidad = rpp.id_nacionalidad
    where rtp.status_reg = 'AC' and rgp.id_parte in (3, 4)
   union all
   select rtp.id_tramite_temp id_tramite,
          rtp.id_persona,
          rtp.id_parte,
          rgp.desc_parte,
          rtp.per_juridica,
          case when rtp.per_juridica=
             'PF' then (select    nombre_persona
                           || ' '
                           || ap_paterno
                           || ' '
                           || ap_materno
                      from rug.rug_personas_fisicas
                     where id_persona = rtp.id_persona)
               when rtp.per_juridica=
             'PM' then (select razon_social
                      from rug.rug_personas_morales
                     where id_persona = rtp.id_persona) end 
             as nombre,
          case when rpp.per_juridica =
                  'PF' then (select nombre_persona
                           from rug.rug_personas_fisicas
                          where id_persona = rtp.id_persona) else
                  null end
             as nombre_persona,
          case when rpp.per_juridica =
                  'PF' then (select ap_paterno
                           from rug.rug_personas_fisicas
                          where id_persona = rtp.id_persona) else
                  null end
             as ap_paterno_persona,
          case when rpp.per_juridica =
                  'PF' then (select ap_materno
                           from rug.rug_personas_fisicas
                          where id_persona = rtp.id_persona) else
                  null end
             as ap_materno_persona,
          case when rpp.per_juridica =
                  'PM' then (select razon_social
                           from rug.rug_personas_morales
                          where id_persona = rtp.id_persona) else
                  null end
             as razon_social,
          rpp.folio_mercantil,
          rpp.rfc,
          case when rpp.per_juridica =
                  'PF' then (select curp
                           from rug.rug_personas_fisicas
                          where id_persona = rtp.id_persona) else
                  null end
             as curp,
          rpp.id_domicilio,
          vd.calle,
          vd.num_exterior,
          vd.num_interior,
          vd.id_colonia,
          vd.cve_colonia,
          vd.id_localidad,
          vd.cve_localidad,
          vd.cve_deleg_municip,
          vd.nom_deleg_municip,
          vd.cve_estado,
          vd.nom_estado,
          vd.cve_pais,
          vd.nom_pais,
          vd.codigo_postal,
          rpp.id_nacionalidad,
          rcn.desc_nacionalidad,
          rpp.e_mail,
          rtt.telefono,
          rtt.extension,
          rpp.curp_doc,
          vd.localidad,
          vd.nom_colonia,
          vd.id_pais_residencia,
          vd.ubica_domicilio_1,
          vd.ubica_domicilio_2,
          vd.poblacion,
          vd.zona_postal,
          case when rpp.per_juridica =
                  'PM' then (select tipo
                           from rug.rug_personas_morales
                          where id_persona = rtp.id_persona) else
                  null end
             as tipo_sociedad
     from rug.rug_rel_tram_inc_partes rtp
          inner join rug.rug_partes rgp
             on rtp.id_parte = rgp.id_parte
          inner join rug.rug_personas rpp
             on rtp.id_persona = rpp.id_persona
          left join rug.v_domicilios vd
             on vd.id_domicilio = rpp.id_domicilio
          left join rug.rug_telefonos rtt
             on rtp.id_persona = rtt.id_persona
          inner join rug.rug_cat_nacionalidades rcn
             on rcn.id_nacionalidad = rpp.id_nacionalidad
    where rtp.status_reg = 'AC' and rgp.id_parte in (1, 2);

-- view v_tramites_incomp_partes  



create or replace view rug.v_tramites_pendientes as select   tcr.id_tramite_temp as id_tramite_temp,
            tcr.id_tipo_tramite as id_tipo_tramite,
            -- ggr 11042013 - mmescn2013-81  /* inicio */
            rug.fn_borra_sin_con_garantia(ttr.descripcion) as tipo_tramite,
            -- ggr 11042013 - mmescn2013-81  /* fin */
            ttr.precio as precio,
            rbb.fecha_status as fecha_status,
            sst.descrip_status as descrip_status,
            tcr.id_status_tram as id_status,
            ran.id_garantia_pend as id_garantia_pend,
            tps.desc_garantia as desc_garantia,
            rug.fnconcatotorgante (tcr.id_tramite_temp, 3) nombre,
            rug.fnconcatotorgante (tcr.id_tramite_temp, 4) folio_mercantil,
            tcr.id_persona as id_persona_login,
            rss.url as url,
            tcr.id_paso as id_paso,
            (select   id_persona
               from   rug.rug_rel_tram_inc_partes
              where       id_tramite_temp = tcr.id_tramite_temp
                      and id_parte = 4
                      and status_reg = 'AC')
               id_acreedor,
            tps.id_garantia_modificar as id_garantia_modificar,
            case when rtr.id_tramite_temp is not null then 'V' else 'F' end
               as tramite_reasignado,
            null desc_tram_firma
     from   rug.tramites_rug_incomp tcr
     left join rug.rug_cat_tipo_tramite ttr
       on   tcr.id_tipo_tramite = ttr.id_tipo_tramite
     left join rug.rug_bitac_tramites rbb
       on   tcr.id_tramite_temp = rbb.id_tramite_temp
    inner join rug.status_tramite sst
       on   tcr.id_status_tram = sst.id_status_tram
     left join rug.rug_rel_tram_inc_garan ran
       on   tcr.id_tramite_temp = ran.id_tramite_temp
     left join       (select   *
                        from   rug.rug_garantias_pendientes
                       where   id_garantia_pend in
                                     (select   distinct id_garantia_pend
                                        from   rug.rug_garantias
                                       where   garantia_status <> 'FV')) tps
       on   ran.id_garantia_pend = tps.id_garantia_pend
     left outer join rug.rug_cat_pasos rss
       on   tcr.id_paso = rss.id_paso
     left join rug.rug_tramites_reasignados rtr
       on   tcr.id_tramite_temp = rtr.id_tramite_temp
    where   tcr.id_status_tram <> 3
      and   tcr.status_reg = 'AC'
      and   rbb.status_reg = 'AC'
      and   tcr.id_tipo_tramite not in (12, 19
                                        , 26,27,28,29, 25,24,23,22) --- ggr 05122013 - mmescn2013-81 y 82 
      and   tcr.id_tramite_temp not in
                 (select   distinct id_tramite_temp
                    from   rug.rug_firma_masiva
                   where   id_tramite_temp in
                                 (select   distinct id_tramite_temp
                                    from   rug.tramites_rug_incomp
                                   where   id_tipo_tramite <> 12)
                  union all
                  select   tra.id_tramite_temp
                    from   rug.tramites_rug_incomp tra,
                           (select   id_tramite_temp,
                                     id_persona id_acreedor
                              from   rug.rug_rel_tram_inc_partes
                             where   id_parte = 4) prt,
                           rug.rel_usu_acreedor uacr
                   where       1 = 1
                           and tra.id_tramite_temp = prt.id_tramite_temp
                           and uacr.id_usuario = tra.id_persona
                           and uacr.id_acreedor = prt.id_acreedor
                           --                               and tra.id_tipo_tramite <> 12
                           and tra.id_status_tram <> 3
                           and uacr.status_reg = 'IN'
                           and tra.id_persona = tcr.id_persona)
   union all
   select   tcr.id_tramite_temp,
            tcr.id_tipo_tramite,
            ttr.descripcion as tipo_tramite,
            ttr.precio,
            rbb.fecha_status,
            sst.descrip_status,
            tcr.id_status_tram as id_status,
            null id_garantia_pend,
            null desc_garantia,
            null nombre,
            null folio_mercantil,
            tcr.id_persona as id_persona_login,
            null url,
            tcr.id_paso,
            (select   id_persona
               from   rug.rug_rel_tram_inc_partes
              where       id_tramite_temp = tcr.id_tramite_temp
                      and id_parte = 4
                      and status_reg = 'AC')
               id_acreedor,
            null id_garantia_modificar,
            case when rtr.id_tramite_temp is not null then 'V' else 'F' end
               as tramite_reasignado,
            (select   distinct c.descripcion
               from   rug.tramites_rug_incomp a,
                      rug.rug_firma_masiva b,
                      rug.rug_cat_tipo_tramite c,
                      rug.tramites_rug_incomp d
              where       a.id_tipo_tramite = 18
                      and b.id_firma_masiva = a.id_tramite_temp
                      and b.id_tramite_temp = d.id_tramite_temp
                      and d.id_tipo_tramite = c.id_tipo_tramite
                      and a.id_tramite_temp = tcr.id_tramite_temp)
               desc_tram_firma
     from   rug.tramites_rug_incomp tcr
     left join rug.rug_cat_tipo_tramite ttr
       on   tcr.id_tipo_tramite = ttr.id_tipo_tramite
     left join rug.rug_bitac_tramites rbb
       on   tcr.id_tramite_temp = rbb.id_tramite_temp
    inner join rug.status_tramite sst
       on   tcr.id_status_tram = sst.id_status_tram
     left join rug.rug_tramites_reasignados rtr
       on   tcr.id_tramite_temp = rtr.id_tramite_temp
    where   tcr.id_status_tram <> 3
      and   tcr.id_tipo_tramite not in (12)
      and   tcr.status_reg = 'AC'
      and   rbb.status_reg = 'AC'
      and   tcr.id_tramite_temp in
                 (select   distinct id_firma_masiva
                    from   rug.rug_firma_masiva
                   where   id_tramite_temp in
                                 (select   distinct id_tramite_temp
                                    from   rug.tramites_rug_incomp
                                   where   id_tipo_tramite <> 12)
                  union all
                  select   tra.id_tramite_temp
                    from   rug.tramites_rug_incomp tra,
                           (select   id_tramite_temp,
                                     id_persona id_acreedor
                              from   rug.rug_rel_tram_inc_partes
                             where   id_parte = 4) prt,
                           rug.rel_usu_acreedor uacr
                   where       1 = 1
                           and tra.id_tramite_temp = prt.id_tramite_temp
                           and uacr.id_usuario = tra.id_persona
                           and uacr.id_acreedor = prt.id_acreedor
                           and tra.id_tipo_tramite <> 12
                           and tra.id_status_tram <> 3
                           and uacr.status_reg = 'IN'
                           and tra.id_persona = tcr.id_persona)
   -- ggr 11042013 - mmescn2013-81  /* inicio */
     union all
   select   ai.id_anotacion_temp
        ,   ti.id_tipo_tramite  
        ,   replace( 
                replace(tt.descripcion, 'con Garantía', '')
                   , 'sin Garantía', '')
        ,   tt.precio
        ,   ai.fecha_reg -- verificar si es la última fecha de modificación del registro porque nace en estatus 3
        ,   st.descrip_status
        ,   ti.id_status_tram
        ,   g.id_garantia
        ,   g.desc_garantia
        ,   pp.nombre
        ,   p.folio_mercantil
        ,   ti.id_persona --ai.id_usuario
        ,   '/NULO' as url
        ,   0  as id_paso
        ,   null as id_acreedor
        ,   null as id_garantia_modificar
        ,   'F' tramite_reasignado
        ,   null as desc_tram_firma-- esto es la firma
     from   rug.rug_anotaciones_seg_inc_csg ai
    inner join rug.tramites_rug_incomp ti
       on   ti.id_tramite_temp = ai.id_anotacion_temp
    inner join rug.rug_cat_tipo_tramite tt
       on   tt.id_tipo_tramite = ti.id_tipo_tramite
    inner join rug.status_tramite st
       on   st.id_status_tram = ti.id_status_tram-- .id_status
     left join rug.rug_garantias g          -- no aplica porque la garantia no esta pendiente el tramiite padre fue completado
       on   g.id_garantia = ai.id_garantia
     left join rug.rug_rel_tram_inc_partes tip
       on   tip.id_tramite_temp = ti.id_tramite_temp
      and   tip.id_parte = 5
     left join rug.rug_personas p
       on   p.id_persona = tip.id_persona
     left join rug.rug_rel_tram_inc_partes tio
       on   tio.id_tramite_temp = ti.id_tramite_temp
      and   tio.id_parte = 1
     left join ( select pf.id_persona
                      , pf.nombre_persona ||' '|| pf.ap_paterno ||' '|| pf.ap_materno as nombre
                   from rug.rug_personas_fisicas pf
                 union all
                 select pm.id_persona
                      , pm.razon_social
                   from rug.rug_personas_morales pm 
               ) pp
       on   pp.id_persona = tio.id_persona
    where   ti.id_status_tram <> 3
      and   ai.status_reg = 'AC'
;

-- view v_tramites_pendientes  



create or replace view rug.v_tramites_subusuarios as select rra.id_acreedor,
          rra.id_sub_usuario,
          rra.id_usuario,
             rpf.nombre_persona
          || ' '
          || rpf.ap_paterno
          || ' '
          || rpf.ap_materno
             as nombre_comp,
          rra.id_grupo,
          vtp.id_tramite_temp,
          vtp.id_tipo_tramite,
          vtp.tipo_tramite as desc_tipo_tramite,
          vtp.id_status,
          vtp.descrip_status,
          vtp.url,
          rra.status_reg as sit_relacion
     from rug.rug_rel_grupo_acreedor rra,
          rug.v_tramites_pendientes vtp,
          rug.rug_personas_fisicas rpf
    where     rra.id_sub_usuario = vtp.id_persona_login
          and rra.id_acreedor = vtp.id_acreedor
          and rra.id_sub_usuario = rpf.id_persona
          and vtp.id_status <> 0
          and rra.id_sub_usuario <> rra.id_usuario;

-- view v_tramites_subusuarios  



create or replace view rug.v_usuario_acreedor_rep as select   rua.id_usuario as usuario_login,
            rua.id_acreedor as id_persona,
            rpp.per_juridica,
            case
               when rpp.per_juridica in ('PM')
               then
                  (select   razon_social
                     from   rug.rug_personas_morales
                    where   id_persona = rua.id_acreedor)
            end
               as razon_social,
            case when
               rpp.per_juridica=
               'PF' then
               (select      f.nombre_persona
                         || ' '
                         || f.ap_paterno
                         || ' '
                         || f.ap_materno
                  from  rug.rug_personas_fisicas f
                 where   f.id_persona = rpp.id_persona)
                 when
               rpp.per_juridica=
               'PM' then
               (select   m.razon_social
                  from   rug.rug_personas_morales m
                 where   m.id_persona = rpp.id_persona)
            end 
               as nombre_acreedor,
            case
               when rpp.per_juridica in ('PF')
               then
                  (select   nombre_persona
                     from  rug.rug_personas_fisicas
                    where   id_persona = rua.id_acreedor)
            end
               as nombre,
            case
               when rpp.per_juridica in ('PF')
               then
                  (select   ap_paterno
                     from  rug.rug_personas_fisicas
                    where   id_persona = rua.id_acreedor)
            end
               as ap_paterno,
            case
               when rpp.per_juridica in ('PF')
               then
                  (select   ap_materno
                     from  rug.rug_personas_fisicas
                    where   id_persona = rua.id_acreedor)
            end
               as ap_materno,
            rpp.folio_mercantil,
            rpp.rfc,
            case when rpp.per_juridica =
                    'PF' then (select   curp
                             from  rug.rug_personas_fisicas
                            where   id_persona = rua.id_acreedor) else
                    null end
               as curp,
            rpp.id_domicilio,
            vd.calle,
            '' calle_colindante_1,
            '' calle_colindante_2,
            vd.localidad,
            vd.num_exterior,
            vd.num_interior,
            vd.id_colonia,
            vd.nom_colonia desc_colonia,
            vd.id_localidad,
            vd.localidad desc_localidad,
            vd.cve_estado,
            vd.cve_pais,
            vd.cve_deleg_municip cve_municip_deleg,
            vd.codigo_postal,
            rcn.id_nacionalidad,
            rcn.desc_nacionalidad,
            rt.clave_pais,
            rt.telefono,
            rt.extension,
            rpp.e_mail,
            vd.ubica_domicilio_1,
            vd.ubica_domicilio_2,
            vd.poblacion,
            vd.zona_postal
     from               rug.rel_usu_acreedor rua
                     inner join
                        rug.rug_personas rpp
                     on rpp.id_persona = rua.id_acreedor
                  left join
                     rug.rug_cat_nacionalidades rcn
                  on rcn.id_nacionalidad = rpp.id_nacionalidad
               left join
                  rug.rug_telefonos rt
               on rt.id_persona = rpp.id_persona
            left join
               rug.v_domicilios vd
            on rpp.id_domicilio = vd.id_domicilio
    where   rua.status_reg = 'AC' and rua.b_firmado = 'Y';

-- view v_usuario_acreedor_rep  



create or replace view rug.v_usuario_acreedor_rep2 as select   rua.id_usuario as usuario_login,
            rua.id_acreedor as id_persona,
            rpp.per_juridica,
            case when rpp.per_juridica =
                    'PF' then (select   nombre_persona
                             from  rug.rug_personas_fisicas
                            where   id_persona = rua.id_acreedor) else
                    null end
               as nombre_acreedor,
            case when rpp.per_juridica =
                    'PF' then (select   ap_paterno
                             from  rug.rug_personas_fisicas
                            where   id_persona = rua.id_acreedor) else
                    null end
               as ap_paterno_acreedor,
            case when rpp.per_juridica =
                    'PF' then (select   ap_materno
                             from  rug.rug_personas_fisicas
                            where   id_persona = rua.id_acreedor) else
                    null end
               as ap_materno_acreedor,
            case when rpp.per_juridica =
                    'PM' then (select   razon_social
                             from   rug.rug_personas_morales
                            where   id_persona = rua.id_acreedor) else
                    null end
               as razon_social_acreedor,
            rpp.folio_mercantil,
            rpp.rfc,
            case when rpp.per_juridica =
                    'PF' then (select   curp
                             from  rug.rug_personas_fisicas
                            where   id_persona = rua.id_acreedor) else
                    null end
               as curp,
            rpp.id_domicilio,
            rdm.calle,
            '' calle_colindante_1,
            '' calle_colindante_2,
            rdm.localidad,
            rdm.num_exterior,
            rdm.num_interior,
            rdm.id_colonia,
            rdm.nom_colonia desc_colonia,
            rdm.id_localidad,
            rdm.localidad desc_localidad,
            rdm.cve_estado,
            rdm.cve_pais,
            rdm.cve_deleg_municip cve_municip_deleg,
            rdm.codigo_postal
     from         rug.rel_usu_acreedor rua
               inner join
                  rug.rug_personas rpp
               on rpp.id_persona = rua.id_acreedor
            left join
               rug.v_domicilios rdm
            on rpp.id_domicilio = rdm.id_domicilio
    where   rua.status_reg = 'AC';

-- view v_usuario_acreedor_rep2  



create or replace view rug.v_usuario_acreedor_rep_todos as select   rrtip.id_tramite_temp,
            tri.id_tipo_tramite,
            rua.id_usuario as usuario_login,
            rua.id_acreedor as id_persona,
            rua.b_firmado,
            rpp.per_juridica,
            case
               when rpp.per_juridica in ('PM')
               then
                  (select   razon_social
                     from   rug.rug_personas_morales
                    where   id_persona = rua.id_acreedor)
            end
               as razon_social,
            case when
               rpp.per_juridica =
               'PF' then
               (select      f.nombre_persona
                         || ' '
                         || f.ap_paterno
                         || ' '
                         || f.ap_materno
                  from  rug.rug_personas_fisicas f
                 where   f.id_persona = rpp.id_persona)
                 when
               rpp.per_juridica =
               'PM' then
               (select   m.razon_social
                  from   rug.rug_personas_morales m
                 where   m.id_persona = rpp.id_persona)
            end
               as nombre_acreedor,
            case
               when rpp.per_juridica in ('PF')
               then
                  (select   nombre_persona
                     from  rug.rug_personas_fisicas
                    where   id_persona = rua.id_acreedor)
            end
               as nombre,
            case
               when rpp.per_juridica in ('PF')
               then
                  (select   ap_paterno
                     from  rug.rug_personas_fisicas
                    where   id_persona = rua.id_acreedor)
            end
               as ap_paterno,
            case
               when rpp.per_juridica in ('PF')
               then
                  (select   ap_materno
                     from  rug.rug_personas_fisicas
                    where   id_persona = rua.id_acreedor)
            end
               as ap_materno,
            rpp.folio_mercantil,
            rpp.rfc,
            case when rpp.per_juridica =
                    'PF' then
                    (select   curp
                       from  rug.rug_personas_fisicas
                      where   id_persona = rua.id_acreedor)
                      when rpp.per_juridica =
                    'PM' then
                    (select   curp_doc
                       from   rug.rug_personas
                      where   id_persona = rua.id_acreedor) end
               as curp,
            rpp.id_domicilio,
            rdm.calle,
            '' calle_colindante_1,
            '' calle_colindante_2,
            rdm.localidad,
            rdm.num_exterior,
            rdm.num_interior,
            rdm.id_colonia,
            rdm.nom_colonia desc_colonia,
            rdm.id_localidad,
            rdm.localidad desc_localidad,
            rdm.cve_estado,
            rdm.cve_pais,
            rdm.cve_deleg_municip cve_municip_deleg,
            rdm.codigo_postal,
            rcn.id_nacionalidad,
            rcn.desc_nacionalidad,
            rt.clave_pais,
            rt.telefono,
            rt.extension,
            rpp.e_mail,
            rdm.id_pais_residencia,
            rdm.ubica_domicilio_1,
            rdm.ubica_domicilio_2,
            rdm.poblacion,
            rdm.zona_postal
     from                     rug.rel_usu_acreedor rua
                           inner join
                              rug.rug_personas rpp
                           on rpp.id_persona = rua.id_acreedor
                        left join
                           rug.rug_cat_nacionalidades rcn
                        on rcn.id_nacionalidad = rpp.id_nacionalidad
                     left join
                        rug.rug_telefonos rt
                     on rt.id_persona = rpp.id_persona
                  left join
                     rug.v_domicilios rdm
                  on rpp.id_domicilio = rdm.id_domicilio
               inner join
                  rug.rug_rel_tram_inc_partes rrtip
               on rua.id_acreedor = rrtip.id_persona
            inner join
               rug.tramites_rug_incomp tri
            on rrtip.id_tramite_temp = tri.id_tramite_temp
    where       rua.status_reg = 'AC'
            and rrtip.id_parte = 4
            and tri.id_tipo_tramite = 12
            and tri.id_tramite_temp not in
                     (select   distinct a.id_tramite_temp
                        from   rug.rug_firma_masiva a, rug.tramites_rug_incomp b
                       where       b.id_tramite_temp = a.id_tramite_temp
                               and b.id_tipo_tramite = 12
                               and b.id_status_tram = 5)
   union all
   select   rrtip.id_tramite_temp,
            tri.id_tipo_tramite,
            rrma.id_usuario_modifica as usuario_login,
            rrma.id_acreedor_nuevo as id_persona,
            rrma.b_firmado,
            rpp.per_juridica,
            case
               when rpp.per_juridica in ('PM')
               then
                  (select   razon_social
                     from   rug.rug_personas_morales
                    where   id_persona = rrma.id_acreedor)
            end
               as razon_social,
            case when 
               rpp.per_juridica =
               'PF' then
               (select      f.nombre_persona
                         || ' '
                         || f.ap_paterno
                         || ' '
                         || f.ap_materno
                  from  rug.rug_personas_fisicas f
                 where   f.id_persona = rpp.id_persona)
                 when 
               rpp.per_juridica =
               'PM' then
               (select   m.razon_social
                  from   rug.rug_personas_morales m
                 where   m.id_persona = rpp.id_persona)
            end
               as nombre_acreedor,
            case
               when rpp.per_juridica in ('PF')
               then
                  (select   nombre_persona
                     from  rug.rug_personas_fisicas
                    where   id_persona = rrma.id_acreedor)
            end
               as nombre,
            case
               when rpp.per_juridica in ('PF')
               then
                  (select   ap_paterno
                     from  rug.rug_personas_fisicas
                    where   id_persona = rrma.id_acreedor)
            end
               as ap_paterno,
            case
               when rpp.per_juridica in ('PF')
               then
                  (select   ap_materno
                     from  rug.rug_personas_fisicas
                    where   id_persona = rrma.id_acreedor)
            end
               as ap_materno,
            rpp.folio_mercantil,
            rpp.rfc,
            case when rpp.per_juridica=
                    'PF' then
                    (select   curp
                       from  rug.rug_personas_fisicas
                      where   id_persona = rrma.id_acreedor)
                      when rpp.per_juridica=
                    'PM' then
                    (select   curp_doc
                       from   rug.rug_personas
                      where   id_persona = rrma.id_acreedor) end
               as curp,
            rpp.id_domicilio,
            rdm.calle,
            '' calle_colindante_1,
            '' calle_colindante_2,
            rdm.localidad,
            rdm.num_exterior,
            rdm.num_interior,
            rdm.id_colonia,
            rdm.nom_colonia desc_colonia,
            rdm.id_localidad,
            rdm.localidad desc_localidad,
            rdm.cve_estado,
            rdm.cve_pais,
            rdm.cve_deleg_municip cve_municip_deleg,
            rdm.codigo_postal,
            rcn.id_nacionalidad,
            rcn.desc_nacionalidad,
            rt.clave_pais,
            rt.telefono,
            rt.extension,
            rpp.e_mail,
            rdm.id_pais_residencia,
            rdm.ubica_domicilio_1,
            rdm.ubica_domicilio_2,
            rdm.poblacion,
            rdm.zona_postal
     from                     rug.rug_rel_modifica_acreedor rrma
                           inner join
                              rug.rug_personas rpp
                           on rpp.id_persona = rrma.id_acreedor_nuevo
                        left join
                           rug.rug_cat_nacionalidades rcn
                        on rcn.id_nacionalidad = rpp.id_nacionalidad
                     left join
                        rug.rug_telefonos rt
                     on rt.id_persona = rpp.id_persona
                  left join
                     rug.v_domicilios rdm
                  on rpp.id_domicilio = rdm.id_domicilio
               inner join
                  rug.rug_rel_tram_inc_partes rrtip
               on rrma.id_acreedor_nuevo = rrtip.id_persona
            inner join
               rug.tramites_rug_incomp tri
            on rrtip.id_tramite_temp = tri.id_tramite_temp
    where       rrma.status_reg = 'AC'
            and rrtip.id_parte = 4
            and tri.id_tipo_tramite = 19
            and tri.id_tramite_temp not in
                     (select   distinct a.id_tramite_temp
                        from   rug.rug_firma_masiva a, rug.tramites_rug_incomp b
                       where       b.id_tramite_temp = a.id_tramite_temp
                               and b.id_tipo_tramite = 12
                               and b.id_status_tram = 5)
;

-- view v_usuario_acreedor_rep_todos  
