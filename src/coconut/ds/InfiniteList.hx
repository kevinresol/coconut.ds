package coconut.ds;

import coconut.data.*;
using tink.CoreApi;

class InfiniteList<T> implements Model {
	@:constant var perPage:Int;
	@:constant var loader:{
		function concat(existing:List<T>, loaded:List<T>):List<T>;
		function load(after:Option<T>, perPage:Int):Promise<List<T>>;
	}
	@:observable var list:List<T> = @byDefault null;
	@:observable var last:Option<T> = @byDefault None;
	
	@:transition
	function reset() {
		if(isInTransition) return Promise.lift(new Error(Conflict, 'Already loading'));
		return {
			list: null,
			last: None,
		}
	}
	
	@:transition
	function loadNext() {
		if(isInTransition) return Promise.lift(new Error(Conflict, 'Already loading'));
		return loader.load(last, perPage)
			.next(function(loaded) return {
				list: loader.concat(list, loaded),
				last: switch loaded.last() {
					case None: last;
					case v: v;
				},
			});
	}
}