package coconut.ds.cache;

#if !macro
using tink.CoreApi;

@:require(tink_json, "Requires the tink_json library (https://github.com/haxetink/tink_json)")
@:require(react_native, "Requires the react-native library (https://github.com/haxe-react/haxe-react-native)")
@:genericBuild(coconut.ds.cache.ReactNativeCache.build())
class ReactNativeCache<T> {}

class ReactNativeCacheBase {
	var key:String;
	
	public function new(key)
		this.key = key;
		
	function getItem()
		return Promise.ofJsPromise(react.native.api.AsyncStorage.getItem(key));
		
	function setItem(v):Promise<Noise>
		return Promise.ofJsPromise(react.native.api.AsyncStorage.setItem(key, v));
}

#else

import tink.macro.BuildCache;

using tink.MacroApi;

class ReactNativeCache {
	public static function build() {
		return BuildCache.getType('coconut.ds.cache.ReactNativeCache', ctx -> {
			var name = ctx.name;
			var ct = ctx.type.toComplex();
			
			var def = macro class $name extends coconut.ds.cache.ReactNativeCache.ReactNativeCacheBase implements coconut.ds.cache.Cache<$ct> {
				public function get()
					return getItem().next(v -> tink.Json.parse((v:$ct))).recover(_ -> null);
				
				public function set(v:$ct)
					return setItem(tink.Json.stringify(v)).recover(_ -> Noise);
			}
			
			def.pack = ['coconut','ds','cache'];
			
			return def;
		});
	}
}

#end