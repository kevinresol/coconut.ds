package coconut.ds.cache;

#if !macro
using tink.CoreApi;

@:require(tink_json, "Requires the tink_json library (https://github.com/haxetink/tink_json)")
@:genericBuild(coconut.ds.cache.JsonCache.build())
class JsonCache<T> {}

class JsonCacheBase<T> {
	var storage:Cache<String>;
	public function new(storage)
		this.storage = storage;
}

#else

import tink.macro.BuildCache;

using tink.MacroApi;

class JsonCache {
	public static function build() {
		return BuildCache.getType('coconut.ds.cache.JsonCache', ctx -> {
			var name = ctx.name;
			var ct = ctx.type.toComplex();
			
			var def = macro class $name extends coconut.ds.cache.JsonCache.JsonCacheBase<$ct> implements coconut.ds.cache.Cache<$ct> {
				public function get()
					return storage.get().next(v -> tink.Json.parse((tink.core.Option.OptionTools.orNull(v):$ct)))
						.next(haxe.ds.Option.Some)
						.recover(_ -> haxe.ds.Option.None);
				
				public function set(v:$ct)
					return storage.set(tink.Json.stringify(v));
			}
			
			def.pack = ['coconut','ds','cache'];
			
			return def;
		});
	}
}

#end