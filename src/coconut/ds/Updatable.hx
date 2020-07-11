package coconut.ds;

using tink.CoreApi;
using tink.state.Promised;

class Updatable<Content, Patch> implements coconut.data.Model {
	@:constant var loader:Void->Promise<Content>;
	@:constant var updater:Content->Patch->Promise<Content>;
	@:editable private var revision:Int = 0;
	@:editable private var cache:Option<Content> = @byDefault None;
	@:loaded var data:Content = {
		revision;
		switch cache {
			case None: loader();
			case Some(v): v;
		}
	}
	
	@:keep public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
	
	public function update(patch) {
		var ret = observables.data.getNext(function(v) return v.toOption()).next(updater.bind(_, patch));
		ret.handle(function(o) switch o {
			case Success(v): refresh(Some(v));
			case Failure(e): // skip
		});
		return ret;
	}
}
