package;

import Controls.Action;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.util.FlxGradient;
import Section.SwagSection;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import lime.utils.Assets;
import DifficultyIcons;
import lime.system.System;
import flixel.addons.transition.FlxTransitionableState;
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

class RobloxMenuState extends MusicBeatState
{
	var selector:FlxSprite;
	var buttonNames:Array<String> = ['Home', 'Story', 'Freeplay', 'Credits', 'Settings'];

	var deCamera:FlxObject;
	var sideBar:FlxCamera;
	var homeMenu:FlxCamera;
	var storyMenu:FlxCamera;
	var freeplayMenu:FlxCamera;
	var creditsMenu:FlxCamera;
	var settingsMenu:FlxCamera;
	var extraMenu:FlxCamera;
	var menus:Array<FlxCamera> = [];

	var homeGames:Array<Array<Dynamic>> = [];
	var recentlyPlayed:Array<String> = [];
	var storyStuff:Array<Array<Dynamic>> = [];
	var storySections:Array<Array<String>> = [
		['Ghost Week', 'Eerie-Presence', 'Cloaked', 'Hijinks'],
		['Creature Week', 'Lemon', 'Sour-Feeling', 'Aftertaste']
	];
	var funnyVar:Bool = false;
	// divided by rows VVV
	var freeplayGames:Array<Array<Array<Dynamic>>> = [];
	var noFreeplay:Bool = false;
	var settingBoxes:Array<FlxSprite> = [];

	static var curSelected:Int = 0;
	var onSideBar:Bool = true;
	var curPos:Array<Int> = [0, 0];
	var posLimits:Array<Int> = [];

	override function create() {
		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(FNFAssets.getSound('assets/music/custom_menu_music/'
				+ CoolUtil.parseJson(FNFAssets.getJson("assets/music/custom_menu_music/custom_menu_music")).Menu
				+ '/freakyMenu'
				+ TitleState.soundExt));
		}

		sideBar = new FlxCamera();
		sideBar.bgColor.alpha = 0;
		FlxG.cameras.add(sideBar);
		FlxCamera.defaultCameras = [sideBar];

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF303030);
		add(bg);

		var daBar = new FlxSprite().makeGraphic(320, FlxG.height, 0xFF232323);
		add(daBar);

		selector = new FlxSprite(0, 200).makeGraphic(320, 60, 0xFF6B6B6B);
		add(selector);

		for (i in 0...buttonNames.length) {
			var button = new FlxText(70, 110 + 60*i, 0, buttonNames[i], 32);
			add(button);
			var image = new FlxSprite(10, 110 + 60*i).loadGraphic(FNFAssets.getBitmapData('assets/images/robloxMenus/button' + buttonNames[i] + '.png'));
			add(image);
		}

		homeMenu = new FlxCamera();
		storyMenu = new FlxCamera();
		freeplayMenu = new FlxCamera();
		creditsMenu = new FlxCamera();
		settingsMenu = new FlxCamera();
		extraMenu = new FlxCamera();
		menus = [homeMenu, storyMenu, freeplayMenu, creditsMenu, settingsMenu];

		deCamera = new FlxObject(0, 0, FlxG.width, FlxG.height);

		freeplayMenu.follow(deCamera, LOCKON, 0.08);
		freeplayMenu.focusOn(deCamera.getPosition());
		creditsMenu.follow(deCamera, LOCKON, 0.08);
		creditsMenu.focusOn(deCamera.getPosition());

		for (menu in menus) {
			menu.bgColor.alpha = 0;
			FlxG.cameras.add(menu);
			menu.visible = false;
		}

		extraMenu.bgColor.alpha = 0;
		FlxG.cameras.add(extraMenu);

		// Home menu stuff

		var bfImage = new FlxSprite(410, 60).loadGraphic(FNFAssets.getBitmapData('assets/images/robloxMenus/bf face lol.png'));
		bfImage.setGraphicSize(Std.int(bfImage.width * 0.5));
		bfImage.updateHitbox();
		bfImage.antialiasing = true;
		bfImage.cameras = [homeMenu];
		add(bfImage);

		var helloTxt = new FlxText(600, 110, 0, 'Hello, Boyfriend!', 36);
		helloTxt.cameras = [homeMenu];
		add(helloTxt);

		recentlyPlayed = CoolUtil.coolTextFile('assets/data/recentlyPlayed.txt');

		var playedTxt = new FlxText(400, 300, 0, 'Recently Played', 32);
		playedTxt.cameras = [homeMenu];
		add(playedTxt);
		for (i in 0...recentlyPlayed.length) {
			var gameImage = new FlxSprite(playedTxt.x + 10 + 170*i, playedTxt.y + 60).loadGraphic(FNFAssets.getBitmapData('assets/images/custom_cutscenes/robloxIntro/' + getGameImage(recentlyPlayed[i]) + '.png'));
			gameImage.setGraphicSize(150, 150);
			gameImage.updateHitbox();
			gameImage.antialiasing = true;
			gameImage.cameras = [homeMenu];
			add(gameImage);

			var game = new FlxSprite(playedTxt.x + 170*i, playedTxt.y + 50);
			game.frames = FlxAtlasFrames.fromSparrow('assets/images/robloxMenus/selection box.png', 'assets/images/robloxMenus/selection box.xml');
			game.animation.addByPrefix("idle", "boxFalse", 24);
			game.animation.addByPrefix("selected", "boxTrue", 24);
			game.animation.play('idle');
			game.antialiasing = true;
			game.cameras = [homeMenu];
			if (recentlyPlayed[0] != '')
				add(game);
			var deGame:Array<Dynamic> = [game, recentlyPlayed[i]];
			homeGames.push(deGame);

			var gameText = new FlxText(game.x + 10, game.y + 165, 150, StringTools.replace(recentlyPlayed[i], '-', ' '), 16);
			gameText.cameras = [homeMenu];
			add(gameText);
		}
		if (recentlyPlayed[0] == '') {
			var noGames = new FlxSprite(625, playedTxt.y + 50).loadGraphic(FNFAssets.getBitmapData('assets/images/robloxMenus/no games.png'));
			noGames.antialiasing = true;
			noGames.cameras = [homeMenu];
			add(noGames);
		}

		// story

		for (i in 0...storySections.length) {
			var game = new FlxSprite(400, FlxG.height / 2 - 179 + 200*i); // I like symmetry
			game.frames = FlxAtlasFrames.fromSparrow('assets/images/robloxMenus/story box.png', 'assets/images/robloxMenus/story box.xml');
			game.animation.addByPrefix("idle", "boxFalse", 24);
			game.animation.addByPrefix("selected", "boxTrue", 24);
			game.animation.addByPrefix("pressed", "boxBlink", 12, true);
			game.animation.play('idle');
			game.antialiasing = true;
			game.cameras = [storyMenu];

			var gameImage = new FlxSprite(game.x + 15, game.y + 15).loadGraphic(FNFAssets.getBitmapData('assets/images/custom_cutscenes/robloxIntro/' + getGameImage(storySections[i][0]) + '.png'));
			gameImage.setGraphicSize(128, 128);
			gameImage.updateHitbox();
			gameImage.antialiasing = true;
			gameImage.cameras = [storyMenu];
			add(gameImage);
			add(game);

			var gameText = new FlxText(game.x + 160, game.y + 10, 600, storySections[i][0], 24);
			gameText.cameras = [storyMenu];
			add(gameText);

			var intendedScore = Highscore.getWeekScore(storySections[i][0], 2);
			var intendedAccuracy = Highscore.getWeekAccuracy(storySections[i][0], 2);

			var gameScore = new FlxText(game.x + 160, game.y + 120, 0, 'Score: $intendedScore  Accuracy: ' + HelperFunctions.truncateFloat(intendedAccuracy, 2) + '%', 18);
			gameScore.cameras = [storyMenu];
			if (intendedScore != 0)
				add(gameScore);

			storyStuff.push([game, gameImage, gameText, gameScore]);
		}

		// freeplay

		// Bonus ['Ghastly', 'Coincidence', 'Disappointment'], 
		var songs:Array<Array<String>> = [];

		if (Highscore.getWeekScore('Ghost Week', 2) != 0) {
			songs.push(['Ghost Week', 'Eerie-Presence', 'Cloaked', 'Hijinks']);
		}

		if (Highscore.getWeekScore('Creature Week', 2) != 0) {
			songs.push(['Creature Week', 'Lemon', 'Sour-Feeling', 'Aftertaste']);
			songs.push(['Covers', 'Power-Link-Remix', 'High-Jinks', 'Two-Lemons']);
		}

		if (songs.length != 0) {
			for (i in 0...songs.length) {
				var catTxt = new FlxText(400, 40 + 300*i, 0, songs[i][0], 32);
				catTxt.cameras = [freeplayMenu];
				add(catTxt);
				freeplayGames.push([]);
				for (i2 in 1...songs[i].length) {
					var gameImage = new FlxSprite(catTxt.x + 10 + 170*(i2-1), catTxt.y + 60).loadGraphic(FNFAssets.getBitmapData('assets/images/custom_cutscenes/robloxIntro/' + getGameImage(songs[i][i2]) + '.png'));
					gameImage.setGraphicSize(150, 150);
					gameImage.updateHitbox();
					gameImage.antialiasing = true;
					gameImage.cameras = [freeplayMenu];
					add(gameImage);

					var game = new FlxSprite(catTxt.x + 170*(i2-1), catTxt.y + 50);
					game.frames = FlxAtlasFrames.fromSparrow('assets/images/robloxMenus/selection box.png', 'assets/images/robloxMenus/selection box.xml');
					game.animation.addByPrefix("idle", "boxFalse", 24);
					game.animation.addByPrefix("selected", "boxTrue", 24);
					game.animation.play('idle');
					game.antialiasing = true;
					game.cameras = [freeplayMenu];
					add(game);
					var deGame:Array<Dynamic> = [game, songs[i][i2]];
					freeplayGames[i].push(deGame);

					var gameText = new FlxText(game.x + 10, game.y + 165, 150, StringTools.replace(songs[i][i2], '-', ' '), 16);
					gameText.cameras = [freeplayMenu];
					add(gameText);
				}
			}
		} else {
			noFreeplay = true;
			var noGames = new FlxSprite(625, 250).loadGraphic(FNFAssets.getBitmapData('assets/images/robloxMenus/no games.png'));
			noGames.antialiasing = true;
			noGames.cameras = [freeplayMenu];
			add(noGames);
		}

		//credits

		var daCreds:Array<Array<String>> = [
			['The Roblox Disappointment', 'Basically made the whole mod lol', 'disappointment'],
			['Richie "Smecko Geck" Scassellati', 'An awesome youtuber known for his BETADCIUs\n(I used his Lemon Monster voice for Two Lemons)', 'smeckygecky'],
			['Shaggy x Matt team', 'Made the Shaggy x Matt mod', 'shaggyandmatt'],
			['Tails Gets Trolled team', 'Made the Tails Gets Trolled mod', 'tailstrolled'],
			['Lemon Demon', 'Made Two Trucks\n(Excellent song btw)', 'notlemonmonster'],
			['FNF team', 'Made the original game', 'coolpeople'],
			['Modding Plus Team', 'Made the base engine\nTweaked by The Roblox Disappointment', 'notme'],
		];

		for (i in 0...daCreds.length) {
			var credImage = new FlxSprite(350, 50 + 160*i).loadGraphic(FNFAssets.getBitmapData('assets/images/robloxMenus/credits/' + daCreds[i][2] + '.png'));
			credImage.antialiasing = true;
			credImage.cameras = [creditsMenu];
			add(credImage);

			var credText = new FlxText(500, 60 + 160*i, 0, daCreds[i][0], 24);
			credText.cameras = [creditsMenu];
			add(credText);

			var credDesc = new FlxText(500, 90 + 160*i, 0, daCreds[i][1], 16);
			credDesc.cameras = [creditsMenu];
			add(credDesc);
		}

		//settings

		var deSettings:Array<String> = ['Keybinds', 'Downscroll', 'Ghost Tapping', 'Disable Freeplay Intro'];

		for (i in 0...deSettings.length) {
			var setBox = new FlxSprite(400, 100 + 100*i);
			setBox.frames = FlxAtlasFrames.fromSparrow('assets/images/robloxMenus/checkbox.png', 'assets/images/robloxMenus/checkbox.xml');
			setBox.animation.addByPrefix("idle", "boxFalse", 24);
			setBox.animation.addByPrefix("selected", "boxTrue", 24);
			setBox.animation.play('idle');
			setBox.antialiasing = true;
			setBox.cameras = [settingsMenu];
			setBox.alpha = 0.5;
			add(setBox);

			settingBoxes.push(setBox);

			var setText = new FlxText(500, 100 + 100*i, 0, deSettings[i], 24);
			setText.y += setBox.height / 2 - setText.height / 2;
			setText.cameras = [settingsMenu];
			add(setText);
		}

		updateSettings();

		menus[curSelected].visible = true;

		super.create();
	}

	override function update(elapsed:Float) {
		selector.y = 105 + 60*curSelected;

		if (onSideBar) {
			selector.x = 0;
		} else {
			selector.x = -315;
		}

		// This is a data wipe so I can test stuff lol
		// No one will accidently activate this... right?
		if (FlxG.keys.pressed.ONE && FlxG.keys.pressed.SIX && FlxG.keys.pressed.J && FlxG.keys.justPressed.ENTER) {
			Highscore.deleteWeekScore('Ghost Week', 2);
			Highscore.deleteWeekScore('Creature Week', 2);
			FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);
			FlxG.resetState();
		}

		if (!funnyVar) {
			if (controls.UP_MENU)
				changeSelection(-1, true);
			if (controls.DOWN_MENU)
				changeSelection(1, true);
			if (controls.RIGHT_MENU)
				changeSelection(1);
			if (controls.LEFT_MENU)
				changeSelection(-1);

			if (controls.ACCEPT) {
				if (onSideBar) {
					if ((curSelected != 2 || !noFreeplay) && (curSelected != 0 || recentlyPlayed[0] != '')) {
						curPos = [0, 0];
						onSideBar = false;

						switch(curSelected) {
							case 0:
								posLimits = [homeGames.length - 1, 0];
							case 1:
								posLimits = [0, 1];
							case 2:
								posLimits = [3 - 1, freeplayGames.length - 1];
							case 3:
								posLimits = [0, 3];
							case 4:
								posLimits = [0, 3];
						}
					}
				} else {
					switch(curSelected) {
						case 0:
							startSong(homeGames[curPos[0]][1]);
						case 1:
							startStory(curPos[1]);
						case 2:
							startSong(freeplayGames[curPos[1]][curPos[0]][1]);
						case 4:
							switch(curPos[1]) {
								case 0:
									toggleOption('keybinds');
								case 1:
									toggleOption('dscroll');
								case 2:
									toggleOption('ghastlytap');
								case 3:
									toggleOption('disableintros');
							}
					}
				}
			}

			if (!onSideBar) {
				switch(curSelected) {
					case 0:
						for (i in 0...homeGames.length) {
							homeGames[i][0].animation.play('idle');
						}
						homeGames[curPos[0]][0].animation.play('selected');
					case 1:
						for (i in 0...storyStuff.length) {
							storyStuff[i][0].animation.play('idle');
						}
						storyStuff[curPos[1]][0].animation.play('selected');
					case 2:
						for (i in 0...freeplayGames.length) {
							for (i2 in 0...freeplayGames[i].length) {
								freeplayGames[i][i2][0].animation.play('idle');
							}
						}
						freeplayGames[curPos[1]][curPos[0]][0].animation.play('selected');
					case 4:
						for (i in 0...settingBoxes.length) {
							settingBoxes[i].alpha = 0.5;
						}
						settingBoxes[curPos[1]].alpha = 1;
				}
			} else {
				switch(curSelected) {
					case 0:
						for (i in 0...homeGames.length) {
							homeGames[i][0].animation.play('idle');
						}
					case 1:
						for (i in 0...storyStuff.length) {
							storyStuff[i][0].animation.play('idle');
						}
					case 2:
						for (i in 0...freeplayGames.length) {
							for (i2 in 0...freeplayGames[i].length) {
								freeplayGames[i][i2][0].animation.play('idle');
							}
						}
					case 4:
						for (i in 0...settingBoxes.length) {
							settingBoxes[i].alpha = 0.5;
						}
				}
			}
		
			if (controls.BACK && onSideBar)
				LoadingState.loadAndSwitchState(new TitleState());
			if (controls.BACK && !onSideBar)
				onSideBar = true;
			if (FlxG.keys.justPressed.SEVEN)
				LoadingState.loadAndSwitchState(new MainMenuState());
		}
		// I had difficulties
		if (funnyVar)
			storyStuff[curPos[1]][0].animation.play('pressed');

		if (curSelected == 2) {
			deCamera.y = -200 + 200*curPos[1];
		} else if (curSelected == 3) {
			deCamera.y = -200 + 160*curPos[1];
		}

		super.update(elapsed);
	}

	function updateMenus() {
		for (menu in menus) {
			menu.visible = false;
		}
		menus[curSelected].visible = true;

		curPos = [0, 0];
	}

	function toggleOption(daOpt:String) {
		switch(daOpt) {
			case 'dscroll':
				OptionsHandler.options.downscroll = !OptionsHandler.options.downscroll;
			case 'ghastlytap':
				OptionsHandler.options.useCustomInput = !OptionsHandler.options.useCustomInput;
			case 'disableintros':
				OptionsHandler.options.alwaysDoCutscenes = !OptionsHandler.options.alwaysDoCutscenes;
			case 'keybinds':
				LoadingState.loadAndSwitchState(new ControlsState());
		}
		updateSettings();
	}

	function updateSettings() {
		if (OptionsHandler.options.downscroll) {
			settingBoxes[1].animation.play('selected', true);
		} else {
			settingBoxes[1].animation.play('idle', true);
		}
		if (OptionsHandler.options.useCustomInput) {
			settingBoxes[2].animation.play('selected', true);
		} else {
			settingBoxes[2].animation.play('idle', true);
		}
		if (!OptionsHandler.options.alwaysDoCutscenes) {
			settingBoxes[3].animation.play('selected', true);
		} else {
			settingBoxes[3].animation.play('idle', true);
		}
	}

	function changeSelection(change:Int = 0, direction:Bool = false) {
		if (onSideBar) {
			if (direction) {
				curSelected += change;

				if (curSelected < 0)
					curSelected = buttonNames.length - 1;
				if (curSelected >= buttonNames.length)
					curSelected = 0;

				updateMenus();
			}
		} else {
			if (direction) {
				if (curPos[1] + change > posLimits[1]) {
					curPos[1] = 0;
				} else if (curPos[1] + change < 0) {
					curPos[1] = posLimits[1];
				} else {
					curPos[1] += change;
				}
			} else {
				if (curPos[0] + change > posLimits[0]) {
					curPos[0] = 0;
				} else if (curPos[0] + change < 0) {
					curPos[0] = posLimits[0];
				} else {
					curPos[0] += change;
				}
			}
		}
	}
	
	function getGameImage(song:String) {
		var image:String = '';
		switch(song) {
			case "Ghost Week" | "Eerie-Presence" | "Cloaked" | "Hijinks":
				if (Highscore.getWeekScore('Ghost Week', 2) != 0)
					image = "reginald 'raspy' ghost";
				else
					image = 'dark man';
			case "Creature Week" | "Lemon" | "Sour-Feeling" | "Aftertaste":
				if (Highscore.getWeekScore('Creature Week', 2) != 0)
					image = 'simply lemon';
				else
					image = 'dark creature';
			case "Power-Link-Remix":
				image = 'mattspy lol';
			case "High-Jinks":
				image = 'gravestone';
			case "Two-Lemons":
				image = 'three lemons';
			case "Disappointment":
				image = '';
		}
		return image;
	}

	function startSong(daSong:String, diff:Int = 2) {
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		var poop = daSong.toLowerCase() + DifficultyIcons.getEndingFP(diff);
		if (!FNFAssets.exists('assets/data/' + daSong.toLowerCase() + '/' + poop.toLowerCase() + '.json')) {
			// assume we pecked up the difficulty, return to default difficulty
			trace("UH OH SONG IN SPECIFIED DIFFICULTY DOESN'T EXIST\nUSING DEFAULT DIFFICULTY");
			poop = daSong;
			diff = DifficultyIcons.getDefaultDiffFP();
		}
		PlayState.SONG = Song.loadFromJson(poop, daSong.toLowerCase());
		PlayState.isStoryMode = false;
		ModifierState.isStoryMode = false;
		PlayState.storyDifficulty = diff;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		var darken = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		darken.alpha = 0.5;
		darken.cameras = [extraMenu];
		add(darken);
		var loadingGame = new FlxSprite().loadGraphic(FNFAssets.getBitmapData('assets/images/robloxMenus/loading song.png'));
		loadingGame.screenCenter();
		loadingGame.antialiasing = true;
		loadingGame.cameras = [extraMenu];
		add(loadingGame);
		LoadingState.loadAndSwitchState(new PlayState(), true);
	}

	function startStory(deWeek:Int) {
		funnyVar = true;
		FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);

		storyStuff[curPos[1]][0].animation.play('pressed', true);
		var direct = curPos[1] == 0 ? 1 : -1;
		for (object in storyStuff[curPos[1] + direct]) {
			FlxTween.tween(object, {alpha: 0}, 0.4);
		}
		for (object in storyStuff[curPos[1]]) {
			FlxTween.tween(object, {y: object.y + 100 * direct}, 0.8, {ease: FlxEase.bounceOut});
		}

		var deSongs = [];
		for (i in 1...storySections[deWeek].length) {
			deSongs.push(storySections[deWeek][i]);
		}
		StoryMenuState.storySongPlaylist = deSongs;
		PlayState.storyPlaylist = StoryMenuState.storySongPlaylist;
		PlayState.defaultPlaylistLength = deSongs.length;
		PlayState.isStoryMode = true;
		ModifierState.isStoryMode = true;
		PlayState.storyDifficulty = 2;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-hard', PlayState.storyPlaylist[0].toLowerCase());
		PlayState.storyWeek = storySections[deWeek][0];
		PlayState.storyWeekNum = deWeek;
		PlayState.campaignScore = 0;
		PlayState.campaignAccuracy = 0;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		new FlxTimer().start(1.2, function(tmr:FlxTimer) {
			LoadingState.loadAndSwitchState(new PlayState());
		});
	}
}
