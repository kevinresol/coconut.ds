package;

import coconut.ds.*;
import coconut.ds.Collection;
import tink.anon.*;
import tink.pure.List;

using tink.state.Promised;
using tink.CoreApi;
using Lambda;

@:asserts
class CollectionTest extends Base {
	var server:Array<Data> = [
		{id: 1, value: 'foo'},
		{id: 2, value: 'bar'},
	];
	
	public function int() {
		var collection = new Collection<Int, Data, Model>({
			fetch: function():Promise<List<Data>> return delay(function() return List.fromArray(server)),
			extractKey: function(data:Data):Int return data.id,
			createItem: function(id:Int, data:Option<Data>):Model {
				return new Model({
					cache: data,
					loader: function() return delay(function() return server.find(function(item) return item.id == id)),
					updater: function(_, v) {
						server = server.filter(function(item) return item.id != v.id).concat([v]);
						return v;
					}
				});
			},
			updateItem: function(model:Model, data:Data) model.refresh(Some(data)),
		});
		
		var sub = collection.sub(function():Promise<List<Data>> return delay(function() return List.fromArray(server.filter(function(v) return v.id == 1))));
		
		asserts.assert(collection.list == Loading);
		asserts.assert(sub.list == Loading);
		Future.delay(250, Noise)
			.next(function(_) {
				switch [collection.list, sub.list] {
					case [Done(items), Done(subitems)]: 
						asserts.assert(items.length == 2);
						asserts.assert(subitems.length == 1);
						asserts.assert(sub.get(1) == collection.get(1), 'SubCollection gets the same reference as in its parent Collection');
					case [Failed(e), _] | [_, Failed(e)]:
						asserts.fail(e);
					case _:
						asserts.fail(new Error('Expected Done'));
				}
				return Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
}

private typedef Data = ReadOnly<{id:Int, value:String}>;
private typedef Model = Updatable<Data, Data>;

