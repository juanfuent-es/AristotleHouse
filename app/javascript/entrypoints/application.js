/*  ____                  ________ 
   / __ \____  ____ ___  / ____/ / 
  / / / / __ \/ __ `__ \/ / __/ /  
 / /_/ / /_/ / / / / / / /_/ / /___
/_____/\____/_/ /_/ /_/\____/_____*/

import Credits from '../components/credits'
import Foil from '../components/foil'
import Reading from '../components/reading'

new Credits()
new Foil()

const reading = document.querySelector('[data-reading]')
if (reading) new Reading(reading)
