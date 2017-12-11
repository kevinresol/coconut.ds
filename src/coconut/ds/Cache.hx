package coconut.ds;

using tink.CoreApi;

class Cache<T> implements coconut.data.Model {
	@:constant var load:Void->Promise<T>;
	@:editable private var cache:Option<T> = @:byDefault None;
	@:loaded var data:T = 
		switch cache {
			case Some(v): v;
			case None: load();
		} 
	
	public function setCache(v:T)
		cache = Some(v);
	
	public function clearCache()
		cache = None;
}