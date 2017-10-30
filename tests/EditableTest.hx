package;

import coconut.ds.*;

using tink.CoreApi;

@:asserts
class EditableTest {
	public function new() {}
	
	var server:{
		flat:FlatData,
	 } = {
		 flat: {name: 'John Doe', age: 48},
	 }
	
	public function flat() {
		var editable = new FlatEditable({
			loader: function() return Promise.lift(server.flat),
			updater: function(v) {
				switch v.name {
					case Some(v): server.flat.name = v;
					case _:
				}
				switch v.age {
					case Some(v): server.flat.age = v;
					case _:
				}
				return Noise;
			}
		});
		
		asserts.assert(editable.name == null);
		asserts.assert(editable.age == null);
		editable.refresh()
			.next(function(o) {
				asserts.assert(editable.name == server.flat.name);
				asserts.assert(editable.age == server.flat.age);
				return editable.update({name:Some('Chris Wong'), age:None});
			})
			.next(function(o) {
				asserts.assert(server.flat.name == 'Chris Wong');
				asserts.assert(server.flat.age == 48);
				asserts.assert(editable.name == server.flat.name);
				asserts.assert(editable.age == server.flat.age);
				return Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
}

typedef FlatData = {name:String, age:Int};
typedef FlatEditable = Editable<FlatData>;