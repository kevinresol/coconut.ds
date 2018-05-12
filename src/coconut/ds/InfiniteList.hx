package coconut.ds;

import coconut.data.*;
using tink.CoreApi;

class InfiniteList<T> implements Model {
	@:constant var perPage:Int;
	@:constant var concat:List<T>->List<T>->List<T>; // existing->loaded->result
	@:constant var load:Option<T>->Int->Promise<List<T>>; // after->count->result
	@:observable var list:List<T> = @byDefault null;
	@:observable var last:Option<T> = @byDefault None;
	
	@:transition
	function reset() {
		return {
			list: null,
			last: None,
		}
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
	function set(list:List<T>) {
		return {
			list: list,
			last: list.last(),
		}
	}
	
	function loadAfter(last, reset = false) {
		return load(last, perPage)
			.next(function(loaded) return {
				list: reset ? loaded : concat(list, loaded),
				last: switch loaded.last() {
					case None: last;
					case v: v;
				},
			});
	}
}