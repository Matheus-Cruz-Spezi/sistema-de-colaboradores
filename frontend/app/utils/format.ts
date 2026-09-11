const brl = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" })
const dateFmt = new Intl.DateTimeFormat("pt-BR", { day: "2-digit", month: "2-digit", year: "numeric" })
const dateTimeFmt = new Intl.DateTimeFormat("pt-BR", { dateStyle: "short", timeStyle: "short" })

export function currency(value: number | null | undefined): string {
  return value == null ? "—" : brl.format(value)
}

export function formatDate(value: string | null | undefined): string {
  return value ? dateFmt.format(new Date(value)) : "—"
}

export function formatDateTime(value: string | null | undefined): string {
  return value ? dateTimeFmt.format(new Date(value)) : "—"
}

export function statusLabel(status: string): string {
  return { active: "Ativo", on_leave: "Afastado", terminated: "Desligado" }[status] ?? status
}

export function statusTone(status: string): "success" | "warning" | "danger" | "default" {
  return { active: "success", on_leave: "warning", terminated: "danger" }[status] as never ?? "default"
}

const rtf = new Intl.RelativeTimeFormat("pt-BR", { numeric: "auto" })

/** "há 5 minutos", "ontem", "há 3 dias"… a partir de um timestamp ISO. */
export function timeAgo(value: string | null | undefined): string {
  if (!value) return "—"

  const diffMs = new Date(value).getTime() - Date.now()
  const diffMin = Math.round(diffMs / 60_000)
  if (Math.abs(diffMin) < 1) return "agora"
  if (Math.abs(diffMin) < 60) return rtf.format(diffMin, "minute")

  const diffHour = Math.round(diffMin / 60)
  if (Math.abs(diffHour) < 24) return rtf.format(diffHour, "hour")

  const diffDay = Math.round(diffHour / 24)
  if (Math.abs(diffDay) < 30) return rtf.format(diffDay, "day")

  const diffMonth = Math.round(diffDay / 30)
  return rtf.format(diffMonth, "month")
}

export function notificationIcon(category: string): string {
  return { info: "ℹ️", success: "✅", warning: "⚠️", alert: "🚨" }[category] ?? "🔔"
}

export function notificationTone(category: string): "success" | "warning" | "danger" | "default" {
  return { success: "success", warning: "warning", alert: "danger" }[category] as never ?? "default"
}
