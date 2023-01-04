drop database bd_ControlEpp
CREATE DATABASE bd_controlepp

select * from usuario

drop table if exists area;
create table Area(
	idarea char(3) primary key not null,
	descripcion varchar(90) not null
);
drop table if exists colaborador;
create table colaborador(
	idcolaborador char(8) primary key not null,
	idarea char(3) not null,
	nombrecolaborador varchar(80) not null,
	cargo varchar (30) not null,
	--firmadiguital bytea null,
	foreign key(idarea) references area(idarea)
);
drop table if exists Usuario;
CREATE TABLE Usuario(
  	idusuario char(8) primary key not null,
	nombreusuario varchar(80) not null,
	usuario varchar(90)not null,
	contraseña varchar(90)not null
);
drop table if exists Rol;
CREATE TABLE Rol(
  	idrol serial primary key not null,
	rol varchar(30)not null
);
drop table if exists privilegios

create table privilegios(
	idprivilegios serial primary key,
	idusuario char(8),
	idrol serial,
	foreign key(idusuario) references Usuario(idusuario),
	foreign key(idrol) references Rol(idrol)
);

drop table if exists Patrimonio;
create table Patrimonio(
	idpatrimonio varchar(30) primary key not null,
	descripcionpatrimonio varchar(100) not null,
	stock int not null,
	talla varchar(5) null,
	unidadmedida varchar(20)not null,
	retorno char(2) not NULL
);


drop table if exists Registro_Salida_Almacen;--FALTA CANTIDAD POR CADA FECHA
create table Registro_Salida_Almacen(
	idsalidaoficina char(10) primary key not null,
	idusuario char(8) not null,
	idcolaborador char(8) not null,
	idpatrimonio varchar(30) not null,
	cantidad int not null,
	fechasalida date not null,
	fechaprirenovacion date null,
	fechasegrenovacion date null,
	estadosalida varchar(20),
	foreign key(idusuario) references Usuario(idusuario),
	foreign key(idcolaborador) references Colaborador(idcolaborador),
	foreign key(idpatrimonio) references Patrimonio(idpatrimonio)
);

ALTER TABLE Registro_Entrada_Almacen ALTER COLUMN identradaoficina SET DATA TYPE char(10);
drop table if exists Registro_Entrada_Almacen;
create table Registro_Entrada_Almacen(
	identradaoficina char(10) primary key not null,
	idusuario char(8) not null,
	idpatrimonio varchar(30) not null,
	cantidad int not null,
	fechaentrada date not null,
	estadoentrada varchar(20),
	foreign key(idusuario) references Usuario(idusuario),
	foreign key(idpatrimonio) references Patrimonio(idpatrimonio)
);