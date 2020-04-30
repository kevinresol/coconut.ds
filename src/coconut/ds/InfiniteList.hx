package coconut.ds;

import coconut.ds.cache.*;
import coconut.data.*;
import tink.state.*;
using tink.CoreApi;

@:forward
abstract InfiniteList<T>(InfiniteListImpl<T>) from InfiniteListImpl<T> to InfiniteListImpl<T> {
	public function new(initial) {
		this = new InfiniteListImpl<T>(initial);
		Observable.untracked(this.init);
	}
}

@:allow(coconut.ds.InfiniteList)
private class InfiniteListImpl<T> implements Model {
	@:constant var perPage:Int;
	@:constant var concat:List<T>->List<T>->List<T>; // existing->loaded->result
	@:constant var load:Option<T>->Int->Promise<List<T>>; // after->count->result
	@:constant var cache:Cache<List<T>> = @byDefault new NoCache();
	@:constant var onCacheLoaded:List<T>->Void = @byDefault null;
	
	@:editable private var cached:List<T> = null;
	@:observable private var loaded:Option<List<T>> = None;
	
	@:computed var list:List<T> = loaded.or(cached);
	@:computed var last:Option<T> = list.last();
	
	@:transition
	function reset() {
		cached = null;
		return {
			loaded: None,
		}
	}
	
	@:transition
	function init() {
		cache.get().handle(function(v) {
			cached = v.orNull();
			if(onCacheLoaded != null) onCacheLoaded(cached);
		});
		return loadAfter(None, true);
	}
	
	@:transition
	function refresh() {
		return loadAfter(None, true);
	}
	
	@:transition
	function loadNext() {
		return loadAfter(last);
	}
	
	@:transition
	function set(v) {
		trace('set');
		return {
			loaded: Some(v),
		}
	}
	
	function loadAfter(last, reset = false):Promise<coconut.data.Patch<InfiniteListImpl<T>>> {
		// if(isInTransition) return new Error('Already refreshing');
		return load(last, perPage)
			.next(function(v):coconut.data.Patch<InfiniteListImpl<T>> {
				var updated = switch loaded {
					case Some(list) if(!reset): concat(list, v);
					case _: v;
				};
				cached = updated;
				cache.set(updated).eager();
				return {
					loaded: Some(updated),
				}
			});
	}
}
