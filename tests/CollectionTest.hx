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
			createItem: function(id:Int, data:Data):Model {
				return new Model({
					cache: Some(data),
					loader: function() return delay(function() return server.find(function(item) return item.id == id)),
					updater: function(_, v) {
						server = server.filter(function(item) return item.id != v.id).concat([v]);
						return v;
					}
				});
			},
			updateItem: function(model:Model, data:Data) model.refresh(Some(data)),
		});
		
		asserts.assert(collection.list == Loading);
		Future.delay(250, Noise)
			.next(function(_) {
				switch collection.list {
					case Done(items): 
						asserts.assert(items.length == 2);
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

private typedef Data = ReadOnly<{id:Int, value:String}>;
private typedef Model = Updatable<Data, Data>;