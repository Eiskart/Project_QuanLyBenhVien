-- Thinh's

-- Bảng THANH TOÁN
CREATE TABLE THANHTOAN (
    MATHANHTOAN VARCHAR(20) PRIMARY KEY,
    MAHOADON INT NOT NULL,
    NGAYTHANHTOAN DATETIME NOT NULL,
    SOTIEN DECIMAL(18,2) NOT NULL,
    PHUONGTHUC NVARCHAR(50),
    TRANGTHAI NVARCHAR(50),
    CONSTRAINT FK_TT_HDVP FOREIGN KEY (MAHOADON) REFERENCES HOADONVIENPHI(MAHOADON)
);

-- Bảng NHẬP VIỆN
CREATE TABLE DIEUTRINOITRU (
	MANOITRU VARCHAR(10) PRIMARY KEY,
	MABN VARCHAR(10) NOT NULL,
	MABACSI VARCHAR(10),
	MAPHONG VARCHAR(10),
	NGAYNHAPVIEN DATETIME NOT NULL,
	NGAYXUATVIEN DATETIME,
	LYDONHAPVIEN NVARCHAR(MAX) NOT NULL,
	TINHTRANGRAVIEN NVARCHAR(255),
	CONSTRAINT FK_DTNT_BENHNHAN FOREIGN KEY (MABN) REFERENCES BENHNHAN(MABN),
	CONSTRAINT FK_DTNT_PHONGBENH FOREIGN KEY (MAPHONG) REFERENCES PHONGBENH(MAPHONG),
	CONSTRAINT FK_DTNT_BACSI FOREIGN KEY (MABACSI) REFERENCES NHANVIEN(MANV),
);

-- Bảng HỒ SƠ BỆNH ÁN --> gọi tắt là "hồ sơ" (HOSO)
CREATE TABLE HOSO (
	MAHS VARCHAR(10) PRIMARY KEY,
	MANOITRU VARCHAR(10) NOT NULL,
	MABN VARCHAR(10) NOT NULL,
	MABACSI VARCHAR(10) NOT NULL,
	CHUANDOAN NVARCHAR(MAX) NOT NULL,
	TRIEUCHUNG NVARCHAR(MAX) NOT NULL,
	KETLUAN NVARCAHR(MAX),
	HUONGDIEUTRI NVARCHAR(MAX),
	NGAYKHAM DATETIME NOT NULL,
	TRANGTHAIHOSO NVARCHAR(50),
	CONSTRAINT FK_HOSO_DTNT FOREIGN KEY (MANOITRU) REFERENCES DIEUTRINOITRU(MANOITRU),
	CONSTRAINT FK_HOSO_BENHNHAN FOREIGN KEY (MABN) REFERENCES BENHNHAN(MABN),
	CONSTRAINT FK_HOSO_NHANVIEN FOREIGN KEY (MABACSI) REFERENCES NHANVIEN(MANV)
);

-- Bảng LỊCH SỬ ĐIỀU TRỊ
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

-- Bảng CHI TIẾT DỊCH VỤ
CREATE TABLE CHITIETDICHVU (
    MAHS VARCHAR(10) NOT NULL,
    MADV INT NOT NULL,
    NGAYTHUCHIEN DATETIME NOT NULL,
    KETQUA NVARCHAR(MAX),
    CHIPHI DECIMAL(18,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (MAHS, MADV), -- Khóa chính (hỗn hợp) 
    CONSTRAINT FK_CTDV_HOSO FOREIGN KEY (MAHS) REFERENCES HOSO(MAHS),
    CONSTRAINT FK_CTDV_DICHVU FOREIGN KEY (MADV) REFERENCES DICHVUYTE(MADV)
);

-- Bảng TOA THUỐC
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
	CONSTRAINT FK_TOATHUOC_THUOC FOREIGN KEY (MATHUOC) REFERENCES THUOC(MATHUOC),
);


-- a) 5 câu truy vấn đơn giản:
-- 1. Lấy danh sách tất cả bệnh nhân có giới tính là "Nữ"
SELECT * 
FROM BENHNHAN 
WHERE GIOITINH = N'Nữ';

-- 2. Hiển thị thông tin thuốc có giá trên 5k
SELECT TENTHUOC, DONVI, GIA, SOLUONGTON
FROM THUOC
WHERE GIA > 5000;

-- 3. Tìm kiếm nhân viên có họ hoặc tên chứa chữ "Nguyễn"
SELECT MANV, HOTEN, CHUCVU, SODT
FROM NHANVIEN
WHERE HOTEN LIKE N'%Nguyễn%';

-- 4. Đếm tổng số lượng hóa đơn viện phí chưa được thanh toán
SELECT COUNT(*) AS SoHoaDonChuaThanhToan
FROM HOADONVIENPHI
WHERE TRANGTHAITHANHTOAN = N'Chưa thanh toán';

-- 5. Xem danh sách các phòng bệnh lớn có sức chứa từ 5 người trở lên
SELECT MAPHONG, TENPHONG, SUCCHUA, GIAPHONG
FROM PHONGBENH
WHERE SUCCHUA >= 5;


-- c) Truy vấn với mệnh đề having
-- 13. Tìm các chức vụ có từ 3 nhân viên trở lên
SELECT CHUCVU, COUNT(*) AS SoLuongNhanVien
FROM NHANVIEN
GROUP BY CHUCVU
HAVING COUNT(*) >= 3;

-- 14. Thống kê các đơn vị tính của thuốc có giá trung bình lớn hơn 15k
SELECT DONVI, AVG(GIA) AS GiaTrungBinh
FROM THUOC
GROUP BY DONVI
HAVING AVG(GIA) > 15000;

-- 15. Tìm các mức giá phòng bệnh đang có nhiều hơn 2 phòng áp dụng
SELECT GIAPHONG, COUNT(*) AS SoPhongCungMucGia
FROM PHONGBENH
GROUP BY GIAPHONG
HAVING COUNT(*) > 2;

-- 16. Tìm các bệnh nhân đã đặt lịch hẹn khám từ 2 lần trở lên
SELECT MABN, COUNT(*) AS SoLanHenKham
FROM LICHHENKHAM
GROUP BY MABN
HAVING COUNT(*) >= 2;

-- 17. Tìm các hồ sơ bệnh án được kê từ 3 loại thuốc trở lên trong toa
SELECT MAHS, COUNT(MATHUOC) AS SoLoaiThuocDuocKe
FROM TOATHUOC
GROUP BY MAHS
HAVING COUNT(MATHUOC) >= 3;


-- f) Truy vấn Hợp/Giao/Trừ
-- 27. Lấy danh sách liên hệ của cả Bệnh nhân và Nhân viên
SELECT 
    HOTEN AS HoTen, 
    SDT AS SoDienThoai, 
    N'Bệnh Nhân' AS NhomDoiTuong 
FROM BENHNHAN

UNION

SELECT 
    HOTEN AS HoTen, 
    SODT AS SoDienThoai, 
    N'Nhân Viên' AS NhomDoiTuong 
FROM NHANVIEN;

-- 28. Tìm danh sách các Bác sĩ (Mã bác sĩ, Họ tên, Chuyên môn) vừa tham gia khám ngoại trú,
--    vừa tham gia điều trị nội trú
SELECT 
    NV.MANV AS MaBacSi, 
    NV.HOTEN AS TenBacSi, 
    NV.CHUYENMON AS ChuyenMon
FROM NHANVIEN NV
JOIN LICHHENKHAM LHK ON NV.MANV = LHK.MABACSI
INTERSECT
SELECT 
    NV.MANV AS MaBacSi, 
    NV.HOTEN AS TenBacSi, 
    NV.CHUYENMON AS ChuyenMon
FROM NHANVIEN NV
JOIN DIEUTRINOITRU DTNT ON NV.MANV = DTNT.MABACSI;

-- 29.Tìm danh sách các Bệnh nhân (Mã bệnh nhân, Họ tên, Số điện thoại) đã từng có Hồ sơ khám bệnh, 
--   nhưng KHÔNG phát sinh bất kỳ dịch vụ y tế nào lưu trong bảng CHITIETDICHVU
SELECT 
    BN.MABN, 
    BN.HOTEN, 
    BN.SDT
FROM BENHNHAN BN
JOIN HOSO HS ON BN.MABN = HS.MABN
EXCEPT
SELECT 
    BN.MABN, 
    BN.HOTEN, 
    BN.SDT
FROM BENHNHAN BN
JOIN HOSO HS ON BN.MABN = HS.MABN
JOIN CHITIETDICHVU CTDV ON HS.MAHS = CTDV.MAHS;





------------------------------------------------- THỦ TỤC ---------------------------------------------------------------------
/*========= 1. Tìm kiếm thuốc theo tên tương đối ===*/


-- Ví dụ tìm các loại thuốc có chữ "Para" (như Paracetamol)
EXEC sp_TimKiemThuoc @TenThuoc = N'Para';


/*========= 2. Thêm dữ liệu dăng ký lịch hẹn khám mới ===*/
-- (Note!! sử dụng code dưới đây trước và sau khi thực hiện ví dụ để ktra thủ tục/ví dụ có hoạt động không)
SELECT MALICHHEN, MABN, MABACSI, NGAYHEN, GIOHEN, TRANGTHAI, GHICHU 
FROM LICHHENKHAM 
WHERE MALICHHEN = 21;

-- Ví dụ: Thêm một lịch hẹn mới (đồng thời tận dụng luôn giá trị mặc định của trạng thái)
EXEC sp_DatLichHen 
    @MaLichHen = 21, 
    @MaBN = 'BN020', 
    @MaBacSi = 'NV009', 
    @NgayHen = '2026-06-05', 
    @GioHen = '07:30:00', 
    -- Bỏ qua @TrangThai để nhận giá trị mặc định
    @GhiChu = N'Kiểm tra lại chỉ số đường huyết';


/*========= 3. Thêm chi tiết kê toa thuốc cho hồ sơ bệnh án ===*/
-- (Note!! sử dụng code dưới đây trước và sau khi thực hiện ví dụ để ktra thủ tục/ví dụ có hoạt động không)
SELECT MATOA, MAHS, MATHUOC, SOLUONG, DONGIA, THANHTIEN, CACHDUNG 
FROM TOATHUOC 
WHERE MATOA = 'TOA001';

-- Ví dụ: Kê đơn thuốc Kháng sinh
EXEC sp_KeToaThuoc
    @MaToa = 'TOA001',
    @MaHS = 'HS001',
    @MaThuoc = 2,
    @SoLuong = 20,
    @DonGia = 3500.00,
    @LieuLuong = N'1 viên/lần',
    @CachDung = N'Sáng 1 viên, Tối 1 viên sau ăn',
    @GhiChu = N'Kháng sinh';

/*========= 4. Cập nhật thanh toán hóa đơn viện phí ===*/
-- (Note!! sử dụng code dưới đây trước và sau khi thực hiện ví dụ để ktra thủ tục/ví dụ có hoạt động không)
SELECT MAHOADON, MABN, TONGTIEN, TRANGTHAITHANHTOAN, GHICHU 
FROM HOADONVIENPHI 
WHERE MAHOADON = 1007;

-- Ví dụ: thanh toán hóa đơn số 1007 và cập nhật ghi chú mới
EXEC sp_ThanhToanHoaDon 
    @MaHoaDon = 1007, 
    @GhiChuMoi = N'Bảo hiểm đã duyệt và tất toán toàn bộ';

/*========= 5. Hủy lịch hẹn khám ===*/

-- Ví dụ: Hủy lịch hẹn và ghi đè lý do hủy mới
EXEC sp_HuyLichHen 
    @MaLichHen = 4, 
    @LyDoHuy = N'Bệnh nhân xin đổi lịch sang tuần sau do trùng lịch công tác';

/*========= 6. Tính tổng doanh thu dịch vụ theo khoảng thời gian ===*/
-- Ví dụ: Xem báo cáo doanh thu dịch vụ phát sinh trong quý 1 năm 2026
EXEC sp_ThongKeDoanhThuDichVuTrucTiep
    @TuNgay = '2026-01-01',
    @DenNgay = '2026-03-31';


/*========= 7. In danh sách bệnh nhân nội trú của một khoa ===*/
-- Ví dụ: Lấy danh sách bệnh nhân đang nằm tại khoa Sản (K006)
EXEC sp_DanhSachBenhNhanTheoKhoa @MaKhoa = 'K006';

