package com.gov.api.dto;

/**
 * 文件上传结果 DTO（跨服务传输用）
 * <p>
 * gov-file 服务在文件上传成功后返回给调用方的元数据。
 * 包含 MinIO 对象名（供后续下载/删除引用）、原始文件名、大小、类型等。
 * </p>
 */
public class FileUploadDTO {

    /** 文件记录主键 ID（数据库自增） */
    private String fileId;
    /** MinIO 对象名，格式为 {@code tenantId/uuid.ext}，跨服务引用文件的唯一标识 */
    private String objectName;
    /** 用户上传时的原始文件名（可能含中文，展示用） */
    private String originalName;
    /** 文件大小，单位字节 */
    private Long size;
    /** MIME 类型，如 {@code image/png}、{@code application/pdf} */
    private String contentType;

    public String getFileId() { return fileId; }
    public void setFileId(String fileId) { this.fileId = fileId; }
    public String getObjectName() { return objectName; }
    public void setObjectName(String objectName) { this.objectName = objectName; }
    public String getOriginalName() { return originalName; }
    public void setOriginalName(String originalName) { this.originalName = originalName; }
    public Long getSize() { return size; }
    public void setSize(Long size) { this.size = size; }
    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }
}