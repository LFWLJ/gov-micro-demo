package com.gov.application.dto;

import lombok.Data;

@Data
public class SensitiveWordQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    private String word;
    private String category;
}