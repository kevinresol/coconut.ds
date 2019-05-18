package;

import coconut.ds.Dict;
import deepequal.DeepEqual.*;

@:asserts
class DictTest extends Base {
	
	public function int() {
		var dict = new Dict<Int, Object<Int>>(function(i) return {id: i});
		asserts.assert(dict.get(1).id == 1);
		asserts.assert(dict.get(2, function(i) return {id: i + 1}).id == 3);
		return asserts.done();
	}
	
	public function string() {
		var dict = new Dict<String, Object<String>>(function(i) return {id: i});
		asserts.assert(dict.get('a').id == 'a');
		asserts.assert(dict.get('b', function(i) return {id: i + '1'}).id == 'b1');
		return asserts.done();
	}
	
	public function enumValue() {
		var dict = new Dict<E, Object<E>>(function(i) return {id: i});
		asserts.assert(compare(A(1), dict.get(A(1)).id));
		asserts.assert(compare(A(3), dict.get(A(2), function(i) return {id: switch i {case A(v): A(v+1);}}).id));
		return asserts.done();
	}
}


private typedef Object<T> = {
	var id(default, never):T;
}

private enum E {
	A(i:Int);
}