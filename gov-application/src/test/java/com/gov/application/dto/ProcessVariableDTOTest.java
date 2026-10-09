package com.gov.application.dto;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 流程 DTO 的变量透传测试。
 *
 * <p>原来 {@code ProcessController} 直接收 {@code Map<String, Object>}：取出
 * {@code businessKey}/{@code applicant} 后，**其余键全部作为流程变量**传入。
 * 改用 DTO 后必须保证这一行为不变——尤其是「未显式声明的字段不能静默丢弃」，
 * 否则调用方传的自定义流程变量会莫名其妙消失。这里把该语义钉住。
 */
class ProcessVariableDTOTest {

    private final ObjectMapper mapper = new ObjectMapper();

    @Test
    void startDtoKeepsKnownAndUnknownVariables() throws Exception {
        String json = "{\"businessKey\":\"LEAVE-1\",\"applicant\":\"ZhangSan\","
                + "\"deptLeader\":\"LiSi\",\"director\":\"WangWu\",\"hr\":\"ZhaoLiu\","
                + "\"days\":3,\"extraFlag\":\"x\"}";

        ProcessStartDTO dto = mapper.readValue(json, ProcessStartDTO.class);

        assertEquals("LEAVE-1", dto.getBusinessKey());
        assertEquals("ZhangSan", dto.getApplicant());

        Map<String, Object> variables = dto.toVariables();

        // businessKey / applicant 由服务层单独处理，与原实现一致，不应出现在变量里
        assertFalse(variables.containsKey("businessKey"), "businessKey 不应作为流程变量");
        assertFalse(variables.containsKey("applicant"), "applicant 不应作为流程变量");

        assertEquals("LiSi", variables.get("deptLeader"));
        assertEquals("WangWu", variables.get("director"));
        assertEquals("ZhaoLiu", variables.get("hr"));
        assertEquals(3, ((Number) variables.get("days")).intValue());
        assertEquals("x", variables.get("extraFlag"), "未声明的字段必须照旧透传，不能静默丢弃");
    }

    @Test
    void startDtoOmitsAbsentOptionalFields() throws Exception {
        ProcessStartDTO dto = mapper.readValue(
                "{\"businessKey\":\"B-1\",\"applicant\":\"A\"}", ProcessStartDTO.class);

        Map<String, Object> variables = dto.toVariables();

        assertFalse(variables.containsKey("deptLeader"));
        assertFalse(variables.containsKey("days"));
        assertTrue(variables.isEmpty(), "未传的可选字段不应被写成 null 变量");
    }

    @Test
    void completeDtoKeepsKnownAndUnknownVariables() throws Exception {
        ProcessCompleteDTO dto = mapper.readValue(
                "{\"approved\":true,\"comment\":\"同意\",\"extra\":1}", ProcessCompleteDTO.class);

        Map<String, Object> variables = dto.toVariables();

        assertEquals(Boolean.TRUE, variables.get("approved"));
        assertEquals("同意", variables.get("comment"));
        assertEquals(1, ((Number) variables.get("extra")).intValue());
    }
}
