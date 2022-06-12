package;


import haxe.io.Bytes;
import lime.utils.AssetBundle;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

		}

		if (rootPath == null) {

			#if (ios || tvos || emscripten)
			rootPath = "assets/";
			#elseif android
			rootPath = "";
			#elseif console
			rootPath = lime.system.System.applicationDirectory;
			#else
			rootPath = "./";
			#end

		}

		#if (openfl && !flash && !display)
		
		#end

		var data, manifest, library, bundle;

		#if kha

		null
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("null", library);

		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("null");

		#else

		data = '{"name":"card","assets":"aoy4:pathy8:card.biny4:sizei395423y4:typey4:TEXTy2:idR1y7:preloadtgh","rootPath":"lib/card","version":2,"libraryArgs":["card.bin","JefbeFal47exkc3w7opD"],"libraryType":"openfl._internal.formats.swf.SWFLiteLibrary"}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("card", library);
		data = '{"name":"ambient","assets":"aoy4:pathy11:ambient.biny4:sizei84024y4:typey4:TEXTy2:idR1y7:preloadtgh","rootPath":"lib/ambient","version":2,"libraryArgs":["ambient.bin","BDG6YVx7mnwTB0xW47JV"],"libraryType":"openfl._internal.formats.swf.SWFLiteLibrary"}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("ambient", library);
		data = '{"name":"walk","assets":"aoy4:pathy8:walk.biny4:sizei290599y4:typey4:TEXTy2:idR1y7:preloadtgh","rootPath":"lib/walk","version":2,"libraryArgs":["walk.bin","4Us1yF2KEt8cm1QCy5ek"],"libraryType":"openfl._internal.formats.swf.SWFLiteLibrary"}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("walk", library);
		data = '{"name":null,"assets":"aoy4:pathy17:assets%2Fwalk.swfy4:sizei26798y4:typey6:BINARYy2:idR1y7:preloadtgoR0y23:assets%2Fcardtestpp.swfR2i50474R3R4R5R7R6tgoR0y17:assets%2Fcard.swfR2i54755R3R4R5R8R6tgoR0y20:assets%2Fambient.swfR2i7114R3R4R5R9R6tgoR0y20:assets%2Fcolors.jsonR2i863R3y4:TEXTR5R10R6tgoR0y6:colorsR2i863R3R11R5R12R6tgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		

		library = Assets.getLibrary ("card");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("card");
		library = Assets.getLibrary ("ambient");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("ambient");
		library = Assets.getLibrary ("walk");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("walk");
		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

		#end

	}


}


#if kha

null

#else

#if !display
#if flash

@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_walk_swf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_cardtestpp_swf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_card_swf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_ambient_swf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_colors_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__colors extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__card_bin extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__lib_card_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__ambient_bin extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__lib_ambient_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__walk_bin extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__lib_walk_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:file("Assets/walk.swf") @:noCompletion #if display private #end class __ASSET__assets_walk_swf extends haxe.io.Bytes {}
@:keep @:file("Assets/cardtestpp.swf") @:noCompletion #if display private #end class __ASSET__assets_cardtestpp_swf extends haxe.io.Bytes {}
@:keep @:file("Assets/card.swf") @:noCompletion #if display private #end class __ASSET__assets_card_swf extends haxe.io.Bytes {}
@:keep @:file("Assets/ambient.swf") @:noCompletion #if display private #end class __ASSET__assets_ambient_swf extends haxe.io.Bytes {}
@:keep @:file("Assets/colors.json") @:noCompletion #if display private #end class __ASSET__assets_colors_json extends haxe.io.Bytes {}
@:keep @:file("Assets/colors.json") @:noCompletion #if display private #end class __ASSET__colors extends haxe.io.Bytes {}
@:keep @:file("/Users/testing/Desktop/html5cj/Export/html5/obj/libraries/card/card.bin") @:noCompletion #if display private #end class __ASSET__card_bin extends haxe.io.Bytes {}
@:keep @:file("") @:noCompletion #if display private #end class __ASSET__lib_card_json extends haxe.io.Bytes {}
@:keep @:file("/Users/testing/Desktop/html5cj/Export/html5/obj/libraries/ambient/ambient.bin") @:noCompletion #if display private #end class __ASSET__ambient_bin extends haxe.io.Bytes {}
@:keep @:file("") @:noCompletion #if display private #end class __ASSET__lib_ambient_json extends haxe.io.Bytes {}
@:keep @:file("/Users/testing/Desktop/html5cj/Export/html5/obj/libraries/walk/walk.bin") @:noCompletion #if display private #end class __ASSET__walk_bin extends haxe.io.Bytes {}
@:keep @:file("") @:noCompletion #if display private #end class __ASSET__lib_walk_json extends haxe.io.Bytes {}
@:keep @:file("") @:noCompletion #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else



#end

#if (openfl && !flash)

#if html5

#else

#end

#end
#end

#end
