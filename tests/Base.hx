package;

using tink.CoreApi;

class Base {
	public function new() {}
	
	function delay<T>(f:Void->Promise<T>, ms = 200)
		return Future.async(function(cb) haxe.Timer.delay(function() f().handle(cb), ms));
}