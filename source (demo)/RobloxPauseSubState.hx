package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.ui.FlxClickArea;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;

typedef RobloxButton = {
	var graphic : FlxSprite;
	var button : FlxClickArea;
}

typedef PlayerBox = {
	var background : FlxSprite;
	var username : FlxText;
	var displayname : FlxText;
	var image : FlxSprite;
	//var buttons : Array<RobloxButton>;
}

class RobloxPauseSubState extends MusicBeatSubstate
{
	var curSelectedMenu:Int = 0;
	var curSelectedButton:Int = 0;
	var curArea:Int = 0;

	var pauseMusic:FlxSound;

	var bg:FlxSprite;
	var reset:FlxSprite;
	var leave:FlxSprite;
	var resume:FlxSprite;
	var sections:FlxSprite;

	var players:Array<PlayerBox>;

	var clickArea = 0;
	var resetArea:FlxClickArea;
	var leaveArea:FlxClickArea;
	var resumeArea:FlxClickArea;

	public function new(x:Float, y:Float, charactersLol:Array<Character>) {
		FlxG.mouse.visible = true;

		super();

		pauseMusic = new FlxSound().loadEmbedded('assets/music/breakfast' + TitleState.soundExt, true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF232323);
		bg.y -= FlxG.height;
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		players = [];
		var playerList = CoolUtil.parseJson(FNFAssets.getText('assets/data/playerList.json'));
		for (i in 0...charactersLol.length) {
			var playerBackground = new FlxSprite().loadGraphic('assets/images/pauseAlt/roblox/player background.png');
			playerBackground.screenCenter();
			add(playerBackground);

			var playerDescription = Reflect.field(playerList, charactersLol[i].curCharacter);

			var displayText;
			if (playerDescription != null && playerDescription.displayName != null) {
				displayText = new FlxText(playerBackground.x + 60, 0, 0, playerDescription.displayName);
			} else {
				displayText = new FlxText(playerBackground.x + 60, 0, 0, 'Player Data Not Found');
			}
			displayText.setFormat("assets/fonts/vcr.tff", 28, 0xFFFFFFFF, 'left');
			add(displayText);
			
			var usernameText;
			if (playerDescription != null && playerDescription.userName != null) {
				usernameText = new FlxText(playerBackground.x + 60, 0, 0, '@' + playerDescription.userName);
			} else {
				usernameText = new FlxText(playerBackground.x + 60, 0, 0, '@' + charactersLol[i].curCharacter);
			}
			usernameText.setFormat("assets/fonts/vcr.tff", 20, 0xFF999999, 'left');
			add(usernameText);
			
			var playerImage;
			if (playerDescription != null && playerDescription.charImage != null) {
				playerImage = new FlxSprite(playerBackground.x + 5).loadGraphic('assets/images/pauseAlt/roblox/playerImages/' + playerDescription.charImage + '.png');
			} else {
				playerImage = new FlxSprite(playerBackground.x + 5).loadGraphic('assets/images/pauseAlt/roblox/playerImages/null.png');
			}
			playerImage.setGraphicSize(52, 52);
			playerImage.updateHitbox();
			playerImage.antialiasing = true;
			add(playerImage);

			var daBox:PlayerBox = {
				background: playerBackground,
				displayname: displayText,
				username: usernameText,
				image: playerImage
			};
			players.push(daBox);
		}

		sections = new FlxSprite();
		sections.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/roblox/menu buttons.png', 'assets/images/pauseAlt/roblox/menu buttons.xml');
		sections.animation.addByPrefix("menu0", "sectionMenu0", 24);
		sections.animation.addByPrefix("menu1", "sectionMenu1", 24);
		sections.animation.addByPrefix("menu2", "sectionMenu2", 24);
		sections.animation.addByPrefix("menu3", "sectionMenu3", 24);
		sections.animation.addByPrefix("menu4", "sectionMenu4", 24);
		sections.screenCenter();
		sections.antialiasing = true;
		sections.animation.play('menu0');
		add(sections);

		reset = new FlxSprite(250);
		reset.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/roblox/roblox buttons.png', 'assets/images/pauseAlt/roblox/roblox buttons.xml');
		reset.animation.addByPrefix('idle', 'resetCharA', 24);
		reset.animation.addByPrefix('selected', 'resetCharB', 24);
		reset.setGraphicSize(Std.int(reset.width * 0.95));
		reset.scrollFactor.set();
		reset.antialiasing = true;
		reset.animation.play('idle');
		add(reset);

		leave = new FlxSprite(510);
		leave.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/roblox/roblox buttons.png', 'assets/images/pauseAlt/roblox/roblox buttons.xml');
		leave.animation.addByPrefix('idle', 'leaveA', 24);
		leave.animation.addByPrefix('selected', 'leaveB', 24);
		leave.setGraphicSize(Std.int(leave.width * 0.95));
		leave.scrollFactor.set();
		leave.antialiasing = true;
		leave.animation.play('idle');
		add(leave);

		resume = new FlxSprite(770);
		resume.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/roblox/roblox buttons.png', 'assets/images/pauseAlt/roblox/roblox buttons.xml');
		resume.animation.addByPrefix('idle', 'resumeA', 24);
		resume.animation.addByPrefix('selected', 'resumeB', 24);
		resume.setGraphicSize(Std.int(resume.width * 0.95));
		resume.scrollFactor.set();
		resume.antialiasing = true;
		resume.animation.play('idle');
		add(resume);

		resetArea = new FlxClickArea(160, 0, 300, 90);
		resetArea.onUp = function() { areaClicked('reset'); }
		add(resetArea);
		leaveArea = new FlxClickArea(480, 0, 300, 90);
		leaveArea.onUp = function() { areaClicked('leave'); }
		add(leaveArea);
		resumeArea = new FlxClickArea(805, 0, 300, 90);
		resumeArea.onUp = function() { areaClicked('resume'); }
		add(resumeArea);

		FlxTween.tween(bg, {y: 0}, 0.35, {ease: FlxEase.quadInOut, type: ONESHOT});

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	function areaClicked(area:String):Void {
		switch(area) {
			case 'reset':
				FlxG.mouse.visible = false;
				FlxG.resetState();
			case 'leave':
				FlxG.mouse.visible = false;
				if (PlayState.isStoryMode)
					LoadingState.loadAndSwitchState(new StoryMenuState());
				else
					LoadingState.loadAndSwitchState(new FreeplayState());
			case 'resume':
				FlxG.mouse.visible = false;
				resume.animation.play('selected');
				FlxTween.tween(bg, {y: 0 - FlxG.height}, 0.35, {ease: FlxEase.quadInOut, type: ONESHOT,
					onComplete: function(tween:FlxTween) {
						close();
					}
				});
		}
	}

	function createButton(sprite:FlxSprite) {
		var area = new FlxClickArea(sprite.x, sprite.y, sprite.width, sprite.height);
		var button:RobloxButton = {
			graphic: sprite,
			button: area,
		};
		return button;
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		sections.y = bg.y + 100;
		reset.y = bg.y + 600;
		resetArea.y = bg.y + 650;
		leave.y = bg.y + 600;
		leaveArea.y = bg.y + 650;
		resume.y = bg.y + 600;
		resumeArea.y = bg.y + 650;

		for (i in 0...players.length) {
			players[i].background.y = bg.y + 170 + i * 80;
			players[i].displayname.y = players[i].background.y + 5;
			players[i].username.y = players[i].background.y + 30;
			players[i].image.y = players[i].background.y + 5;
		}

		var upP = controls.UP_MENU;
		var downP = controls.DOWN_MENU;
		var leftP = controls.LEFT_MENU;
		var rightP = controls.RIGHT_MENU;
		var accepted = controls.ACCEPT;

		if (curArea == 0) {
			if (leftP) {
				changeSelection(-1);
			} else if (rightP) {
				changeSelection(1);
			}
		} else if (curArea == 1) {
			if (leftP) {
				changeButton(-1);
			} else if (rightP) {
				changeButton(1);
			}
		}

		if (upP) {
			changeArea(-1);
		} else if (downP) {
			changeArea(1);
		}

		/*if (accepted) {
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					if (PlayState.isStoryMode)
						LoadingState.loadAndSwitchState(new StoryMenuState());
					else
						LoadingState.loadAndSwitchState(new FreeplayState());
				case "Change Modifiers":
					LoadingState.loadAndSwitchState(new ModifierState());
				case "Change Options":
					SaveDataState.prevPath = 'freeplay';
					LoadingState.loadAndSwitchState(new SaveDataState());
			}
		}*/

		if (FlxG.keys.justPressed.R || (accepted && curArea == 1 && curSelectedButton == 0))
			areaClicked('reset');

		if (FlxG.keys.justPressed.L || (accepted && curArea == 1 && curSelectedButton == 1))
			areaClicked('leave');

		if (FlxG.keys.justPressed.ESCAPE || (accepted && curArea == 1 && curSelectedButton == 2))
			areaClicked('resume');

		if (resetArea.status == 1)
			reset.animation.play('selected');
		else if (curArea != 1 || curSelectedButton != 0)
			reset.animation.play('idle');

		if (leaveArea.status == 1)
			leave.animation.play('selected');
		else if (curArea != 1 || curSelectedButton != 1)
			leave.animation.play('idle');

		if (resumeArea.status == 1)
			resume.animation.play('selected');
		else if (curArea != 1 || curSelectedButton != 2)
			resume.animation.play('idle');
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		curSelectedMenu += change;

		if (curSelectedMenu < 0)
			curSelectedMenu = 4;
		if (curSelectedMenu >= 5)
			curSelectedMenu = 0;

		sections.animation.play('menu' + curSelectedMenu);
	}
	function changeButton(change:Int = 0):Void {
		curSelectedButton += change;

		if (curSelectedButton < 0)
			curSelectedButton = 2;
		if (curSelectedButton >= 3)
			curSelectedButton = 0;

		unselectButtons();

		switch(curSelectedButton) {
			case 0:
				reset.animation.play('selected');
			case 1:
				leave.animation.play('selected');
			case 2:
				resume.animation.play('selected');
		}
	}
	function unselectButtons() {
		reset.animation.play('idle');
		leave.animation.play('idle');
		resume.animation.play('idle');
	}
	function changeArea(change:Int = 0):Void {
		curArea += change;

		if (curArea < 0)
			curArea = 1;
		if (curArea >= 2)
			curArea = 0;

		switch(curArea) {
			case 0:
				unselectButtons();
			case 1:
				curSelectedButton = 0;
				changeButton();
		}
	}
}
