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

USE QuanLyBenhVien;
GO

/* ========================================================================================= */
/* 1. THÊM DỮ LIỆU BẢNG KHOA (Tạm thời để TRUONGKHOA = NULL để tránh lỗi tham chiếu vòng)    */
/* ========================================================================================= */
INSERT INTO KHOA (MAKHOA, TENKHOA, VITRI, SODIENTHOAI, TRUONGKHOA, NGAYTHANHLAP, EMAILKHOA, GHICHU) VALUES
('K001', N'Khoa Khám Bệnh', N'Tầng 1 - Tòa nhà A', '0283111111', NULL, '2015-01-01', 'khambenh@bv.vn', N'Khoa tiếp nhận ban đầu'),
('K002', N'Khoa Cấp Cứu', N'Tầng trệt - Tòa nhà A', '0283222222', NULL, '2015-01-01', 'capcuu@bv.vn', N'Trực 24/7'),
('K003', N'Khoa Hồi Sức Tích Cực', N'Tầng 2 - Tòa nhà A', '0283333333', NULL, '2015-06-15', 'icu@bv.vn', N'Dành cho bệnh nhân nặng'),
('K004', N'Khoa Nội Tổng Hợp', N'Tầng 3 - Tòa nhà B', '0283444444', NULL, '2016-02-10', 'noitonghop@bv.vn', N'Điều trị các bệnh nội khoa'),
('K005', N'Khoa Ngoại Tổng Hợp', N'Tầng 4 - Tòa nhà B', '0283555555', NULL, '2016-02-10', 'ngoaitonghop@bv.vn', N'Phẫu thuật và thủ thuật'),
('K006', N'Khoa Phụ Sản', N'Tầng 5 - Tòa nhà B', '0283666666', NULL, '2015-03-20', 'phusan@bv.vn', N'Chăm sóc mẹ và bé'),
('K007', N'Khoa Nhi', N'Tầng 6 - Tòa nhà B', '0283777777', NULL, '2015-04-12', 'nhikhoa@bv.vn', N'Chăm sóc sức khỏe trẻ em'),
('K008', N'Khoa Chấn Thương Chỉnh Hình', N'Tầng 2 - Tòa nhà C', '0283888888', NULL, '2017-08-05', 'chanthuong@bv.vn', N'Phẫu thuật xương khớp'),
('K009', N'Khoa Tim Mạch', N'Tầng 3 - Tòa nhà C', '0283999999', NULL, '2016-11-20', 'timmach@bv.vn', N'Khám và can thiệp tim mạch'),
('K010', N'Khoa Thần Kinh', N'Tầng 4 - Tòa nhà C', '0283101010', NULL, '2018-05-18', 'thankinh@bv.vn', N'Nội thần kinh'),
('K011', N'Khoa Tai Mũi Họng', N'Tầng 1 - Tòa nhà D', '0283121212', NULL, '2015-09-09', 'taimuihong@bv.vn', N'Nội soi và phẫu thuật TMH'),
('K012', N'Khoa Răng Hàm Mặt', N'Tầng 2 - Tòa nhà D', '0283131313', NULL, '2016-10-10', 'ranghammat@bv.vn', N'Nha khoa tổng quát'),
('K013', N'Khoa Mắt', N'Tầng 3 - Tòa nhà D', '0283141414', NULL, '2017-12-12', 'nhankhoa@bv.vn', N'Khám và mổ mắt'),
('K014', N'Khoa Da Liễu', N'Tầng 4 - Tòa nhà D', '0283151515', NULL, '2019-01-20', 'dalieu@bv.vn', N'Điều trị bệnh lý da'),
('K015', N'Khoa Truyền Nhiễm', N'Tòa nhà E (Khu cách ly)', '0283161616', NULL, '2020-02-01', 'truyennhiem@bv.vn', N'Kiểm soát bệnh dịch'),
('K016', N'Khoa Ung Bướu', N'Tầng 1 - Tòa nhà F', '0283171717', NULL, '2019-06-15', 'ungbuou@bv.vn', N'Xạ trị và hóa trị'),
('K017', N'Khoa Chẩn Đoán Hình Ảnh', N'Tầng hầm - Tòa nhà A', '0283181818', NULL, '2015-01-01', 'cdha@bv.vn', N'X-Quang, MRI, Siêu âm'),
('K018', N'Khoa Xét Nghiệm', N'Tầng 2 - Tòa nhà A', '0283191919', NULL, '2015-01-01', 'xetnghiem@bv.vn', N'Huyết học, Sinh hóa'),
('K019', N'Khoa Dược', N'Tầng trệt - Tòa nhà C', '0283202020', NULL, '2015-01-01', 'khoaduoc@bv.vn', N'Quản lý và cấp phát thuốc'),
('K020', N'Khoa Dinh Dưỡng', N'Tầng hầm - Tòa nhà B', '0283212121', NULL, '2018-09-05', 'dinhduong@bv.vn', N'Chăm sóc suất ăn bệnh lý');

/* ========================================================================================= */
/* 2. THÊM DỮ LIỆU BẢNG NHANVIEN                                                             */
/* ========================================================================================= */
INSERT INTO NHANVIEN (MANV, HOTEN, NGAYSINH, GIOITINH, DIACHI, SODT, MAKHOA, CHUCVU, EMAIL, NGAYVAOLAM, BANGCAP, CHUYENMON, TRANGTHAI) VALUES
('NV001', N'Lê Minh Đạt', '1975-08-20', N'Nam', N'Quận 1, TP. HCM', '0901111111', 'K001', N'Trưởng Khoa', 'dat.le@bv.vn', '2015-02-01', N'Tiến sĩ', N'Nội Đa Khoa', N'Đang làm việc'),
('NV002', N'Trần Thanh Sơn', '1980-12-05', N'Nam', N'Quận 3, TP. HCM', '0902222222', 'K002', N'Trưởng Khoa', 'son.tran@bv.vn', '2015-02-15', N'Thạc sĩ', N'Hồi sức cấp cứu', N'Đang làm việc'),
('NV003', N'Phạm Thu Hà', '1982-03-10', N'Nữ', N'Quận 5, TP. HCM', '0903333333', 'K003', N'Trưởng Khoa', 'ha.pham@bv.vn', '2015-07-01', N'Tiến sĩ', N'Gây mê hồi sức', N'Đang làm việc'),
('NV004', N'Nguyễn Hoàng Bách', '1978-11-22', N'Nam', N'Quận 10, TP. HCM', '0904444444', 'K004', N'Trưởng Khoa', 'bach.nguyen@bv.vn', '2016-03-01', N'Tiến sĩ', N'Nội Tổng Quát', N'Đang làm việc'),
('NV005', N'Hoàng Vĩnh Khang', '1974-05-30', N'Nam', N'Tân Bình, TP. HCM', '0905555555', 'K005', N'Trưởng Khoa', 'khang.hoang@bv.vn', '2016-03-15', N'Tiến sĩ', N'Ngoại Tiêu Hóa', N'Đang làm việc'),
('NV006', N'Đinh Mai Phương', '1985-09-15', N'Nữ', N'Gò Vấp, TP. HCM', '0906666666', 'K006', N'Trưởng Khoa', 'phuong.dinh@bv.vn', '2015-04-10', N'Thạc sĩ', N'Sản Phụ Khoa', N'Đang làm việc'),
('NV007', N'Lương Quốc Trí', '1981-02-28', N'Nam', N'Phú Nhuận, TP. HCM', '0907777777', 'K007', N'Trưởng Khoa', 'tri.luong@bv.vn', '2015-05-01', N'Tiến sĩ', N'Nhi Khoa', N'Đang làm việc'),
('NV008', N'Võ Đức Cường', '1979-07-14', N'Nam', N'Bình Thạnh, TP. HCM', '0908888888', 'K008', N'Trưởng Khoa', 'cuong.vo@bv.vn', '2017-09-01', N'BS Chuyên Khoa II', N'Cơ Xương Khớp', N'Đang làm việc'),
('NV009', N'Tạ Đình Phong', '1976-10-09', N'Nam', N'Thủ Đức, TP. HCM', '0909999999', 'K009', N'Trưởng Khoa', 'phong.ta@bv.vn', '2016-12-01', N'Tiến sĩ', N'Nội Tim Mạch', N'Đang làm việc'),
('NV010', N'Trương Mỹ Linh', '1983-12-25', N'Nữ', N'Quận 1, TP. HCM', '0910101010', 'K010', N'Trưởng Khoa', 'linh.truong@bv.vn', '2018-06-01', N'BS Chuyên Khoa II', N'Nội Thần Kinh', N'Đang làm việc'),
('NV011', N'Châu Tấn Phát', '1988-04-18', N'Nam', N'Quận 7, TP. HCM', '0911112222', 'K011', N'Trưởng Khoa', 'phat.chau@bv.vn', '2015-10-01', N'Thạc sĩ', N'Tai Mũi Họng', N'Đang nghỉ phép'),
('NV012', N'Lâm Hữu Nghĩa', '1984-01-20', N'Nam', N'Quận 8, TP. HCM', '0912223333', 'K012', N'Trưởng Khoa', 'nghia.lam@bv.vn', '2016-11-01', N'Tiến sĩ', N'Nha Khoa', N'Đang làm việc'),
('NV013', N'Đặng Phương Nam', '1977-06-12', N'Nam', N'Quận 5, TP. HCM', '0913334444', 'K013', N'Trưởng Khoa', 'nam.dang@bv.vn', '2018-01-01', N'BS Chuyên Khoa II', N'Nhãn Khoa', N'Đang làm việc'),
('NV014', N'Ngô Tố Uyên', '1989-08-08', N'Nữ', N'Tân Phú, TP. HCM', '0914445555', 'K014', N'Trưởng Khoa', 'uyen.ngo@bv.vn', '2019-02-01', N'Thạc sĩ', N'Da Liễu', N'Đang làm việc'),
('NV015', N'Bùi Thanh Tuấn', '1980-03-24', N'Nam', N'Nhà Bè, TP. HCM', '0915556666', 'K015', N'Trưởng Khoa', 'tuan.bui@bv.vn', '2020-03-01', N'BS Chuyên Khoa II', N'Bệnh Nhiệt Đới', N'Đang làm việc'),
('NV016', N'Phan Bích Thủy', '1975-11-30', N'Nữ', N'Quận 1, TP. HCM', '0916667777', 'K016', N'Trưởng Khoa', 'thuy.phan@bv.vn', '2019-07-01', N'Tiến sĩ', N'Ung Bướu', N'Đang làm việc'),
('NV017', N'Kiều Quang Hiếu', '1982-05-05', N'Nam', N'Bình Tân, TP. HCM', '0917778888', 'K017', N'Trưởng Khoa', 'hieu.kieu@bv.vn', '2015-02-01', N'Thạc sĩ', N'CĐHA', N'Đang làm việc'),
('NV018', N'Vũ Bích Ngọc', '1987-09-02', N'Nữ', N'Quận 4, TP. HCM', '0918889999', 'K018', N'Trưởng Khoa', 'ngoc.vu@bv.vn', '2015-02-01', N'Tiến sĩ', N'Sinh hóa lâm sàng', N'Đang làm việc'),
('NV019', N'Đoàn Bảo Châu', '1986-12-12', N'Nữ', N'Quận 2, TP. HCM', '0919990000', 'K019', N'Trưởng Khoa', 'chau.doan@bv.vn', '2015-02-01', N'Dược sĩ CK II', N'Dược Lâm Sàng', N'Đang làm việc'),
('NV020', N'Mạch Tấn Lộc', '1990-07-27', N'Nam', N'Quận 11, TP. HCM', '0920001111', 'K020', N'Trưởng Khoa', 'loc.mach@bv.vn', '2018-10-01', N'Thạc sĩ', N'Dinh dưỡng y khoa', N'Đang làm việc');

/* ========================================================================================= */
/* 3. CẬP NHẬT TRƯỞNG KHOA CHO BẢNG KHOA (Giải quyết khóa ngoại tham chiếu)                  */
/* ========================================================================================= */
UPDATE KHOA SET TRUONGKHOA = 'NV001' WHERE MAKHOA = 'K001';
UPDATE KHOA SET TRUONGKHOA = 'NV002' WHERE MAKHOA = 'K002';
UPDATE KHOA SET TRUONGKHOA = 'NV003' WHERE MAKHOA = 'K003';
UPDATE KHOA SET TRUONGKHOA = 'NV004' WHERE MAKHOA = 'K004';
UPDATE KHOA SET TRUONGKHOA = 'NV005' WHERE MAKHOA = 'K005';
UPDATE KHOA SET TRUONGKHOA = 'NV006' WHERE MAKHOA = 'K006';
UPDATE KHOA SET TRUONGKHOA = 'NV007' WHERE MAKHOA = 'K007';
UPDATE KHOA SET TRUONGKHOA = 'NV008' WHERE MAKHOA = 'K008';
UPDATE KHOA SET TRUONGKHOA = 'NV009' WHERE MAKHOA = 'K009';
UPDATE KHOA SET TRUONGKHOA = 'NV010' WHERE MAKHOA = 'K010';
UPDATE KHOA SET TRUONGKHOA = 'NV011' WHERE MAKHOA = 'K011';
UPDATE KHOA SET TRUONGKHOA = 'NV012' WHERE MAKHOA = 'K012';
UPDATE KHOA SET TRUONGKHOA = 'NV013' WHERE MAKHOA = 'K013';
UPDATE KHOA SET TRUONGKHOA = 'NV014' WHERE MAKHOA = 'K014';
UPDATE KHOA SET TRUONGKHOA = 'NV015' WHERE MAKHOA = 'K015';
UPDATE KHOA SET TRUONGKHOA = 'NV016' WHERE MAKHOA = 'K016';
UPDATE KHOA SET TRUONGKHOA = 'NV017' WHERE MAKHOA = 'K017';
UPDATE KHOA SET TRUONGKHOA = 'NV018' WHERE MAKHOA = 'K018';
UPDATE KHOA SET TRUONGKHOA = 'NV019' WHERE MAKHOA = 'K019';
UPDATE KHOA SET TRUONGKHOA = 'NV020' WHERE MAKHOA = 'K020';

/* ========================================================================================= */
/* 4. THÊM DỮ LIỆU BẢNG PHONGBENH (MAPHONG tự động tăng)                                     */
/* ========================================================================================= */
INSERT INTO PHONGBENH (TENPHONG, MALOAIPHONG, MAKHOA, SUCCHUA, GIAPHONG, TRANGTHAI, SOGIUONGTRONG, GHICHU) VALUES
(N'Phòng Khám 101', 'LP001', 'K001', 4, 150000.00, N'Sẵn sàng', 4, N'Khám hô hấp'),
(N'Cấp Cứu A1', 'LP006', 'K002', 10, 250000.00, N'Đang sử dụng', 2, N'Khu vực đỏ'),
(N'Hồi Sức Tích Cực 1', 'LP007', 'K003', 6, 1500000.00, N'Đang sử dụng', 1, N'Theo dõi monitor 24/7'),
(N'Phòng Nội Tổng Hợp 301', 'LP002', 'K004', 2, 300000.00, N'Sẵn sàng', 2, N'Nam giới'),
(N'Phòng Hậu Phẫu 402', 'LP009', 'K005', 4, 400000.00, N'Đang sử dụng', 1, N'Theo dõi sau mổ'),
(N'Phòng Sanh 501', 'LP012', 'K006', 1, 1800000.00, N'Sẵn sàng', 1, N'Sanh dịch vụ gia đình'),
(N'Phòng Nhi Đồng 601', 'LP003', 'K007', 1, 600000.00, N'Đang sử dụng', 0, N'Dành cho trẻ em dưới 5 tuổi'),
(N'Phòng VIP Chấn Thương', 'LP004', 'K008', 1, 1200000.00, N'Sẵn sàng', 1, N'Tiện nghi cao cấp'),
(N'Phòng Tim Mạch 305', 'LP002', 'K009', 2, 300000.00, N'Bảo trì', 0, N'Đang khử khuẩn định kỳ'),
(N'Phòng Tổng Thống Thần Kinh', 'LP005', 'K010', 1, 3500000.00, N'Sẵn sàng', 1, N'Siêu VIP'),
(N'Phòng Phẫu Thuật TMH', 'LP010', 'K011', 1, 1500000.00, N'Đang sử dụng', 0, N'Hậu phẫu VIP'),
(N'Phòng Khám Nha Khoa', 'LP001', 'K012', 4, 150000.00, N'Sẵn sàng', 3, N'Khu vực ghế răng'),
(N'Phòng Mổ Mắt', 'LP020', 'K013', 2, 200000.00, N'Sẵn sàng', 2, N'Lưu trú sau phẫu thuật Phaco'),
(N'Phòng Da Liễu Đơn', 'LP018', 'K014', 1, 350000.00, N'Sẵn sàng', 1, N'Không điều hòa'),
(N'Phòng Cách Ly Âm', 'LP008', 'K015', 1, 2000000.00, N'Đang sử dụng', 0, N'Cách ly ca nhiễm nCov'),
(N'Phòng Hóa Trị 1', 'LP014', 'K016', 6, 350000.00, N'Sẵn sàng', 4, N'Truyền hóa chất ban ngày'),
(N'Phòng Siêu Âm VIP', 'LP004', 'K017', 1, 1200000.00, N'Sẵn sàng', 1, N'Lưu chờ kết quả CĐHA'),
(N'Phòng Chờ Xét Nghiệm', 'LP001', 'K018', 4, 150000.00, N'Sẵn sàng', 4, N'Lấy máu xét nghiệm'),
(N'Phòng Chăm Sóc Sơ Sinh', 'LP011', 'K006', 5, 800000.00, N'Đang sử dụng', 2, N'Lồng ấp nhi sinh non'),
(N'Phòng Chạy Thận 1', 'LP013', 'K004', 10, 500000.00, N'Sẵn sàng', 5, N'Có 10 máy chạy thận');

/* ========================================================================================= */
/* 5. THÊM DỮ LIỆU BẢNG DICHVUYTE                                                            */
/* ========================================================================================= */
INSERT INTO DICHVUYTE (MADV, TENDV, DONGIA, MOTA, TRANGTHAI) VALUES
(1, N'Khám Lâm Sàng Chung', 150000.00, N'Khám bệnh lý tổng quát bởi bác sĩ chuyên khoa', N'Đang áp dụng'),
(2, N'Khám Chuyên Gia', 500000.00, N'Khám với Phó Giáo Sư, Giáo Sư, Trưởng Khoa', N'Đang áp dụng'),
(3, N'Siêu Âm Ổ Bụng', 250000.00, N'Siêu âm màu 4D kiểm tra các tạng trong ổ bụng', N'Đang áp dụng'),
(4, N'X-Quang Ngực Thẳng', 120000.00, N'Chụp X-quang tim phổi kỹ thuật số', N'Đang áp dụng'),
(5, N'MRI Sọ Não', 2500000.00, N'Chụp cộng hưởng từ sọ não không có thuốc cản từ', N'Đang áp dụng'),
(6, N'CT Scanner 128 Lát Cắt', 1800000.00, N'Chụp cắt lớp vi tính toàn thân', N'Đang áp dụng'),
(7, N'Điện Tâm Đồ (ECG)', 80000.00, N'Ghi điện tim phát hiện loạn nhịp', N'Đang áp dụng'),
(8, N'Nội Soi Dạ Dày', 800000.00, N'Nội soi thực quản, dạ dày, tá tràng không gây mê', N'Đang áp dụng'),
(9, N'Nội Soi Đại Tràng Gây Mê', 2200000.00, N'Nội soi tầm soát ung thư đại trực tràng có tiền mê', N'Đang áp dụng'),
(10, N'Xét Nghiệm Máu Tự Động', 150000.00, N'Phân tích tế bào máu ngoại vi 22 thông số', N'Đang áp dụng'),
(11, N'Sinh Hóa Máu (Glucose, Ure, Creatinin)', 120000.00, N'Đánh giá chức năng gan, thận, đường huyết', N'Đang áp dụng'),
(12, N'Phẫu Thuật Nội Soi Ruột Thừa', 8000000.00, N'Cắt ruột thừa bằng phương pháp nội soi', N'Đang áp dụng'),
(13, N'Tán Sỏi Thận Qua Da', 15000000.00, N'Tán sỏi công nghệ Laser xâm lấn tối thiểu', N'Đang áp dụng'),
(14, N'Nhổ Răng Khôn Mọc Lệch', 1500000.00, N'Tiểu phẫu nhổ răng khôn hàm dưới', N'Đang áp dụng'),
(15, N'Đo Loãng Xương', 300000.00, N'Đo mật độ xương bằng phương pháp DEXA', N'Đang áp dụng'),
(16, N'Lọc Máu Chu Kỳ', 800000.00, N'Chạy thận nhân tạo 1 ca (4 tiếng)', N'Đang áp dụng'),
(17, N'Kéo Dãn Cột Sống', 100000.00, N'Vật lý trị liệu bằng máy kéo dãn', N'Đang áp dụng'),
(18, N'Tầm Soát Ung Thư Vú', 400000.00, N'Chụp Mammography tuyến vú 2 bên', N'Đang áp dụng'),
(19, N'Cấp Cứu Ngưng Tim Phổi', 500000.00, N'Hồi sức tim phổi (CPR) tích cực', N'Đang áp dụng'),
(20, N'Truyền Máu (1 Đơn Vị)', 1200000.00, N'Truyền 250ml khối hồng cầu cùng nhóm', N'Đang áp dụng');

/* ========================================================================================= */
/* 6. THÊM DỮ LIỆU BẢNG CHITIETVIENPHI (MAHOADON đã có sẵn từ 1001 đến 1020)                   */
/* ========================================================================================= */
INSERT INTO CHITIETVIENPHI (MAHOADON, LOAICHIPHI, SOTIEN, MOTA) VALUES
(1001, N'Tiền Khám Bệnh', 150000.00, N'Khám lâm sàng nội khoa'),
(1002, N'Tiền Giường Bệnh', 3500000.00, N'Lưu viện 7 ngày phòng Hậu phẫu'),
(1003, N'Chi Phí Xét Nghiệm', 450000.00, N'Xét nghiệm tổng phân tích tế bào máu'),
(1004, N'Phẫu Thuật Nội Soi', 8000000.00, N'Cắt ruột thừa nội soi'),
(1005, N'Tiền Thuốc Nội Trú', 2500000.00, N'Thuốc kháng sinh và dịch truyền'),
(1006, N'Khám Chuyên Khoa', 150000.00, N'Khám TMH'),
(1007, N'Vật Tư Y Tế', 800000.00, N'Băng gạc, kim tiêm, dây truyền'),
(1008, N'Chẩn Đoán Hình Ảnh', 1200000.00, N'Siêu âm tim và X-Quang ngực'),
(1009, N'Chụp MRI', 2500000.00, N'Cộng hưởng từ khớp gối'),
(1010, N'Tạm Ứng Phẫu Thuật', 15000000.00, N'Đóng trước phẫu thuật kết hợp xương'),
(1011, N'Gói Khám Sức Khỏe', 2100000.00, N'Tầm soát sức khỏe tổng quát nâng cao'),
(1012, N'Tiền Thủ Thuật Nội Soi', 2200000.00, N'Nội soi dạ dày gây mê'),
(1013, N'Truyền Máu', 2400000.00, N'Truyền 2 đơn vị máu'),
(1014, N'Siêu Âm Thai 4D', 400000.00, N'Siêu âm hình thái học thai nhi'),
(1015, N'Vật Lý Trị Liệu', 1500000.00, N'Gói tập phục hồi 10 buổi'),
(1016, N'Thuốc Ngoại Trú (Mạn tính)', 4500000.00, N'Cấp phát thuốc tiểu đường 3 tháng'),
(1017, N'Tiền Giường VIP', 8400000.00, N'Nằm viện phòng VIP 7 ngày'),
(1018, N'Điện Tâm Đồ', 80000.00, N'Đo ECG 12 chuyển đạo'),
(1019, N'Khám Nhi Khoa', 150000.00, N'Tư vấn dinh dưỡng trẻ em'),
(1020, N'Lọc Máu Chu Kỳ', 4000000.00, N'Chi phí chạy thận 5 lần/tháng');

/* ========================================================================================= */
/* 7. THÊM DỮ LIỆU BẢNG LICHHENKHAM                                                          */
/* ========================================================================================= */
INSERT INTO LICHHENKHAM (MALICHHEN, MABN, MABACSI, NGAYHEN, GIOHEN, TRANGTHAI, GHICHU) VALUES
(1, 'BN001', 'NV001', '2026-05-15', '08:30:00', N'Đã xác nhận', N'Tái khám nội khoa định kỳ'),
(2, 'BN002', 'NV006', '2026-05-16', '09:00:00', N'Đã xác nhận', N'Kiểm tra thai kỳ tuần 28'),
(3, 'BN003', 'NV008', '2026-05-17', '14:00:00', N'Đã xác nhận', N'Tái khám chấn thương khớp gối'),
(4, 'BN004', 'NV005', '2026-05-18', '10:15:00', N'Đang chờ khám', N'Tái khám sau mổ ruột thừa'),
(5, 'BN005', 'NV011', '2026-05-19', '15:30:00', N'Đã hủy', N'Bệnh nhân bận việc đột xuất'),
(6, 'BN006', 'NV014', '2026-05-20', '08:00:00', N'Đã xác nhận', N'Khám mề đay, dị ứng da'),
(7, 'BN007', 'NV007', '2026-05-21', '09:45:00', N'Đã xác nhận', N'Tiêm ngừa vắc-xin nhi'),
(8, 'BN008', 'NV009', '2026-05-22', '13:30:00', N'Đã xác nhận', N'Tái khám huyết áp và tim mạch'),
(9, 'BN009', 'NV013', '2026-05-23', '10:00:00', N'Đã xác nhận', N'Đo độ cận thị và cắt kính'),
(10, 'BN010', 'NV012', '2026-05-24', '16:00:00', N'Đã xác nhận', N'Lấy vôi răng và trám răng sâu'),
(11, 'BN011', 'NV004', '2026-05-25', '07:30:00', N'Đã xác nhận', N'Tái khám dạ dày'),
(12, 'BN012', 'NV015', '2026-05-26', '14:15:00', N'Đã xác nhận', N'Tái khám viêm gan siêu vi B'),
(13, 'BN013', 'NV008', '2026-05-27', '08:45:00', N'Đã xác nhận', N'Tháo bột cánh tay'),
(14, 'BN014', 'NV006', '2026-05-28', '09:30:00', N'Đã hủy', N'Đổi lịch sang tuần sau'),
(15, 'BN015', 'NV010', '2026-05-29', '15:00:00', N'Đã xác nhận', N'Khám đau đầu mãn tính'),
(16, 'BN016', 'NV019', '2026-05-30', '10:30:00', N'Đã xác nhận', N'Tư vấn tương tác thuốc sử dụng'),
(17, 'BN017', 'NV020', '2026-06-01', '13:00:00', N'Đã xác nhận', N'Lên thực đơn tiểu đường thai kỳ'),
(18, 'BN018', 'NV016', '2026-06-02', '14:30:00', N'Đã xác nhận', N'Kiểm tra định kỳ u nang tuyến giáp'),
(19, 'BN019', 'NV007', '2026-06-03', '08:15:00', N'Đã xác nhận', N'Kiểm tra sức khỏe đầu năm học'),
(20, 'BN020', 'NV009', '2026-06-04', '09:00:00', N'Đã xác nhận', N'Làm siêu âm Doppler mạch máu');


-- Thinh's
-- /////
INSERT INTO DIEUTRINOITRU (MANOITRU, MABN, MABACSI, MAPHONG, NGAYNHAPVIEN, NGAYXUATVIEN, LYDONHAPVIEN, TINHTRANGRAVIEN) VALUES
('NT001', 'BN001', 'NV001', 1, '2026-01-11 08:00:00', '2026-01-15 14:00:00', N'Viêm phế quản cấp', N'Đã hồi phục tốt'),
('NT002', 'BN002', 'NV002', 2, '2026-01-15 09:30:00', '2026-01-20 10:00:00', N'Suy nhược cơ thể', N'Sức khỏe ổn định'),
('NT003', 'BN003', 'NV003', 3, '2026-01-21 10:15:00', '2026-01-25 11:30:00', N'Sốt xuất huyết Dengue', N'Tiểu cầu tăng, khỏe'),
('NT004', 'BN004', 'NV004', 4, '2026-02-02 14:00:00', '2026-02-08 09:00:00', N'Viêm ruột thừa cấp', N'Vết mổ khô, xuất viện'),
('NT005', 'BN005', 'NV005', 5, '2026-02-06 16:45:00', '2026-02-12 15:20:00', N'Viêm phổi thùy', N'Hết sốt, phổi trong'),
('NT006', 'BN006', 'NV006', 6, '2026-02-11 07:30:00', '2026-02-14 10:00:00', N'Chuyển dạ sinh mổ', N'Mẹ tròn con vuông'),
('NT007', 'BN007', 'NV007', 7, '2026-02-16 11:00:00', NULL, N'Viêm não nhật bản', N'Đang theo dõi'),
('NT008', 'BN008', 'NV008', 8, '2026-02-21 15:30:00', '2026-03-01 08:30:00', N'Gãy xương đùi', N'Đã cố định, tập phục hồi'),
('NT009', 'BN009', 'NV009', 9, '2026-03-02 09:15:00', '2026-03-07 16:00:00', N'Cơn đau thắt ngực', N'Ổn định, chuyển ngoại trú'),
('NT010', 'BN010', 'NV010', 10, '2026-03-06 14:20:00', NULL, N'Đột quỵ não', N'Đang hồi sức'),
('NT011', 'BN011', 'NV011', 11, '2026-03-11 08:45:00', '2026-03-15 10:00:00', N'Cắt amidan', N'Hết chảy máu, ăn uống nhẹ'),
('NT012', 'BN012', 'NV012', 12, '2026-03-16 13:00:00', '2026-03-18 14:00:00', N'Nhiễm trùng răng', N'Đã hết sưng tấy'),
('NT013', 'BN013', 'NV013', 13, '2026-03-21 07:30:00', '2026-03-22 09:00:00', N'Phẫu thuật đục thủy tinh thể', N'Thị lực phục hồi tốt'),
('NT014', 'BN014', 'NV014', 14, '2026-03-26 10:45:00', '2026-03-30 11:00:00', N'Zona thần kinh biến chứng', N'Giảm đau, tổn thương khô'),
('NT015', 'BN015', 'NV015', 15, '2026-04-02 09:00:00', '2026-04-10 15:00:00', N'Nhiễm Covid-19', N'Âm tính, chức năng phổi tốt'),
('NT016', 'BN016', 'NV016', 16, '2026-04-06 14:30:00', NULL, N'Hóa trị ung thư vú đợt 1', N'Đang điều trị'),
('NT017', 'BN017', 'NV017', 17, '2026-04-11 08:15:00', '2026-04-13 16:30:00', N'Theo dõi chấn thương sọ não', N'Không có máu bầm, tỉnh táo'),
('NT018', 'BN018', 'NV018', 18, '2026-04-16 11:00:00', '2026-04-18 09:00:00', N'Suy nhược thần kinh', N'Tinh thần ổn định'),
('NT019', 'BN019', 'NV007', 19, '2026-04-21 15:45:00', NULL, N'Trẻ sinh non suy hô hấp', N'Đang theo dõi trong lồng ấp'),
('NT020', 'BN020', 'NV004', 20, '2026-04-26 09:30:00', '2026-05-01 10:00:00', N'Suy thận mạn tính đợt cấp', N'Chức năng thận tạm ổn');

INSERT INTO HOSO (MAHS, MANOITRU, MABN, MABACSI, CHUANDOAN, TRIEUCHUNG, KETLUAN, HUONGDIEUTRI, NGAYKHAM, TRANGTHAIHOSO) VALUES
('HS001', 'NT001', 'BN001', 'NV001', N'Viêm phế quản cấp', N'Ho nhiều, sốt nhẹ', N'Nhiễm khuẩn hô hấp trên', N'Kháng sinh, giảm ho', '2026-01-11 08:30:00', N'Đã đóng'),
('HS002', 'NT002', 'BN002', 'NV002', N'Suy nhược cơ thể', N'Mệt mỏi, chán ăn', N'Suy nhược do làm việc quá sức', N'Truyền dịch, nghỉ ngơi', '2026-01-15 10:00:00', N'Đã đóng'),
('HS003', 'NT003', 'BN003', 'NV003', N'Sốt xuất huyết', N'Sốt cao 39 độ, đau nhức cơ', N'SXH Dengue ngày thứ 3', N'Bù dịch, hạ sốt', '2026-01-21 10:45:00', N'Đã đóng'),
('HS004', 'NT004', 'BN004', 'NV004', N'Viêm ruột thừa', N'Đau hố chậu phải', N'Viêm ruột thừa cấp', N'Phẫu thuật cắt ruột thừa', '2026-02-02 14:30:00', N'Đã đóng'),
('HS005', 'NT005', 'BN005', 'NV005', N'Viêm phổi thùy', N'Đau ngực, ho có đờm', N'Viêm phổi do vi khuẩn', N'Kháng sinh tĩnh mạch', '2026-02-06 17:00:00', N'Đã đóng'),
('HS006', 'NT006', 'BN006', 'NV006', N'Thai phụ chuyển dạ', N'Vỡ ối, cơn gò tử cung', N'Chỉ định mổ bắt con', N'Phẫu thuật lấy thai', '2026-02-11 08:00:00', N'Đã đóng'),
('HS007', 'NT007', 'BN007', 'NV007', N'Viêm não', N'Hôn mê, co giật', N'Nghi ngờ viêm não Nhật Bản', N'Hồi sức, kháng sinh tủy', '2026-02-16 11:30:00', N'Đang mở'),
('HS008', 'NT008', 'BN008', 'NV008', N'Gãy xương đùi', N'Đau, biến dạng chi phải', N'Gãy kín 1/3 giữa đùi', N'Phẫu thuật kết hợp xương', '2026-02-21 16:00:00', N'Đã đóng'),
('HS009', 'NT009', 'BN009', 'NV009', N'Đau thắt ngực', N'Đau tức ngực trái', N'Thiếu máu cục bộ cơ tim', N'Thuốc giãn mạch, theo dõi', '2026-03-02 09:45:00', N'Đã đóng'),
('HS010', 'NT010', 'BN010', 'NV010', N'Đột quỵ não', N'Yếu nửa người trái', N'Nhồi máu não cấp', N'Tiêu sợi huyết, HSTC', '2026-03-06 14:50:00', N'Đang mở'),
('HS011', 'NT011', 'BN011', 'NV011', N'Viêm Amidan mạn', N'Đau họng, khó nuốt', N'Quá phát Amidan', N'Cắt Amidan', '2026-03-11 09:15:00', N'Đã đóng'),
('HS012', 'NT012', 'BN012', 'NV012', N'Áp xe răng', N'Sưng phù má trái, đau', N'Nhiễm trùng nang chân răng', N'Rạch áp xe, kháng sinh', '2026-03-16 13:30:00', N'Đã đóng'),
('HS013', 'NT013', 'BN013', 'NV013', N'Đục thủy tinh thể', N'Mờ mắt dần', N'Cườm khô mắt phải', N'Mổ Phaco', '2026-03-21 08:00:00', N'Đã đóng'),
('HS014', 'NT014', 'BN014', 'NV014', N'Zona thần kinh', N'Nổi mụn nước, rát', N'Zona vùng liên sườn', N'Thuốc kháng virus', '2026-03-26 11:15:00', N'Đã đóng'),
('HS015', 'NT015', 'BN015', 'NV015', N'Nhiễm Covid-19', N'Sốt, khó thở, ho', N'Covid-19 thể vừa', N'Cách ly, kháng virus', '2026-04-02 09:30:00', N'Đã đóng'),
('HS016', 'NT016', 'BN016', 'NV016', N'K Vú', N'Sờ thấy u', N'Ung thư vú giai đoạn 2', N'Hóa trị', '2026-04-06 15:00:00', N'Đang mở'),
('HS017', 'NT017', 'BN017', 'NV017', N'Chấn thương đầu', N'Sưng nề vùng trán', N'Tổn thương mô mềm', N'Theo dõi nội trú 48h', '2026-04-11 08:45:00', N'Đã đóng'),
('HS018', 'NT018', 'BN018', 'NV018', N'Rối loạn lo âu', N'Mất ngủ, nhịp tim nhanh', N'Suy nhược thần kinh', N'Trị liệu tâm lý', '2026-04-16 11:30:00', N'Đã đóng'),
('HS019', 'NT019', 'BN019', 'NV007', N'Sinh non 32 tuần', N'Nhẹ cân, suy hô hấp', N'Bệnh màng trong', N'Nằm lồng ấp, thở CPAP', '2026-04-21 16:15:00', N'Đang mở'),
('HS020', 'NT020', 'BN020', 'NV004', N'Suy thận mạn', N'Phù nề, mệt mỏi', N'Suy thận độ 3', N'Lọc máu chu kỳ', '2026-04-26 10:00:00', N'Đã đóng');

INSERT INTO THANHTOAN (MATHANHTOAN, MAHOADON, NGAYTHANHTOAN, SOTIEN, PHUONGTHUC, TRANGTHAI) VALUES
('TT001', 1001, '2026-01-20 11:00:00', 1520000.00, N'Tiền mặt', N'Thành công'),
('TT002', 1002, '2026-01-25 16:00:00', 8500000.00, N'Chuyển khoản', N'Thành công'),
('TT003', 1003, '2026-02-02 09:45:00', 450000.00, N'Thẻ tín dụng', N'Thành công'),
('TT004', 1004, '2026-02-10 11:50:00', 12500000.00, N'Chuyển khoản', N'Thành công'),
('TT005', 1005, '2026-02-15 17:00:00', 3200000.00, N'Tiền mặt', N'Thành công'),
('TT006', 1006, '2026-02-28 08:30:00', 650000.00, N'Momo', N'Thành công'),
('TT007', 1007, '2026-03-06 10:00:00', 500000.00, N'Tiền mặt', N'Tạm ứng'), -- HD 1007 chưa thanh toán xong
('TT008', 1008, '2026-03-12 10:30:00', 5400000.00, N'Chuyển khoản', N'Thành công'),
('TT009', 1009, '2026-03-18 14:15:00', 950000.00, N'VNPay', N'Thành công'),
('TT010', 1010, '2026-03-25 12:00:00', 5000000.00, N'Chuyển khoản', N'Tạm ứng'), -- HD 1010 chưa thanh toán xong
('TT011', 1011, '2026-03-28 17:30:00', 2100000.00, N'Thẻ tín dụng', N'Thành công'),
('TT012', 1012, '2026-04-02 10:15:00', 780000.00, N'Tiền mặt', N'Thành công'),
('TT013', 1013, '2026-04-10 15:50:00', 6200000.00, N'Chuyển khoản', N'Thành công'),
('TT014', 1014, '2026-04-15 10:45:00', 1250000.00, N'Tiền mặt', N'Thành công'),
('TT015', 1015, '2026-04-18 15:10:00', 3100000.00, N'Chuyển khoản', N'Thành công'),
('TT016', 1016, '2026-04-20 16:40:00', 1000000.00, N'Tiền mặt', N'Tạm ứng'),
('TT017', 1017, '2026-04-22 09:00:00', 13500000.00, N'Thẻ ghi nợ', N'Thành công'),
('TT018', 1018, '2026-04-25 11:30:00', 920000.00, N'Momo', N'Thành công'),
('TT019', 1019, '2026-04-28 13:55:00', 500000.00, N'Tiền mặt', N'Thành công'),
('TT020', 1020, '2026-05-02 11:20:00', 2000000.00, N'Chuyển khoản', N'Tạm ứng');

INSERT INTO LICHSUDIEUTRI (MALS, MAHS, NGAYCAPNHAT, NOIDUNG, MANV, GHICHU) VALUES
('LS001', 'HS001', '2026-01-12 08:00:00', N'Bệnh nhân giảm ho, không còn sốt', 'NV001', N'Tiếp tục dùng thuốc'),
('LS002', 'HS002', '2026-01-16 09:00:00', N'Đã ăn uống được, đỡ mệt mỏi', 'NV002', N'Tăng cường dinh dưỡng'),
('LS003', 'HS003', '2026-01-22 10:00:00', N'Tiểu cầu bắt đầu tăng lại', 'NV003', N'Giảm lượng dịch truyền'),
('LS004', 'HS004', '2026-02-03 14:00:00', N'Vết mổ khô, không chảy máu', 'NV004', N'Tập đi lại nhẹ nhàng'),
('LS005', 'HS005', '2026-02-08 08:30:00', N'Phổi nghe trong, hết rale', 'NV005', N'Cắt kháng sinh tiêm'),
('LS006', 'HS006', '2026-02-12 09:00:00', N'Tử cung gò tốt, sản dịch bình thường', 'NV006', N'Cho bé bú mẹ'),
('LS007', 'HS007', '2026-02-18 11:00:00', N'Thang điểm Glasgow 12đ, còn lơ mơ', 'NV007', N'Tiếp tục theo dõi sát'),
('LS008', 'HS008', '2026-02-23 15:00:00', N'Mạch mu chân rõ, không chèn ép khoang', 'NV008', N'Thay băng mỗi ngày'),
('LS009', 'HS009', '2026-03-04 09:00:00', N'Không còn ghi nhận đau ngực', 'NV009', N'Đo lại ECG'),
('LS010', 'HS010', '2026-03-08 14:00:00', N'Huyết áp ổn định, bắt đầu tập VLTL', 'NV010', N'Hỗ trợ tập vận động'),
('LS011', 'HS011', '2026-03-12 08:00:00', N'Cổ họng giảm sưng đỏ, nuốt đỡ đau', 'NV011', N'Dùng thức ăn lỏng'),
('LS012', 'HS012', '2026-03-17 10:30:00', N'Không còn mủ tại vị trí rạch', 'NV012', N'Tiếp tục súc miệng nước muối'),
('LS013', 'HS013', '2026-03-22 08:00:00', N'Mắt sáng, không đỏ', 'NV013', N'Khám xuất viện'),
('LS014', 'HS014', '2026-03-28 11:00:00', N'Mụn nước đã đóng mài', 'NV014', N'Bôi thuốc mỡ'),
('LS015', 'HS015', '2026-04-05 09:00:00', N'Test PCR âm tính lần 1', 'NV015', N'Chờ test lần 2'),
('LS016', 'HS016', '2026-04-08 15:00:00', N'Buồn nôn nhẹ sau truyền hóa chất', 'NV016', N'Dùng thuốc chống nôn'),
('LS017', 'HS017', '2026-04-12 08:30:00', N'Tỉnh táo, không nôn ói', 'NV017', N'Có thể xuất viện'),
('LS018', 'HS018', '2026-04-17 11:00:00', N'Ngủ ngon giấc hơn, bớt căng thẳng', 'NV018', N'Tiếp tục uống thuốc an thần'),
('LS019', 'HS019', '2026-04-23 09:00:00', N'Nhịp thở đều, SpO2 98%', 'NV007', N'Cai máy thở CPAP'),
('LS020', 'HS020', '2026-04-28 10:00:00', N'Giảm phù, đi tiểu khá hơn', 'NV004', N'Hạn chế muối trong thức ăn');

INSERT INTO CHITIETDICHVU (MAHS, MADV, NGAYTHUCHIEN, KETQUA, CHIPHI) VALUES
('HS001', 5, '2026-01-11 09:00:00', N'Phổi tăng sáng nhẹ', 120000.00),
('HS001', 7, '2026-01-11 09:15:00', N'Bạch cầu tăng', 180000.00),
('HS002', 8, '2026-01-15 10:30:00', N'Đường huyết thấp', 450000.00),
('HS003', 7, '2026-01-21 11:00:00', N'Tiểu cầu giảm', 180000.00),
('HS004', 3, '2026-02-02 15:00:00', N'Hình ảnh viêm ruột thừa', 250000.00),
('HS005', 5, '2026-02-06 17:30:00', N'Đám mờ thùy dưới phổi phải', 120000.00),
('HS006', 3, '2026-02-11 08:30:00', N'Tim thai bình thường', 250000.00),
('HS007', 14, '2026-02-16 12:00:00', N'Viêm màng não', 2500000.00),
('HS008', 6, '2026-02-21 16:30:00', N'Gãy 1/3 xương đùi', 150000.00),
('HS009', 9, '2026-03-02 10:00:00', N'Thiếu máu cơ tim', 100000.00),
('HS009', 10, '2026-03-02 10:30:00', N'Giảm động vùng mỏm tim', 350000.00),
('HS010', 13, '2026-03-06 15:00:00', N'Nhồi máu não bán cầu phải', 1800000.00),
('HS011', 7, '2026-03-11 09:30:00', N'Bình thường', 180000.00),
('HS012', 6, '2026-03-16 14:00:00', N'Nang chân răng', 150000.00),
('HS013', 7, '2026-03-21 08:30:00', N'Chỉ số sinh hóa bình thường', 180000.00),
('HS015', 5, '2026-04-02 10:00:00', N'Kính mờ rải rác 2 phế trường', 120000.00),
('HS016', 3, '2026-04-06 15:30:00', N'Khối u vú T', 250000.00),
('HS017', 13, '2026-04-11 09:00:00', N'Không xuất huyết não', 1800000.00),
('HS018', 9, '2026-04-16 12:00:00', N'Nhịp nhanh xoang', 100000.00),
('HS020', 8, '2026-04-26 10:30:00', N'Creatinin máu cao', 450000.00);

INSERT INTO TOATHUOC (MATOA, MAHS, MATHUOC, SOLUONG, DONGIA, THANHTIEN, LIEULUONG, CACHDUNG, GHICHU) VALUES
('TOA001', 'HS001', 2, 20, 3500.00, 70000.00, N'1 viên/lần', N'Sáng 1 viên, Tối 1 viên sau ăn', N'Kháng sinh'),
('TOA001', 'HS001', 1, 10, 1500.00, 15000.00, N'1 viên/lần', N'Uống khi sốt > 38.5 độ', N'Giảm sốt'),
('TOA002', 'HS002', 20, 30, 3000.00, 90000.00, N'1 viên/lần', N'Sáng 1 viên sau ăn', N'Bổ sung Vitamin C'),
('TOA003', 'HS003', 19, 15, 4000.00, 60000.00, N'1 viên/lần', N'Uống khi sốt cao', N'Pha nước sủi bọt'),
('TOA004', 'HS004', 14, 5, 45000.00, 225000.00, N'1 lọ/lần', N'Tiêm tĩnh mạch chậm', N'Thực hiện bởi y tá'),
('TOA005', 'HS005', 11, 14, 15000.00, 210000.00, N'1 viên/lần', N'Sáng 1 viên, Chiều 1 viên', N'Kháng sinh mạnh'),
('TOA006', 'HS006', 12, 10, 12000.00, 120000.00, N'1 vỉ/lần', N'Uống giảm đau vết mổ', N'Không quá 4 lần/ngày'),
('TOA008', 'HS008', 3, 20, 2000.00, 40000.00, N'1 viên/lần', N'Sáng, Tối sau ăn no', N'Giảm đau, kháng viêm'),
('TOA009', 'HS009', 6, 30, 3000.00, 90000.00, N'1 viên/lần', N'Sáng 1 viên', N'Kiểm soát huyết áp'),
('TOA009', 'HS009', 10, 30, 8000.00, 240000.00, N'1 viên/lần', N'Tối 1 viên', N'Thuốc hạ mỡ máu'),
('TOA011', 'HS011', 2, 15, 3500.00, 52500.00, N'1 viên/lần', N'Sáng, trưa, tối', N'Sau khi ăn'),
('TOA012', 'HS012', 11, 10, 15000.00, 150000.00, N'1 viên/lần', N'Sáng, tối', N'Điều trị nhiễm trùng răng'),
('TOA013', 'HS013', 1, 10, 1500.00, 15000.00, N'1 viên/lần', N'Uống khi nhức mắt', N'Giảm đau nhẹ'),
('TOA014', 'HS014', 9, 10, 1200.00, 12000.00, N'1 viên/lần', N'Tối 1 viên', N'Giảm ngứa'),
('TOA015', 'HS015', 20, 20, 3000.00, 60000.00, N'1 viên/lần', N'Sáng 1 viên', N'Tăng đề kháng'),
('TOA015', 'HS015', 13, 10, 1500.00, 15000.00, N'1 viên/lần', N'Uống khi sổ mũi', N'Thuốc cảm'),
('TOA017', 'HS017', 1, 10, 1500.00, 15000.00, N'1 viên/lần', N'Uống khi đau đầu', N'Chỉ uống khi cần'),
('TOA018', 'HS018', 20, 15, 3000.00, 45000.00, N'1 viên/lần', N'Sáng 1 viên', N'Bổ sung thể lực'),
('TOA020', 'HS020', 6, 30, 3000.00, 90000.00, N'1 viên/lần', N'Sáng 1 viên', N'Hạ áp'),
('TOA020', 'HS020', 16, 30, 1000.00, 30000.00, N'1 viên/lần', N'Tối 1 viên', N'Chống đông máu');