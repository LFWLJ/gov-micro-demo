package com.gov.application.service;

import java.util.List;
import java.util.Map;

public interface ProcessBizService {

    Map<String, Object> startProcess(String businessKey,
                                     String applicant,
                                     Map<String, Object> variables);

    List<Map<String, Object>> listTasks(String assignee);

    void completeTask(String taskId, Map<String, Object> variables);

    Map<String, Object> getProcessStatus(String processInstanceId);

    Map<String, Object> getProcessTrace(String processInstanceId);
}