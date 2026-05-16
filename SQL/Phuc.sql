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
CREATE TABLE THUOC(
MATHUOC INT IDENTITY(1,1) PRIMARY KEY,
TENTHUOC NVARCHAR(100) NOT NULL,
DONVI NVARCHAR(20),
GIA DECIMAL(18,2) NOT NULL DEFAULT 0,
HAMLUONG NVARCHAR(100),
HOATCHAT NVARCHAR(255),
HANSUDUNG DATE,
SOLUONGTON INT,
TRANGTHAI NVARCHAR(20),
);
CREATE TABLE LOAIPHONG (
    MALOAIPHONG VARCHAR(10) PRIMARY KEY,
    TENLOAIPHONG NVARCHAR(100) NOT NULL,
    MOTA NVARCHAR(MAX),
    GIACOBAN DECIMAL(18, 2) NOT NULL DEFAULT 0 
);
CREATE TABLE HOADONVIENPHI (
    MAHOADON INT PRIMARY KEY,
    MABN VARCHAR(10) NOT NULL, 
    NGAYLAP DATETIME,
    TONGTIEN DECIMAL(18, 2) DEFAULT 0,
    TRANGTHAITHANHTOAN NVARCHAR(50), 
    GHICHU NVARCHAR(MAX),
	FOREIGN KEY (MABN) REFERENCES BENHNHAN(MABN)
);
--------------------------Truy vấn b) Truy vấn với Agregate function------------------------------------------------

-- Thống kê nhân sự để biết mỗi vị trí (Bác sĩ, Điều dưỡng,...) có bao nhiêu người.
SELECT CHUCVU, COUNT(MANV) AS TongSoNhanVien
FROM NHANVIEN
GROUP BY CHUCVU;

-- Xác định doanh thu hoặc chi phí thuốc dựa trên từng mã tòa thuốc cụ thể.
SELECT MATOA, SUM(THANHTIEN) AS TongTienToaThuoc
FROM TOATHUOC
GROUP BY MATOA;

-- Hỗ trợ ban quản lý xem xét mức giá trung bình giữa phòng thường, phòng dịch vụ...
SELECT MALOAIPHONG, AVG(GIAPHONG) AS GiaPhongTrungBinh
FROM PHONGBENH
GROUP BY MALOAIPHONG;

-- Tìm ra loại dịch vụ đắt nhất
SELECT MAX(DONGIA) AS ChiPhiDichVuCaoNhat
FROM DICHVUYTE;

-- Thống kê lượng tồn kho thấp nhất của các thuốc có trạng thái 'Còn hàng'
SELECT TENTHUOC, MIN(SOLUONGTON) AS TonKhoThapNhat
FROM THUOC
WHERE TRANGTHAI = N'Còn hàng'
GROUP BY TENTHUOC;

-- Ý nghĩa: Phân tích hành vi thanh toán của bệnh nhân (Chuyển khoản, Tiền mặt) đối với các giao dịch thành công.
SELECT PHUONGTHUC, COUNT(MATHANHTOAN) AS SoLuotGiaoDich
FROM THANHTOAN
WHERE TRANGTHAI = N'Thành công'
GROUP BY PHUONGTHUC;

--Giúp bệnh viện quản lý biên độ giá của các nhóm thuốc (Viên, Chai, Lọ, Ống...).
SELECT DONVI, MIN(GIA) AS GiaThapNhat, MAX(GIA) AS GiaCaoNhat
FROM THUOC
GROUP BY DONVI;

--------------------------Truy vấn g) Truy vấn với Update & Delete------------------------------------------------

-- Thay đổi số điện thoại và địa chỉ khi bệnh nhân báo có sự thay đổi.
UPDATE BENHNHAN
SET SDT = '0912345678', DIACHI = N'78 Lê Lợi, Nha Trang'
WHERE MABN = 'BN001';

-- Điều chỉnh tăng 10% giá cơ bản của loại phòng VIP ('LP01') do trượt giá thị trường.
UPDATE LOAIPHONG
SET GIACOBAN = GIACOBAN * 1.10
WHERE MALOAIPHONG = 'LP01';

-- Ý nghĩa: Tự động chuyển đổi trạng thái thành 'Hết hạn' cho tất cả các loại thuốc có hạn sử dụng trước ngày hiện tại.
UPDATE THUOC
SET TRANGTHAI = N'Hết hạn'
WHERE HANSUDUNG < GETDATE();

-- Đồng bộ cột TONGTIEN ở bảng HOADONVIENPHI bằng cách tính tổng các khoản tiền phát sinh từ bảng CHITIETVIENPHI.
UPDATE HOADONVIENPHI
SET TONGTIEN = (
    SELECT SUM(SOTIEN) 
    FROM CHITIETVIENPHI 
    WHERE CHITIETVIENPHI.MAHOADON = HOADONVIENPHI.MAHOADON
)
WHERE MAHOADON IN (SELECT DISTINCT MAHOADON FROM CHITIETVIENPHI);

-- Người bệnh gọi điện xin hủy một lịch hẹn khám cụ thể ra khỏi hệ thống.
DELETE FROM LICHHENKHAM
WHERE MALICHHEN = 1;

-- Dọn dẹp danh mục bằng cách xóa các dịch vụ thử nghiệm cũ không còn áp dụng và giá bằng 0.
DELETE FROM DICHVUYTE
WHERE TRANGTHAI = N'Ngừng áp dụng' AND DONGIA = 0;

-- Lọc và xóa các tài khoản bệnh nhân ảo chưa từng tới khám hay điều trị nội trú.
DELETE FROM BENHNHAN
WHERE MABN NOT IN (SELECT DISTINCT MABN FROM HOSO)
  AND MABN NOT IN (SELECT DISTINCT MABN FROM DIEUTRINOITRU);