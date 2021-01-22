package coconut.ds;

import tink.pure.List;

using tink.CoreApi;

/*
 * Shares the same underlying Dict as the parent Collection
 * so that any updates to the Item instances will be also be shared
 * For example, there are a collection of "all posts" and one for "post with tag X"
 * If there are 2 separate collections, updates to one item in one collection will not update the same-id item in the other collection
 * With SubCollection, the update will be shared.
 * 
 * ```haxe
 * var allPosts = new Collection({fetch: () -> listAllPosts()});
 * var postsWithTagX = allPosts.sub(() -> listPostsWithTag('X'));
 * postsWithTagX.get(id) == allPosts.get(id); // true, same instance
 * ```
 */
class SubCollection<Key, RawData, Item> implements coconut.data.Model implements coconut.ds.Collection.ICollection<Key, RawData, Item> {
	@:editable private var revision:Int = 0;
	@:constant var fetch:Void->Promise<List<RawData>>;
	@:constant var parent:Collection<Key, RawData, Item>;
	@:editable private var cache:Option<List<Item>> = @byDefault None;
	
	// forwards
	@:constant var map:Dict<Key, Item> = parent.map;
	@:constant var updateItem:Item->RawData->Void = parent.updateItem;
	@:constant var extractKey:RawData->Key = parent.extractKey;
	
	@:loaded var list:List<Item> = {
		revision;
		switch cache {
			case None:
				fetch().next(function(list) return list.map(function(data) {
					var item = parent.get(parent.extractKey(data));
					parent.updateItem(item, data);
					return item;
				}));
			case Some(v):
				v;
		}
	}
	
	public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
}