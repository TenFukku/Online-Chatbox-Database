CREATE DATABASE CHATROOM;
USE CHATROOM;
CREATE TABLE NGUOIDUNG (
    TAIKHOAN VARCHAR(20) PRIMARY KEY NOT NULL,
    MATKHAU VARCHAR(500) NOT NULL,
    TENND VARCHAR(50) NOT NULL,
    EMAIL VARCHAR(255) NOT NULL,
    SDT CHAR(10) NOT NULL,
    TTTRUCTUYEN BIT NOT NULL,
    NGAYTAO SMALLDATETIME NOT NULL,
    NGAYSUA SMALLDATETIME NOT NULL
);

CREATE TABLE HOSO (
	TAIKHOAN VARCHAR(20) PRIMARY KEY,
    FOREIGN KEY (TAIKHOAN) REFERENCES NGUOIDUNG (TAIKHOAN),
    MOTA TEXT,
    HINHDD VARCHAR(255),
    ONLINE_CUOI DATETIME NOT NULL
);

CREATE TABLE PHONGCHAT (
	MAPC INT PRIMARY KEY,
    TENPC VARCHAR(50) NOT NULL,
    MATKHAU VARCHAR(20),
    NGAYTAO SMALLDATETIME
);

CREATE TABLE ND_PC (
	TAIKHOAN VARCHAR(20) NOT NULL,
    MAPC INT NOT NULL,
    PRIMARY KEY (TAIKHOAN, MAPC),
    FOREIGN KEY (TAIKHOAN) REFERENCES NGUOIDUNG (TAIKHOAN),
    FOREIGN KEY (MAPC) REFERENCES PHONGCHAT (MAPC),
    QUYEN BIT NOT NULL,
    NGAYTG SMALLDATETIME NOT NULL
);

CREATE TABLE TINNHAN (
	MATN INT PRIMARY KEY NOT NULL,
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
    NGAYNHAN SMALLDATETIME NOT NULL
);

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

#View để in ra mã phòng chat nằm trong  top10 phòng chat có số lượng tin nhắn nhiều nhất 
CREATE VIEW IN_TOP10
AS
	SELECT TOP 10  PC.MAPC,COUNT(TN.MATN) AS SLTINNHAN
	FROM TINNHAN TN JOIN PHONGCHAT PC ON TN.MAPC=PC.MAPC 
	GROUP BY PC.MAPC 
	ORDER BY COUNT(TN.MATN) DESC
SELECT * FROM IN_TN;

#Stored Procedure in danh sách phòng chat mà một người dùng đã tham gia
DELIMITER //
CREATE PROCEDURE In_PhongChat_Tu_NguoiDung @taikhoan INT
AS 
BEGIN
    SELECT P.MAPC, TENPC
    FROM PHONGCHAT P
    INNER JOIN ND_PC N ON P.MAPC = N.MAPC
    WHERE N.TAIKHOAN = @taikhoan;
END //
DELIMITER ;

#Stored Procedure đếm số lượng người dùng trong phòng chat
DELIMITER //

CREATE PROCEDURE Dem_NguoiDung_Trong_PhongChat 
    @mapc INT OUTPUT
AS
BEGIN
    SELECT @mapc = COUNT(*)
    FROM ND_PC
    WHERE MAPC = @mapc;
END; //
DELIMITER ;
#Stored Procedure đánh dấu một tin nhắn là đã xem cho một người dùng cụ thể
DELIMITER //
CREATE PROCEDURE DanhDau_TinNhan_DaXem_Tu_NguoiDung
    @matn INT,
    @taikhoan INT
AS
BEGIN
    UPDATE TINNHAN
    SET TINHTRANG = 'Đã xem'
    WHERE MATN = @matn AND TAIKHOAN = @taikhoan;
END;//
DELIMITER ;

#Stored Procedure xoá phòng chat thì xóa luôn tin nhắn và người dùng tham gia
DELIMITER //
CREATE PROCEDURE Xoa_PhongChat
    @mapc INT
AS
BEGIN
    DELETE FROM TINNHAN 
    WHERE MAPC = @mapc;
    DELETE FROM ND_PC 
    WHERE MAPC = @mapc;
    DELETE FROM PHONGCHAT 
    WHERE MAPC = @mapc;
END; //
DELIMITER ;

--Trigger 
--Cập nhật ngày NGAYSUA trong bảng NGUOIDUNG bất cứ khi nào bản ghi được cập nhật 
CREATE TRIGGER trgUpdateNguoiDung
ON NGUOIDUNG
AFTER UPDATE
AS
BEGIN
    UPDATE NGUOIDUNG
    SET NGAYSUA = GETDATE()
    FROM NGUOIDUNG n
    INNER JOIN inserted i ON n.TAIKHOAN = i.TAIKHOAN
END;
--Tự động chèn bản ghi tương ứng vào bảng HOSO khi người dùng mới được thêm vào bảng NGUOIDUNG 
CREATE TRIGGER trgInsertNguoiDung
ON NGUOIDUNG
AFTER INSERT
AS
BEGIN
    INSERT INTO HOSO (TAIKHOAN, ONLINE_CUOI)
    SELECT TAIKHOAN, GETDATE()
    FROM inserted
END;

--Trigger ngăn chặn việc xóa người dùng nếu vẫn còn liên kết bất kỳ phòng trò chuyện nào trong bảng ND_PC 
CREATE TRIGGER trgDeleteNguoiDung
ON NGUOIDUNG
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN ND_PC n ON d.TAIKHOAN = n.TAIKHOAN
    )
    BEGIN
        RAISERROR ('Cannot delete user because they are associated with a chat room.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM NGUOIDUNG
        WHERE TAIKHOAN IN (SELECT TAIKHOAN FROM deleted);
    END
END;
--Hàm trả về số lượng người đang trực tuyến
CREATE FUNCTION dbo.GetOnlineUserCount()
RETURNS INT
AS
BEGIN
    DECLARE @OnlineUserCount INT;

    SELECT @OnlineUserCount = COUNT(*)
    FROM NGUOIDUNG
    WHERE TTTRUCTUYEN = 1;

    RETURN @OnlineUserCount;
END;

SELECT dbo.GetOnlineUserCount() AS OnlineUserCount;
--Hàm lấy danh sách tên người đang trực tuyến
CREATE FUNCTION dbo.GetOnlineUsers()
RETURNS @OnlineUsers TABLE (
    TAIKHOAN VARCHAR(20),
    TENND VARCHAR(50)
)
AS
BEGIN
    INSERT INTO @OnlineUsers
    SELECT TAIKHOAN, TENND
    FROM NGUOIDUNG
    WHERE TTTRUCTUYEN = 1;

    RETURN;
END;

SELECT * FROM dbo.GetOnlineUsers();
--Hàm lấy số lượng tin nhắn người dùng đã gửi 
CREATE FUNCTION dbo.GetMessageCountForUserInRoom (
    @taikhoan VARCHAR(20),
    @mapc INT
)
RETURNS INT
AS
BEGIN
    DECLARE @MessageCount INT;

    SELECT @MessageCount = COUNT(*)
    FROM TINNHAN
    WHERE TAIKHOAN = @taikhoan AND MAPC = @mapc;

    RETURN @MessageCount;
END;
