package com.gov.file.service;

import com.gov.file.dto.AttachmentSaveDTO;
import com.gov.file.dto.vo.AttachmentVO;

import java.util.List;

public interface AttachmentService {

    /** 关联文件到业务对象 */
    Long save(AttachmentSaveDTO dto, String tenantId);

    /** 查询某业务对象的所有附件 */
    List<AttachmentVO> listByBiz(String bizType, Long bizId, String tenantId);

    /** 删除关联 */
    void delete(Long id, String tenantId);
}