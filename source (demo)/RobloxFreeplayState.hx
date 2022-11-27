package;

import Controls.Action;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.util.FlxGradient;
import Section.SwagSection;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import lime.utils.Assets;
import DifficultyIcons;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flixel.system.FlxSound;
import sys.FileSystem;
import flash.media.Sound;
#end
import haxe.Json;
import tjson.TJSON;
using StringTools;

class RobloxFreeplayState extends MusicBeatState
{
	var camGame:FlxCamera;
	var camPlay:FlxCamera;

	static var curSelected:Int = 0;
	static var curRow:Int = 0;
	
	var categories:Array<String> = [];
	var songs:Array<Array<String>> = [];
	var games:Array<Array<FlxSprite>> = [];

	override function create() {
		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(FNFAssets.getSound('assets/music/custom_menu_music/'
				+ CoolUtil.parseJson(FNFAssets.getJson("assets/music/custom_menu_music/custom_menu_music")).Menu
				+ '/freakyMenu'
				+ TitleState.soundExt));
		}

		var epicCategoryJs:Array<Dynamic> = CoolUtil.parseJson(FNFAssets.getJson('assets/data/freeplaySongJson'));
		for (i in 0...epicCategoryJs.length) {
			var category = epicCategoryJs[i];
			categories.push(category.name);
			songs.push([]);
			for (i2 in 0...category.songs) {
				var song = category.songs[i2];
				songs[i].push(song.name);
			}
		}

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].display, true, false, false, null, null, null, true);
			if (!OptionsHandler.options.style) {
				songText.itemType = "Classic";
			}
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			// icons won't be visible 
			icon.visible = !OptionsHandler.options.style;
			iconArray.push(icon);
			add(icon);
			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
			var starCount:Int = 0;
			for (diff in 0...3) { //make it detect the other difficulties
				if (Highscore.getFCLevel(songs[i].songName, diff, 'best-accuracy') != 0) {
					var rankStar:RankStar = new RankStar(songs[i].songName, diff);
					rankStar.sprTracker = icon;
					rankStar.starNum = starCount;
					rankStar.visible = !OptionsHandler.options.style;
					add(rankStar);
					starCount += 1;
				} else {
					var rankStar:FlxSprite = new FlxSprite();
				}
			}
		}

		super.create();
	}

	override function update(elapsed:Float) {
		if (controls.LEFT_MENU)
			changeSelection(-1);
		if (controls.RIGHT_MENU)
			changeSelection(1);
		if (controls.DOWN_MENU)
			changeRow(-1);
		if (controls.UP_MENU)
			changeRow(1);

		if (controls.BACK)
			LoadingState.loadAndSwitchState(new MainMenuState());

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;

		if (curSelected < 0)
			curSelected = 69 - 1;
		if (curSelected >= 69)
			curSelected = 0;
	}

	function changeRow(change:Int = 0) {
		curRow += change;

		if (curRow < 0)
			curRow = 69 - 1;
		if (curRow >= 69)
			curRow = 0;
	}
}
