package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.atlas.FlxAtlas;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;


class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function txtREADME(key:String, ?library:String)
		{
			return getPath('$key.txt', TEXT, library);
		}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function video(key:String, ?library:String)
		{
			trace('assets/videos/$key.mp4');
			return getPath('videos/$key.mp4', BINARY, library);
		}

	/*static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	*///}

	static public function sound(key:String, ?library:String)
		{
			var result = getPath('sounds/$key.$SOUND_EXT', SOUND, library);
			return doesSoundAssetExist(result) ? result : null;
		}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	/*inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	*///}

	inline static public function music(key:String, ?library:String)
		{
			var result = getPath('music/$key.$SOUND_EXT', MUSIC, library);
			return doesSoundAssetExist(result) ? result : null;
		}

	/*inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}*/

	inline static public function voices(song:String)
		{
			var result = 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
			return doesSoundAssetExist(result) ? result : null;
		}
	
		inline static public function inst(song:String)
		{
			var result = 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
			return doesSoundAssetExist(result) ? result : null;
		}

	/*inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}*/

	inline static public function image(key:String, ?library:String)
		{
			return getPath('images/$key.png', IMAGE, library);
		}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	/*inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}*/

	inline static public function getSparrowAtlas(key:String, ?library:String)
		{
			return FlxAtlasFrames.fromSparrow(loadImage(key, library), file('images/$key.xml', library));
		}
	
		inline static public function getPackerAtlas(key:String, ?library:String)
		{
			return FlxAtlasFrames.fromSpriteSheetPacker(loadImage(key, library), file('images/$key.txt', library));
		}

	static public function listSongsToCache()
		{
			// We need to query OpenFlAssets, not the file system, because of Polymod.
			var soundAssets = OpenFlAssets.list(AssetType.MUSIC).concat(OpenFlAssets.list(AssetType.SOUND));
	
			// TODO: Maybe rework this to pull from a text file rather than scan the list of assets.
			var songNames = [];
	
			for (sound in soundAssets)
			{
				// Parse end-to-beginning to support mods.
				var path = sound.split('/');
				path.reverse();
	
				var fileName = path[0];
				var songName = path[1];
	
				if (path[2] != 'songs')
					continue;
	
				// Remove duplicates.
				if (songNames.indexOf(songName) != -1)
					continue;
	
				songNames.push(songName);
			}
	
			return songNames;
		}
	
		static public function listAudioToCache(isSound:Bool)
		{
			// We need to query OpenFlAssets, not the file system, because of Polymod.
			var soundAssets = OpenFlAssets.list(AssetType.MUSIC).concat(OpenFlAssets.list(AssetType.SOUND));
	
			// TODO: Maybe rework this to pull from a text file rather than scan the list of assets.
			var fileNames = [];
	
			var folderName = 'music';
	
			if (isSound)
				folderName = 'sounds';
	
			for (sound in soundAssets)
			{
				// Parse end-to-beginning to support mods.
				var path = sound.split('/');
				path.reverse();
	
				var fileName = path[0];
	
				if (path[1] != folderName)
					continue;
	
				// Remove duplicates.
				if (fileNames.indexOf(fileName) != -1)
					continue;
	
				fileNames.push(fileName);
			}
	
			return fileNames;
		}
	
		static public function doesSoundAssetExist(path:String)
		{
			if (path == null || path == "")
				return false;
			return OpenFlAssets.exists(path, AssetType.SOUND) || OpenFlAssets.exists(path, AssetType.MUSIC);
		}

		static public function loadImage(key:String, ?library:String):FlxGraphic
			{
				var path = image(key, library);
		
				#if cpp
				if (Caching.bitmapData != null)
				{
					if (Caching.bitmapData.exists(key))
						// Get data from cache.
						return Caching.bitmapData.get(key);
				}
				#end
		
				if (OpenFlAssets.exists(path, IMAGE))
				{
					var bitmap = OpenFlAssets.getBitmapData(path);
					return FlxGraphic.fromBitmapData(bitmap);
				}
				else
					// Could not find image at path
					return null;
			}
}
