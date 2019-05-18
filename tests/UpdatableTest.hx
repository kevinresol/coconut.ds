package;

import coconut.ds.*;
import tink.anon.*;

using tink.state.Promised;
using tink.CoreApi;

@:asserts
class UpdatableTest extends Base {
	var data:Data = {name: 'John', age: 48}
	
	public function test() {
		var model = new Model({
			loader: function() return delay(function() return Promise.lift(data)),
			updater: function(v) return delay(function() return data = v),
		});
		
		asserts.assert(model.data == Loading);
		Future.delay(250, Noise)
			.next(function(_) {
				switch model.data {
					case Done(v): 
						asserts.assert(v.name == 'John');
						asserts.assert(v.age == 48);
					case Failed(e):
						asserts.fail(e);
					case Loading:
						asserts.fail(new Error('Expected Done'));
				}
				return model.update({name: 'Doe', age: 50});
			})
			.next(function(_) {
				switch model.data {
					case Done(v): 
						asserts.assert(v.name == 'Doe');
						asserts.assert(v.age == 50);
					case Failed(e):
						asserts.fail(e);
					case Loading:
						asserts.fail(new Error('Expected Done'));
				}
				return Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
	
}

private typedef Data = ReadOnly<{name:String, age:Int}>;
private typedef Model = Updatable<Data, Data>;