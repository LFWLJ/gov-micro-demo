package com.gov.file.dto;

import lombok.Data;

@Data
public class AttachmentSaveDTO {

    private String bizType;

    private Long bizId;

    private String fileId;

    private String fileName;
}