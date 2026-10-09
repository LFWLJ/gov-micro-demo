import { ElMessageBox } from 'element-plus'

/**
 * 确认对话框，用户取消返回 false，确认返回 true
 */
export async function confirm(message, title = '提示', options = {}) {
    try {
        await ElMessageBox.confirm(message, title, { type: 'warning', ...options })
        return true
    } catch (e) {
        return false
    }
}

/**
 * 输入对话框，用户取消返回 null，确认返回输入值
 */
export async function prompt(message, title = '提示', options = {}) {
    try {
        const { value } = await ElMessageBox.prompt(message, title, options)
        return value
    } catch (e) {
        return null
    }
}