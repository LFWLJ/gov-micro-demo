package com.gov.application.tenant;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class DataScopeContextTest {

    @AfterEach
    void tearDown() {
        DataScopeContext.clear();
    }

    @Test
    void testSetAndGet() {
        DataScopeContext.set("1", "2", "3");

        assertEquals("1", DataScopeContext.getUserId());
        assertEquals(2L, DataScopeContext.getDeptId());
        assertEquals(3, DataScopeContext.getDataScope());
    }

    @Test
    void testSetNullValues() {
        DataScopeContext.set(null, null, null);

        assertNull(DataScopeContext.getUserId());
        assertNull(DataScopeContext.getDeptId());
        assertNull(DataScopeContext.getDataScope());
    }

    @Test
    void testInvalidDeptId() {
        DataScopeContext.set("1", "abc", "3");

        assertNull(DataScopeContext.getDeptId(), "非法 deptId 应转为 null");
        assertEquals(3, DataScopeContext.getDataScope());
    }

    @Test
    void testClear() {
        DataScopeContext.set("1", "2", "3");
        DataScopeContext.clear();

        assertNull(DataScopeContext.getUserId());
        assertNull(DataScopeContext.getDeptId());
        assertNull(DataScopeContext.getDataScope());
    }
}