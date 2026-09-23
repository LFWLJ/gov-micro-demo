package com.gov.application.service;

import com.gov.application.entity.Evaluation;

import java.util.Map;

public interface EvaluationService {

    Map<String, Object> page(int page, int size, Integer score,
                             Integer isBad, String rectifyStatus);

    Long submit(Evaluation eval);

    void rectify(Long evaluationId, String content);

    Map<String, Object> stats();
}