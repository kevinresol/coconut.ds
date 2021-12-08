package coconut.ds;

import tink.pure.Vector;
import tink.state.Observable;
import tink.state.Promised;
import coconut.data.ObservablesOf;
import coconut.ds.Dict;

using tink.CoreApi;

typedef Init<Key, RawData, Item> = {
	fetch:Void->Promise<Vector<RawData>>,
	extractKey:RawData->Key,
	createItem:Key->Option<RawData>->Item,
	updateItem:Item->RawData->Void,
	?cache:Option<Vector<Item>>,
}

@:forward
@:multiType(@:followWithAbstracts K)
abstract Collection<K, RawData, Item>(ICollection<K, RawData, Item>) from ICollection<K, RawData, Item> {
	public var observables(get, never):ObservablesOfCollection<K, RawData, Item>;
	
	public function new(init:Init<K, RawData, Item>);
		
	public inline function get_observables():ObservablesOfCollection<K, RawData, Item>
		return this.observables;
		
	public inline function get(key:K):Item
		return this.map.get(key);
	
	public inline function sub(fetch:Void->Promise<Vector<RawData>>):Collection<K, RawData, Item> {
		return new SubCollection({
			fetch: fetch,
			parent: this,
		});
	}
	
	public inline function collect<V>(f:Item->Promised<V>):Promised<Vector<V>> {
		return this.list.flatMap(list -> PromisedTools.all(list.map(f))).map(Vector.fromArray);
	}
	
	public inline function iterator()
		return this.list.or(([]:Vector<Item>)).iterator();
	
	@:to static inline function toIntCollection<RawData, Item>(c:ICollection<Int, RawData, Item>, init):IntCollection<RawData, Item>
		return new IntCollection<RawData, Item>(init);
	
	@:to static inline function toStringCollection<RawData, Item>(c:ICollection<String, RawData, Item>, init):StringCollection<RawData, Item>
		return new StringCollection<RawData, Item>(init);
	
	@:to static inline function toEnumValueCollection<RawData, Item>(c:ICollection<EnumValue, RawData, Item>, init):EnumValueCollection<RawData, Item>
		return new EnumValueCollection<RawData, Item>(init);
	
	@:from static inline function fromIntCollection<RawData, Item>(collection:IntCollection<RawData, Item>):Collection<Int, RawData, Item>
		return cast collection;
	
	@:from static inline function fromStringCollection<RawData, Item>(collection:StringCollection<RawData, Item>):Collection<String, RawData, Item>
		return cast collection;
	
	@:from static inline function fromEnumValueCollection<RawData, Item>(collection:EnumValueCollection<RawData, Item>):Collection<EnumValue, RawData, Item>
		return cast collection;
}

interface ICollection<K, RawData, Item> {
	var list(get, never):Promised<Vector<Item>>;
	var map(get, never):Dict<K, Item>;
	var observables(default, never):ObservablesOfCollection<K, RawData, Item>;
	var updateItem(get, never):Item->RawData->Void;
	var extractKey(get, never):RawData->K;
	function refresh(?cache:Option<Vector<Item>>):Void;
}

typedef ObservablesOfCollection<K, RawData, Item> = {
	var updateItem(default, never):Observable<Item->RawData->Void>;
	var map(default, never):Observable<Dict<K, Item>>;
	var list(default, never):Observable<Promised<Vector<Item>>>;
	var isInTransition(default, never):Observable<Bool>;
	var fetch(default, never):Observable<Void->Promise<Vector<RawData>>>;
	var extractKey(default, never):Observable<RawData->K>;
	// var createItem(default, never):Observable<K->Option<RawData>->Item>;
}

class IntCollection<RawData, Item> implements coconut.data.Model implements ICollection<Int, RawData, Item> {
	@:editable private var revision:Int = 0;
	@:constant var fetch:Void->Promise<Vector<RawData>>;
	@:constant var createItem:Int->Option<RawData>->Item;
	@:constant var updateItem:Item->RawData->Void;
	@:constant var extractKey:RawData->Int;
	@:editable private var cache:Option<Vector<Item>> = @byDefault None;
	@:loaded var list:Vector<Item> = {
		revision;
		switch cache {
			case None:
				fetch().next(function(list) return list.map(function(data) {
					var item = map.get(extractKey(data));
					updateItem(item, data);
					return item;
				}));
			case Some(v):
				v;
		}
	}
	@:constant var map:Dict<Int, Item> = new Dict(createItem.bind(_, None));
	
	public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
}

class StringCollection<RawData, Item> implements coconut.data.Model implements ICollection<String, RawData, Item> {
	@:editable private var revision:Int = 0;
	@:constant var fetch:Void->Promise<Vector<RawData>>;
	@:constant var createItem:String->Option<RawData>->Item;
	@:constant var updateItem:Item->RawData->Void;
	@:constant var extractKey:RawData->String;
	@:editable private var cache:Option<Vector<Item>> = @byDefault None;
	@:loaded var list:Vector<Item> = {
		revision;
		switch cache {
			case None:
				fetch().next(function(list) return list.map(function(data) {
					var item = map.get(extractKey(data));
					updateItem(item, data);
					return item;
				}));
			case Some(v):
				v;
		}
	}
	@:constant var map:Dict<String, Item> = new Dict(createItem.bind(_, None));
	
	public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
}

class EnumValueCollection<RawData, Item> implements coconut.data.Model implements ICollection<EnumValue, RawData, Item> {
	@:editable private var revision:Int = 0;
	@:constant var fetch:Void->Promise<Vector<RawData>>;
	@:constant var createItem:EnumValue->Option<RawData>->Item;
	@:constant var updateItem:Item->RawData->Void;
	@:constant var extractKey:RawData->EnumValue;
	@:editable private var cache:Option<Vector<Item>> = @byDefault None;
	@:loaded var list:Vector<Item> = {
		revision;
		switch cache {
			case None:
				fetch().next(function(list) return list.map(function(data) {
					var item = map.get(extractKey(data));
					updateItem(item, data);
					return item;
				}));
			case Some(v):
				v;
		}
	}
	@:constant var map:Dict<EnumValue, Item> = new Dict(createItem.bind(_, None));
	
	public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
}