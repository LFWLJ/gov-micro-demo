package com.gov.application.dto;

import lombok.Data;
import java.util.List;

@Data
public class AssignUserDTO {
    private List<Long> userIds;
}