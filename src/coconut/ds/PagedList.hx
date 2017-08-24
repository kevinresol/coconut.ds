package coconut.ds;

import coconut.data.*;
using tink.CoreApi;

class PagedList<T> implements Model {
	@:observable var page:Int = @byDefault 0;
	@:constant var perPage:Int;
	
	@:observable var list:List<T> = @byDefault null;
	@:constant var loader:{function load(page:Int, perPage:Int):Promise<List<T>>;}
	
	@:transition
	function reset() {
		return {
			page: 0, 
			list: null
		};
	}
	
	@:transition
	function init() {
		return loadPage(0, false);
	}
	
	@:transition
	function loadNext() {
		return loadPage(page + 1);
	}
	
	function loadPage(page:Int, append = true) {
		return loader.load(page, perPage)
			.next(function(loaded) {
				return @patch {
					page: page,
					list: if(append) list.concat(loaded) else loaded,
				}
			});
	}
	
}