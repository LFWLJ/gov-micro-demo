package com.gov.application.util;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

class LicensePdfUtilTest {

    /**
     * 中文字体候选路径（与 LicensePdfUtil 的查找顺序一致）。
     *
     * <p>仓库不提交字体文件（约 10MB 且有授权限制），所以这里按环境探测：
     * 找到就用 {@code gov.pdf.font.path} 指过去；找不到就让 PDF 用例**跳过**，
     * 而不是把"本机没装字体"误报成代码缺陷。
     *
     * <p>注意：{@code .ttc} 字体集合 PDFBox 的 {@code PDType0Font.load} 不能直接加载，故排除。
     */
    private static final List<String> FONT_CANDIDATES = Arrays.asList(
            System.getenv("GOV_PDF_FONT_PATH"),
            "../docker/fonts/simhei.ttf",
            "C:/Windows/Fonts/simhei.ttf",
            "/usr/share/fonts/truetype/droid/DroidSansFallbackFull.ttf"
    );

    @BeforeAll
    static void locateFont() {
        for (String path : FONT_CANDIDATES) {
            if (path == null || path.isEmpty()) continue;
            File f = new File(path);
            if (f.isFile() && path.toLowerCase().endsWith(".ttf")) {
                System.setProperty("gov.pdf.font.path", f.getAbsolutePath());
                return;
            }
        }
    }

    /** PDF 渲染依赖中文字体，没有就跳过（CI 上可通过 GOV_PDF_FONT_PATH 提供） */
    private static void requireFont() {
        String p = System.getProperty("gov.pdf.font.path");
        assumeTrue(p != null && new File(p).isFile(),
                "本机未提供中文 TTF 字体，跳过 PDF 渲染用例");
    }

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
        requireFont();
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
        requireFont();
        byte[] pdf = LicensePdfUtil.generate(
                "LIC-20260920-002", "许可证", "李四", "330102199001011234",
                "A市财政局", LocalDate.of(2026, 9, 20),
                null, null, "http://test.com/verify"
        );
        assertNotNull(pdf);
        assertTrue(pdf.length > 0);
    }
}
