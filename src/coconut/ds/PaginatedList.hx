package coconut.ds;

import tink.pure.*;
import coconut.data.*;

using tink.CoreApi;

class PaginatedList<T> implements Model {
	@:editable var page:Int = @byDefault 0; // zero-indexed
	@:constant var perPage:Int;
	@:constant var loader:{
		function getMaxPage(perPage:Int):Promise<Int>;
		function getData(page:Int, perPage:Int):Promise<List<T>>;
	}
	@:loaded var maxPage:Int = loader.getMaxPage(perPage); // zero-indexed
	@:loaded var data:List<T> = 
		if(cache.exists(page))
			cache.get(page);
		else {
			var loaded = loader.getData(page, perPage);
			var current = page; // page may be modified when loading
			loaded.handle(function(o) switch o {
				case Success(data): cache = cache.with(current, data);
				case Failure(_):
			});
			loaded;
		}
	@:editable private var cache:Mapping<Int, List<T>> = new Mapping();
	
	// let's assume on the remote side the data is immutable as well
	// so we don't need to provide mechanisms to reset maxPage and cache
}