import api from './request'

export function pageEvaluations(params) {
  return api.get('/api/evaluation/page', { params })
}

export function submitEvaluation(data) {
  return api.post('/api/evaluation', data)
}

export function rectifyEvaluation(id, content) {
  return api.post(`/api/evaluation/rectify/${id}`, { content })
}

export function getEvaluationStats() {
  return api.get('/api/evaluation/stats')
}