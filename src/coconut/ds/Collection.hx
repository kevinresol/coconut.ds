package coconut.ds;

import tink.pure.List;
import tink.state.Observable;
import tink.state.Promised;
import coconut.data.ObservablesOf;
import coconut.ds.Dict;

using tink.CoreApi;

typedef Init<Key, RawData, Item> = {
	fetch:Void->Promise<List<RawData>>,
	extractKey:RawData->Key,
	createItem:Key->Option<RawData>->Item,
	updateItem:Item->RawData->Void,
	?cache:Option<List<Item>>,
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
	
	public inline function sub(fetch:Void->Promise<List<RawData>>):SubCollection<K, RawData, Item> {
		return new SubCollection({
			fetch: fetch,
			parent: this,
		});
	}
	
	@:to inline function toIntCollection<K:Int, RawData, Item>(init):IntCollection<RawData, Item>
		return new IntCollection<RawData, Item>(init);
	
	@:to inline function toStringCollection<K:String, RawData, Item>(init):StringCollection<RawData, Item>
		return new StringCollection<RawData, Item>(init);
	
	@:to inline function toEnumValueCollection<K:EnumValue, RawData, Item>(init):EnumValueCollection<RawData, Item>
		return new EnumValueCollection<RawData, Item>(init);
	
	@:from static inline function fromIntCollection<RawData, Item>(collection:IntCollection<RawData, Item>):Collection<Int, RawData, Item>
		return collection;
	
	@:from static inline function fromStringCollection<RawData, Item>(collection:StringCollection<RawData, Item>):Collection<String, RawData, Item>
		return collection;
	
	@:from static inline function fromEnumValueCollection<RawData, Item>(collection:EnumValueCollection<RawData, Item>):Collection<EnumValue, RawData, Item>
		return collection;
}

interface ICollection<K, RawData, Item> {
	var list(get, never):Promised<List<Item>>;
	var map(get, never):Dict<K, Item>;
	var observables(default, never):ObservablesOfCollection<K, RawData, Item>;
	var updateItem(get, never):Item->RawData->Void;
	var extractKey(get, never):RawData->K;
	function refresh(?cache:Option<List<Item>>):Void;
}

typedef ObservablesOfCollection<K, RawData, Item> = {
	var updateItem(default, never):Observable<Item->RawData->Void>;
	var map(default, never):Observable<Dict<K, Item>>;
	var list(default, never):Observable<Promised<List<Item>>>;
	var isInTransition(default, never):Observable<Bool>;
	var fetch(default, never):Observable<Void->Promise<List<RawData>>>;
	var extractKey(default, never):Observable<RawData->K>;
	// var createItem(default, never):Observable<K->Option<RawData>->Item>;
}

class IntCollection<RawData, Item> implements coconut.data.Model implements ICollection<Int, RawData, Item> {
	@:editable private var revision:Int = 0;
	@:constant var fetch:Void->Promise<List<RawData>>;
	@:constant var createItem:Int->Option<RawData>->Item;
	@:constant var updateItem:Item->RawData->Void;
	@:constant var extractKey:RawData->Int;
	@:editable private var cache:Option<List<Item>> = @byDefault None;
	@:loaded var list:List<Item> = {
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
	
	@:keep public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
}

class StringCollection<RawData, Item> implements coconut.data.Model implements ICollection<String, RawData, Item> {
	@:editable private var revision:Int = 0;
	@:constant var fetch:Void->Promise<List<RawData>>;
	@:constant var createItem:String->Option<RawData>->Item;
	@:constant var updateItem:Item->RawData->Void;
	@:constant var extractKey:RawData->String;
	@:editable private var cache:Option<List<Item>> = @byDefault None;
	@:loaded var list:List<Item> = {
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
	
	@:keep public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
}

class EnumValueCollection<RawData, Item> implements coconut.data.Model implements ICollection<EnumValue, RawData, Item> {
	@:editable private var revision:Int = 0;
	@:constant var fetch:Void->Promise<List<RawData>>;
	@:constant var createItem:EnumValue->Option<RawData>->Item;
	@:constant var updateItem:Item->RawData->Void;
	@:constant var extractKey:RawData->EnumValue;
	@:editable private var cache:Option<List<Item>> = @byDefault None;
	@:loaded var list:List<Item> = {
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
	
	@:keep public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
}
