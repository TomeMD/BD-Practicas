/*1. Mostra todos os pacientes rexistrados na BD. Indica, para cada un: DNI; nome completo;
  data na que foi rexistrado/a por primeira vez no sistema; método de rexistro
  (chamada/ingreso centro hospitalario)*/
 
  select p.DNI, NomePila, AP1, AP2, to_char(DataHoraInicio,'DD/MM/YYYY HH24:MI:SS'), MetodoRexistro
  from paciente p join ingreso i on p.DNI = i.DNI
  where DataHoraInicio <= ALL (select DataHoraInicio from ingreso where DNI = p.DNI);


/*2. Mostra o identificador e nome completo de todos os pacientes que permanecían confinados
  na súa casa o dia 1 de maio de 2020 ás 00:00:00h.*/

  select p.DNI, NomePila, AP1, AP2
  from paciente p join ingreso i on p.DNI = i.DNI join centro c on i.CodCentro = c.CodCentro
  where (DataHoraFin is NULL) AND (Tipo = 'DOMICILIO');

/*3. Mostra o identificador e nome completo de todos os pacientes estaban ingresados nun
  centro hospitalario o día 1 de maio de 2020 ás 00:00:00h.*/

  select p.DNI, NomePila, AP1, AP2
  from paciente p join ingreso i on p.DNI = i.DNI join centro c on i.CodCentro = c.CodCentro
  where (DataHoraFin is NULL) AND  NOT (Tipo = 'DOMICILIO');

/*4. Mostra o identificador e nome completo de todos os pacientes que estiveron ingresados en
  polo menos dous hospitais diferentes. Indica tamén cantos hospitais foron.*/

  select p.DNI, NomePila, AP1, AP2, count(distinct i.CodCentro) as hospitais
  from paciente p join ingreso i on p.DNI = i.DNI join centro c on i.CodCentro = c.CodCentro
  where NOT (Tipo = 'DOMICILIO')
  group by p.DNI, NomePila, AP1, AP2
  having count(distinct i.CodCentro) >= 2;

/*5. Mostra o identificador e nome completo de todos os pacientes que estiveron confinados no
  seu domicilio en dous ou mais períodos diferentes. Indica tamén cantas veces foron en total.*/

  select p.DNI, NomePila, AP1, AP2, count(*)
  from paciente p join ingreso i on p.DNI = i.DNI join centro c on i.CodCentro = c.CodCentro
  where (Tipo = 'DOMICILIO')
  group by p.DNI, NomePila, AP1, AP2
  having count(*) >= 2;

/*6. Lista o identificador e nome completo de todos aqueles pacientes que xa foron dados de
  alta. Mostra tamén a data de alta.*/

  select p.DNI, NomePila, AP1, AP2, to_char(DataHoraFin,'DD/MM/YYYY HH24:MI:SS')
  from paciente p join ingreso i on p.DNI = i.DNI
  where (DataHoraInicio >= ALL (select DataHoraInicio from ingreso where DNI = p.DNI)) AND (DataHoraFin is NOT NULL);

/*7. Elixe un dos pacientes do resultado da consulta 2. Mostra a data e hora das próximas
  chamadas telefónicas programadas de control que lle hai que facer.
  DNI paciente escollido: 33911269F*/

  select to_char(DataHora,'DD/MM/YYYY HH24:MI:SS') as futuras_chamadas
  from revision
  where (DataHora > to_date('01/05/2020 00:00:00','DD/MM/YYYY HH24:MI:SS')) AND (DNI = '33911269F') AND (Metodo = 'CHAMADA'); 

/*8. Mostra, para o mesmo paciente, o número de chamadas realizadas ata agora nas que
  superou os 37º de temperatura e rexistrou unha tensión sistólica superior a 12.*/

  select count(DataHora)
  from paciente p left join revision rv on p.DNI = rv.DNI 
  		AND (p.DNI, DataHora) = ANY (select r.DNI, r.DataHora from revision r join recolle re on (r.DNI = re.DNI) AND (r.DataHora = re.DataHora)
  							where (CodExploracion = 'E01') AND (resultado is NOT NULL) AND (resultado > 37) AND (Metodo = 'CHAMADA'))
  		AND (p.DNI, DataHora) = ANY (select r.DNI, r.DataHora from revision r join recolle re on (r.DNI = re.DNI) AND (r.DataHora = re.DataHora)
  							where (CodExploracion = 'E02') AND (resultado is NOT NULL) AND (resultado > 12) AND (Metodo = 'CHAMADA'))
  where (p.DNI = '33911269F')
  group by p.DNI;

/*9. Elixe un dos pacientes do resultado da consulta 3. Mostra a data e hora das próximas
  revisións periódicas programadas que lle hai que facer.
  DNI paciente escollido: 36620730Q*/

  /*Entendendo revisións como as revisións realizadas nun centro*/
  select to_char(DataHora,'DD/MM/YYYY HH24:MI:SS') as futuras_revisions
  from revision
  where (DataHora > to_date('01/05/2020 00:00:00','DD/MM/YYYY HH24:MI:SS')) AND (DNI = '36620730Q') AND (Metodo = 'REVISIÓN EN CENTRO');

  /*Entendendo revisións como calquer tipo de revisión (inclúe chamadas)*/
  select to_char(DataHora,'DD/MM/YYYY HH24:MI:SS') as futuras_revisions
  from revision
  where (DataHora > to_date('01/05/2020 00:00:00','DD/MM/YYYY HH24:MI:SS')) AND (DNI = '36620730Q');

/*10. Mostra, para o mesmo paciente, o número de revisións realizadas ata agora nas que
  superou os 37º de temperatura e rexistrou unha tensión sistólica superior a 12. */

  /*Entendendo revisións como as revisións realizadas nun centro*/
  select count(DataHora)
  from paciente p left join revision rv on (p.DNI = rv.DNI)
  		AND (p.DNI, DataHora) = ANY (select r.DNI, r.DataHora from revision r join recolle re on (r.DNI = re.DNI) AND (r.DataHora = re.DataHora)
  							where (CodExploracion = 'E01') AND (resultado is NOT NULL) AND (resultado > 37) AND (Metodo = 'REVISIÓN EN CENTRO'))
  		AND (p.DNI, DataHora) = ANY (select r.DNI, r.DataHora from revision r join recolle re on (r.DNI = re.DNI) AND (r.DataHora = re.DataHora)
  							where (CodExploracion = 'E02') AND (resultado is NOT NULL) AND (resultado > 12) AND (Metodo = 'REVISIÓN EN CENTRO'))
  where (p.DNI = '36620730Q')
  group by p.DNI;

  /*Entendendo revisións como calquer tipo de revisión (inclúe chamadas)*/
  select count(DataHora)
  from paciente p left join revision rv on (p.DNI = rv.DNI)
      AND (p.DNI, DataHora) = ANY (select r.DNI, r.DataHora from revision r join recolle re on (r.DNI = re.DNI) AND (r.DataHora = re.DataHora)
                where (CodExploracion = 'E01') AND (resultado is NOT NULL) AND (resultado > 37))
      AND (p.DNI, DataHora) = ANY (select r.DNI, r.DataHora from revision r join recolle re on (r.DNI = re.DNI) AND (r.DataHora = re.DataHora)
                where (CodExploracion = 'E02') AND (resultado is NOT NULL) AND (resultado > 12))
  where (p.DNI = '36620730Q')
  group by p.DNI;

/*11. Mostra, para o mesmo paciente: tipo de exploracións realizadas na última revisión; nome do
  sanitario/a que realizou cada exploración; resultado de cada exploración. Podes utilizar
  directamente na consulta a data da revisión.*/

  select Tipo, NomePila, Resultado, Descricion
  from recolle re join exploracion e on re.CodExploracion = e.CodExploracion
  				  join sanitario s on re.NSS = s.NSS
  where (DNI = '36620730Q') AND (DataHora = to_date('28/04/2020 17:00:00','DD/MM/YYYY HH24:MI:SS'));

/*12. Mostra, para cada equipo de sanitarios rexistrado na BD: identificador do equipo; nome do
  centro hospitalario no que traballa; número ACTUAL de integrantes; e data do último
  cambio na composición do equipo.*/

  select e.CodEquipo, Nome as centro_asignado, count(h.NSS) as integrantes, 
    	to_char((select max(Data) from ((select CodEquipo, DataHoraEntrada as Data from entra_en) UNION 
              (select CodEquipo, DataHoraSaida as Data from entra_en)) where CodEquipo = e.CodEquipo), 'DD/MM/YYYY HH24:MI:SS') as ultimo_cambio
  from centro c right join equipo e on c.CodCentro = CentroAsignado left join entra_en h on e.CodEquipo = h.CodEquipo
  where (DataHoraSaida is NULL)
  group by e.CodEquipo, Nome
  order by e.CodEquipo;

/*13. Elixe un dos equipos do resultado da consulta 12. Mostra a lista (identificador; nome
  completo; posto; centro hospitalario) dos seus membros nunha data concreta (por exemplo,
  o día 01 de maio de 2020 ás 00:00:00 horas).
  Codigo do equipo escollido: 0004*/

  select s.NSS, NomePila, AP1, AP2, Posto, CodCentro
  from entra_en h join sanitario s on h.NSS = s.NSS
  where (CodEquipo = 0004) AND (DataHoraEntrada <= to_date('01/05/2020 00:00:00','DD/MM/YYYY HH24:MI:SS')) AND 
  		((DataHoraSaida is NULL) OR (DataHoraSaida > to_date('01/05/2020 00:00:00','DD/MM/YYYY HH24:MI:SS')));

/*14. Indica, para cada centro hospitalario rexistrado na BD, que equipo (ou equipos) estará de
  garda o 01 de maio de 2020 ás 22:00:00. Mostra o identificador do equipo, o nome do
  centro hospitalario, e a data de inicio e fin da quenda que está cubrindo o equipo no centro
  hospitalario. */

  select CodEquipo, Nome as Nome_Centro, to_char(DataHoraInicio,'DD/MM/YYYY HH24:MI:SS') as Inicio, to_char(DataHoraFin,'DD/MM/YYYY HH24:MI:SS') as Fin
  from quenda q join centro c on q.CodCentro = c.CodCentro
  where (DataHoraInicio <= to_date('01/05/2020 22:00:00','DD/MM/YYYY HH24:MI:SS')) AND 
  		(DataHoraFin > to_date('01/05/2020 22:00:00','DD/MM/YYYY HH24:MI:SS'));

/*15. Elixe a un dos pacientes do resultado da consulta 3. Mostra o tratamento que tiña
  establecido o día 01 de maio de 2020, ás 00:00:00h: nome do medicamento, dose
  establecida, e identificador e nome completo do sanitario que autorizou ese medicamento.
  DNI paciente escollido: 44320110T*/

  select m.Nome as medicamento, sm.Dose, s.NomePila, s.AP1, s.AP2
  from tratamento t join suministra sm on (t.DNI = sm.DNI) AND (t.DataHoraInicio = sm.DataHoraInicio)
  					join medicamento m on sm.CodMedicamento = m.CodMedicamento
  					join sanitario s on t.NSS = s.NSS
  where (t.DNI = '44320110T') AND (t.DataHoraFin is NULL);

/*16. Para cada tipo de material rexistrado na BD, indica o stock dispoñible en cada centro
  hospitalario. Mostra: nome do material; nome do centro hospitalario; unidades dispoñibles
  no centro; limiar mínimo de stock no centro; e diferencia entre eles.*/

  select m.Nome as nome_material, c.Nome as nome_centro, Stock, StockMinimo, (Stock - StockMinimo) as StockAlarma 
  from centro c join usa u on c.CodCentro = u.CodCentro
  				join tipo_material m on u.CodMaterial = m.CodMaterial
  order by m.Nome, c.Nome;

/*17. Elixe a un dos equipos da consulta 14. Queremos saber as unidades concretas de material
  foron usadas durante a quenda cuberta na dita consulta 14 polo equipo en cuestión. Mostra
  a referencia do material, e o tipo/nome de material.
  Codigo do equipo escollido: 0001*/

  select Nome as nome_material, referencia
  from quenda q join unidade u on (q.CodEquipo = u.CodEquipo) AND (q.DataHoraInicio = u.DataHoraInicio)
  				join tipo_material m on u.CodMaterial = m.CodMaterial
  where (q.CodEquipo = 0001) AND (q.DataHoraInicio = to_date('01/05/2020 16:00:00','DD/MM/YYYY HH24:MI:SS'));

/*18. Para cada equipo rexistrado na BD, indica cantas quendas ten programadas para o día
  2 de maio ás 00:00:00 (inclúe tamén aos equipos que non teñan quendas programadas). Mostra 
  o identificador do equipo, nome do centro hospitalario no que traballa e número de quendas programadas.*/

  select e.CodEquipo, Nome as nome_centro, count(DataHoraInicio)
  from equipo e left join quenda q on (e.CodEquipo = q.CodEquipo) AND (DataHoraInicio >= to_date('02/05/2020 00:00:00','DD/MM/YYYY HH24:MI:SS'))
    				                                                      AND (DataHoraFin <= to_date('02/05/2020 23:59:59','DD/MM/YYYY HH24:MI:SS'))
                     join centro c on CentroAsignado = c.CodCentro
  group by e.CodEquipo, Nome
  order by e.CodEquipo;

/*19. Para cada material, mostra os centros que teñen un stock superior á media, é dicir, ao stock medio dese
  material en concreto por centro. Mostra o código do material, o código do centro, o seu stock e o stock medio.*/

  select CodMaterial, CodCentro, Stock, (select avg(Stock) from usa where CodMaterial = u.CodMaterial) as stock_medio
  from usa u
  where  stock > (select avg(Stock) from usa where CodMaterial = u.CodMaterial)
  order by CodMaterial;

/*20. Para cada centro, indica o sanitario ou sanitarios que pertenceron a máis equipos distintos dende que foron
  rexistrados na BD. Mostra o código do centro, nome completo do sanitario e en cantos equipos distintos estivo 
  dito sanitario.*/

  select CodCentro, NomePila, AP1, AP2, count(distinct CodEquipo)
  from entra_en e join sanitario s on e.NSS = s.NSS
  where CodCentro is NOT NULL
  group by CodCentro, s.NSS, NomePila, AP1, AP2
  having count(distinct CodEquipo) >= ALL (select count(distinct CodEquipo) 
													  from entra_en e join sanitario sn on e.NSS = sn.NSS
													  where (sn.CodCentro = s.CodCentro)
													  group by sn.NSS);