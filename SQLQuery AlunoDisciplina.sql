use Universidade;

Create Table Aluno (
RA int IDENTITY(1,1) Not Null,
Nome Varchar(50) Not Null

Constraint RA PRIMARY KEY (RA)
);


create table Disciplina(
Sigla char(3) not null,
Nome varchar(20) not null,
Carga_Horaria int not null

Constraint Sigla PRIMARY KEY (Sigla)
);


CREATE TABLE Matricula (
RA int not null,
Sigla char(3) not null,
Data_Ano int not null,
Data_Semestre int not null,
Falta int,
Nota_N1 float,
Nota_N2 float, 
Nota_Sub float, 
Nota_Media float,
Situacao bit,

Constraint PK_Matricula PRIMARY KEY (RA,Sigla, Data_Ano, Data_Semestre), /*Define o nome PK_Matricula para a chave composta*/
FOREIGN KEY (RA) REFERENCES Aluno(RA),
FOREIGN KEY (Sigla) REFERENCES Disciplina(Sigla)
);


insert into Aluno
Values('Felipe'),
('Pedro'),
('Mariana'),
('John'),
('Fred'),
('Parker'),
('Felicia'),
('Michele'),
('Karen'),
('David'),
('Susana'),
('Leonardo');

select * from Aluno;

insert into Disciplina
Values('elm', 'Eletromagnetismo', 30),
('cal', 'Cálculo', 30),
('lip', 'Língua Portuguesa', 20),
('cel', 'Circuito Eletrônico', 30),
('bdd', 'Banco de Dados', 40),
('alg', 'Algoritmos', 40),
('log', 'Lógica', 40),
('poo', 'POO', 40),
('edd', 'Estrutura de Dados', 40),
('etc', 'Ética', 30),
('dsi', 'Design Sistemas', 20),
('pla', 'Planejamento', 20);

select * from Disciplina;
GO

--Trigger aciona pelo comando Insert e Update na tabela Matricula
drop TRIGGER TGR_MATRICULA;
go

CREATE TRIGGER TGR_MATRICULA
ON dbo.Matricula
FOR UPDATE, INSERT
AS
BEGIN

DECLARE @N1 float, @N2 float, @Falta int

select @N1 = inserted.Nota_N1,
	   @N2 = inserted.Nota_N2,
	   @Falta = inserted.Falta
from inserted

IF (@N1 is not null AND @N2 is not null AND @Falta is not null)
Begin

DECLARE 
    @Media float,
	@Carga_Horaria int,
	@RA int,
	@Sigla char(3),
	@Data_Ano int,
	@Data_Semestre int,
	@Nsub float

select 
	   @RA = inserted.RA,
	   @Sigla = inserted.Sigla,
	   @Data_Ano = inserted.Data_Ano,
	   @Data_Semestre = inserted.Data_Semestre,
	   @Nsub = inserted.Nota_Sub
from inserted

		IF (@Nsub is not null AND (@Nsub > @N1 OR @Nsub > @N2))
		Begin
		        IF  (@N1 <= @N2)
				Begin
				set @Media = (@NSub + @N2)/2;
				End 
				ELSE
				Begin
				set @Media = (@N1 + @NSub)/2;
				End
		End
		ELSE
		Begin
		set @Media = (@N1 + @N2)/2;
		End
	

select @Carga_Horaria = d.Carga_Horaria
from inserted inner join dbo.Disciplina as d 
on inserted.Sigla = d.Sigla;

Update dbo.Matricula set Nota_Media = @Media
where RA = @RA AND Sigla = @Sigla
AND Data_Ano = @Data_Ano AND Data_Semestre = @Data_Semestre;


		IF (@Media >= 5 AND @Falta < @Carga_Horaria * 0.25)
		Begin
			Update dbo.Matricula set Situacao = 1
			where RA = @RA AND Sigla = @Sigla
			AND Data_Ano = @Data_Ano AND Data_Semestre = @Data_Semestre;

			end 
		ELSE
		Begin
			Update dbo.Matricula set Situacao = 0
			where RA = @RA AND Sigla = @Sigla
			AND Data_Ano = @Data_Ano AND Data_Semestre = @Data_Semestre;

	    End

End

END

GO


drop TRIGGER TGR_REMATRICULA
go


CREATE TRIGGER TGR_REMATRICULA
ON dbo.Matricula
FOR UPDATE, INSERT
AS
BEGIN

Declare @Data_ProxAno int,
@RA int, @Sigla Char(3), @Data_Semestre int, @Situacao bit

select @Data_ProxAno = Data_ano + 1,
@RA = RA, @Sigla = Sigla, @Data_Semestre = Data_Semestre, @Situacao = Situacao
from inserted

IF (@Situacao = 0)
Begin

insert into dbo.Matricula (RA, Sigla, Data_Ano, Data_Semestre)
Values (@RA, @Sigla,@Data_ProxAno, @Data_Semestre)

End

END
GO





delete from Matricula;

--Início dos testes, para comprovar que o Trigger calcula somente a partir de quando tiver informações em Falta, Nota1 e Nota2.


--Adicionando os dados pelo Insert InTo, menos a nota_sub
insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre, Nota_N2, Nota_N1, Falta)
	Values	(3, 'cel', 2023, 2, 2, 2, 5);

select * from Matricula;


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values (6, 'CAL', 2021, 1);
--Update para adicionar somente a nota 1
update Matricula set Nota_N1 = 10 where (RA = 6 and Sigla = 'CAL'and Data_Ano = 2021 and Data_Semestre = 1);


select * from Matricula;


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values (7, 'CAL', 2021, 1);
--Update para adicionar somente as faltas:
update Matricula set Falta = 1 where (RA = 7 and Sigla = 'CAL'and Data_Ano = 2021 and Data_Semestre = 1);


select * from Matricula;


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values (9, 'CEL', 2021, 1);
--Update para adicionar somente nota 2
update Matricula set Nota_N2 = 2 where (RA = 9 and Sigla = 'CEL'and Data_Ano = 2021 and Data_Semestre = 1);


select * from Matricula;


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values	(5, 'LIP', 2021, 2);
--Update para adicionar nota 1 e nota 2 sem adicionar falta
update Matricula set Nota_N1 = 2, Nota_N2 = 4 where (RA = 5 and Sigla = 'LIP'and Data_Ano = 2021 and Data_Semestre = 2);


select * from Matricula;


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values	(1, 'LIP', 2021, 2);
--Update para adicionar Nota 2 e Falta sem adicionar Nota 1
update Matricula set Nota_N2 = 2, Falta = 4 where (RA = 1 and Sigla = 'LIP'and Data_Ano = 2021 and Data_Semestre = 2);


select * from Matricula;

--Fim dos testes, comprovado que o Trigger calcula somente a partir de quando tiver informações em Falta, Nota1 e Nota2.



--Limpar Tabela
delete from Matricula;
GO

--Adicionando vários registros para a tabela matricula:

insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values(1, 'ELM', 2021, 1), (1, 'CAL', 2021, 1), (1, 'LIP', 2021, 1), (1, 'CEL', 2021, 1), (1, 'BDD', 2021, 1);

update Matricula set Falta = 5, Nota_N1 = 2, Nota_N2 = 4, Nota_Sub = 3 where (RA = 1 and Sigla = 'ELM'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 15, Nota_N1 = 8, Nota_N2 = 9 where (RA = 1 and Sigla = 'CAL'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 4, Nota_N1 = 2, Nota_N2 = 4, Nota_Sub =7 where (RA = 1 and Sigla = 'LIP'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 2, Nota_N1 = 8, Nota_N2 = 7 where (RA = 1 and Sigla = 'CEL'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 6, Nota_N1 = 10, Nota_N2 = 4 where (RA = 1 and Sigla = 'BDD'and Data_Ano = 2021 and Data_Semestre = 1);


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values(1, 'LOG', 2021, 2), (1, 'POO', 2021, 2), (1, 'EDD', 2021, 2), (1, 'ETC', 2021, 2), (1, 'DSI', 2021, 2);

update Matricula set Falta = 2, Nota_N1 = 3, Nota_N2 = 9 where (RA = 1 and Sigla = 'LOG'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 5, Nota_N1 = 6, Nota_N2 = 5 where (RA = 1 and Sigla = 'POO'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 20, Nota_N1 = 10, Nota_N2 = 10 where (RA = 1 and Sigla = 'EDD'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 3, Nota_N1 = 5, Nota_N2 = 5 where (RA = 1 and Sigla = 'ETC'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 4, Nota_N1 = 6, Nota_N2 = 4 where (RA = 1 and Sigla = 'DSI'and Data_Ano = 2021 and Data_Semestre = 2);


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values(2, 'ELM', 2021, 1), (2, 'CAL', 2021, 1), (2, 'LIP', 2021, 1), (2, 'CEL', 2021, 1), (2, 'ALG', 2021, 1);

update Matricula set Falta = 5, Nota_N1 = 2, Nota_N2 = 4 , Nota_Sub = 6 where (RA = 2 and Sigla = 'ELM'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 15, Nota_N1 = 2, Nota_N2 = 9 where (RA = 2 and Sigla = 'CAL'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 4, Nota_N1 = 3, Nota_N2 = 2, Nota_Sub = 5 where (RA = 2 and Sigla = 'LIP'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 2, Nota_N1 = 6, Nota_N2 = 5 where (RA = 2 and Sigla = 'CEL'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 6, Nota_N1 = 2, Nota_N2 = 1, Nota_Sub = 7 where (RA = 2 and Sigla = 'ALG'and Data_Ano = 2021 and Data_Semestre = 1);


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values(2, 'LOG', 2021, 2), (2, 'POO', 2021, 2), (2, 'EDD', 2021, 2), (2, 'ETC', 2021, 2), (2, 'PLA', 2021, 2);

update Matricula set Falta = 18, Nota_N1 = 2, Nota_N2 = 4 where (RA = 2 and Sigla = 'LOG'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 15, Nota_N1 = 3.5, Nota_N2 = 0 where (RA = 2 and Sigla = 'POO'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 20, Nota_N1 = 1, Nota_N2 = 4 where (RA = 2 and Sigla = 'EDD'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 0, Nota_N1 = 6.5, Nota_N2 = 1.5, Nota_Sub = 7 where (RA = 2 and Sigla = 'ETC'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 5, Nota_N1 = 4, Nota_N2 = 1, Nota_Sub = 9 where (RA = 2 and Sigla = 'PLA'and Data_Ano = 2021 and Data_Semestre = 2);


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values(3, 'CAL', 2021, 1), (3, 'LIP', 2021, 1), (3, 'CEL', 2021, 1), (3, 'BDD', 2021, 1), (3, 'ALG', 2021, 1);

update Matricula set Falta = 5, Nota_N1 = 4, Nota_N2 = 4, Nota_Sub = 8 where (RA = 3 and Sigla = 'CAL'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 4, Nota_N1 = 5, Nota_N2 = 2, Nota_Sub = 5 where (RA = 3 and Sigla = 'LIP'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 9, Nota_N1 = 2, Nota_N2 = 1 where (RA = 3 and Sigla = 'CEL'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 2, Nota_N1 = 7, Nota_N2 = 6 where (RA = 3 and Sigla = 'BDD'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 2, Nota_N1 = 5, Nota_N2 = 5 where (RA = 3 and Sigla = 'ALG'and Data_Ano = 2021 and Data_Semestre = 1);


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values(3, 'POO', 2021, 2), (3, 'EDD', 2021, 2), (3, 'ETC', 2021, 2), (3, 'DSI', 2021, 2), (3, 'PLA', 2021, 2);

update Matricula set Falta = 3, Nota_N1 = 2, Nota_N2 = 3, Nota_Sub = 7 where (RA = 3 and Sigla = 'POO'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 30, Nota_N1 = 5, Nota_N2 = 0 where (RA = 3 and Sigla = 'EDD'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 4, Nota_N1 = 8, Nota_N2 = 9 where (RA = 3 and Sigla = 'ETC'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 5, Nota_N1 = 4, Nota_N2 = 6 where (RA = 3 and Sigla = 'DSI'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 7, Nota_N1 = 5, Nota_N2 = 4, Nota_Sub = 5 where (RA = 3 and Sigla = 'PLA'and Data_Ano = 2021 and Data_Semestre = 2);


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values(4, 'CAL', 2021, 1), (4, 'LIP', 2021, 1), (4, 'CEL', 2021, 1), (4, 'BDD', 2021, 1), (4, 'ALG', 2021, 1);

update Matricula set Falta = 9, Nota_N1 = 2, Nota_N2 = 7, Nota_Sub = 8 where (RA = 4 and Sigla = 'CAL'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 2, Nota_N1 = 7, Nota_N2 = 4, Nota_Sub = 5 where (RA = 4 and Sigla = 'LIP'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 5, Nota_N1 = 9, Nota_N2 = 9 where (RA = 4 and Sigla = 'CEL'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 3, Nota_N1 = 8, Nota_N2 = 10 where (RA = 4 and Sigla = 'BDD'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 0, Nota_N1 = 10, Nota_N2 = 10 where (RA = 4 and Sigla = 'ALG'and Data_Ano = 2021 and Data_Semestre = 1);


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values(4, 'POO', 2021, 2), (4, 'EDD', 2021, 2), (4, 'ETC', 2021, 2), (4, 'DSI', 2021, 2), (4, 'PLA', 2021, 2);

update Matricula set Falta = 12, Nota_N1 = 8, Nota_N2 = 9, Nota_Sub = 7 where (RA = 4 and Sigla = 'POO'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 3, Nota_N1 = 5, Nota_N2 = 5 where (RA = 4 and Sigla = 'EDD'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 6, Nota_N1 = 6, Nota_N2 = 8 where (RA = 4 and Sigla = 'ETC'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 2, Nota_N1 = 2, Nota_N2 = 8 where (RA = 4 and Sigla = 'DSI'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 4, Nota_N1 = 9, Nota_N2 = 0, Nota_Sub = 5 where (RA = 4 and Sigla = 'PLA'and Data_Ano = 2021 and Data_Semestre = 2);


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values(5, 'ELM', 2021, 1), (5, 'CAL', 2021, 1), (5, 'LIP', 2021, 1), (5, 'CEL', 2021, 1), (5, 'BDD', 2021, 1);

update Matricula set Falta = 0, Nota_N1 = 0, Nota_N2 = 0, Nota_Sub = 10 where (RA = 5 and Sigla = 'ELM'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 19, Nota_N1 = 10, Nota_N2 = 10 where (RA = 5 and Sigla = 'CAL'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 2, Nota_N1 = 6, Nota_N2 = 5, Nota_Sub = 3 where (RA = 5 and Sigla = 'LIP'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 1, Nota_N1 = 6, Nota_N2 = 7 where (RA = 5 and Sigla = 'CEL'and Data_Ano = 2021 and Data_Semestre = 1);
update Matricula set Falta = 4, Nota_N1 = 10, Nota_N2 = 8 where (RA = 5 and Sigla = 'BDD'and Data_Ano = 2021 and Data_Semestre = 1);


insert into Matricula(RA, Sigla, Data_Ano, Data_Semestre)
Values(5, 'LOG', 2021, 2), (5, 'POO', 2021, 2), (5, 'EDD', 2021, 2), (5, 'ETC', 2021, 2), (5, 'DSI', 2021, 2);

update Matricula set Falta = 7, Nota_N1 = 8, Nota_N2 = 7 where (RA = 5 and Sigla = 'LOG'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 3, Nota_N1 = 6, Nota_N2 = 7 where (RA = 5 and Sigla = 'POO'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 4, Nota_N1 = 7, Nota_N2 = 10 where (RA = 5 and Sigla = 'EDD'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 2, Nota_N1 = 9, Nota_N2 = 4 where (RA = 5 and Sigla = 'ETC'and Data_Ano = 2021 and Data_Semestre = 2);
update Matricula set Falta = 4, Nota_N1 = 3, Nota_N2 = 4.5 where (RA = 5 and Sigla = 'DSI'and Data_Ano = 2021 and Data_Semestre = 2);
go



--Mostrar Tabela Matricula
select * from Matricula;



--Quais são alunos de uma determinada disciplina ministrada no ano de 2021, com suas notas, faltas e Situação Final.

--Consulta 1
select Disciplina.Nome, Aluno.Nome, Matricula.Data_Ano, Matricula.Falta, Matricula. Nota_N1,
Matricula. Nota_N2, Matricula. Nota_Sub, Matricula. Nota_Media, Matricula.Situacao
from Disciplina, Matricula, Aluno
where Data_Ano = 2021 AND Matricula.Sigla = 'CAL' AND Disciplina.Sigla = Matricula.Sigla AND Aluno.RA = Matricula.RA

--Consulta 2
select Disciplina.Nome, Aluno.Nome, Matricula.Data_Ano, Matricula.Falta, Matricula. Nota_N1,
Matricula. Nota_N2, Matricula. Nota_Sub, Matricula. Nota_Media, Matricula.Situacao
from Disciplina, Matricula, Aluno
where Data_Ano = 2021 AND Matricula.Sigla = 'LIP' AND Disciplina.Sigla = Matricula.Sigla AND Aluno.RA = Matricula.RA


--Quais são as notas, faltas e situação final (Boletim) de um aluno em todas as disciplinas por ele cursadas no ano de 2021, no segundo semestre.

--Consulta 1
select Disciplina.Nome, Aluno.Nome, Matricula.Data_Ano, Matricula.Data_Semestre, Matricula.Falta, Matricula. Nota_N1,
Matricula. Nota_N2, Matricula. Nota_Sub, Matricula. Nota_Media, Matricula.Situacao
from Disciplina, Matricula, Aluno
where Data_Ano = 2021 AND Aluno.Nome = 'Felipe' AND Disciplina.Sigla = Matricula.Sigla AND Aluno.RA = Matricula.RA
Order By Data_Semestre;

--Consulta 2
select Disciplina.Nome, Aluno.Nome, Matricula.Data_Ano, Matricula.Data_Semestre, Matricula.Falta, Matricula. Nota_N1,
Matricula. Nota_N2, Matricula. Nota_Sub, Matricula. Nota_Media, Matricula.Situacao
from Disciplina, Matricula, Aluno
where Data_Ano = 2021 AND Aluno.Nome = 'Mariana' AND Disciplina.Sigla = Matricula.Sigla AND Aluno.RA = Matricula.RA
Order By Data_Semestre;


--Quais são os alunos reprovados por nota (média inferior a cinco) no ano de 2021 e, o nome das disciplinas em que eles reprovaram, com suas notas e médias.

--Consulta 1
select Disciplina.Nome as 'Disciplina Reprovada', Aluno.Nome as 'Aluno', Matricula.Data_Ano as 'Ano' , 
Matricula.Data_Semestre as 'Semestre', Matricula.Falta, Matricula.Nota_N1,
Matricula. Nota_N2, Matricula. Nota_Sub, Matricula. Nota_Media as 'Media Reprovada'
from Disciplina, Matricula, Aluno
where Data_Ano = 2021 AND Matricula.Nota_Media < 5 AND Disciplina.Sigla = Matricula.Sigla AND Aluno.RA = Matricula.RA
Order By Data_Semestre;



--Consulta 2 Alunos Aprovados
select Disciplina.Nome as 'Disciplina Aprovada', Aluno.Nome as 'Aluno', Matricula.Data_Ano as 'Ano' , 
Matricula.Data_Semestre as 'Semestre', Matricula.Falta, Matricula.Nota_N1,
Matricula. Nota_N2, Matricula. Nota_Sub, Matricula. Nota_Media as 'Media Aprovada'
from Disciplina, Matricula, Aluno
where Data_Ano = 2021 AND Matricula.Nota_Media >= 5 AND Disciplina.Sigla = Matricula.Sigla AND Aluno.RA = Matricula.RA
Order By Aluno;