USE master;
GO

-- Cấu hình cơ sở dữ liệu về SINGLE_USER để ngắt toàn bộ các kết nối đang hoạt động
IF EXISTS (SELECT 1 FROM sys.databases WHERE name='QuanLyBenhVien')
BEGIN
    ALTER DATABASE QuanLyBenhVien SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyBenhVien;
END

GO
CREATE DATABASE QuanLyBenhVien;
GO

USE QuanLyBenhVien;
GO

/* ======================================== PHẦN TẠO BẢNG ======================================== */

-- 1. Bảng BENHNHAN (Độc lập)
CREATE TABLE BENHNHAN(
    MABN VARCHAR(10) PRIMARY KEY,
    HOTEN NVARCHAR(100) NOT NULL,
    NGAYSINH DATE NOT NULL,
    GIOITINH NVARCHAR(10),
    DIACHI NVARCHAR(255),
    SOBHYT CHAR(10) UNIQUE,
    SDT VARCHAR(20),
    EMAIL VARCHAR(100),
    CCCD CHAR(16) UNIQUE,
    NGAYNHAPHS DATE,
    NGUOITHANLIENHE NVARCHAR(100),
    SDTNGUOITHAN VARCHAR(20)
);

-- 2. Bảng THUOC (Độc lập)
CREATE TABLE THUOC(
    MATHUOC INT IDENTITY(1,1) PRIMARY KEY,
    TENTHUOC NVARCHAR(100) NOT NULL,
    DONVI NVARCHAR(20),
    GIA DECIMAL(18,2) NOT NULL DEFAULT 0,
    HAMLUONG NVARCHAR(100),
    HOATCHAT NVARCHAR(255),
    HANSUDUNG DATE,
    SOLUONGTON INT,
    TRANGTHAI NVARCHAR(20)
);

-- 3. Bảng LOAIPHONG 
CREATE TABLE LOAIPHONG (
    MALOAIPHONG VARCHAR(10) PRIMARY KEY,
    TENLOAIPHONG NVARCHAR(100) NOT NULL,
    MOTA NVARCHAR(MAX),
    GIACOBAN DECIMAL(18, 2) NOT NULL DEFAULT 0 
);

-- 4. Bảng KHOA 
CREATE TABLE KHOA (
    MAKHOA VARCHAR(10) NOT NULL,
    TENKHOA NVARCHAR(100) NOT NULL,
    VITRI NVARCHAR(100),
    SODIENTHOAI VARCHAR(15),
    TRUONGKHOA VARCHAR(10),
    NGAYTHANHLAP DATE,
    EMAILKHOA VARCHAR(50),
    GHICHU NVARCHAR(50),
    CONSTRAINT PK_KHOA PRIMARY KEY (MAKHOA)
);

-- 5. Bảng NHANVIEN (Tham chiếu đến KHOA)
CREATE TABLE NHANVIEN (
    MANV VARCHAR(10) NOT NULL,
    HOTEN NVARCHAR(100) NOT NULL,
    NGAYSINH DATE,
    GIOITINH NVARCHAR(10),
    DIACHI NVARCHAR(200),
    SODT VARCHAR(15),
    MAKHOA VARCHAR(10), -- Sửa lại kiểu VARCHAR(10) đồng bộ với bảng KHOA
    CHUCVU NVARCHAR(50),    
    EMAIL VARCHAR(50),
    NGAYVAOLAM DATE,
    BANGCAP VARCHAR(50),
    CHUYENMON VARCHAR(50),
    TRANGTHAI NVARCHAR(50),
    CONSTRAINT PK_NV PRIMARY KEY (MANV),
    CONSTRAINT FK_NV_KHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)
);


ALTER TABLE KHOA
ADD CONSTRAINT FK_KHOA_TRUONGKHOA FOREIGN KEY (TRUONGKHOA) REFERENCES NHANVIEN(MANV);

-- 6. Bảng PHONGBENH (Tham chiếu đến KHOA và LOAIPHONG)
CREATE TABLE PHONGBENH (
    MAPHONG INT IDENTITY(1,1) NOT NULL,
    TENPHONG NVARCHAR(100),
    MALOAIPHONG VARCHAR(10),
    MAKHOA VARCHAR(10),
    SUCCHUA INT,
    GIAPHONG DECIMAL(10,2),
    TRANGTHAI NVARCHAR(20),
    SOGIUONGTRONG INT,
    GHICHU NVARCHAR(50),
    CONSTRAINT PK_PB PRIMARY KEY (MAPHONG),
    CONSTRAINT FK_PB_KHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA),
    CONSTRAINT FK_PB_LOAIPHONG FOREIGN KEY (MALOAIPHONG) REFERENCES LOAIPHONG(MALOAIPHONG)
);

-- 7. Bảng DIEUTRINOITRU (Tham chiếu đến BENHNHAN, PHONGBENH, NHANVIEN)
CREATE TABLE DIEUTRINOITRU (
    MANOITRU VARCHAR(10) PRIMARY KEY,
    MABN VARCHAR(10) NOT NULL,
    MABACSI VARCHAR(10),
    MAPHONG INT, 
    NGAYNHAPVIEN DATETIME NOT NULL,
    NGAYXUATVIEN DATETIME,
    LYDONHAPVIEN NVARCHAR(MAX) NOT NULL,
    TINHTRANGRAVIEN NVARCHAR(255),
    CONSTRAINT FK_DTNT_BENHNHAN FOREIGN KEY (MABN) REFERENCES BENHNHAN(MABN),
    CONSTRAINT FK_DTNT_PHONGBENH FOREIGN KEY (MAPHONG) REFERENCES PHONGBENH(MAPHONG),
    CONSTRAINT FK_DTNT_BACSI FOREIGN KEY (MABACSI) REFERENCES NHANVIEN(MANV)
);

-- 8. Bảng HOSO (Tham chiếu đến DIEUTRINOITRU, BENHNHAN, NHANVIEN)
CREATE TABLE HOSO (
    MAHS VARCHAR(10) PRIMARY KEY,
    MANOITRU VARCHAR(10) NOT NULL,
    MABN VARCHAR(10) NOT NULL,
    MABACSI VARCHAR(10) NOT NULL,
    CHUANDOAN NVARCHAR(MAX) NOT NULL,
    TRIEUCHUNG NVARCHAR(MAX) NOT NULL,
    KETLUAN NVARCHAR(MAX),
    HUONGDIEUTRI NVARCHAR(MAX),
    NGAYKHAM DATETIME NOT NULL,
    TRANGTHAIHOSO NVARCHAR(50),
    CONSTRAINT FK_HOSO_DTNT FOREIGN KEY (MANOITRU) REFERENCES DIEUTRINOITRU(MANOITRU),
    CONSTRAINT FK_HOSO_BENHNHAN FOREIGN KEY (MABN) REFERENCES BENHNHAN(MABN),
    CONSTRAINT FK_HOSO_NHANVIEN FOREIGN KEY (MABACSI) REFERENCES NHANVIEN(MANV)
);

-- 9. Bảng HOADONVIENPHI (Tạo trước bảng THANHTOAN và CHITIETVIENPHI)
CREATE TABLE HOADONVIENPHI (
    MAHOADON INT PRIMARY KEY,
    MABN VARCHAR(10) NOT NULL, 
    NGAYLAP DATETIME,
    TONGTIEN DECIMAL(18, 2) DEFAULT 0,
    TRANGTHAITHANHTOAN NVARCHAR(50), 
    GHICHU NVARCHAR(MAX),
    FOREIGN KEY (MABN) REFERENCES BENHNHAN(MABN)
);

-- 10. Bảng THANHTOAN (Tham chiếu đến HOADONVIENPHI)
CREATE TABLE THANHTOAN (
    MATHANHTOAN VARCHAR(20) PRIMARY KEY,
    MAHOADON INT NOT NULL,
    NGAYTHANHTOAN DATETIME NOT NULL,
    SOTIEN DECIMAL(18,2) NOT NULL,
    PHUONGTHUC NVARCHAR(50),
    TRANGTHAI NVARCHAR(50),
    CONSTRAINT FK_TT_HDVP FOREIGN KEY (MAHOADON) REFERENCES HOADONVIENPHI(MAHOADON)
);

-- 11. Bảng CHITIETVIENPHI (Tham chiếu đến HOADONVIENPHI)
CREATE TABLE CHITIETVIENPHI (
    MAHOADON INT NOT NULL,
    LOAICHIPHI NVARCHAR(100) NOT NULL,
    SOTIEN DECIMAL(14,2),
    MOTA NVARCHAR(255),
    PRIMARY KEY (MAHOADON, LOAICHIPHI),
    FOREIGN KEY (MAHOADON) REFERENCES HOADONVIENPHI(MAHOADON)
);

-- 12. Bảng DICHVUYTE (Độc lập)
CREATE TABLE DICHVUYTE (
    MADV INT NOT NULL,
    TENDV NVARCHAR(150),
    DONGIA DECIMAL(12,2),
    MOTA NVARCHAR(255),
    TRANGTHAI NVARCHAR(50),
    PRIMARY KEY (MADV)
);

-- 13. Bảng LICHHENKHAM 
CREATE TABLE LICHHENKHAM (
    MALICHHEN INT NOT NULL,
    MABN VARCHAR(10),
    MABACSI VARCHAR(10),
    NGAYHEN DATE,
    GIOHEN TIME,
    TRANGTHAI NVARCHAR(50),
    GHICHU NVARCHAR(255),
    PRIMARY KEY (MALICHHEN),
    FOREIGN KEY (MABN) REFERENCES BENHNHAN(MABN),
    FOREIGN KEY (MABACSI) REFERENCES NHANVIEN(MANV) -- Tham chiếu chính xác đến bảng nhân viên (bác sĩ)
);

-- 14. Bảng LICHSUDIEUTRI (Tham chiếu đến HOSO và NHANVIEN)
CREATE TABLE LICHSUDIEUTRI (
    MALS VARCHAR(10) PRIMARY KEY,
    MAHS VARCHAR(10) NOT NULL,
    NGAYCAPNHAT DATETIME NOT NULL,
    NOIDUNG NVARCHAR(MAX) NOT NULL,
    MANV VARCHAR(10) NOT NULL,
    GHICHU NVARCHAR(255),
    CONSTRAINT FK_LSDT_HOSO FOREIGN KEY (MAHS) REFERENCES HOSO(MAHS),
    CONSTRAINT FK_LSDT_NHANVIEN FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV)
);

-- 15. Bảng CHI TIẾT DỊCH VỤ (Tham chiếu đến HOSO và DICHVUYTE)
CREATE TABLE CHITIETDICHVU (
    MAHS VARCHAR(10) NOT NULL,
    MADV INT NOT NULL,
    NGAYTHUCHIEN DATETIME NOT NULL,
    KETQUA NVARCHAR(MAX),
    CHIPHI DECIMAL(18,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (MAHS, MADV), 
    CONSTRAINT FK_CTDV_HOSO FOREIGN KEY (MAHS) REFERENCES HOSO(MAHS),
    CONSTRAINT FK_CTDV_DICHVU FOREIGN KEY (MADV) REFERENCES DICHVUYTE(MADV)
);

-- 16. Bảng TOA THUỐC (Tham chiếu đến HOSO và THUOC)
CREATE TABLE TOATHUOC (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MATOA VARCHAR(10) NOT NULL,
    MAHS VARCHAR(10) NOT NULL,
    MATHUOC INT NOT NULL,
    SOLUONG INT NOT NULL,
    DONGIA DECIMAL(18,2) NOT NULL,
    THANHTIEN DECIMAL(18,2),
    LIEULUONG NVARCHAR(100) NOT NULL,
    CACHDUNG NVARCHAR(255),
    GHICHU NVARCHAR(MAX),
    CONSTRAINT FK_TOATHUOC_HOSO FOREIGN KEY (MAHS) REFERENCES HOSO(MAHS),
    CONSTRAINT FK_TOATHUOC_THUOC FOREIGN KEY (MATHUOC) REFERENCES THUOC(MATHUOC)
);
/*     ==============================Nhét dữ liệu ========================================		*/
use QuanLyBenhVien;
INSERT INTO BENHNHAN (MABN, HOTEN, NGAYSINH, GIOITINH, DIACHI, SOBHYT, SDT, EMAIL, CCCD, NGAYNHAPHS, NGUOITHANLIENHE, SDTNGUOITHAN) VALUES
('BN001', N'Nguyễn Văn An', '1985-05-12', N'Nam', N'123 Đường Lê Lợi, Quận 1, TP. HCM', 'GD47901001', '0905123456', 'an.nguyen@gmail.com', '031085000123', '2026-01-10', N'Nguyễn Văn Bình (Bố)', '0905123457'),
('BN002', N'Trần Thị Bình', '1990-09-23', N'Nữ', N'456 Đường Nguyễn Trãi, Thanh Xuân, Hà Nội', 'DN47901002', '0913987654', 'binh.tran@yahoo.com', '001090000456', '2026-01-15', N'Trần Anh Tuấn (Chồng)', '0913987655'),
('BN003', N'Lê Hoàng Cường', '1978-02-14', N'Nam', N'78 Đường Hùng Vương, Hải Châu, Đà Nẵng', 'HN47901003', '0935112233', 'cuong.le@hotmail.com', '048078000789', '2026-01-20', N'Lê Thị Dung (Vợ)', '0935112234'),
('BN004', N'Phạm Thị Diễm', '2002-11-05', N'Nữ', N'12 Lô C, Chung cư Ngô Gia Tự, Quận 10, TP. HCM', 'DK47901004', '0944556677', 'diem.pham@outlook.com', '079002000111', '2026-02-01', N'Phạm Văn Em (Bố)', '0944556678'),
('BN005', N'Hoàng Văn Giang', '1965-07-30', N'Nam', N'89 Đường Trần Hưng Đạo, Hoàn Kiếm, Hà Nội', 'HT47901005', '0988776655', 'giang.hoang@gmail.com', '001065000222', '2026-02-05', N'Hoàng Lệ Hằng (Con gái)', '0988776654'),
('BN006', N'Phan Thị Hương', '1995-04-18', N'Nữ', N'234 Đường Điện Biên Phủ, Thanh Khê, Đà Nẵng', 'GD47901006', '0977112244', 'huong.phan@gmail.com', '048095000333', '2026-02-10', N'Nguyễn Quốc Khánh (Chồng)', '0977112245'),
('BN007', N'Vũ Minh Khang', '2015-08-25', N'Nam', N'56 Đường Cách Mạng Tháng 8, Quận 3, TP. HCM', 'TE47901007', '0966334455', 'khang.vu@gmail.com', '079115000444', '2026-02-15', N'Vũ Đình Lâm (Bố)', '0966334456'),
('BN008', N'Đỗ Thị Lan', '1958-12-03', N'Nữ', N'101 Đường Kim Mã, Ba Đình, Hà Nội', 'HT47901008', '0912345678', 'lan.do@yahoo.com', '001058000555', '2026-02-20', N'Lê Văn Minh (Con trai)', '0912345679'),
('BN009', N'Bùi Văn Nam', '1988-10-10', N'Nam', N'12 Đường 30/4, Hòa Cường Bắc, Đà Nẵng', 'GD47901009', '0903998877', 'nam.bui@gmail.com', '048088000666', '2026-03-01', N'Bùi Thị Nga (Chị gái)', '0903998878'),
('BN010', N'Ngô Thị Oanh', '1993-01-27', N'Nữ', N'345 Đường Võ Văn Kiệt, Quận 5, TP. HCM', 'DN47901010', '0922889900', 'oanh.ngo@gmail.com', '079093000777', '2026-03-05', N'Ngô Văn Phát (Bố)', '0922889901'),
('BN011', N'Dương Văn Phúc', '1972-06-14', N'Nam', N'67 Đường Giải Phóng, Hai Bà Trưng, Hà Nội', 'GD47901011', '0955112299', 'phuc.duong@gmail.com', '001072000888', '2026-03-10', N'Dương Thị Quỳnh (Vợ)', '0955112298'),
('BN012', N'Lý Thị Sơn', '1961-03-09', N'Nữ', N'78 Đường Lê Duẩn, Hải Châu, Đà Nẵng', 'HT47901012', '0981223344', 'son.ly@gmail.com', '048061000999', '2026-03-15', N'Trần Văn Tài (Con trai)', '0981223345'),
('BN013', N'Đặng Văn Thanh', '1982-07-22', N'Nam', N'15 Đường Nguyễn Chí Thanh, Quận 5, TP. HCM', 'GD47901013', '0915667788', 'thanh.dang@gmail.com', '079082000101', '2026-03-20', N'Đặng Thị Uyên (Em gái)', '0915667789'),
('BN014', N'Mai Thị Vân', '1998-05-17', N'Nữ', N'22 Đường Láng, Đống Đa, Hà Nội', 'DN47901014', '0933778899', 'van.mai@gmail.com', '001098000202', '2026-03-25', N'Mai Văn Xuân (Bố)', '0933778890'),
('BN015', N'Trịnh Xuân Hải', '1991-12-11', N'Nam', N'90 Đường Trường Chinh, Cẩm Lệ, Đà Nẵng', 'GD47901015', '0944889900', 'hai.trinh@gmail.com', '048091000303', '2026-04-01', N'Trịnh Thị Yên (Mẹ)', '0944889901'),
('BN016', N'Lâm Thị Khánh', '2000-02-28', N'Nữ', N'56 Đường Hòa Bình, Quận Tân Phú, TP. HCM', 'DK47901016', '0977223355', 'khanh.lam@gmail.com', '079100000404', '2026-04-05', N'Lâm Văn Long (Anh trai)', '0977223356'),
('BN017', N'Vương Đình Phong', '1975-10-15', N'Nam', N'142 Đường Nguyễn Văn Cừ, Long Biên, Hà Nội', 'GD47901017', '0966445566', 'phong.vuong@gmail.com', '001075000505', '2026-04-10', N'Vương Thị Mai (Vợ)', '0966445567'),
('BN018', N'Nguyễn Thúy Kiều', '1994-08-08', N'Nữ', N'88 Đường Núi Thành, Hải Châu, Đà Nẵng', 'DN47901018', '0905888999', 'kieu.nguyen@gmail.com', '048094000606', '2026-04-15', N'Nguyễn Văn Trọng (Chồng)', '0905888990'),
('BN019', N'Cao Minh Triết', '2010-04-04', N'Nam', N'213 Đường Cộng Hòa, Quận Tân Bình, TP. HCM', 'TE47901019', '0931223322', 'triet.cao@gmail.com', '079110000707', '2026-04-20', N'Cao Minh Hùng (Bố)', '0931223323'),
('BN020', N'Tiêu Thị Trâm', '1968-11-19', N'Nữ', N'77 Phố Huế, Hai Bà Trưng, Hà Nội', 'HT47901020', '0985445544', 'tram.tieu@gmail.com', '001068000808', '2026-04-25', N'Tiêu Văn Minh (Em trai)', '0985445545');

INSERT INTO THUOC (TENTHUOC, DONVI, GIA, HAMLUONG, HOATCHAT, HANSUDUNG, SOLUONGTON, TRANGTHAI) VALUES
(N'Paracetamol', N'Viên', 1500.00, N'500mg', N'Paracetamol', '2028-12-31', 5000, N'Còn hàng'),
(N'Amoxicillin', N'Viên', 3500.00, N'500mg', N'Amoxicillin trihydrate', '2027-06-30', 2500, N'Còn hàng'),
(N'Ibuprofen', N'Viên', 2000.00, N'400mg', N'Ibuprofen', '2027-09-15', 3000, N'Còn hàng'),
(N'Gliclazide', N'Viên', 4500.00, N'80mg', N'Gliclazide', '2028-03-20', 1500, N'Còn hàng'),
(N'Metformin', N'Viên', 2500.00, N'850mg', N'Metformin hydrochloride', '2028-05-10', 4000, N'Còn hàng'),
(N'Amlodipine', N'Viên', 3000.00, N'5mg', N'Amlodipine besylate', '2027-11-25', 3500, N'Còn hàng'),
(N'Salbutamol', N'Chai', 85000.00, N'100mcg/liều', N'Salbutamol sulfate', '2027-08-18', 200, N'Còn hàng'),
(N'Omeprazole', N'Viên', 1800.00, N'20mg', N'Omeprazole', '2028-01-15', 6000, N'Còn hàng'),
(N'Loratadine', N'Viên', 1200.00, N'10mg', N'Loratadine', '2027-10-05', 4500, N'Còn hàng'),
(N'Atorvastatin', N'Viên', 8000.00, N'10mg', N'Atorvastatin calcium', '2028-04-12', 1800, N'Còn hàng'),
(N'Augmentin', N'Viên', 15000.00, N'1g', N'Amoxicillin + Clavulanic acid', '2027-05-20', 800, N'Còn hàng'),
(N'Panadol Extra', N'Vỉ', 12000.00, N'500mg/65mg', N'Paracetamol + Caffeine', '2028-09-30', 1200, N'Còn hàng'),
(N'Decolgen Forte', N'Viên', 1500.00, N'500mg/10mg/2mg', N'Paracetamol + Phenylephrine + Chlorpheniramine', '2027-12-15', 5000, N'Còn hàng'),
(N'Ceftriaxone', N'Lọ', 45000.00, N'1g', N'Ceftriaxone sodium', '2027-04-30', 150, N'Hạn dùng ngắn'),
(N'Methylprednisolone', N'Viên', 4000.00, N'16mg', N'Methylprednisolone', '2028-02-28', 2200, N'Còn hàng'),
(N'Aspirin pH8', N'Viên', 1000.00, N'81mg', N'Acetylsalicylic acid', '2027-07-10', 3000, N'Còn hàng'),
(N'Berberin', N'Lọ', 15000.00, N'10mg', N'Berberin chloride', '2029-01-01', 1000, N'Còn hàng'),
(N'Smecta', N'Gói', 5500.00, N'3g', N'Dioctahedral smectite', '2028-08-22', 2000, N'Còn hàng'),
(N'Efferalgan', N'Viên sủi', 4000.00, N'500mg', N'Paracetamol', '2028-06-14', 1800, N'Còn hàng'),
(N'Vitamin C', N'Viên sủi', 3000.00, N'1000mg', N'Acid ascorbic', '2027-12-31', 2500, N'Còn hàng');

INSERT INTO LOAIPHONG (MALOAIPHONG, TENLOAIPHONG, MOTA, GIACOBAN) VALUES
('LP001', N'Phòng Thường 4 Giường', N'Phòng bệnh tiêu chuẩn dành cho 4 bệnh nhân, trang bị quạt và tủ đồ cá nhân.', 150000.00),
('LP002', N'Phòng Thường 2 Giường', N'Phòng bán tư nhân dành cho 2 bệnh nhân, trang bị điều hòa và tủ lạnh nhỏ.', 300000.00),
('LP003', N'Phòng Đơn Tiêu Chuẩn', N'Phòng dịch vụ 1 giường dành riêng cho 1 bệnh nhân, có nhà vệ sinh khép kín.', 600000.00),
('LP004', N'Phòng VIP 1', N'Phòng dịch vụ cao cấp, đầy đủ tiện nghi: tivi, tủ lạnh, sofa cho người nhà.', 1200000.00),
('LP005', N'Phòng Tổng Thống (Presidential Suite)', N'Phòng bệnh đặc biệt siêu sang, có phòng khách riêng cho người thân và chế độ chăm sóc 24/7.', 3500000.00),
('LP006', N'Phòng Cấp Cứu Thường (ER)', N'Phòng tiếp nhận bệnh nhân cấp cứu ban đầu, trang bị máy theo dõi cơ bản.', 250000.00),
('LP007', N'Phòng Hồi Sức Tích Cực (ICU)', N'Phòng chăm sóc đặc biệt cho bệnh nhân nặng, đầy đủ máy thở và thiết bị hỗ trợ sinh tồn.', 1500000.00),
('LP008', N'Phòng Cách Ly Áp Lực Âm', N'Phòng đặc biệt dành cho bệnh nhân mắc bệnh truyền nhiễm nguy hiểm, tránh phát tán virus.', 2000000.00),
('LP009', N'Phòng Hậu Phẫu Tiêu Chuẩn', N'Phòng theo dõi bệnh nhân ngay sau khi mổ trước khi chuyển về khoa điều trị.', 400000.00),
('LP010', N'Phòng Hậu Phẫu VIP', N'Phòng hồi sức sau mổ cao cấp, yên tĩnh, riêng tư và có y tá túc trực trực tiếp.', 1500000.00),
('LP011', N'Phòng Chăm Sóc Sơ Sinh Đặc Biệt (NICU)', N'Phòng vô trùng trang bị lồng ấp và máy sưởi cho trẻ sinh non hoặc cần chăm sóc đặc biệt.', 800000.00),
('LP012', N'Phòng Sản Dịch Vụ Gia Đình', N'Phòng sinh gia đình cho phép chồng/người thân cùng vào phòng sinh và lưu viện.', 1800000.00),
('LP013', N'Phòng Chạy Thận Nhân Tạo', N'Phòng chuyên dụng trang bị hệ thống máy lọc máu và lọc thận chu kỳ.', 500000.00),
('LP014', N'Phòng Hóa Trị Liệu Trong Ngày', N'Phòng dịch vụ phục vụ bệnh nhân đến truyền hóa chất, hóa trị rồi về trong ngày.', 350000.00),
('LP015', N'Phòng Vật Lý Trị Liệu - Phục Hồi', N'Phòng lưu bệnh kết hợp trang thiết bị tập luyện phục hồi chức năng sau tai biến/chấn thương.', 300000.00),
('LP016', N'Phòng Cách Ly Thường', N'Phòng cách ly tiêu chuẩn cho các ca nghi nhiễm khuẩn thông thường.', 500000.00),
('LP017', N'Phòng Chăm Sóc Giảm Nhẹ', N'Phòng bệnh yên tĩnh dành cho bệnh nhân giai đoạn cuối, tối ưu hóa sự thoải mái và tinh thần.', 450000.00),
('LP018', N'Phòng Đơn Tiết Kiệm (Không Điều Hòa)', N'Phòng dịch vụ 1 giường giá rẻ, trang bị quạt điện thông thoáng tự nhiên.', 350000.00),
('LP019', N'Phòng VIP 2 (Double Bed VIP)', N'Phòng VIP trang bị giường đôi lớn, hỗ trợ người nhà ở lại chăm sóc thuận tiện nhất.', 1600000.00),
('LP020', N'Phòng Chẩn Đoán Hình Ảnh Lưu Trữ', N'Phòng lưu bệnh nhân ngắn hạn sau khi thực hiện các thủ thuật gây mê xâm lấn như nội soi.', 200000.00);

INSERT INTO HOADONVIENPHI (MAHOADON, MABN, NGAYLAP, TONGTIEN, TRANGTHAITHANHTOAN, GHICHU) VALUES
(1001, 'BN001', '2026-01-20 10:30:00', 1520000.00, N'Đã thanh toán', N'Hóa đơn điều trị ngoại trú thông thường'),
(1002, 'BN002', '2026-01-25 15:45:00', 8500000.00, N'Đã thanh toán', N'Thanh toán viện phí đợt 1 điều trị nội trú'),
(1003, 'BN003', '2026-02-02 09:15:00', 450000.00, N'Đã thanh toán', N'Khám lâm sàng và xét nghiệm máu'),
(1004, 'BN004', '2026-02-10 11:20:00', 12500000.00, N'Đã thanh toán', N'Trọn gói phẫu thuật ruột thừa'),
(1005, 'BN005', '2026-02-15 16:30:00', 3200000.00, N'Đã thanh toán', N'Điều trị viêm phổi cấp tính'),
(1006, 'BN006', '2026-02-28 08:00:00', 650000.00, N'Đã thanh toán', N'Khám định kỳ tai mũi họng'),
(1007, 'BN007', '2026-03-05 14:10:00', 1800000.00, N'Chưa thanh toán', N'Hóa đơn chờ bảo hiểm duyệt chi trả'),
(1008, 'BN008', '2026-03-12 10:00:00', 5400000.00, N'Đã thanh toán', N'Điều trị nội trú khoa Tim mạch'),
(1009, 'BN009', '2026-03-18 13:50:00', 950000.00, N'Đã thanh toán', N'Chụp MRI khớp gối và thuốc kèm theo'),
(1010, 'BN010', '2026-03-25 11:30:00', 15000000.00, N'Chưa thanh toán', N'Tạm ứng chi phí phẫu thuật chấn thương chỉnh hình'),
(1011, 'BN011', '2026-03-28 17:00:00', 2100000.00, N'Đã thanh toán', N'Khám tổng quát và sàng lọc sức khỏe nâng cao'),
(1012, 'BN012', '2026-04-02 09:45:00', 780000.00, N'Đã thanh toán', N'Nội soi dạ dày tá tràng có gây mê'),
(1013, 'BN013', '2026-04-10 15:20:00', 6200000.00, N'Đã thanh toán', N'Điều trị xuất huyết tiêu hóa nhẹ'),
(1014, 'BN014', '2026-04-15 10:15:00', 1250000.00, N'Đã thanh toán', N'Khám sản phụ khoa dịch vụ'),
(1015, 'BN015', '2026-04-18 14:40:00', 3100000.00, N'Đã thanh toán', N'Vật lý trị liệu phục hồi chức năng sau bó bột'),
(1016, 'BN016', '2026-04-20 16:10:00', 4500000.00, N'Chưa thanh toán', N'Hóa đơn thuốc điều trị ngoại trú dài hạn'),
(1017, 'BN017', '2026-04-22 08:30:00', 13500000.00, N'Đã thanh toán', N'Chi phí nằm viện phòng VIP khoa Nội'),
(1018, 'BN018', '2026-04-25 11:00:00', 920000.00, N'Đã thanh toán', N'Siêu âm tim và điện tâm đồ kiểm tra'),
(1019, 'BN019', '2026-04-28 13:25:00', 500000.00, N'Đã thanh toán', N'Khám nhi khoa và tư vấn dinh dưỡng'),
(1020, 'BN020', '2026-05-02 10:50:00', 8900000.00, N'Chưa thanh toán', N'Viện phí phát sinh điều trị lão khoa thực tế');
