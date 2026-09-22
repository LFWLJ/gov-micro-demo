import api from './request'

export function getScreenOverview() {
  return api.get('/api/screen/overview')
}