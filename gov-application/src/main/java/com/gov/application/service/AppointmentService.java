package com.gov.application.service;

import com.gov.application.entity.Appointment;

import java.util.List;
import java.util.Map;

public interface AppointmentService {

    Map<String, Object> page(int page, int size, String keyword,
                             String status, String appointDate);

    Map<String, Object> create(Appointment appointment);

    void checkin(Long id);

    void finish(Long id);

    void cancel(Long id, String reason);

    List<Appointment> todayQueue();

    Map<String, Object> stats();
}