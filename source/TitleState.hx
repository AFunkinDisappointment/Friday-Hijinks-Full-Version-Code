package;

#if windows
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import haxe.Json;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
import sys.FileSystem;
import Song.SwagSong;
#end
import tjson.TJSON;
import flixel.input.keyboard.FlxKey;
using StringTools;
typedef DiscordJson = {
	var intro:String;
	var freeplay:String;
	var mainmenu:String;
};
class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;
	static public var soundExt:String = ".ogg";
	static public var firstTime = false;
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var shownWacky:Int = -1;
	var curWacky:Array<String> = [];
	var wackyEndBeat:Int = 0;
	var wackyImage:FlxSprite;
	var coolDudes:Array<String> = [];
	
	var name_1:Array<String> = [];
	var name_2:Array<String> = [];
	var name_3:Array<String> = [];

	// doing this shit again because it broke in the last build :grief: (start)
	var curName:Array<String> = [];
	var curX:Array<Float> = [];
	var curY:Array<Float> = [];
	var curFPS:Array<Float> = [];
	var isPixel:Array<Bool> = [];
	var shouldScale:Array<Bool> = [];
	var curScale:Array<Float> = [];
	var animationType:Array<String> = [];
	// doing this shit again because it broke in the last build :grief: (end)

	// defining these variables now so i dont gotta do them later (start)
	var gfTitle = CoolUtil.parseJson(FNFAssets.getJson("assets/data/gfTitle"));
	var logoTitle = CoolUtil.parseJson(FNFAssets.getJson("assets/data/logoTitle"));
	var bgTitle = CoolUtil.parseJson(FNFAssets.getJson("assets/data/bgTitle"));
	public static var discordStuff:DiscordJson = CoolUtil.parseJson(FNFAssets.getJson("assets/discord/presence/discord"));
	// defining these variables now so i dont gotta do them later (end)

	var customMenuConfirm: Array<Array<String>>;
	var customMenuScroll: Array<Array<String>>;
	override public function create():Void
	{

		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		// Updating Discord Rich Presence
		var customPrecence = discordStuff.intro;
		Discord.DiscordClient.changePresence(customPrecence, null);
		#end
		
		
		
		PluginManager.init();
		DifficultyManager.init();
		ModifierState.init();
		curWacky = FlxG.random.getObject(getIntroTextShit());
		// DEBUG BULLSHIT
		super.create();
		FlxG.mouse.visible = false;
		FlxG.save.bind("preferredSave", "bulbyVR");
		var preferredSave:Int = 0;
		if (Reflect.hasField(FlxG.save.data, "preferredSave")) {
			preferredSave = FlxG.save.data.preferredSave;
		} else {
			FlxG.save.data.preferredSave = 0;
		}

		FlxG.save.close();
		FlxG.save.bind("save"+preferredSave, 'bulbyVR');
		PlayerSettings.init();
		Highscore.load();


		#if FREEPLAY
		LoadingState.loadAndSwitchState(new CategoryState());
		#elseif CHARTING
		LoadingState.loadAndSwitchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var boy:FlxSprite;
	var raspy:FlxSprite;
	var titleText:FlxSprite;
	var titleBg:FlxSprite;
	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream('assets/music/freakyMenu' + TitleState.soundExt);
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic('assets/music/custom_menu_music/'
				+ CoolUtil.parseJson(FNFAssets.getText("assets/music/custom_menu_music/custom_menu_music.json")).Menu+'/freakyMenu' + TitleState.soundExt, 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		if (CoolUtil.parseJson(FNFAssets.getText("assets/music/custom_menu_music/custom_menu_music.json")).Menu == 'Ghastly')
			Conductor.changeBPM(73);
		else
			Conductor.changeBPM(102);
		persistentUpdate = true;

		titleBg = new FlxSprite();
		titleBg.frames = FlxAtlasFrames.fromSparrow('assets/images/titleBG.png', 'assets/images/titleBG.xml');
		titleBg.antialiasing = !bgTitle.isPixel;
		titleBg.animation.addByPrefix('thefunny', bgTitle.curName, bgTitle.curFPS, true);
		titleBg.animation.play('thefunny');

		if (OptionsHandler.options.titleToggle)
			add(titleBg);

		logoBl = new FlxSprite(logoTitle.curX, logoTitle.curY);
		logoBl.frames = FlxAtlasFrames.fromSparrow('assets/images/logoBumpin.png', 'assets/images/logoBumpin.xml');
		logoBl.antialiasing = !logoTitle.isPixel;
		logoBl.animation.addByPrefix('bump', logoTitle.curName, logoTitle.curFPS, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		if (logoTitle.shouldScale)
			logoBl.setGraphicSize(Std.int(logoBl.width * logoTitle.curScale));
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		// sorry but I don't feel like doing it this way :(
		/*gfDance = new FlxSprite(gfTitle.curX, gfTitle.curY);
		gfDance.frames = FlxAtlasFrames.fromSparrow('assets/images/gfDanceTitle.png', 'assets/images/gfDanceTitle.xml');
		if (gfTitle.animationType == "gfIdle"){
			gfDance.animation.addByIndices('danceLeft', gfTitle.curName, [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", gfTitle.curFPS, false);
			gfDance.animation.addByIndices('danceRight', gfTitle.curName, [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", gfTitle.curFPS, false);
		}
		if (gfTitle.animationType == "bfIdle"){
			gfDance.animation.addByPrefix('dance', gfTitle.curName, gfTitle.curFPS, false);
		}
		if (gfTitle.animationType == "loopIdle"){
			gfDance.animation.addByPrefix('loopyFunny', gfTitle.curName, gfTitle.curFPS, true);
		}
		gfDance.antialiasing = !gfTitle.isPixel;
		if (gfTitle.shouldScale == true){
			gfDance.setGraphicSize(Std.int(gfDance.width * gfTitle.curScale));
		}
		add(gfDance); */

		raspy = new FlxSprite(-10, -80);
		raspy.frames = FlxAtlasFrames.fromSparrow('assets/images/ghostDanceTitle.png', 'assets/images/ghostDanceTitle.xml');
		raspy.animation.addByPrefix('bounce', 'raspy idle', 24, false);
		raspy.animation.addByPrefix('start', 'raspy boo', 24, true);
		raspy.antialiasing = true;
		raspy.setGraphicSize(Std.int(raspy.width * 1.1));
		raspy.animation.play('bounce');
		add(raspy);

		boy = new FlxSprite(300, 300);
		boy.frames = FlxAtlasFrames.fromSparrow('assets/images/boyDanceTitle.png', 'assets/images/boyDanceTitle.xml');
		boy.animation.addByPrefix('bounce', 'bf idle scared', 24, false);
		boy.animation.addByPrefix('start', 'BF idle shaking', 24, true);
		boy.antialiasing = true;
		boy.flipX = true;
		boy.animation.play('bounce');
		add(boy);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = FlxAtlasFrames.fromSparrow('assets/images/titleEnter.png', 'assets/images/titleEnter.xml');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic('assets/images/logo.png');
		logo.screenCenter();
		logo.antialiasing = true;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);
		// THIS SHIT DOESN'T WORK ON NEKO!
		// IDK WHY I AM TESTING IT ON NEKO!
		coolDudes = Assets.getText('assets/data/creators.txt').split("\n");
		trace(coolDudes);
		credTextShit = new Alphabet(0, 0, "akofhafsk", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic('assets/images/newgrounds_logo.png');
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText('assets/data/introText.txt');

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{

			titleText.animation.play('press');
			titleBg.animation.addByPrefix('selected', bgTitle.curName + " selected", bgTitle.curFPS, false);
			titleBg.animation.play('selected');
			boy.animation.play('start');
			raspy.animation.play('start');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play('assets/sounds/custom_menu_sounds/'
				+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuConfirm+'/confirmMenu' + TitleState.soundExt, 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Check if version is outdated
				//LoadingState.loadAndSwitchState(new MainMenuState());
				LoadingState.loadAndSwitchState(new RobloxMenuState());
			});
			// FlxG.sound.play('assets/music/titleShoot' + TitleState.soundExt, 0.7);
		}

		if (pressedEnter && !skippedIntro)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		/*if (gfTitle.animationType == "gfIdle"){
			if (danceLeft){
				gfDance.animation.play('danceRight');
			}
			else{
				gfDance.animation.play('danceLeft');
			}
		}
		if (gfTitle.animationType == "bfIdle"){
			gfDance.animation.play('dance');
		}
		if (gfTitle.animationType == "loopIdle"){
			gfDance.animation.play('loopyFunny');
		}*/
		if (raspy.animation.curAnim.name != 'start')
			raspy.animation.play('bounce', true);
		if (boy.animation.curAnim.name != 'start')
		    boy.animation.play('bounce', true);

		FlxG.log.add(curBeat);

		if (curBeat < 9) {
			switch (curBeat)
			{
				case 1:
					createCoolText(coolDudes);
				// credTextShit.visible = true;
				case 3:
					addMoreText('present');
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					createCoolText(['Not in association', 'with']);
				case 7:
					addMoreText('these guys');
					ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 9:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 11:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 12:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 13:
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 14:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 15:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 16:
					skipIntro();
			}
		} else {
			if (curBeat == 9) {
				createCoolText([curWacky[0]]);
				shownWacky = 0;
				wackyEndBeat = curBeat;
			} else if (curBeat % 2 == 1 && shownWacky + 1 < curWacky.length) {
				shownWacky += 1;
				addMoreText(curWacky[shownWacky]);
				wackyEndBeat = curBeat;
			} else if (shownWacky == curWacky.length - 1){
				trace(wackyEndBeat + " " + curBeat);
				switch (curBeat - wackyEndBeat) {
					case 1:
						deleteCoolText();
					case 2:
						addMoreText(CoolUtil.parseJson(FNFAssets.getText("assets/data/gameInfo.json")).name_1);
					case 3:
						addMoreText(CoolUtil.parseJson(FNFAssets.getText("assets/data/gameInfo.json")).name_2);
					case 4:
						addMoreText(CoolUtil.parseJson(FNFAssets.getText("assets/data/gameInfo.json")).name_3);
					case 5:
						skipIntro();
				}
			}
		}

	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 1);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
