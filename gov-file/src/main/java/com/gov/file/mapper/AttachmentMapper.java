package com.gov.file.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gov.file.entity.Attachment;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AttachmentMapper extends BaseMapper<Attachment> {
}