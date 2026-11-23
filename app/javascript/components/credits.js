/**
 * @author JuanFuent.es
 * @desc Prints the code and design credits in the browser console
 * @param { String } msg
 */
export default class Credits {
    constructor(msg = "Aristotle House · Code and design by JuanFuent.es") {
        this.msg = [
            `%c ${msg} `,
            'background: #0B0A0F; color: #F2EFE8; padding: 5px;'
        ]
        this.roll()
    }

    roll() {
        console.log.apply(console, this.msg)
    }
}
