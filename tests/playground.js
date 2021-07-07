import {Zymkey} from '../dist/Zymkey.js'
import ref from 'ref-napi'

// console.log(ref.types.void)

// const Zymkey = require('../dist/Zymkey.js').Zymkey

const zymkey = new Zymkey();
zymkey.open();
console.log(zymkey.getModelNumberString());