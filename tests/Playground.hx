package;

import js.node.Os;

class Playground {
	static function main() {
		final zymkey = new Zymkey();
		zymkey.open();
		
		zymkey.ledFlash(100, 3000, 0);
		trace(zymkey.getModelNumberString());
		trace(zymkey.getFirmwareVersionString());
		trace(zymkey.getSerialNumberString());
		
		final encrypted = zymkey.lockDataB2B(js.node.Buffer.from('Hello, World!'), false);
		trace(encrypted.toString('hex'));
		
		final decrypted = zymkey.unlockDataB2B(encrypted, false);
		trace(decrypted.toString());
		
		final sig = zymkey.sign(encrypted, 0);
		trace('sig', sig.toString('hex'));
		trace(zymkey.verify(encrypted, 0, sig));
		
		for(i in 0...3) trace(i, zymkey.exportPubKey(0, false).toString('hex'));
		for(i in 0...10) trace(i, zymkey.getRandBytes(64).toString('hex'));
	}
} 