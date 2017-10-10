package coconut.ds;

import tink.pure.*;
import coconut.data.*;

using tink.CoreApi;

class PaginatedList<T> implements Model {
	@:observable var page:Int = @byDefault -1; // zero-indexed
	@:constant var perPage:Int;
	@:constant var loader:{
		function load(page:Int, perPage:Int):Promise<{total:Int, data:List<T>}>;
	}
	@:observable var total:Int = @byDefault -1;
	@:computed var maxPage:Int = total == -1 ? -1 : Math.ceil(total / perPage) - 1;
	@:observable var data:List<T> = @byDefault null;
	
		// if(cache.exists(page))
		// 	cache.get(page);
		// else {
		// 	var loaded = loader.getData(page, perPage);
		// 	var current = page; // page may be modified when loading
		// 	loaded.handle(function(o) switch o {
		// 		case Success(data): cache = cache.with(current, data);
		// 		case Failure(_):
		// 	});
		// 	loaded;
		// }
	// @:editable private var cache:Mapping<Int, List<T>> = new Mapping();
	
	@:transition
	function nextPage()
		return setPage(page + 1);
	
	@:transition
	function prevPage()
		return setPage(page - 1);
	
	@:transition
	function setPage(page:Int) {
		if(isInTransition) return Promise.lift(new Error('Already loading'));
		if(this.page == page) return @patch {};
		return loader.load(page, perPage)
			.next(function(o) return {
				page: page,
				total: o.total,
				data: o.data,
			});
	}
	
	// let's assume on the remote side the data is immutable as well
	// so we don't need to provide mechanisms to reset maxPage and cache
}