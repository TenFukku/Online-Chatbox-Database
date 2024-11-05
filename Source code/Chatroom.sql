CREATE DATABASE chatroom;

USE chatroom;

CREATE TABLE NGUOIDUNG (
    TAIKHOAN VARCHAR(20) PRIMARY KEY NOT NULL,
    MATKHAU VARCHAR(500) NOT NULL,
    TENND VARCHAR(50) NOT NULL,
    EMAIL VARCHAR(255) NOT NULL,
    SDT CHAR(10) NOT NULL,
    TTTRUCTUYEN BOOLEAN NOT NULL,
    NGAYTAO DATETIME DEFAULT CURRENT_TIMESTAMP,
    NGAYSUA DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE HOSO (
	TAIKHOAN VARCHAR(20) PRIMARY KEY,
    FOREIGN KEY (TAIKHOAN) REFERENCES NGUOIDUNG (TAIKHOAN),
    MOTA TEXT,
    HINHDD VARCHAR(255),
    ONLINE_CUOI DATETIME NOT NULL
);

CREATE TABLE PHONGCHAT (
	MAPC INT PRIMARY KEY AUTO_INCREMENT,
    TENPC VARCHAR(50) NOT NULL,
    MATKHAU VARCHAR(20),
    NGAYTAO DATETIME DEFAULT CURRENT_TIMESTAMP
);

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
	MATB VARCHAR(10) PRIMARY KEY NOT NULL,
    TAIKHOAN VARCHAR(20) NOT NULL,
    FOREIGN KEY (TAIKHOAN) REFERENCES NGUOIDUNG (TAIKHOAN),
    NOIDUNG TEXT NOT NULL,
    NGAYNHAN DATETIME NOT NULL
);

#Ràng buộc cho thuộc tính TAIKHOAN của NGUOIDUNG để tráng SQL Injection
ALTER TABLE NGUOIDUNG
ADD CONSTRAINT username_format CHECK (TAIKHOAN REGEXP '^[a-zA-Z0-9]+$');

#Ràng buộc cho thuộc tính EMAIL của NGUOIDUNG
ALTER TABLE NGUOIDUNG
ADD CONSTRAINT email_format CHECK (EMAIL LIKE '%@%.%');

#Stored Procedure in danh sách phòng chat mà một người dùng đã tham gia
DELIMITER //
CREATE PROCEDURE In_PhongChat_Tu_NguoiDung(IN taikhoan INT)
BEGIN
    SELECT P.MAPC, TENPC
    FROM PHONGCHAT P
    INNER JOIN ND_PC N ON P.MAPC = N.MAPC
    WHERE N.TAIKHOAN = taikhoan;
END //
DELIMITER ;

#Stored Procedure đếm số lượng người dùng trong phòng chat
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

#Stored Procedure đánh dấu một tin nhắn là đã xem cho một người dùng cụ thể
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

#Stored Procedure tìm kiếm tin nhắn chứa một từ khóa cụ thể
DELIMITER //
CREATE PROCEDURE TimKiem_TinNhan_Bang_TuKhoa(IN keyword TEXT)
BEGIN
    SELECT *
    FROM TINNHAN
    WHERE NOIDUNG LIKE CONCAT('%', keyword, '%');
END //
DELIMITER ;

#Stored Procedure xoá phòng chat thì xóa luôn tin nhắn và người dùng tham gia
DELIMITER //
CREATE PROCEDURE Xoa_PhongChat(IN mapc INT)
BEGIN
    DELETE FROM TINNHAN WHERE MAPC = mapc;
    DELETE FROM ND_PC WHERE MAPC = mapc;
    DELETE FROM PHONGCHAT WHERE MAPC = mapc;
END //
DELIMITER ;

#Trigger ngăn mật khẩu người dùng dưới 8 ký tự
DELIMITER //
CREATE TRIGGER MatKhau_NguoiDung_BeforeInsert
BEFORE INSERT ON NGUOIDUNG
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.MATKHAU) < 8 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mật khẩu phải có ít nhất 8 ký tự';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER MatKhau_NguoiDung_BeforeUpdate
BEFORE UPDATE ON NGUOIDUNG
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.MATKHAU) < 8 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mật khẩu phải có ít nhất 8 ký tự';
    END IF;
END//
DELIMITER ;

#Trigger ngăn tên của các phòng chat không được trùng nhau
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

#Trigger ngăn user không có quyền quản trị viên xóa phòng chat
DELIMITER //
CREATE TRIGGER PhongChat_BeforeDelete
BEFORE DELETE ON PHONGCHAT
FOR EACH ROW
BEGIN
    DECLARE adminCheck INT;
    SELECT COUNT(*) INTO adminCheck
    FROM ND_PC
    WHERE MAPC = OLD.MAPC AND QUYEN = 'Quản trị viên';
    IF adminCheck = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không được phép xóa phòng chat khi không có quyền Quản trị viên';
    END IF;
END //
DELIMITER ;

#Function trả về số lượng tổng tin nhắn trong một phòng chat
DELIMITER //
CREATE FUNCTION SoLuong_TinNhan_Trong_PhongChat(mapc INT) RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN 
    DECLARE messageCount INT;
    SELECT COUNT(*) INTO messageCount
    FROM TINNHAN
    WHERE MAPC = mapc;
    RETURN messageCount;
END //
DELIMITER ;

#Function cập nhật trạng thái người dùng
DELIMITER //
CREATE FUNCTION CapNhat_TrangThai_NguoiDung(taikhoan INT) RETURNS INT
DETERMINISTIC
READS SQL DATA
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

#Cursor đếm số lượng tin nhắn chưa đọc của một người dùng 
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

#Cursor truy vấn 3 phòng chat mà người dùng(được nhập vào) chat nhiều nhất
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

#Cursor truy vấn 3 phòng chat mà người dùng(được nhập vào) chat gần nhất
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

#Tạo role
CREATE ROLE 'manager_role';
CREATE ROLE 'roomlead_role';
CREATE ROLE 'roommember_role';

#Tạo Manager user và giao quyền manager_role
CREATE USER 'manager_user'@'localhost' IDENTIFIED BY 'manager';
GRANT 'manager_role' TO 'manager_user'@'localhost';
SET DEFAULT ROLE 'manager_role' TO 'manager_user'@'localhost';

#Tạo Roomlead user và giao quyền roomlead_role
CREATE USER 'roomlead_user'@'localhost' IDENTIFIED BY 'roomlead';
GRANT 'roomlead_role' TO 'roomlead_user'@'localhost';
SET DEFAULT ROLE 'roomlead_role' TO 'roomlead_user'@'localhost';

#Tạo Roommember user và giao quyền roommember_role
CREATE USER 'roommember_user'@'localhost' IDENTIFIED BY 'roommember';
GRANT 'roommember_role' TO 'roommember_user'@'localhost';
SET DEFAULT ROLE 'roommember_role' TO 'roommember_user'@'localhost';

#Phân quyền cho manager_role
GRANT SELECT, INSERT, DELETE, UPDATE ON NGUOIDUNG TO manager_role WITH GRANT OPTION;
GRANT SELECT, INSERT, DELETE, UPDATE ON HOSO TO manager_role WITH GRANT OPTION;
GRANT SELECT, INSERT, DELETE, UPDATE ON PHONGCHAT TO manager_role WITH GRANT OPTION;
GRANT SELECT, INSERT, DELETE, UPDATE ON ND_PC TO manager_role WITH GRANT OPTION;
GRANT SELECT, INSERT, DELETE, UPDATE ON TINNHAN TO manager_role WITH GRANT OPTION;
GRANT SELECT, INSERT, DELETE, UPDATE ON THONGBAO TO manager_role WITH GRANT OPTION;

GRANT EXECUTE ON PROCEDURE In_PhongChat_Tu_NguoiDung TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE Dem_NguoiDung_Trong_PhongChat TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE DanhDau_TinNhan_DaXem_Tu_NguoiDung TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE TimKiem_TinNhan_Bang_TuKhoa TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE Xoa_PhongChat TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE SoLuong_TinNhan_ChuaDoc_Tu_NguoiDung TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE Top3_PhongChat_NguoiDung_Nhap_NhieuNhat TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE Top3_PhongChat_NguoiDung_Nhap_GanNhat TO roomlead_role WITH GRANT OPTION;

GRANT EXECUTE ON FUNCTION SoLuong_TinNhan_Trong_PhongChat TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION KiemTra_TrangThai_NguoiDung TO roomlead_role WITH GRANT OPTION;

#Phân quyền cho roomlead_role
GRANT SELECT ON NGUOIDUNG TO roomlead_role WITH GRANT OPTION;
GRANT SELECT ON HOSO TO roomlead_role WITH GRANT OPTION;
GRANT SELECT ON PHONGCHAT TO roomlead_role WITH GRANT OPTION;
GRANT SELECT, INSERT, DELETE, UPDATE ON ND_PC TO roomlead_role WITH GRANT OPTION;
GRANT SELECT, INSERT, DELETE ON TINNHAN TO roomlead_role WITH GRANT OPTION;
GRANT SELECT, INSERT ON THONGBAO TO roomlead_role WITH GRANT OPTION;

GRANT EXECUTE ON PROCEDURE Dem_NguoiDung_Trong_PhongChat TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE DanhDau_TinNhan_DaXem_Tu_NguoiDung TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE TimKiem_TinNhan_bang_TuKhoa TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE Xoa_PhongChat TO roomlead_role WITH GRANT OPTION;

GRANT EXECUTE ON FUNCTION SoLuong_TinNhan_Trong_PhongChat TO roomlead_role WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION CapNhat_TrangThai_NguoiDung TO roomlead_role WITH GRANT OPTION;

#Phân quyền cho roommember_role

GRANT SELECT ON NGUOIDUNG TO roommember_role WITH GRANT OPTION;
GRANT SELECT ON HOSO TO roommember_role WITH GRANT OPTION;
GRANT SELECT ON PHONGCHAT TO roommember_role WITH GRANT OPTION;
GRANT SELECT ON ND_PC TO roommember_role WITH GRANT OPTION;
GRANT SELECT ON TINNHAN TO roommember_role WITH GRANT OPTION;
GRANT SELECT ON THONGBAO TO roommember_role WITH GRANT OPTION;

GRANT EXECUTE ON PROCEDURE Dem_NguoiDung_Trong_PhongChat TO roommember_role WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE TimKiem_TinNhan_bang_TuKhoa TO roommember_role WITH GRANT OPTION;

GRANT EXECUTE ON FUNCTION SoLuong_TinNhan_Trong_PhongChat TO roommember_role WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION CapNhat_TrangThai_NguoiDung TO roommember_role WITH GRANT OPTION;

#View ẩn đi dữ liệu nhạy cảm của người dùng bao gồm email, số điện thoại, mật khẩu
CREATE VIEW IN_TTND
AS
	SELECT TAIKHOAN, TENND
	FROM NGUOIDUNG;

SELECT * FROM IN_TTND; 

#View để xem hồ sơ của người dùng
CREATE VIEW IN_HSND
AS
	SELECT *
	FROM HOSO;

SELECT * FROM IN_HSND;

#View để in ra nội dung tin nhắn
CREATE VIEW IN_TN
AS
	SELECT MATN, MAPC, NOIDUNG
	FROM TINNHAN;

SELECT * FROM IN_TN;