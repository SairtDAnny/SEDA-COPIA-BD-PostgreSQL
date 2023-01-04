insert into area values('107','OFICINA TECNOLOGÍAS DE LA INFORMACÓN Y COMUNICACIÓN');
insert into area values('100','MANTENIMEINTO');
insert into area values('101','CATASTRO');
insert into area values('102','ALMACEN');
insert into area values('108','OTIC');

SELECT * FROM area
delete from area


insert into usuario values('76637832','107','Sairt Pariguana','Practicante');
insert into usuario values('76637833','107','Tony Saire','Administrador');
SELECT * FROM usuario

insert into colaborador values('12345678','100','Carlos Gutierres','operario');
insert into colaborador values('12345679','101','Juan Montoya','operario');
insert into colaborador values('12345680','102','Alonso Salas','operario');
insert into colaborador values('12345681','100','Michael Fernandes','operario');
insert into colaborador values('12345682','102','Gonzalo Suares','operario');
insert into colaborador values('12345111','102','Gonzalo Suares','operario');

SELECT * FROM colaborador

insert into patrimonio values('201850','PANTALON DE JEAN PARA TRABAJO CON LOGO',50,'S','Unidad','NO');
insert into patrimonio values('201851','PANTALON DE JEAN PARA TRABAJO CON LOGO',42,'M','Unidad','NO');
insert into patrimonio values('201852','PANTALON DE JEAN PARA TRABAJO CON LOGO',10,'L','Unidad','NO');

insert into patrimonio values('201853','CASACA DOBLE IMPERMEABLE  DE SEGURIDAD INDUSTRIAL',50,'S','Unidad','NO');
insert into patrimonio values('201854','CASACA DOBLE IMPERMEABLE  DE SEGURIDAD INDUSTRIAL',42,'M','Unidad','NO');
insert into patrimonio values('201855','CASACA DOBLE IMPERMEABLE  DE SEGURIDAD INDUSTRIAL',10,'L','Unidad','NO');


SELECT * FROM patrimonio order by idpatrimonio

--registrar entrada a alamcen 

insert into registro_entrada_almacen values('I0001','76637832','201852','20','16-10-2022','Buen Estado');
insert into registro_entrada_almacen values('I0002','76637832','201851','5','16-10-2022','Buen Estado');
insert into registro_entrada_almacen values('I0003','76637832','201850','30','16-10-2022','Buen Estado');
insert into registro_entrada_almacen values('I0004','76637832','201851','4','16-10-2022','Buen Estado');

select *from  registro_entrada_almacen order by identradaoficina




---------------------------------------------------------------------PROCEDMIENTOS ALAMACENADOS VISTAS Y FUNCIONAES-------------------------------

----------------------procedimiento alamcenado REGISTRO DE ENTRADA DE EPP..................................................................

drop PROCEDURE	registrar_entrada;--NOSE UTILIZA
CREATE PROCEDURE registrar_entrada( _codigo char, _usuario char, _patrimonio varchar, _talla varchar, _cantidad integer,_estado varchar)
LANGUAGE SQL
AS $BODY$
	--registrar ingreso de epp/patrimonios en alamcén
    INSERT INTO registro_entrada_almacen(identradaoficina,idusuario,idpatrimonio, cantidad, fechaentrada, estadoentrada)
    VALUES(_codigo,
		   (select idusuario from usuario where _usuario =nombreusuario),
		  (select idpatrimonio from patrimonio where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))), 
		   _cantidad,
		   (select CURRENT_DATE), 
		   _estado);
	--actualizar stock
	update patrimonio set stock = ((select stock from patrimonio 
									where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))) + _cantidad) 
									where (_patrimonio=descripcionpatrimonio) and (_talla=talla);
	--select identradaoficina from registro_entrada_almacen where  identradaoficina = (SELECT MAX(identradaoficina) FROM registro_entrada_almacen)									
	
$BODY$;



call registrar_entrada('0001234598','Sairt Pariguana','PANTALON DE JEAN PARA TRABAJO CON LOGO','S','2','Buen Estado');

call registrar_entrada('I0002','Sairt Pariguana','PANTALON DE JEAN PARA TRABAJO CON LOGO','M','5','25-10-2022','Buen Estado');
call registrar_entrada('I0003','Sairt Pariguana','PANTALON DE JEAN PARA TRABAJO CON LOGO','L','5','26-10-2022','Buen Estado');

SELECT * FROM  registro_entrada_almacen

select * from patrimonio



--FUNCION DE INSERTAR REGISTRO DE ENTRADA
drop FUNCTION registrar_entrada;
CREATE or replace FUNCTION registrar_entrada(_codigo char, _usuario varchar, _patrimonio varchar, _talla varchar, _cantidad integer,_estado varchar)
returns CHAR
LANGUAGE plpgsql
COST 10
VOLATILE
as $Body$
DECLARE gen VARCHAR;
BEGIN
    --registrar ingreso de epp/patrimonios en alamcén
    INSERT INTO registro_entrada_almacen(identradaoficina,idusuario,idpatrimonio, cantidad, fechaentrada, estadoentrada)
    VALUES(_codigo,
		   (select idusuario from usuario where _usuario =nombreusuario),
		  (select idpatrimonio from patrimonio where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))), 
		   _cantidad,
		   (select CURRENT_DATE), 
		   _estado);
	--actualizar stock
	update patrimonio set stock = ((select stock from patrimonio 
									where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))) + _cantidad) 
									where (_patrimonio=descripcionpatrimonio) and (_talla=talla);
		
		select identradaoficina into gen from registro_entrada_almacen where  _codigo = identradaoficina;
		return gen;
END;
$Body$;

select * from  registrar_entrada('1001211120','Sairt Pariguana','PANTALON DE JEAN PARA TRABAJO CON LOGO','S','2','Buen Estado');



---------------------------------------------------------------------------------------------------- listar por funcion ENTRADA ALMACEN --NO SE UTILIZA

drop FUNCTION listar_Entrada;
CREATE or replace FUNCTION listar_Entrada()
returns Table
(
	identradaoficina char,
	idusuario varchar,
	idpatrimonio varchar,
	talla varchar,
	cantidad int,
	estadoentrada varchar,
	fechaentrada date
)
AS $func$
BEGIN
	return query

	select rsa.identradaoficina,rsu.nombreusuario, rsp.descripcionpatrimonio, rsp.talla, rsa.cantidad, rsa.estadoentrada, rsa.fechaentrada
	from registro_entrada_almacen rsa
	INNER join patrimonio rsp ON rsp.idpatrimonio = rsa.idpatrimonio
	INNER JOIN usuario rsu ON rsu.idusuario = rsa.idusuario
	order by rsa.fechaentrada desc;
END
$func$ LANGUAGE plpgsql;

select * from listar_Entrada()
--lISTAR EPPS QUE IONGRESAN A ALMACEN 

--FUNCION DE ACTUALIZAR	 REGISTRO DE ENTRADA
drop FUNCTION actualizar_entrada;
CREATE or replace FUNCTION actualizar_entrada(_codigo char, _usuario varchar, _patrimonio varchar, _talla varchar, _cantidad integer,_estado varchar)
returns CHAR
LANGUAGE plpgsql
COST 10
VOLATILE
as $Body$
DECLARE gen VARCHAR;
BEGIN
    --registrar ingreso de epp/patrimonios en alamcén
	UPDATE registro_entrada_almacen set idusuario=(select idusuario from usuario where _usuario =nombreusuario),
										idpatrimonio=(select idpatrimonio from patrimonio where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))),
										cantidad=_cantidad,
										fechaentrada=(select CURRENT_DATE),
										estadoentrada=_estado where identradaoficina=_codigo;
	--actualizar stock
	if _cantidad!=(select cantidad from registro_entrada_almacen where identradaoficina=_codigo)
		then
		update patrimonio set stock = ((select stock from patrimonio 
									where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))) + _cantidad) 
									where (_patrimonio=descripcionpatrimonio) and (_talla=talla);	
	else
	
	end if;
	select identradaoficina into gen from registro_entrada_almacen where  identradaoficina=_codigo;
	return gen;
END;
$Body$;

select * from actualizar_entrada('0122541021','Sairt Pariguana','PANTALON DE JEAN PARA TRABAJO CON LOGO','M','2','Mal estado');--201850
select * from registro_entrada_almacen

--vista para listar entarda
drop VIEW Listar_Entrada_Alm
CREATE VIEW Listar_Entrada_Alm
AS
	select rsa.identradaoficina,rsp.descripcionpatrimonio, rsp.talla, rsa.cantidad, rsa.estadoentrada, rsa.fechaentrada, rsu.nombreusuario
	from registro_entrada_almacen rsa
	INNER join patrimonio rsp ON rsp.idpatrimonio = rsa.idpatrimonio
	INNER JOIN usuario rsu ON rsu.idusuario = rsa.idusuario
	order by rsa.fechaentrada desc;


select * from listar_entrada_alm

                                                                                                                                                                                                                                                                                                       
-- procedimiento alamcenado REGISTRO DE SALIDA DE EPP.........................................................................................REGISTRO DE SALIDA DFE ALMACEN 

drop procedure	registrar_salida;
CREATE PROCEDURE registrar_salida(_usuario char, _colaborador char,_patrimonio char,_talla char, _cantidad integer, _fecha date, _estado varchar)
AS $$
begin
	IF _cantidad <= (select stock from patrimonio where ((_patrimonio=descripcion_patrimonio) and (_talla=talla)))
		   then
		--registrar salida de epp/patrimonios en alamcén
			INSERT INTO registro_salida_almacen(idusuario, idcolaborador, idpatrimonio, cantidad, fechasalida, estadosalida)
			VALUES((select idusuario from usuario where _usuario =nombreusuario),
				   (select idcolaborador from colaborador where _colaborador=nombrecolaborador),
				   (select idpatrimonio from patrimonio where (_patrimonio=descripcionpatrimonio) and (_talla=talla)),
				   _cantidad,
				   _fecha,
				   _estado);
					--actualizar stock
					update patrimonio set stock = ((select stock from patrimonio where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))) - _cantidad) where (_patrimonio=descripcionpatrimonio) and (_talla=talla);
   	else
		raise info 'no hay suficiente stock del producto %', now();
	END IF;
END;
$$ LANGUAGE plpgsql;

call registrar_salida('S0001','Sairt Pariguana','Carlos Gutierres','PANTALON DE JEAN PARA TRABAJO CON LOGO','S','10','17-10-2022','Buen Estado');
call registrar_salida('S0002','Sairt Pariguana','Carlos Gutierres','CASACA DOBLE IMPERMEABLE  DE SEGURIDAD INDUSTRIAL','S','10','18-10-2022','Buen Estado');

SELECT * FROM registro_salida_almacen



--FUNCION DE INSERTAR REGISTRO DE SALIDA
drop FUNCTION registrar_salida;
CREATE or replace FUNCTION registrar_salida(_codigo char, _usuario char, _colaborador char,_patrimonio char,_talla char, _cantidad integer, _estado varchar)
returns CHAR
LANGUAGE plpgsql
COST 10
VOLATILE
as $Body$
DECLARE gen VARCHAR;
BEGIN
    --registrar ingreso de epp/patrimonios en alamcén
    IF _cantidad <= (select stock from patrimonio where ((_patrimonio=descripcionpatrimonio) and (_talla=talla)))
		   then
		--registrar salida de epp/patrimonios en alamcén
			INSERT INTO registro_salida_almacen(idsalidaoficina, idusuario, idcolaborador, idpatrimonio, cantidad, fechasalida, estadosalida)
			VALUES	(_codigo,
					(select idusuario from usuario where _usuario =nombreusuario),
				   	(select idcolaborador from colaborador where _colaborador=nombrecolaborador),
				   	(select idpatrimonio from patrimonio where (_patrimonio=descripcionpatrimonio) and (_talla=talla)),
				   	_cantidad,
				   	(select CURRENT_DATE),
				  	_estado);
					--actualizar stock
					update patrimonio set stock = ((select stock from patrimonio where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))) - _cantidad) where (_patrimonio=descripcionpatrimonio) and (_talla=talla);
   	else
		raise info 'no hay suficiente stock del producto %', now();
	END IF;
	
	select idsalidaoficina into gen from registro_salida_almacen where  _codigo = idsalidaoficina;
	return gen;
END;
$Body$;

select * from  registrar_salida('0001230100','Sairt Pariguana','Alonso Salas','PANTALON DE JEAN PARA TRABAJO CON LOGO','M','10','Buen Estado');
select * from  registrar_salida('0001230101','Sairt Pariguana','Alonso Salas','PANTALON DE JEAN PARA TRABAJO CON LOGO','M','10','Buen Estado');
SELECT * FROM Registro_Salida_Almacen
select * from colaborador


--FUNCION DE ACTUALIZAR	 REGISTRO DE SALISDA
drop FUNCTION actualizar_salida;
CREATE or replace FUNCTION actualizar_salida(_codigo char, _usuario char, _colaborador char,_patrimonio char,_talla char, _cantidad integer, _estado varchar)
returns CHAR
LANGUAGE plpgsql
COST 10
VOLATILE
as $Body$
DECLARE gen VARCHAR;
BEGIN
    --registrar ingreso de epp/patrimonios en alamcén
	UPDATE registro_salida_almacen set 	idusuario=(select idusuario from usuario where _usuario =nombreusuario),
										idcolaborador=(select idcolaborador from colaborador where _colaborador=nombrecolaborador),
										idpatrimonio=(select idpatrimonio from patrimonio where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))),
										cantidad=_cantidad,
										fechasalida=(select CURRENT_DATE),
										estadosalida=_estado where idsalidaoficina=_codigo;
	--actualizar stock
	if _cantidad!=(select cantidad from registro_entrada_almacen where identradaoficina=_codigo)
		then
		update patrimonio set stock = ((select stock from patrimonio 
									where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))) - _cantidad) 
									where (_patrimonio=descripcionpatrimonio) and (_talla=talla);	
	else
	
	end if;
	select idsalidaoficina into gen from registro_salida_almacen where  idsalidaoficina=_codigo;
	return gen;
END;
$Body$;


select * from  actualizar_salida('0001230100','Sairt Pariguana','Alonso Salas','PANTALON DE JEAN PARA TRABAJO CON LOGO','M','10','NUEVO');
SELECT * FROM Registro_Salida_Almacen







-- listar por funcion SALIDA ALMACEN

drop FUNCTION listar_Salida;
CREATE or replace FUNCTION listar_Salida()
returns Table
(
	idsalidaoficina char,
	idcolaborador varchar,
	idpatrimonio varchar,
	talla varchar,
	cantidad int,
	estadosalida varchar,
	fechasalida date,
	fechaprirenovacion date,
	fechasegrenovacion date,
	idusuario varchar
	
)
AS $func$
BEGIN
	return query	
	select rsa.idsalidaoficina,nombrecolaborador, descripcionpatrimonio, rsp.talla,rsa.cantidad, rsa.estadosalida, 
	rsa.fechasalida, rsa.fechaprirenovacion, rsa.fechasegrenovacion, nombreusuario
	from registro_salida_almacen rsa
	inner join colaborador rsc ON rsc.idcolaborador = rsa.idcolaborador
	INNER join patrimonio rsp ON rsp.idpatrimonio = rsa.idpatrimonio
	INNER JOIN usuario rsu ON rsu.idusuario = rsa.idusuario
	order by rsa.fechasalida desc;
END
$func$ LANGUAGE plpgsql;                                                                                                                                                                                                                                                                 
select * from listar_Salida();




-- crar un vista para listar la salida de almacen

create view listar-Salida-Almacen

drop VIEW listar_Salida_Almacen
CREATE VIEW listar_Salida_Almacen
AS
	select nombrecolaborador, descripcionpatrimonio, talla,cantidad, estadosalida, 
	fechasalida, fechaprirenovacion, fechasegrenovacion, nombreusuario
	from registro_salida_almacen rsa
	inner join colaborador rsc ON rsc.idcolaborador = rsa.idcolaborador
	INNER join patrimonio rsp ON rsp.idpatrimonio = rsa.idpatrimonio
	INNER JOIN usuario rsu ON rsu.idusuario = rsa.idusuario
	order by rsa.fechasalida desc;

select * from listar_Salida_Almacen









--FUNCION DE LISTAR ENTREGAS DE EPPS A COLABORADORES

drop FUNCTION listar_Registro;
CREATE or replace FUNCTION listar_Registro(_colaborador varchar	)
returns Table
(
	Descripción varchar,
	Tallas varchar,
	Cantidad_Entregada int,
	Estado varchar,
	Entrega date,
	Renovación_1 date,
	Renovación_2 date,
	Responsable varchar
)
AS $func$
BEGIN
	return query	
	Select descripcionpatrimonio, talla,cantidad, estadosalida, 
	fechasalida, fechaprirenovacion, fechasegrenovacion, nombreusuario 
	FROM colaborador,registro_salida_almacen
	com
	inner join colaborador rsc ON rsc.idcolaborador = com.idcolaborador
	INNER join patrimonio rsp ON rsp.idpatrimonio = com.idpatrimonio
	INNER JOIN usuario rsu ON rsu.idusuario = com.idusuario
	where _colaborador=colaborador.nombrecolaborador or _colaborador=colaborador.idcolaborador;
END
$func$ LANGUAGE plpgsql;

select * from listar_Registro('12345679');
select * from colaborador
select *FROM PATRIMONIO















--ACTUALIZAR TABLA CON RENOVACIONES 1 Y 2     _desPatrimonio varchar, _talla char, _cantidad int, _estado varchar, _codigo char 

drop FUNCTION	actualizar_Renovacion;
CREATE or replace FUNCTION actualizar_Renovacion(_codigo char, _usuario char, _colaborador char,_patrimonio char,_talla char, _cantidad integer, _estado varchar)
returns CHAR
LANGUAGE plpgsql
COST 10
VOLATILE
as $Body$
DECLARE gen VARCHAR;
BEGIN
	--condicion si la cantidad excede el sotck
	IF _cantidad <= (select stock from patrimonio where ((_patrimonio=descripcionpatrimonio) and (_talla=talla)))
		   then
		--condicion de insercion en la primera renovacion o la segunda
			if (select fechaprirenovacion from registro_salida_almacen 
			WHERE (select idpatrimonio from patrimonio 
			where (_patrimonio=descripcionpatrimonio) and (_talla=talla))=registro_salida_almacen.idpatrimonio
			and _codigo=idsalidaoficina) is null
				then
				--actualizar fecha
					update registro_salida_almacen set fechaprirenovacion=(select CURRENT_DATE) where (select idpatrimonio from patrimonio 
					where (_patrimonio=descripcionpatrimonio) and (_talla=talla))=registro_salida_almacen.idpatrimonio
					and _codigo=idsalidaoficina;
				--actualizar cantidad
					update registro_salida_almacen set cantidad=(select cantidad from registro_salida_almacen 
															  where _codigo=idsalidaoficina 
																and (select idpatrimonio from patrimonio 
																where (_patrimonio=descripcionpatrimonio) 
																and (_talla=talla))=registro_salida_almacen.idpatrimonio) + _cantidad;
				--caso que la primera renovacion este opcupada prosigue a la segunda renovacion
			else
				--actualizar fecha
				update registro_salida_almacen set fechasegrenovacion=(select CURRENT_DATE) where (select idpatrimonio from patrimonio 
				where (_patrimonio=descripcionpatrimonio) and (_talla=talla))=registro_salida_almacen.idpatrimonio
				and _codigo=idsalidaoficina;
				--actualizar stock
				update patrimonio set stock = ((select stock from patrimonio where ((_patrimonio=descripcionpatrimonio) and (_talla=talla))) - _cantidad) where (_patrimonio=descripcionpatrimonio) and (_talla=talla);
				--actualizar cantidad
				update registro_salida_almacen set cantidad =(select cantidad from registro_salida_almacen 
															  where _codigo=idsalidaoficina 
																and (select idpatrimonio from patrimonio 
																where (_patrimonio=descripcionpatrimonio) 
																and (_talla=talla))=registro_salida_almacen.idpatrimonio) + _cantidad 
																where _codigo=idsalidaoficina 
																and (select idpatrimonio from patrimonio 
																where (_patrimonio=descripcionpatrimonio) 
																and (_talla=talla))=registro_salida_almacen.idpatrimonio;
															
   			end if;
	else
		raise info 'no hay suficiente stock del producto %', now();
	END IF;
	select identradaoficina into gen from registro_entrada_almacen where  identradaoficina=_codigo;
	return gen;
END;
$Body$;

select * from actualizar_Renovacion('PANTALON DE JEAN PARA TRABAJO CON LOGO','S','2','NUEVO','0001230103');

select * from   actualizar_salida('0001230100','Sairt Pariguana','Alonso Salas','PANTALON DE JEAN PARA TRABAJO CON LOGO','M','10','NUEVO');


SELECT * FROM registro_salida_almacen
select * from listar_Salida_Almacen
select * from listar_Registro('12345680')







------------------------------------------------------------------------------------------------------------

drop FUNCTION actualizar_Renovacion;
CREATE or replace FUNCTION actualizar_Renovacion(_desPatrimonio varchar, _talla char, _cantidad int, _estado varchar, _dnicolaborador varchar)
returns CHAR
LANGUAGE plpgsql
COST 10
VOLATILE
as $Body$
DECLARE gen VARCHAR;
BEGIN
   --condicion si la cantidad excede el sotck
	IF _cantidad <= (select stock from patrimonio where ((_desPatrimonio=descripcionpatrimonio) and (_talla=talla)))
		   then
		--condicion de insercion en la primera renovacion o la segunda
			if (select fechaprirenovacion from registro_salida_almacen 
			WHERE (select idpatrimonio from patrimonio 
			where (_desPatrimonio=descripcionpatrimonio) and (_talla=talla))=registro_salida_almacen.idpatrimonio
			and _dnicolaborador=idcolaborador) is null
				then
				--actualizar fecha
					update registro_salida_almacen set fechaprirenovacion=(select CURRENT_DATE) where (select idpatrimonio from patrimonio 
					where (_desPatrimonio=descripcionpatrimonio) and (_talla=talla))=registro_salida_almacen.idpatrimonio
					and _dnicolaborador=idcolaborador;
				--actualizar cantidad
					update registro_salida_almacen set cantidad=(select cantidad from registro_salida_almacen 
															  where _dnicolaborador=idcolaborador 
																and (select idpatrimonio from patrimonio 
																where (_desPatrimonio=descripcionpatrimonio) 
																and (_talla=talla))=registro_salida_almacen.idpatrimonio) + _cantidad;
				--caso que la primera renovacion este opcupada prosigue a la segunda renovacion
			else
				--actualizar fecha
				update registro_salida_almacen set fecha_seg_renovacion=(select CURRENT_DATE) where (select idpatrimonio from patrimonio 
				where (_desPatrimonio=descripcionpatrimonio) and (_talla=talla))=registro_salida_almacen.idpatrimonio
				and _dnicolaborador=idcolaborador;
				--actualizar stock
				update patrimonio set stock = ((select stock from patrimonio where ((_desPatrimonio=descripcionpatrimonio) and (_talla=talla))) - _cantidad) where (_desPatrimonio=descripcionpatrimonio) and (_talla=talla);
				--actualizar cantidad
				update registro_salida_almacen set cantidad=(select cantidad from registro_salida_almacen 
															  where _dnicolaborador=idcolaborador 
																and (select idpatrimonio from patrimonio 
																where (_desPatrimonio=descripcionpatrimonio) 
																and (_talla=talla))=registro_salidaalmacen.idpatrimonio) + _cantidad 
																where _dnicolaborador=idcolaborador 
																and (select idpatrimonio from patrimonio 
																where (_desPatrimonio=descripcionpatrimonio) 
																and (_talla=talla))=registro_salida_almacen.idpatrimonio;
															
   			end if;
	else
		raise info 'no hay suficiente stock del producto %', now();
	END IF;
	select idsalidaoficina into gen from registro_salida_almacen where  _dnicolaborador=idusuario and idpatrimonio=;
	return gen;
				   	
END;
$Body$;


select * from  actualizar_Renovacion('PANTALON DE JEAN PARA TRABAJO CON LOGO','S','2','NUEVO','12345680');
SELECT * FROM registro_salida_almacen
select * from listar_Salida_Almacen
select * from listar_Registro('12345680')


_desPatrimonio varchar, _talla char, _cantidad int, _estado varchar, _dnicolaborador varchar

select fechaprirenovacion from registro_salida_almacen 
			WHERE (select idpatrimonio from patrimonio 
			where ('PANTALON DE JEAN PARA TRABAJO CON LOGO'=descripcionpatrimonio) and ('M'=talla))=registro_salida_almacen.idpatrimonio
			and '12345680'=idcolaborador















--Listar Colaboradores
drop function	listar_Colaborador;
CREATE or replace FUNCTION listar_Colaborador()
returns Table
(
	idcolaborador char(8), 
	idarea varchar,
	nombrecolaborador varchar,
	cargo varchar 
)
AS $func$
BEGIN
	return query	
	select colaborador.idcolaborador, area.descripcion, colaborador.nombrecolaborador, colaborador.cargo 
	from colaborador, area where area.idarea=colaborador.idarea;
END
$func$ LANGUAGE plpgsql;

select * from listar_Colaborador()

select * from  colaborador


--agregar colaborador

drop FUNCTION	insertar_colaborador;
CREATE or replace FUNCTION insertar_colaborador(_idcolaboradorp char, _idareap varchar, _nombrecolaboradorp varchar, _cargop varchar)
returns CHAR
LANGUAGE plpgsql
COST 10
VOLATILE
as $Body$
DECLARE gen VARCHAR;
BEGIN
	--registrar ingreso de epp/patrimonios en alamcén
    INSERT INTO colaborador(idcolaborador,idarea,nombrecolaborador,cargo)
    VALUES(_idcolaboradorp, 
		   	(select idarea from area where _idareap=descripcion),
		  	_nombrecolaboradorp,
		   	_cargop);
	select idcolaborador into gen from colaborador where  _idcolaboradorp = idcolaborador;
	return gen;
END;
$Body$;


select * from  insertar_colaborador('76687412','CATASTROs','Julio Haman','ingeniero Mecanico');
select * from colaborador

SELECT * FROM AREA

select area.idarea from area where 'CATASTRO'=area.descripcion


--ACTUALIZAR colaborador

drop FUNCTION	actualizar_colaborador;
CREATE or replace FUNCTION actualizar_colaborador(_idcolaboradorp char, _idareap varchar, _nombrecolaboradorp varchar, _cargop varchar)
returns CHAR
LANGUAGE plpgsql
COST 10
VOLATILE
as $Body$
DECLARE gen VARCHAR;
BEGIN
	update  colaborador set idcolaborador=_idcolaboradorp,
							idarea=(select idarea from area where _idareap=descripcion),
							nombrecolaborador=_nombrecolaboradorp,
							cargo=_cargop
							where idcolaborador=_idcolaboradorp;
	select idcolaborador into gen from colaborador where  _idcolaboradorp = idcolaborador;
	return gen;
END;
$Body$;

select * from  actualizar_colaborador('76687412','CATASTROs','Julio Haman Salas','ingeniero Mecanico');
select * from colaborador


--listar por id colaborador

drop FUNCTION	list_id_colaborador;
CREATE or replace FUNCTION list_id_colaborador(_idcolaboradorp char)
returns Table
(
	idcolaborador char,
	idarea VARCHAR,
	nombrecolaborador varchar,
	cargo varchar
)
AS $func$
BEGIN
	return query
	select colaborador.idcolaborador,
	(select descripcion from area where area.idarea=colaborador.idarea),
	colaborador.nombrecolaborador,
	colaborador.cargo
	from colaborador where _idcolaboradorp=colaborador.idcolaborador;
END
$func$ LANGUAGE plpgsql;

select * from  list_id_colaborador('76687412');



drop FUNCTION	list_Cola;
CREATE FUNCTION list_Cola(_idcolaboradorp char)
RETURNS colaborador AS $$
DECLARE 
idcolaborador char;
idarea char;
nombrecolaborador varchar;
cargo varchar;
BEGIN
	select  colaborador.idcolaborador,
	(select colaborador from area where area.idarea=colaborador.idarea),
	colaborador.nombrecolaborador,
	colaborador.cargo
	from colaborador where _idcolaboradorp=colaborador.idcolaborador;
	RETURN idcolaborador;
END;
$$
LANGUAGE plpgsql;


	select * from  list_Cola('76687412');

drop view	list_Cola;
create view list_Cola as
select  colaborador.idcolaborador,
(select descripcion from area where area.idarea=colaborador.idarea),
colaborador.nombrecolaborador,
colaborador.cargo
from colaborador where idcolaborador=colaborador.idcolaborador;


select * from  list_Cola where idcolaborador = '76687412'







select * from listar_entrada_alm


--listar area
drop function	listar_area;
CREATE or replace FUNCTION listar_area()
returns Table
(
	idareat char,
	descripciont varchar
)
AS $func$
BEGIN
	return query	
	Select idarea, descripcion from area;
END
$func$ LANGUAGE plpgsql;

select * from listar_area()


select * from area

select * from registro_salida_almacen
select * from listar_Salida()
select * from patrimonio
select * from registro_salida_almacen order by registro_salida_almacen.fecha_salida DESC

update registro_salida_almacen set estado_salida = 'Buen Estado';
SELECT * from  registro_salida_almacen order by fecha_salida
select id_patrimonio from patrimonio where (descripcion_patrimonio||' '||talla )= 'PANTALON DE JEAN PARA TRABAJO CON LOGO S'
select id_patrimonio from patrimonio where descripcion_patrimonio = 'PANTALON DE JEAN PARA TRABAJO CON LOGO' and talla='S'
select * from area
select descripcion_patrimonio||' '||talla from patrimonio


ALTER TABLE area DROP COLUMN descripciont; 






