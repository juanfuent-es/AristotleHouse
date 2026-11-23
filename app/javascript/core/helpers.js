/*  | |      | |      
 ___| |_ __ _| |_ ___ 
/ __| __/ _` | __/ __|
\__ \ || (_| | |_\__ \
|___/\__\__,_|\__|___/ */

import Stats from 'three/examples/jsm/libs/stats.module'

window.STATS = new Stats()
document.body.appendChild( window.STATS.dom )
window.event.on('animate', () => window.STATS.update())