package;

import coconut.ds.*;
import tink.anon.*;

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
			id: '1',
			loader: function(id) return delay(function() return Promise.lift(server.flat)),
			updater: function(id, v) {
				return delay(function() {
					switch v.name {
						case Some(v): server.flat.name = v;
						case _:
					}
					switch v.age {
						case Some(v): server.flat.age = v;
						case _:
					}
					return Noise;
				});
			}
		});
		
		asserts.assert(editable.data == null);
		var refresh = editable.refresh();
		asserts.assert(editable.isInTransition);
		refresh
			.next(function(o) {
				asserts.assert(!editable.isInTransition);
				asserts.assert(editable.data.name == server.flat.name);
				asserts.assert(editable.data.age == server.flat.age);
				var update = editable.update({name:Some('Chris Wong'), age:None});
				asserts.assert(editable.isInTransition);
				return update;
			})
			.next(function(o) {
				asserts.assert(!editable.isInTransition);
				asserts.assert(server.flat.name == 'Chris Wong');
				asserts.assert(server.flat.age == 48);
				asserts.assert(editable.data.name == server.flat.name);
				asserts.assert(editable.data.age == server.flat.age);
				return Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
	
	public function nested() {
		var editable = new NestedEditable({
			id: '1',
			loader: function(id) return delay(function() return Promise.lift(server.nested)),
			updater: function(id, v) {
				return delay(function() {
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
				});
			}
		});
		
		asserts.assert(editable.data == null);
		var refresh = editable.refresh();
		asserts.assert(editable.isInTransition);
		refresh
			.next(function(o) {
				asserts.assert(!editable.isInTransition);
				asserts.assert(editable.data.name == server.nested.name);
				asserts.assert(editable.data.age == server.nested.age);
				asserts.assert(editable.data.contact.phone == server.nested.contact.phone);
				asserts.assert(editable.data.contact.email == server.nested.contact.email);
				var update = editable.update({name:Some('Chris Wong'), age:None, contact:Some({phone:Some('123456789'), email:None})});
				asserts.assert(editable.isInTransition);
				return update;
			})
			.next(function(o) {
				asserts.assert(!editable.isInTransition);
				asserts.assert(server.nested.name == 'Chris Wong');
				asserts.assert(server.nested.age == 48);
				asserts.assert(server.nested.contact.phone == '123456789');
				asserts.assert(server.nested.contact.email == 'john@doe.com');
				asserts.assert(editable.data.name == server.nested.name);
				asserts.assert(editable.data.age == server.nested.age);
				asserts.assert(editable.data.contact.phone == server.nested.contact.phone);
				asserts.assert(editable.data.contact.email == server.nested.contact.email);
				return Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
	
	function delay<T>(f:Void->Promise<T>, ms = 200)
		return Future.async(function(cb) haxe.Timer.delay(function() f().handle(cb), ms));
}

typedef FlatData = {name:String, age:Int};
typedef FlatEditable = Editable<String, ReadOnly<FlatData>>;

typedef NestedData = {name:String, age:Int, contact:{phone:String, email:String}};
typedef NestedEditable = Editable<String, ReadOnly<NestedData>>;

