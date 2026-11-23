/**
 * Ordered list of content blocks: add, move, remove. Works with the keyboard.
 * @author JuanFuent.es
 */
export default class Blocks {
    constructor(el) {
        this.el = el
        this.list = el.querySelector('[data-blocks-list]')
        this.template = el.querySelector('template')
        this.status = el.querySelector('[data-blocks-status]')
        this.next = Date.now()
        el.addEventListener('click', (e) => this.click(e))
        this.number()
    }

    get items() {
        return [...this.list.querySelectorAll('[data-block]:not([hidden])')]
    }

    click(e) {
        const button = e.target.closest('button[data-action]')
        if (!button) return
        const block = button.closest('[data-block]')
        const { action } = button.dataset
        if (action === 'add') this.add(button.dataset.category)
        if (action === 'remove') this.remove(block)
        if (action === 'up') this.move(block, -1, button)
        if (action === 'down') this.move(block, 1, button)
    }

    add(category) {
        const holder = document.createElement('div')
        holder.innerHTML = this.template.innerHTML.replaceAll('NEW_BLOCK', this.next++)
        // Keep only the fields this kind of block uses.
        holder.querySelectorAll('[data-for]').forEach((field) => {
            if (!field.dataset.for.split(' ').includes(category)) field.remove()
        })
        const block = holder.querySelector('[data-block]')
        block.querySelector('[data-category]').value = category
        block.querySelector('[data-name]').textContent = category
        this.list.append(block)
        this.changed(`${category} block added`)
        block.querySelector('input:not([type=hidden]), textarea, select')?.focus()
    }

    remove(block) {
        const destroy = block.querySelector('[data-destroy]')
        const neighbour = this.items[this.items.indexOf(block) + 1] || this.items[this.items.indexOf(block) - 1]
        if (destroy) {
            destroy.value = '1'
            block.hidden = true
        } else {
            block.remove()
        }
        this.changed('Block removed')
        const focus = neighbour?.querySelector('button') || this.el.querySelector('button[data-action=add]')
        focus.focus()
    }

    move(block, step, button) {
        const items = this.items
        const other = items[items.indexOf(block) + step]
        if (!other) return
        if (step < 0) other.before(block)
        else other.after(block)
        this.changed(`Block moved to position ${this.items.indexOf(block) + 1}`)
        button.focus()
    }

    changed(message) {
        this.number()
        this.status.textContent = message
        this.el.dispatchEvent(new CustomEvent('blocks:change', { bubbles: true }))
    }

    number() {
        this.items.forEach((block, i) => { block.querySelector('[data-number]').value = i })
    }
}
