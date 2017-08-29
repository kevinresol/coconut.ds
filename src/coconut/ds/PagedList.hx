package coconut.ds;

import coconut.data.*;
using tink.CoreApi;

class PagedList<T> implements Model {
	@:editable var page:Int = @byDefault 0;
	@:constant var perPage:Int;
	@:constant var loader:{function load(page:Int, perPage:Int):Promise<List<T>>;}
	@:loaded var list:List<T> = loader.load(page, perPage);
	// @:observable private var cache:Mapping<Int, List<T>>;
}