create table isik(
id int not null primary key identity (1,1),
eesnimi varchar(50),
perenimi varchar(50),
sugu char(1),
sunnikuupaev date,
aadress varchar(100),
email varchar(50)
)

create table oppeaine(
id int not null primary key identity (1,1),
nimi varchar(50),
vastutav_opetaja int references isik(id),
aine_kestus varchar(50)
)

create table oppimine(
id int not null primary key identity (1,1),
isik_id int references isik(id),
oppeaine_id int references oppeaine(id),
hinne int
)


create table logi(
id int not null primary key identity (1,1),
kasutaja varchar(100),
kuupaev DATETIME DEFAULT GETDATE(),
sisestatudAndmed text
)

CREATE TRIGGER aaaInsert_logi
ON oppimine
FOR INSERT
AS
BEGIN
    INSERT INTO logi (kasutaja,kuupaev, sisestatudAndmed)
    SELECT
        SYSTEM_USER,    
        GETDATE(),                 
        CONCAT(
		    'oppimine on lisatud id: ', 
            inserted.id, ', isik id: ',
            inserted.isik_id, ', oppeaine id: ',
            inserted.oppeaine_id, ', hinne: ',
			inserted.hinne
        )
    FROM inserted;
END;

CREATE TRIGGER Update_logi
ON oppimine
AFTER UPDATE
AS
BEGIN
    INSERT INTO logi (kasutaja, kuupaev, sisestatudAndmed)
    SELECT
        SYSTEM_USER,
        GETDATE(),
        CONCAT(
            'vana oppimine: ', d.id, ', ', d.isik_id, ', ', d.oppeaine_id, ', ', d.hinne, '; ',
            'uus oppimine: ', i.id, ', ', i.isik_id, ', ', i.oppeaine_id, ', ', i.hinne
        )
    FROM deleted d
    INNER JOIN inserted i ON d.id = i.id;
END;

grant insert,select on isik to Nikita
grant insert,select on oppimine to Nikita
grant insert,select on oppeaine to Nikita
grant create table to table_creator


INSERT INTO isik (eesnimi, perenimi, sugu, sunnikuupaev, aadress, email) VALUES
('Maria', 'Tamm', 'N', '1995-04-12', 'Tallinn, Tartu 12', 'maria.tamm@example.com'),
('Jaan', 'Kask', 'M', '1990-08-23', 'Tartu, Vabaduse 5', 'jaan.kask@example.com'),
('Liis', 'Saar', 'N', '1998-12-01', 'Pärnu, Ranna 7', 'liis.saar@example.com');

INSERT INTO oppeaine (nimi, vastutav_opetaja, aine_kestus) VALUES
('Matemaatika', 1, '1 semester'),
('Inglise keel', 2, '2 semesterit'),
('Keemia', 3, '1 semester');

INSERT INTO oppimine (isik_id, oppeaine_id, hinne) VALUES
(1, 1, 4),
(1, 2, 5),
(2, 1, 3),
(3, 3, 5);

select * from logi
select * from oppimine

BEGIN TRANSACTION;

SAVE TRANSACTION SaveBeforeOppimine;

INSERT INTO oppimine (isik_id, oppeaine_id, hinne) VALUES
(2, 2, 4),
(3, 2, 3);

select * from oppimine

ROLLBACK TRANSACTION SaveBeforeOppimine;

select * from oppimine
