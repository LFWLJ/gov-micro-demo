package com.gov.application.service;

import com.gov.application.entity.Evaluation;
import com.gov.application.entity.Rectify;
import com.gov.application.mapper.EvaluationMapper;
import com.gov.application.mapper.RectifyMapper;
import com.gov.application.service.impl.EvaluationServiceImpl;
import com.gov.common.exception.BizException;
import com.gov.common.tenant.TenantContext;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class EvaluationServiceTest {

    @Mock
    private EvaluationMapper evaluationMapper;

    @Mock
    private RectifyMapper rectifyMapper;

    @InjectMocks
    private EvaluationServiceImpl evaluationService;

    private AutoCloseable closeable;

    @BeforeEach
    void setUp() {
        closeable = MockitoAnnotations.openMocks(this);
        TenantContext.set("tenant_a");
    }

    @AfterEach
    void tearDown() throws Exception {
        TenantContext.clear();
        closeable.close();
    }

    // ============ 提交评价 ============

    @Test
    void testSubmitGoodEvaluation() {
        Evaluation eval = new Evaluation();
        eval.setScore(5);
        eval.setContent("非常满意");
        eval.setBusinessKey("APP-001");

        evaluationService.submit(eval);

        assertEquals(1, eval.getTenantId() != null ? 1 : 0);
        assertEquals("tenant_a", eval.getTenantId());
        assertEquals(0, eval.getIsBad());
        assertEquals("NONE", eval.getRectifyStatus());
        verify(evaluationMapper, times(1)).insert(any(Evaluation.class));
    }

    @Test
    void testSubmitBadEvaluation() {
        Evaluation eval = new Evaluation();
        eval.setScore(1);
        eval.setContent("等待时间太长");

        evaluationService.submit(eval);

        assertEquals(1, eval.getIsBad());
        assertEquals("PENDING", eval.getRectifyStatus());
        verify(evaluationMapper, times(1)).insert(any(Evaluation.class));
    }

    @Test
    void testSubmitWithInvalidScore() {
        Evaluation eval = new Evaluation();
        eval.setScore(0);

        BizException ex = assertThrows(BizException.class,
                () -> evaluationService.submit(eval));
        assertTrue(ex.getMessage().contains("评分"));
        verify(evaluationMapper, never()).insert(any());
    }

    @Test
    void testSubmitWithNullScore() {
        Evaluation eval = new Evaluation();
        eval.setScore(null);

        assertThrows(BizException.class, () -> evaluationService.submit(eval));
    }

    // ============ 整改 ============

    @Test
    void testRectifySuccess() {
        Evaluation eval = new Evaluation();
        eval.setId(1L);
        eval.setIsBad(1);
        eval.setRectifyStatus("PENDING");

        when(evaluationMapper.selectById(1L)).thenReturn(eval);

        evaluationService.rectify(1L, "已加强窗口人员培训");

        assertEquals("DONE", eval.getRectifyStatus());
        verify(rectifyMapper, times(1)).insert(any(Rectify.class));
        verify(evaluationMapper, times(1)).updateById(eval);
    }

    @Test
    void testRectifyNotBadEvaluation() {
        Evaluation eval = new Evaluation();
        eval.setId(1L);
        eval.setIsBad(0);   // 不是差评

        when(evaluationMapper.selectById(1L)).thenReturn(eval);

        assertThrows(BizException.class,
                () -> evaluationService.rectify(1L, "整改内容"));
        verify(rectifyMapper, never()).insert(any());
    }

    @Test
    void testRectifyAlreadyDone() {
        Evaluation eval = new Evaluation();
        eval.setId(1L);
        eval.setIsBad(1);
        eval.setRectifyStatus("DONE");

        when(evaluationMapper.selectById(1L)).thenReturn(eval);

        assertThrows(BizException.class,
                () -> evaluationService.rectify(1L, "整改内容"));
    }

    @Test
    void testRectifyWithEmptyContent() {
        Evaluation eval = new Evaluation();
        eval.setId(1L);
        eval.setIsBad(1);
        eval.setRectifyStatus("PENDING");

        when(evaluationMapper.selectById(1L)).thenReturn(eval);

        assertThrows(BizException.class,
                () -> evaluationService.rectify(1L, ""));
    }

    @Test
    void testRectifyEvaluationNotFound() {
        when(evaluationMapper.selectById(999L)).thenReturn(null);

        assertThrows(BizException.class,
                () -> evaluationService.rectify(999L, "整改内容"));
    }
}