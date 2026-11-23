/**
 * @author JuanFuent.es
 * @desc Imprime en consola del browser créditos
 * @param { String } Message
 */
export default class Credits {
    constructor(msg = "Lorem Credits") {
        this.msg = [
            `%c ${msg}`,
            'background: blue; color: #FFF; padding: 5px 5px 5px 5px;'
        ]
        this.roll()
    }
    
    roll() {
        console.log.apply(console, this.msg)
    }
}