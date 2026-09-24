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

@Service
public class AttachmentServiceImpl implements AttachmentService {

    @Autowired
    private AttachmentMapper attachmentMapper;

    @Autowired
    private FileInfoMapper fileInfoMapper;

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