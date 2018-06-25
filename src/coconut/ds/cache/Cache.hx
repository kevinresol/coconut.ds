package coconut.ds.cache;

using tink.CoreApi;

@:pure
interface Cache<T> {
	function get():Future<Option<T>>;
	function set(v:T):Future<Noise>;
}