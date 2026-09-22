package com.gov.application.util;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class LicensePdfUtilTest {

    @Test
    void testGenerateQrCode() throws Exception {
        byte[] qr = LicensePdfUtil.generateQrCode("http://test.com/verify?code=abc123", 200, 200);

        assertNotNull(qr, "二维码字节不应为 null");
        assertTrue(qr.length > 0, "二维码字节长度应大于 0");
        // PNG 文件头魔数：89 50 4E 47
        assertEquals((byte) 0x89, qr[0]);
        assertEquals((byte) 0x50, qr[1]);
        assertEquals((byte) 0x4E, qr[2]);
        assertEquals((byte) 0x47, qr[3]);
    }

    @Test
    void testGeneratePdf() throws Exception {
        byte[] pdf = LicensePdfUtil.generate(
                "LIC-20260920-001",
                "营业执照",
                "张三",
                "330102199001011234",
                "A市市场监督管理局",
                LocalDate.of(2026, 9, 20),
                LocalDate.of(2031, 9, 19),
                "统一社会信用代码 91330100XXXXXXXX",
                "http://localhost:5173/verify?code=abc123"
        );

        assertNotNull(pdf, "PDF 字节不应为 null");
        assertTrue(pdf.length > 0, "PDF 字节长度应大于 0");
        // PDF 文件头：%PDF
        assertEquals('%', pdf[0]);
        assertEquals('P', pdf[1]);
        assertEquals('D', pdf[2]);
        assertEquals('F', pdf[3]);
    }

    @Test
    void testGeneratePdfWithNullExpireDate() throws Exception {
        byte[] pdf = LicensePdfUtil.generate(
                "LIC-20260920-002", "许可证", "李四", "330102199001011234",
                "A市财政局", LocalDate.of(2026, 9, 20),
                null, null, "http://test.com/verify"
        );
        assertNotNull(pdf);
        assertTrue(pdf.length > 0);
    }
}