package com.gov.file.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.common.exception.BizException;
import com.gov.file.dto.AttachmentSaveDTO;
import com.gov.file.entity.Attachment;
import com.gov.file.entity.FileInfo;
import com.gov.file.mapper.AttachmentMapper;
import com.gov.file.mapper.FileInfoMapper;
import com.gov.file.service.AttachmentService;
import com.gov.file.dto.vo.AttachmentVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 附件关联业务实现
 * <p>
 * 管理业务对象（办件、证照等）与 MinIO 文件之间的多对多关联关系。
 * 本服务<strong>不</strong>直接操作 MinIO 对象，文件的上传 / 删除由
 * {@link com.gov.file.service.FileService} 统一负责，
 * 删除附件关联时只清数据库，不删 MinIO 对象（避免误伤被其他业务引用的文件）。
 * </p>
 * <p>
 * 典型场景：一个办件可以挂多张材料文件，通过 bizType + bizId 关联查询。
 * </p>
 *
 * @see com.gov.file.service.FileService
 */
@Service
public class AttachmentServiceImpl implements AttachmentService {

    @Autowired
    private AttachmentMapper attachmentMapper;

    @Autowired
    private FileInfoMapper fileInfoMapper;

    /**
     * 保存附件关联记录
     * <p>
     * 要求 bizType、bizId、fileId 均必填，tenantId 来自调用方上下文。
     * </p>
     */
    @Override
    public Long save(AttachmentSaveDTO dto, String tenantId) {
        if (!StringUtils.hasText(dto.getBizType())) {
            throw new BizException("bizType 不能为空");
        }
        if (dto.getBizId() == null) {
            throw new BizException("bizId 不能为空");
        }
        if (!StringUtils.hasText(dto.getFileId())) {
            throw new BizException("fileId 不能为空");
        }
        if (!StringUtils.hasText(tenantId)) {
            throw new BizException("缺少租户标识");
        }

        Attachment a = new Attachment();
        a.setTenantId(tenantId);
        a.setBizType(dto.getBizType());
        a.setBizId(dto.getBizId());
        a.setFileId(dto.getFileId());
        a.setFileName(dto.getFileName());
        attachmentMapper.insert(a);
        return a.getId();
    }

    /**
     * 按业务对象查询附件列表，批量回填 FileInfo 的 objectName / size / contentType
     */
    @Override
    public List<AttachmentVO> listByBiz(String bizType, Long bizId, String tenantId) {
        if (!StringUtils.hasText(bizType) || bizId == null) {
            return new ArrayList<>();
        }

        List<Attachment> list = attachmentMapper.selectList(
                new LambdaQueryWrapper<Attachment>()
                        .eq(Attachment::getBizType, bizType)
                        .eq(Attachment::getBizId, bizId)
                        .eq(StringUtils.hasText(tenantId), Attachment::getTenantId, tenantId)
                        .orderByAsc(Attachment::getId));

        if (CollectionUtils.isEmpty(list)) {
            return new ArrayList<>();
        }

        // 批量查 FileInfo
        List<String> fileIds = list.stream()
                .map(Attachment::getFileId)
                .filter(StringUtils::hasText)
                .distinct()
                .collect(Collectors.toList());

        Map<String, FileInfo> fileMap = new HashMap<>();
        if (!fileIds.isEmpty()) {
            List<FileInfo> files = fileInfoMapper.selectList(
                    new LambdaQueryWrapper<FileInfo>()
                            .in(FileInfo::getFileId, fileIds));
            for (FileInfo f : files) {
                fileMap.put(f.getFileId(), f);
            }
        }

        List<AttachmentVO> result = new ArrayList<>();
        for (Attachment a : list) {
            AttachmentVO vo = new AttachmentVO();
            BeanUtils.copyProperties(a, vo);
            FileInfo f = fileMap.get(a.getFileId());
            if (f != null) {
                vo.setObjectName(f.getObjectName());
                vo.setSize(f.getSize());
                vo.setContentType(f.getContentType());
                if (!StringUtils.hasText(vo.getFileName())) {
                    vo.setFileName(f.getOriginalName());
                }
            }
            result.add(vo);
        }
        return result;
    }

    /**
     * 删除附件关联（只清数据库，不删 MinIO 对象，避免误删被其他业务引用的文件）
     */
    @Override
    public void delete(Long id, String tenantId) {
        if (id == null) throw new BizException("id 不能为空");
        Attachment a = attachmentMapper.selectById(id);
        if (a == null) throw new BizException("附件不存在");
        if (StringUtils.hasText(tenantId) && !tenantId.equals(a.getTenantId())) {
            throw new BizException("无权限操作");
        }
        attachmentMapper.deleteById(id);
        // 不删 t_file 和 MinIO，避免误删被其他业务引用的文件
    }
}