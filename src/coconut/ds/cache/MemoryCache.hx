package coconut.ds.cache;

using tink.CoreApi;

class MemoryCache<T> implements Cache<T> {
	var value:Option<T> = None;
	
	public function new() {}
	
	public function get():Future<Option<T>> {
		return Future.sync(value);
	}
	
	public function set(v:T):Future<Noise> {
		value = Some(v);
		return Future.sync(Noise);
	}
}
