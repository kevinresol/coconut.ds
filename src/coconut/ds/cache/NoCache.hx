package coconut.ds.cache;

using tink.CoreApi;

@:forward
abstract NoCache<T>(NoCacheBase<T>) to Cache<T> {
	static var inst:NoCacheBase<Dynamic> = new NoCacheBase();
	
	public function new()
		this = cast inst;
}

private class NoCacheBase<T> implements Cache<T> {
	public function new() {}
	
	public function get():Future<Option<T>> {
		return Future.sync(None);
	}
	
	public function set(v:T):Future<Noise> {
		return Future.sync(Noise);
	}
}
