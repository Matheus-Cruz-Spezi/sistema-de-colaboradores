// @vitest-environment node
// Funções puras — não precisam do runtime do Nuxt, então rodam no ambiente "node" (mais rápido).
import { describe, expect, it } from "vitest"
import {
  currency,
  formatDate,
  formatDateTime,
  notificationIcon,
  notificationTone,
  statusLabel,
  statusTone,
  timeAgo,
} from "~/utils/format"

// Intl.NumberFormat separa "R$" do valor com um espaço especial (U+00A0), não com um espaço comum (U+0020).
function collapseSpaces(value: string): string {
  return value.replace(/[  ]/g, " ")
}

describe("currency", () => {
  it("formata em reais", () => {
    expect(collapseSpaces(currency(1234.5))).toBe("R$ 1.234,50")
    expect(collapseSpaces(currency(0))).toBe("R$ 0,00")
  })

  it("retorna — quando o valor é nulo ou indefinido", () => {
    expect(currency(null)).toBe("—")
    expect(currency(undefined)).toBe("—")
  })
})

describe("formatDate / formatDateTime", () => {
  it("formata uma data ISO no padrão pt-BR", () => {
    expect(formatDate("2024-01-05")).toBe("05/01/2024")
  })

  it("retorna — quando a data é nula", () => {
    expect(formatDate(null)).toBe("—")
    expect(formatDateTime(undefined)).toBe("—")
  })
})

describe("statusLabel / statusTone", () => {
  it("traduz cada situação do funcionário", () => {
    expect(statusLabel("active")).toBe("Ativo")
    expect(statusLabel("on_leave")).toBe("Afastado")
    expect(statusLabel("terminated")).toBe("Desligado")
  })

  it("devolve o próprio valor quando não reconhece a situação", () => {
    expect(statusLabel("desconhecido")).toBe("desconhecido")
  })

  it("associa um tom de cor a cada situação", () => {
    expect(statusTone("active")).toBe("success")
    expect(statusTone("on_leave")).toBe("warning")
    expect(statusTone("terminated")).toBe("danger")
    expect(statusTone("desconhecido")).toBe("default")
  })
})

describe("notificationIcon / notificationTone", () => {
  it("associa um ícone a cada categoria", () => {
    expect(notificationIcon("info")).toBe("ℹ️")
    expect(notificationIcon("success")).toBe("✅")
    expect(notificationIcon("warning")).toBe("⚠️")
    expect(notificationIcon("alert")).toBe("🚨")
    expect(notificationIcon("desconhecida")).toBe("🔔")
  })

  it("associa um tom de cor a cada categoria", () => {
    expect(notificationTone("success")).toBe("success")
    expect(notificationTone("warning")).toBe("warning")
    expect(notificationTone("alert")).toBe("danger")
    expect(notificationTone("info")).toBe("default")
  })
})

describe("timeAgo", () => {
  it('retorna "agora" para um instante muito recente', () => {
    expect(timeAgo(new Date().toISOString())).toBe("agora")
  })

  it("retorna — quando não há data", () => {
    expect(timeAgo(null)).toBe("—")
    expect(timeAgo(undefined)).toBe("—")
  })

  it("expressa minutos no passado", () => {
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60_000).toISOString()
    expect(timeAgo(fiveMinutesAgo)).toContain("minuto")
  })

  it("expressa dias no passado", () => {
    const threeDaysAgo = new Date(Date.now() - 3 * 24 * 60 * 60_000).toISOString()
    expect(timeAgo(threeDaysAgo)).toContain("dia")
  })
})
