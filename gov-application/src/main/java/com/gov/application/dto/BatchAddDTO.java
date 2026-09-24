package com.gov.application.dto;

import lombok.Data;

import java.util.List;

@Data
public class BatchAddDTO {
    private List<String> words;
    private String category;
}