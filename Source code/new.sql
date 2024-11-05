CREATE DATABASE CHATROOM;
USE CHATROOM;
CREATE TABLE NGUOIDUNG (
    TENND VARCHAR(50) NOT NULL,
    EMAIL VARCHAR(50),
    SDT VARCHAR(20),
    TAIKHOAN VARCHAR(20) PRIMARY KEY NOT NULL,
    MATKHAU VARCHAR(255) NOT NULL,
    TTTRUCTUYEN BOOLEAN NOT NULL
);

CREATE TABLE PHONGCHAT (
    MAPC INT PRIMARY KEY AUTO_INCREMENT,
    TENPC VARCHAR(50) NOT NULL,
    NGAYTAO DATETIME NOT NULL
);
SET SQL_SAFE_UPDATES = 0;
delete from phongchat where mapc = 19

CREATE TABLE ND_PC (
    TAIKHOAN VARCHAR(20) NOT NULL,
    MAPC INT NOT NULL,
    PRIMARY KEY (TAIKHOAN, MAPC),
    FOREIGN KEY (TAIKHOAN) REFERENCES NGUOIDUNG (TAIKHOAN),
    FOREIGN KEY (MAPC) REFERENCES PHONGCHAT (MAPC),
    QUYEN BOOLEAN NOT NULL,
    NGAYTG DATETIME NOT NULL
);

CREATE TABLE TINNHAN (
    MATN INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    TAIKHOAN VARCHAR(20) NOT NULL,
    FOREIGN KEY (TAIKHOAN) REFERENCES NGUOIDUNG (TAIKHOAN),
    MAPC INT NOT NULL,
    FOREIGN KEY (MAPC) REFERENCES PHONGCHAT (MAPC),
    NOIDUNG TEXT NOT NULL,
    NGAYGUI DATETIME NOT NULL,
    TINHTRANG VARCHAR(10) NOT NULL
);

CREATE TABLE THONGBAO (
    MATB INT auto_increment PRIMARY KEY NOT NULL,
    TAIKHOAN VARCHAR(20) NOT NULL,
    FOREIGN KEY (TAIKHOAN) REFERENCES NGUOIDUNG (TAIKHOAN),
    NOIDUNG TEXT NOT NULL,
    NGAYNHAN DATETIME NOT NULL
);

DELIMITER //
CREATE PROCEDURE In_PhongChat_Tu_NguoiDung(IN taikhoan INT)
BEGIN
    SELECT P.MAPC, TENPC
    FROM PHONGCHAT P
    INNER JOIN ND_PC N ON P.MAPC = N.MAPC
    WHERE N.TAIKHOAN = taikhoan;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE Dem_NguoiDung_Trong_PhongChat(
    IN mapc INT,
    OUT slnd INT
)
BEGIN
    SELECT COUNT(*) INTO slnd
    FROM ND_PC
    WHERE MAPC = mapc;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE DanhDau_TinNhan_DaXem_Tu_NguoiDung(
    IN matn INT,
    IN taikhoan INT
)
BEGIN
    UPDATE TINNHAN
    SET TINHTRANG = 'Đã xem'
    WHERE MATN = matn AND TAIKHOAN = taikhoan;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE TimKiem_TinNhan_Bang_TuKhoa(IN keyword TEXT)
BEGIN
    SELECT *
    FROM TINNHAN
    WHERE NOIDUNG LIKE CONCAT('%', keyword, '%');
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE Xoa_PhongChat(IN mapc INT)
BEGIN
    DELETE FROM TINNHAN WHERE MAPC = mapc;
    DELETE FROM ND_PC WHERE MAPC = mapc;
    DELETE FROM PHONGCHAT WHERE MAPC = mapc;
END //

DELIMITER ;

DELIMITER //
CREATE TRIGGER MatKhau_NguoiDung_BeforeInsert
BEFORE INSERT ON NGUOIDUNG
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.MATKHAU) < 8 THEN
        SET NEW.MATKHAU = NULL;
    END IF;
END //

DELIMITER //
CREATE TRIGGER MatKhau_NguoiDung_BeforeUpdate
BEFORE UPDATE ON NGUOIDUNG
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.MATKHAU) < 8 THEN
        SET NEW.MATKHAU = NULL;
    END IF;
END //
DELIMITER ;
/** da xoa trigger nay
drop trigger TrangThai_NguoiDung_AfterInsert
DELIMITER //
CREATE TRIGGER TrangThai_NguoiDung_AfterInsert
AFTER INSERT ON NGUOIDUNG
FOR EACH ROW
BEGIN
    DECLARE taiKhoanTemp INT;
    SET taiKhoanTemp = NEW.TAIKHOAN;
    UPDATE NGUOIDUNG
    SET TTTRUCTUYEN = TRUE
    WHERE TAIKHOAN = taiKhoanTemp;
END //
DELIMITER ;**/



DELIMITER ;

DELIMITER //

CREATE TRIGGER Ten_PhongChat_BeforeInsert
BEFORE INSERT ON PHONGCHAT
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PHONGCHAT
        WHERE TENPC = NEW.TENPC
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tên phòng chat đã tồn tại';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER Ten_PhongChat_BeforeUpdate
BEFORE UPDATE ON PHONGCHAT
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PHONGCHAT
        WHERE TENPC = NEW.TENPC AND MAPC <> NEW.MAPC
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tên phòng chat đã tồn tại';
    END IF;
END //

DELIMITER ;
/*
drop trigger PhongChat_BeforeDelete
DELIMITER //
CREATE TRIGGER PhongChat_BeforeDelete
BEFORE DELETE ON PHONGCHAT
FOR EACH ROW
BEGIN
    DECLARE adminCheck INT;
    SELECT COUNT(*) INTO adminCheck
    FROM ND_PC
    WHERE MAPC = OLD.MAPC AND QUYEN = 1;
    IF adminCheck = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không được phép xóa phòng chat khi không có quyền Quản trị viên';
    END IF;
END //
DELIMITER ;**/

/**
DELIMITER //
CREATE TRIGGER Quyen_ND_PC_AfterInsert
AFTER INSERT ON PHONGCHAT
FOR EACH ROW
BEGIN
    DECLARE mapc INT;
    SET mapc = NEW.MAPC;
    INSERT INTO ND_PC (TAIKHOAN, MAPC, QUYEN, NGAYTG)
    SELECT TAIKHOAN, NEW.MAPC, 1, NOW() FROM NGUOIDUNG;
END //
DELIMITER ;**/

DELIMITER //
CREATE FUNCTION SoLuong_TinNhan_Trong_PhongChat(mapc INT) RETURNS INT
BEGIN 
    DECLARE messageCount INT;
    IF NOT EXISTS (SELECT 1 FROM PHONGCHAT WHERE MAPC = mapc) THEN
        RETURN -1;
    END IF;
    SELECT COUNT(*) INTO messageCount
    FROM TINNHAN
    WHERE MAPC = mapc;
    RETURN messageCount;
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION KiemTra_TrangThai_NguoiDung(taikhoan INT) RETURNS INT
BEGIN
    DECLARE trangThai INT;
    
    SELECT IF(TTTRUCTUYEN, 1, 0) INTO trangThai
    FROM NGUOIDUNG
    WHERE TAIKHOAN = taikhoan;
    IF trangThai IS NULL THEN
        SET trangThai = -1;
    END IF;
    RETURN trangThai;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE SoLuong_TinNhan_ChuaDoc_Tu_NguoiDung(IN taikhoan INT)
BEGIN
    DECLARE messageCount INT DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        SELECT COUNT(*)
        FROM TINNHAN
        WHERE TAIKHOAN = taikhoan AND TINHTRANG <> 'Đã xem';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO messageCount;
        IF done THEN
            LEAVE read_loop;
        END IF;
    END LOOP;
    CLOSE cur;
    SELECT messageCount AS unreadMessageCount;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE Top3_PhongChat_NguoiDung_Nhap_NhieuNhat(IN taikhoan INT)
BEGIN 
    DECLARE done INT DEFAULT 0;
    DECLARE tenpc VARCHAR(50);
    DECLARE messageCount INT;
    DECLARE cur CURSOR FOR
        SELECT TENPC, COUNT(MATN) AS MessageCount
        FROM ND_PC N, TINNHAN T
        WHERE N.MAPC = T.MAPC AND N.TAIKHOAN = T.TAIKHOAN AND T.TAIKHOAN = taikhoan
        GROUP BY TENPC
        ORDER BY COUNT(MATN) DESC
        LIMIT 3;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    CREATE TEMPORARY TABLE IF NOT EXISTS TMP_PHONGCHAT(
        TENPC VARCHAR(50),
        MESSAGECOUNT INT
    );
    OPEN cur;
    TOP3_PC: LOOP
        FETCH cur INTO tenpc, messageCount;
        IF done THEN
            LEAVE TOP3_PC;
        END IF;
        INSERT INTO TMP_PHONGCHAT(TENPC, MESSAGECOUNT) VALUES(tenpc, messageCount);
    END LOOP;
    CLOSE cur;
    SELECT TENPC, MESSAGECOUNT
    FROM TMP_PHONGCHAT;
    DROP TEMPORARY TABLE IF EXISTS TMP_PHONGCHAT;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE Top3_PhongChat_NguoiDung_Nhap_GanNhat(IN taikhoan INT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tenpc NVARCHAR(50);
    DECLARE cur CURSOR FOR
        SELECT TENPC
        FROM PHONGCHAT P, TINNHAN T
        WHERE P.MAPC = T.MAPC AND P.TAIKHOAN = taikhoan
        ORDER BY NGAYGUI DESC
        LIMIT 3;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = 1;
    CREATE TEMPORARY TABLE IF NOT EXISTS TMP_PHONGCHAT (
        TENPC VARCHAR(50)
    );
    OPEN cur;
    TOP3_PC: LOOP
        FETCH cur INTO tenpc;
        IF done THEN
            LEAVE TOP3_PC;
        END IF;
        INSERT INTO TMP_PHONGCHAT(TENPC) VALUES(tenpc);
    END LOOP;
    CLOSE CUR;
    SELECT TENPC
    FROM TMP_PHONGCHAT;
    DROP TEMPORARY TABLE IF EXISTS TMP_PHONGCHAT;
END //

DELIMITER ;
