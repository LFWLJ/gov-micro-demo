import api from './request'

export function listTasks(assignee) {
  return api.get('/api/process/tasks', { params: { assignee } })
}

export function startProcess(data) {
  return api.post('/api/process/start', data)
}

export function completeTask(taskId, data) {
  return api.post(`/api/process/complete/${taskId}`, data)
}

// ★ 新增这个
export function getProcessTrace(processInstanceId) {
  return api.get(`/api/process/trace/${processInstanceId}`)
}