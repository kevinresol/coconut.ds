package;

import coconut.ds.*;
import tink.pure.List;
import tink.unit.Helper.*;

using tink.CoreApi;

@:asserts
class InfiniteListTest {
	public function new() {}
	
	public function test() {
		var list = new InfiniteList({
			perPage: 10,
			concat: function(current, loaded) return current.concat(loaded),
			load: function(after, count) return get(after.orNull(), count)
		});
		
		seq([
			lazy(
				function() return list.init()
			),
			lazy(
				function() return list.list,
				function(list) {
					asserts.assert(list.length == 10);
					asserts.assert(list.first().match(Some(0)));
					asserts.assert(list.last().match(Some(9)));
				}
			),
			lazy(
				function() return list.loadNext()
			),
			lazy(
				function() return list.list,
				function(list) {
					asserts.assert(list.length == 20);
					asserts.assert(list.first().match(Some(0)));
					asserts.assert(list.last().match(Some(19)));
				}
			),
			lazy(
				function() return list.refresh()
			),
			lazy(
				function() return list.list,
				function(list) {
					asserts.assert(list.length == 10);
					asserts.assert(list.first().match(Some(0)));
					asserts.assert(list.last().match(Some(9)));
				}
			),
		]).handle(asserts.handle);
		
		return asserts;
	}
	
	function get(after:Int, count:Int):Promise<List<Int>> {
		
		var start = after == null ? 0 : after + 1;
		return List.fromArray([for(i in start...start+count) i]);
	}
}