package com.gov.file.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("t_attachment")
public class Attachment {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String tenantId;

    /** APPLICATION / GUIDE / EVALUATION */
    private String bizType;

    private Long bizId;

    private String fileId;

    private String fileName;

    private LocalDateTime createTime;
}