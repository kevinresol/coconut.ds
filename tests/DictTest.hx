package;

import coconut.ds.Dict;
import deepequal.DeepEqual.*;

@:asserts
class DictTest {
	public function new() {}
	
	public function int() {
		var dict = new Dict<Int, Object<Int>>({factory: function(i) return {id: i}});
		for(i in 0...5) asserts.assert(dict.get(i).id == i);
		return asserts.done();
	}
	
	public function string() {
		var dict = new Dict<String, Object<String>>({factory: function(i) return {id: i}});
		for(i in 0...5) {
			var s = '$i';
			asserts.assert(dict.get(s).id == s);
		}
		return asserts.done();
	}
	
	public function enumValue() {
		var dict = new Dict<EnumValue, Object<EnumValue>>({factory: function(i) return {id: i}});
		for(i in 0...5) {
			var s = A(i);
			asserts.assert(compare(A(i), dict.get(s).id));
		}
		return asserts.done();
	}
}


private typedef Object<T> = {
	var id(default, never):T;
}

private enum E {
	A(i:Int);
}