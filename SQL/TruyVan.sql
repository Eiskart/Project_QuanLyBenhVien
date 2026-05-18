-------------------------------------- CÁC TRUY VẤN CỦA CÂU 2 ---------------------------------------------------------------------
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

--Truy vấn b) Truy vấn với Agregate function

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
-- d. Truy vấn lớn nhất, nhỏ nhất
-- d.1 Tìm bệnh nhân có tổng tiền hóa đơn viện phí cao nhất.
SELECT TOP 1 BN.MABN, BN.HOTEN, HD.TONGTIEN
FROM BENHNHAN BN
JOIN HOADONVIENPHI HD ON BN.MABN = HD.MABN
ORDER BY HD.TONGTIEN DESC;
-- d.2 Tìm loại thuốc có số lượng tồn kho ít nhất.
SELECT TOP 1 MATHUOC, TENTHUOC, SOLUONGTON, DONVI
FROM THUOC
ORDER BY SOLUONGTON ASC;
-- d.3 Tìm nhân viên đảm nhận nhiều hồ sơ bệnh án nhất.
SELECT TOP 1 NV.MANV, NV.HOTEN, COUNT(HS.MAHS) AS SoLuongHoSoDamNhan
FROM NHANVIEN NV
JOIN HOSO HS ON NV.MANV = HS.MABACSI
GROUP BY NV.MANV, NV.HOTEN
ORDER BY COUNT(HS.MAHS) DESC;
-- d.4 Tìm dịch vụ y tế có đơn giá rẻ nhất đang được áp dụng.
SELECT TOP 1 MADV, TENDV, DONGIA
FROM DICHVUYTE
WHERE TRANGTHAI = N'Đang áp dụng'
ORDER BY DONGIA ASC;
-- e. Truy vấn Không/Chưa có (NOT IN, LEFT/RIGHT JOIN)
-- e.1 Tìm các bệnh nhân chưa từng đặt bất kỳ lịch hẹn khám nào.
SELECT BN.MABN, BN.HOTEN, BN.SDT
FROM BENHNHAN BN
LEFT JOIN LICHHENKHAM LHK ON BN.MABN = LHK.MABN
WHERE LHK.MALICHHEN IS NULL;
-- e.2 Tìm các loại thuốc chưa từng được kê trong bất kỳ toa thuốc nào của bệnh nhân.
SELECT MATHUOC, TENTHUOC, HOATCHAT
FROM THUOC
WHERE MATHUOC NOT IN (
    SELECT DISTINCT MATHUOC 
    FROM TOATHUOC
);
-- e.3 Tìm các khoa chưa được bố trí phòng bệnh nào.
SELECT K.MAKHOA, K.TENKHOA
FROM KHOA K
LEFT JOIN PHONGBENH PB ON K.MAKHOA = PB.MAKHOA
WHERE PB.MAPHONG IS NULL;
-- e.4 Tìm các bác sĩ/nhân viên y tế chưa từng khám hay tạo lập hồ sơ (HOSO) nào cho bệnh nhân.
SELECT MANV, HOTEN, CHUYENMON
FROM NHANVIEN
WHERE CHUCVU LIKE N'%Bác sĩ%' OR CHUYENMON IS NOT NULL 
AND MANV NOT IN (
    SELECT DISTINCT MABACSI 
    FROM HOSO
);
-- e.5 Tìm các dịch vụ y tế chưa từng được thực hiện cho bất kỳ bệnh nhân nào (chưa có trong chi tiết dịch vụ của hồ sơ).
SELECT DV.MADV, DV.TENDV, DV.DONGIA
FROM CHITIETDICHVU CT
RIGHT JOIN DICHVUYTE DV ON CT.MADV = DV.MADV
WHERE CT.MAHS IS NULL;


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


-- Truy vấn g) Truy vấn với Update & Delete

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
  -- h. Truy vấn sử dụng phép Chia (Relational Division)
-- h.1 Tìm những bệnh nhân đã chưa từng sử dụng dịch vụ y tế có trong bệnh viện.
SELECT BN.MABN, BN.HOTEN
FROM BENHNHAN BN
LEFT JOIN HOSO HS ON BN.MABN = HS.MABN
LEFT JOIN CHITIETDICHVU CTDV ON HS.MAHS = CTDV.MAHS
GROUP BY BN.MABN, BN.HOTEN
HAVING COUNT(CTDV.MADV) = 0;
-- h.2 Tìm bác sĩ đã từng điều trị (tạo hồ sơ) cho TẤT CẢ các bệnh nhân có trong hệ thống.
SELECT NV.MANV, NV.HOTEN
FROM NHANVIEN NV
WHERE NOT EXISTS (
    SELECT MABN 
    FROM BENHNHAN

    EXCEPT

    SELECT MABN 
    FROM HOSO 
    WHERE MABACSI = NV.MANV
);
-- h.3 Tìm bệnh nhân đã chưa từng được kê bất kỳ loại thuốc nào có lưu trong kho
SELECT BN.MABN, BN.HOTEN
FROM BENHNHAN BN
WHERE NOT EXISTS (
    SELECT 1
    FROM HOSO HS
    JOIN TOATHUOC TT ON HS.MAHS = TT.MAHS
    WHERE HS.MABN = BN.MABN
);
-- h.4 Tìm những bệnh nhân chưa từng điều trị nội trú đã từng lưu trú ở phòng bệnh của bệnh viện.
SELECT BN.MABN, BN.HOTEN
FROM BENHNHAN BN
WHERE BN.MABN IN (
    SELECT MABN 
    FROM BENHNHAN
    
    EXCEPT
    
    SELECT MABN 
    FROM DIEUTRINOITRU
);


------------------------------------------------- VÍ DỤ TRUY VẤN SỬ DỤNG THỦ TỤC ---------------------------------------------------------------------
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

------------------------------------------------- VÍ DỤ TRUY VẤN SỬ DỤNG HÀM ---------------------------------------------------------------------
-- 1. Nguyễn Văn An sinh ngày 1985-05-12. Năm nay 2026 thì kết quả phải ra 41.
SELECT dbo.fn_TinhTuoiBenhNhan('BN001') AS Tuoi_BN001;

-- 2. HS001 có TOA001 gồm: (20 viên * 3500) + (10 viên * 1500) = 85,000. Kết quả phải ra 85000.00.
    SELECT dbo.fn_TongTienThuocHoSo('HS001') AS TienThuoc_HS001;

-- 3. Kiểm tra xem dịch vụ MRI mang lại tổng bao nhiêu tiền dựa trên bảng CHITIETDICHVU
    SELECT dbo.fn_TongDoanhThuDichVu(5) AS DoanhThu_DichVu_5;

-- 4. Hàm này sẽ cộng dồn cột SOGIUONGTRONG của tất cả các phòng thuộc khoa K004
    SELECT dbo.fn_DemGiuongTrongTheoKhoa('K004') AS GiuongTrong_K004;

-- 5. Danh sách bệnh nhân của bác sĩ NV001
    SELECT * FROM dbo.fn_DanhSachBenhNhanCuaBacSi('NV001');

-- 6. Thuốc sắp hết hạn trong vòng 24 tháng tới
    SELECT * FROM dbo.fn_ThuocSapHetHan(24);

-- 7. Lịch sử khám bệnh của bệnh nhân BN004
    SELECT * FROM dbo.fn_LichSuKhamBenh('BN004');

-- 8. Lịch hẹn khám vào ngày 15/05/2026
    SELECT * FROM dbo.fn_LichHenTheoNgay('2026-05-15');