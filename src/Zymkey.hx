package;

import js.node.Buffer;
import js.node.Crypto;

@:keep
class Zymkey {
	final _zkLib:Dynamic;
	var _zkCtx:Dynamic;
	
	public function new(path = '/usr/lib/libzk_app_utils.so') {

		// ref: https://docs.zymbit.com/api/c_api/
		// ref: https://github.com/Oaken-Innovations/zymkey/blob/master/index.js
		final zkCtx = Ref.refType(Ref.types.void);
		final zkCtxPtr = Ref.refType(zkCtx);
		
		_zkLib = Ffi.library(path, {
			'zkOpen': ['int', [zkCtxPtr]],
			'zkClose': ['int', [zkCtx]],
			'zkLEDOn': ['int', [zkCtx]],
			'zkLEDOff': ['int', [zkCtx]],
			'zkLEDFlash': ['int', [zkCtx, 'uint', 'uint', 'uint']],
			'zkGetRandBytes': ['int', [zkCtx, 'byte **', 'int']],
			'zkLockDataB2B': ['int', [zkCtx, 'byte *', 'int', 'byte **', 'int *', 'bool']],
			'zkUnlockDataB2B': ['int', [zkCtx, 'byte *', 'int', 'byte **', 'int *', 'bool']],
			'zkGenECDSASigFromDigest': ['int', [zkCtx, 'void *', 'int', 'void **', 'int *']],
			'zkVerifyECDSASigFromDigest': ['int', [zkCtx, 'void *', 'int', 'void *', 'int']],
			'zkExportPubKey': ['int', [zkCtx, 'byte **', 'int *', 'int', 'bool']],
			'zkGetModelNumberString': ['int', [zkCtx, 'char **']],
			'zkGetSerialNumberString': ['int', [zkCtx, 'char **']],
			'zkGetFirmwareVersionString': ['int', [zkCtx, 'char **']],
			'zkGetCurrentBindingInfo': ['int', [zkCtx, 'bool *', 'bool *']],
		});
	}
	
	public function open():Void {
		final ptr = Ref.alloc('pointer');
		assert(_zkLib.zkOpen(ptr), 'open');
		_zkCtx = ptr.deref();
	}
	
	public function ledOn():Void {
		assert(_zkLib.zkLEDOn(_zkCtx), 'ledOn');
	}
	
	public function ledOff():Void {
		assert(_zkLib.zkLEDOff(_zkCtx), 'ledOff');
	}
	
	public function ledFlash(onMs:Int, offMs:Int, numFlashes:Int):Void {
		assert(_zkLib.zkLEDFlash(_zkCtx, onMs, offMs, numFlashes), 'ledFlash');
	}
	
	public function getRandBytes(size:Int):Buffer {
		final dst = Ref.alloc('pointer');
		assert(_zkLib.zkGetRandBytes(_zkCtx, dst, size), 'getRandBytes');
		return dst.readPointer(0, size);
	}
	
	public function lockDataB2B(src:Buffer, useSharedKey:Bool):Buffer {
		final dst = Ref.alloc('pointer');
		final dstSize = Ref.alloc('int');
		assert(_zkLib.zkLockDataB2B(_zkCtx, src, src.length, dst, dstSize, useSharedKey), 'lockDataB2B');
		return dst.readPointer(0, dstSize.deref());
	}
	
	public function unlockDataB2B(src:Buffer, useSharedKey:Bool):Buffer {
		final dst = Ref.alloc('pointer');
		final dstSize = Ref.alloc('int');
		assert(_zkLib.zkUnlockDataB2B(_zkCtx, src, src.length, dst, dstSize, useSharedKey), 'unlockDataB2B');
		return dst.readPointer(0, dstSize.deref());
	}
	
	public function exportPubKey(pubkeySlot:Int, slotIsForeign:Bool):Buffer {
		final dst = Ref.alloc('pointer');
		final dstSize = Ref.alloc('int');
		assert(_zkLib.zkExportPubKey(_zkCtx, dst, dstSize, pubkeySlot, slotIsForeign), 'exportPubKey');
		return dst.readPointer(0, dstSize.deref());
	}
	
	public function sign(src:Buffer, slot:Int):Buffer {
		final sha256 = Crypto.createHash('sha256').update(src);
		return genECDSASigFromDigest(sha256.digest(), slot);
	}
	
	public function verify(src:Buffer, slot:Int, signature:Buffer):Bool {
		final sha256 = Crypto.createHash('sha256').update(src);
		return verifyECDSASigFromDigest(sha256.digest(), slot, signature);
	}
	
	public function genECDSASigFromDigest(digest:Buffer, slot:Int):Buffer {
		final dst = Ref.alloc('pointer');
		final dstSize = Ref.alloc('int');
		assert(_zkLib.zkGenECDSASigFromDigest(_zkCtx, digest, slot, dst, dstSize), 'genECDSASigFromDigest');
		return dst.readPointer(0, dstSize.deref());
	}
	
	public function verifyECDSASigFromDigest(digest:Buffer, slot:Int, signature:Buffer):Bool {
		final result = _zkLib.zkVerifyECDSASigFromDigest(_zkCtx, digest, slot, signature, signature.length);
		assert(result, 'verifyECDSASigFromDigest');
		return result == 1;
	}
	
	public function getModelNumberString():String {
		final result = Ref.alloc('pointer');
		assert(_zkLib.zkGetModelNumberString(_zkCtx, result), 'getModelNumberString');
		return result.deref().readCString();
	}
	
	public function getFirmwareVersionString():String {
		final result = Ref.alloc('pointer');
		assert(_zkLib.zkGetFirmwareVersionString(_zkCtx, result), 'getFirmwareVersionString');
		return result.deref().readCString();
	}
	
	public function getSerialNumberString():String {
		final result = Ref.alloc('pointer');
		assert(_zkLib.zkGetSerialNumberString(_zkCtx, result), 'getSerialNumberString');
		return result.deref().readCString();
	}
	
	public function close():Void {
		assert(_zkLib.zkClose(_zkCtx), 'close');
	}
	
	inline function assert(v:Int, name:String) {
		if(v < 0) throw new haxe.Exception('$name failed ($v)');
	}
}


@:jsRequire('ref-napi' #if genes , 'default' #end)
extern class Ref {
	static final types:Dynamic;
	static function alloc(v:Dynamic):Dynamic;
	static function ref(v:Dynamic):Dynamic;
	static function refType(v:Dynamic):Dynamic;
	static function getType(v:Dynamic):Dynamic;
	static function get(v:Dynamic):Dynamic;
	static function reinterpret(v:Dynamic, size:Int, offset:Int):Buffer;
}
@:jsRequire('ffi-napi' #if genes , 'default' #end)
extern class Ffi {
	@:native('Library')
	static function library(path:String, fields:Dynamic<Array<Dynamic>>):Dynamic;
}