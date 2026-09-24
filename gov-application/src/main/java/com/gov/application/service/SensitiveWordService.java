package com.gov.application.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.gov.application.dto.BatchAddDTO;
import com.gov.application.dto.SensitiveWordQueryDTO;
import com.gov.application.entity.SensitiveWord;

public interface SensitiveWordService {

    IPage<SensitiveWord> pageWords(SensitiveWordQueryDTO query);

    void addWord(SensitiveWord word);

    void updateWord(SensitiveWord word);

    void deleteWord(Long id);

    /** 批量新增，返回成功插入的数量 */
    int batchAdd(BatchAddDTO dto);
}