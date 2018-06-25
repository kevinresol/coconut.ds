package coconut.ds;

import coconut.ds.cache.*;
import coconut.data.*;
using tink.CoreApi;

class InfiniteList<T> implements Model {
	@:constant var perPage:Int;
	@:constant var concat:List<T>->List<T>->List<T>; // existing->loaded->result
	@:constant var load:Option<T>->Int->Promise<List<T>>; // after->count->result
	
	@:constant var cache:Cache<List<T>> = @byDefault new MemoryCache();
	@:editable private var cached:List<T> = null;
	@:editable private var loaded:Option<List<T>> = None;
	
	@:computed var list:List<T> = loaded.or(cached);
	@:computed var last:Option<T> = list.last();
	
	public function reset() {
		cached = null;
		loaded = None;
	}
	
	public function init() {
		cache.get().handle(function(v) cached = v);
		return refresh();
	}
	
	public function refresh() {
		return loadAfter(None, true);
	}
	
	public function loadNext() {
		return loadAfter(last);
	}
	
	public function set(v) {
		loaded = Some(v);
	}
	
	public function loadAfter(last, reset = false) {
		return load(last, perPage)
			.next(function(v) {
				var updated = switch loaded {
					case Some(list) if(!reset): concat(list, v);
					case _: v;
				};
				cache.set(updated).eager();
				loaded = Some(updated);
				return Noise;
			});
	}
}
