package com.gov.file.dto.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AttachmentVO {

    private Long id;

    private String bizType;

    private Long bizId;

    private String fileId;

    private String fileName;

    private String objectName;

    private Long size;

    private String contentType;

    private LocalDateTime createTime;
}