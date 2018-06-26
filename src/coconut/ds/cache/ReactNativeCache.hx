package coconut.ds.cache;

using tink.CoreApi;

@:require(react_native, "Requires the react-native library (https://github.com/haxe-react/haxe-react-native)")
class ReactNativeCache implements Cache<String> {
	var key:String;
	
	public function new(key)
		this.key = key;
		
	public function get():Future<Option<String>>
		return Promise.ofJsPromise(react.native.api.AsyncStorage.getItem(key))
			.next(Some)
			.recover(_ -> None);
		
	public function set(v):Future<Noise>
		return Promise.ofJsPromise(react.native.api.AsyncStorage.setItem(key, v))
			.noise()
			.recover(_ -> Noise);
}