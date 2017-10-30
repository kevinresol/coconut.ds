package;

import coconut.ds.*;

using tink.CoreApi;

@:asserts
class EditableTest {
	public function new() {}
	
	var server:{
		flat:FlatData,
		nested:NestedData,
	 } = {
		 flat: {name: 'John Doe', age: 48},
		 nested: {name: 'John Doe', age: 48, contact: {phone: '987654321', email: 'john@doe.com'}},
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
	
	public function nested() {
		var editable = new NestedEditable({
			loader: function() return Promise.lift(server.nested),
			updater: function(v) {
				switch v.name {
					case Some(v): server.nested.name = v;
					case _:
				}
				switch v.age {
					case Some(v): server.nested.age = v;
					case _:
				}
				switch v.contact {
					case Some(c):
						switch c.phone {
							case Some(v): server.nested.contact.phone = v;
							case _:
						}
						switch c.email {
							case Some(v): server.nested.contact.email = v;
							case _:
						}
					case _:
				}
				return Noise;
			}
		});
		
		asserts.assert(editable.name == null);
		asserts.assert(editable.age == null);
		asserts.assert(editable.contact == null);
		editable.refresh()
			.next(function(o) {
				asserts.assert(editable.name == server.nested.name);
				asserts.assert(editable.age == server.nested.age);
				asserts.assert(editable.contact.phone == server.nested.contact.phone);
				asserts.assert(editable.contact.email == server.nested.contact.email);
				return editable.update({name:Some('Chris Wong'), age:None, contact:Some({phone:Some('123456789'), email:None})});
			})
			.next(function(o) {
				asserts.assert(server.nested.name == 'Chris Wong');
				asserts.assert(server.nested.age == 48);
				asserts.assert(server.nested.contact.phone == '123456789');
				asserts.assert(server.nested.contact.email == 'john@doe.com');
				asserts.assert(editable.name == server.nested.name);
				asserts.assert(editable.age == server.nested.age);
				asserts.assert(editable.contact.phone == server.nested.contact.phone);
				asserts.assert(editable.contact.email == server.nested.contact.email);
				return Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
}

typedef FlatData = {name:String, age:Int};
typedef FlatEditable = Editable<FlatData>;

typedef NestedData = {name:String, age:Int, contact:{phone:String, email:String}};
typedef NestedEditable = Editable<NestedData>;

