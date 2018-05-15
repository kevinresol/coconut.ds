package coconut.ds;

import tink.pure.*;
import coconut.data.*;

using tink.state.Promised;
using tink.CoreApi;

typedef Envelope<T> = {
	var total(default, never):Int;
	var data(default, never):List<T>;
}

class PaginatedList<T> implements Model {
	
	@:editable var page:Int = @byDefault 0;
	@:constant var perPage:Int = @byDefault 10;
	@:constant var load:Int->Int->Promise<Envelope<T>>; // page->perPage->result
	@:loaded var current:Envelope<T> = load(page, perPage);
	@:loaded var total:Int = current.next(function(e) return e.total);
	@:loaded var maxPage:Int = total.next(function(v) return Math.floor(v / perPage));
	@:loaded var data:List<T> = current.next(function(e) return e.data);
	// @:constant var cache:ObservableMap<Int, Envelope> = new ObservableMap();
	
	inline function nextPage()
		page += 1;
	
	inline function prevPage()
		page -= 1;
}