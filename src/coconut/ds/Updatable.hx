package coconut.ds;

using tink.CoreApi;

class Updatable<Content, Patch> implements coconut.data.Model {
	@:constant var loader:Void->Promise<Content>;
	@:constant var updater:Patch->Promise<Content>;
	@:editable private var revision:Int = 0;
	@:editable private var cache:Content = @byDefault null;
	@:loaded var data:Content = {revision; cache != null ? cache : loader();}
	
	public function refresh(?cache) {
		this.cache = cache;
		revision++;
	}
	
	public function update(data) {
		var ret = updater(data);
		ret.handle(function(o) switch o {
			case Success(v): refresh(v);
			case Failure(e): // skip
		});
		return ret;
	}
}