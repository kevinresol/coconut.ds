package coconut.ds;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.BuildCache;
using tink.MacroApi;

class Macro {
	public static function buildOptional() {
		return BuildCache.getType('coconut.ds.Optional', function(ctx) {
			var name = ctx.name;
			var ct = ctx.type.toComplex();
			var def = macro class $name {};
			function add(c:TypeDefinition) def.fields = def.fields.concat(c.fields);
			
			switch ctx.type.reduce() {
				case TAnonymous(_.get() => {fields: fields}):
					for(field in fields) {
						var fname = field.name;
						var ct = field.type.toComplex();
						if(field.type.reduce().match(TAnonymous(_))) ct = macro:coconut.ds.Optional<$ct>;
						add(macro class {
							var $fname:haxe.ds.Option<$ct>;
						});
					}
				default:
					ctx.pos.error('Only supports anonymous structures');
			}
			
			def.pack = ['coconut', 'ds'];
			def.kind = TDStructure;
			return def;
		});
	}
	
	public static function buildEditable() {
		return BuildCache.getType('coconut.ds.Editable', function(ctx) {
			var name = ctx.name;
			var ct = ctx.type.toComplex();
			var def = macro class $name implements coconut.data.Model {
				@:constant var loader:Void->tink.core.Promise<$ct>;
				@:constant var updater:coconut.ds.Optional<$ct>->tink.core.Promise<tink.core.Noise>;
				
				@:transition function refresh() 
					return loader().next(function(v) {
						set(v);
						return tink.core.Noise.Noise.Noise;
					}).swap({});
				
				@:transition function update(v:coconut.ds.Optional<$ct>)
					return updater(v).next(function(_) {
						setOptional(v);
						return tink.core.Noise.Noise.Noise;
					}).swap({});
			}
			
			function add(c:TypeDefinition) def.fields = def.fields.concat(c.fields);
			
			var setExprs = [];
			var setOptionalExprs = [];
			var objFields = [];
			
			switch ctx.type.reduce() {
				case TAnonymous(_.get() => {fields: fields}):
					for(field in fields) {
						var fname = field.name;
						var pname = '_$fname';
						var ct = field.type.toComplex();
						
						switch field.type.reduce() {
							case TAnonymous(_.get() => {fields: fields}):
								var ct = field.type.toComplex();
								var init = EObjectDecl([for(field in fields) {
									var ffname = field.name;
									{
										field: '_$ffname',
										expr: macro v.$fname.$ffname,
									}
								}].concat([{field: 'loader', expr: macro null}, {field: 'updater', expr: macro null}])).at(field.pos);
								setExprs.push(macro $i{pname} = new coconut.ds.Editable<$ct>($init));
								setOptionalExprs.push(macro switch v.$fname {
									case Some(v): @:privateAccess $i{pname}.setOptional(v);
									case None: // do nothing
								});
								objFields.push({field: fname, expr: macro $i{fname}});
								add(macro class {
									@:computed var $fname:coconut.ds.ReadOnly<$ct> = $i{pname} == null ? null : $i{pname}.asObject();
									@:editable private var $pname:coconut.ds.Editable<$ct> = @byDefault null;
								});
							
							default:
								setExprs.push(macro $i{pname} = v.$fname);
								setOptionalExprs.push(macro switch v.$fname {
									case Some(v): $i{pname} = v;
									case None: // do nothing
								});
								objFields.push({field: fname, expr: macro $i{fname}});
								add(macro class {
									@:computed var $fname:$ct = $i{pname};
									@:editable private var $pname:$ct = @byDefault null;
								});
						}
						
						
					}
				default:
					ctx.pos.error('Only supports anonymous structures');
			}
			
			add(macro class {
				public function set(v:$ct)
					$b{setExprs};
					
				public function setOptional(v:coconut.ds.Optional<$ct>)
					$b{setOptionalExprs};
					
				public function asObject():coconut.ds.ReadOnly<$ct>
					return ${EObjectDecl(objFields).at()};
			});
			
			def.pack = ['coconut', 'ds'];
			return def;
		});
	}
}