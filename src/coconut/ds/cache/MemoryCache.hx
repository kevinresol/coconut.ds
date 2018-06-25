package coconut.ds.cache;

using tink.CoreApi;

@:pure
class MemoryCache<T> implements Cache<T> {
	var value:T;
	
	public function new() {}
	
	public function get():Future<T> {
		return Future.sync(value);
	}
	
	public function set(v:T):Future<Noise> {
		value = v;
		return Future.sync(Noise);
	}
}
