package coconut.ds;

using tink.CoreApi;

class Cache<T> implements coconut.data.Model {
	@:constant var load:Void->Promise<T>;
	@:observable private var revision:Int = @byDefault 0;
	@:observable private var cache:Option<T> = @byDefault None;
	@:loaded var data:T = {
		trace('load data');
		revision;
		switch cache {
			case Some(v): v;
			case None: load();
		} 
	}
	
	@:transition
	function refresh() {
		return {
			revision: revision + 1,
			cache: None,
		}
	}
	
	@:transition
	function setCache(v:T)
		return {cache: Some(v)};
	
	@:transition
	function clearCache()
		return {cache: None};
}