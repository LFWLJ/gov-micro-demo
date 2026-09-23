package com.gov.file.service;

import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.Map;

public interface FileService {

    Map<String, Object> upload(MultipartFile file, String tenantId);

    String getPresignedUrl(String objectName);

    InputStream download(String objectName);

    void delete(String objectName);
}