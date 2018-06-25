package coconut.ds.cache;

using tink.CoreApi;

class NoCache<T> implements Cache<T> {
	public function new() {}
	
	public function get():Future<Option<T>> {
		return Future.sync(None);
	}
	
	public function set(v:T):Future<Noise> {
		return Future.sync(Noise);
	}
}
