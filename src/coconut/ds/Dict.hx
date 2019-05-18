package coconut.ds;

import tink.pure.*;

@:multiType(@:followWithAbstracts K)
abstract Dict<K, V>(IDict<K, V>) {
	public function new(factory:K->V);
	public inline function get(k:K, ?factory:K->V):V
		return this.get(k, factory);
	
	@:to static inline function toStringDict<K:String, V>(dict:IDict<K, V>, f):StringDict<V>
		return new StringDict<V>({factory: f});
		
	@:to static inline function toIntDict<K:Int, V>(dict:IDict<K, V>, f):IntDict<V>
		return new IntDict<V>({factory: f});
	
	@:to static inline function toEnumValueDict<K:EnumValue, V>(dict:IDict<K, V>, f):EnumValueDict<K,V>
		return new EnumValueDict<K,V>({factory: f});
	
	@:from static inline function fromStringDict<V>(dict:StringDict<V>):Dict<String, V>
		return cast dict;
		
	@:from static inline function fromIntDict<V>(dict:IntDict<V>):Dict<Int, V>
		return cast dict;
		
	@:from static inline function fromEnumValueDict<K:EnumValue, V>(dict:EnumValueDict<K, V>):Dict<K, V>
		return cast dict;
}

interface IDict<K, V> {
	function get(i:K, ?factory:K->V):V;
}

class IntDict<T> implements coconut.data.Model {
	@:editable private var map:Mapping<Int, T> = null;
	@:constant private var factory:Int->T;
	
	public function get(i:Int, ?factory:Int->T) {
		return if(!map.exists(i)) {
			var v = factory == null ? this.factory(i) : factory(i);
			map = map.with(i, v);
			v;
		} else {
			map.get(i);
		}
	}
}

class StringDict<T> implements coconut.data.Model {
	@:editable private var map:Mapping<String, T> = null;
	@:constant private var factory:String->T;
	
	public function get(i:String, ?factory:String->T) {
		return if(!map.exists(i)) {
			var v = factory == null ? this.factory(i) : factory(i);
			map = map.with(i, v);
			v;
		} else {
			map.get(i);
		}
	}
}

class EnumValueDict<K:EnumValue, T> implements coconut.data.Model {
	@:editable private var map:Mapping<K, T> = null;
	@:constant private var factory:K->T;
	
	public function get(i:K, ?factory:K->T) {
		return if(!map.exists(i)) {
			var v = factory == null ? this.factory(i) : factory(i);
			map = map.with(i, v);
			v;
		} else {
			map.get(i);
		}
	}
}