import { describe, expect, it } from "vitest"
import { mountSuspended } from "@nuxt/test-utils/runtime"
import StatCard from "~/components/StatCard.vue"

describe("StatCard", () => {
  it("renderiza o rótulo, o valor e a dica", async () => {
    const wrapper = await mountSuspended(StatCard, {
      props: { label: "Ativos", value: 10, hint: "no mês" },
    })

    expect(wrapper.text()).toContain("Ativos")
    expect(wrapper.text()).toContain("10")
    expect(wrapper.text()).toContain("no mês")
  })

  it("não renderiza a dica quando ela não é passada", async () => {
    const wrapper = await mountSuspended(StatCard, {
      props: { label: "Total", value: 5 },
    })

    expect(wrapper.find(".stat-hint").exists()).toBe(false)
  })

  it("aplica a classe do tom escolhido", async () => {
    const wrapper = await mountSuspended(StatCard, {
      props: { label: "Desligados", value: 1, tone: "danger" },
    })

    expect(wrapper.find(".stat").classes()).toContain("tone-danger")
  })

  it("usa o tom padrão quando nenhum é informado", async () => {
    const wrapper = await mountSuspended(StatCard, {
      props: { label: "Funcionários", value: 12 },
    })

    expect(wrapper.find(".stat").classes()).toContain("tone-default")
  })
})
