package com.gov.application.util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType0Font;
import org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

public class LicensePdfUtil {

    /**
     * 生成电子证照 PDF
     */
    public static byte[] generate(String licenseNo, String templateName,
                                  String holderName, String holderIdCard,
                                  String issueDept, LocalDate issueDate,
                                  LocalDate expireDate, String content,
                                  String verifyUrl) throws Exception {

        try (PDDocument doc = new PDDocument();
             ByteArrayOutputStream baos = new ByteArrayOutputStream()) {

            // A4 横向：842 x 595 pt
            PDPage page = new PDPage(new PDRectangle(842, 595));
            doc.addPage(page);

            // 加载中文字体（从 classpath）
            PDType0Font font;
            try (InputStream is = LicensePdfUtil.class
                    .getResourceAsStream("/fonts/simhei.ttf")) {
                if (is == null) {
                    throw new RuntimeException("字体文件 /fonts/simhei.ttf 未找到");
                }
                font = PDType0Font.load(doc, is);
            }

            PDPageContentStream cs = new PDPageContentStream(doc, page);

            // ============ 标题 ============
            cs.beginText();
            cs.setFont(font, 28);
            cs.newLineAtOffset(280, 520);
            cs.showText(templateName);
            cs.endText();

            // ============ 编号 ============
            cs.beginText();
            cs.setFont(font, 12);
            cs.newLineAtOffset(60, 480);
            cs.showText("证照编号：" + licenseNo);
            cs.endText();

            // ============ 正文 ============
            float y = 430;
            float lineHeight = 26;

            y = writeLine(cs, font, 16, 60, y, "持证人：" + safe(holderName));
            y = writeLine(cs, font, 14, 60, y, "身份证号：" + maskIdCard(holderIdCard));
            y = writeLine(cs, font, 14, 60, y, "发证机关：" + safe(issueDept));
            y = writeLine(cs, font, 14, 60, y, "发证日期：" + safe(issueDate));
            if (expireDate != null) {
                y = writeLine(cs, font, 14, 60, y, "有效期至：" + expireDate);
            }
            if (content != null && !content.isEmpty()) {
                y = writeLine(cs, font, 12, 60, y, "证照内容：" + content);
            }

            // ============ 二维码（右下角）============
            byte[] qrBytes = generateQrCode(verifyUrl, 200, 200);
            PDImageXObject qrImage = PDImageXObject.createFromByteArray(doc, qrBytes, "qr");
            cs.drawImage(qrImage, 660, 80, 120, 120);

            cs.beginText();
            cs.setFont(font, 10);
            cs.newLineAtOffset(690, 60);
            cs.showText("扫码验真");
            cs.endText();

            cs.close();
            doc.save(baos);
            return baos.toByteArray();
        }
    }

    /**
     * 写一行文字并返回下一行的 y 坐标
     */
    private static float writeLine(PDPageContentStream cs, PDType0Font font,
                                   float fontSize, float x, float y, String text)
            throws Exception {
        cs.beginText();
        cs.setFont(font, fontSize);
        cs.newLineAtOffset(x, y);
        cs.showText(text);
        cs.endText();
        return y - (fontSize + 10);
    }

    /**
     * 生成二维码
     */
    public static byte[] generateQrCode(String content, int width, int height) throws Exception {
        Map<EncodeHintType, Object> hints = new HashMap<>();
        hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
        hints.put(EncodeHintType.MARGIN, 1);

        BitMatrix matrix = new MultiFormatWriter()
                .encode(content, BarcodeFormat.QR_CODE, width, height, hints);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        MatrixToImageWriter.writeToStream(matrix, "PNG", baos);
        return baos.toByteArray();
    }

    /**
     * 身份证脱敏
     */
    private static String maskIdCard(String idCard) {
        if (idCard == null || idCard.length() < 8) return safe(idCard);
        return idCard.substring(0, 6) + "********" + idCard.substring(idCard.length() - 4);
    }

    private static String safe(Object o) {
        return o == null ? "-" : o.toString();
    }
}