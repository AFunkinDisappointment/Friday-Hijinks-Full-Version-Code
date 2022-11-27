package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;

class GameOverSpecialState extends MusicBeatState
{
	var theEND:Bool = false;
	var boyfriendHand:FlxSprite;
	var mic:FlxSprite;

	public function new():Void
	{
		super();
	}

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var boyfriendDead:FlxSprite = new FlxSprite().loadGraphic('assets/images/pauseAlt/bf funkin died.png');
		add(boyfriendDead);

		boyfriendHand = new FlxSprite(500, 200);
		boyfriendHand.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/Back from the grave.png', 'assets/images/pauseAlt/Back from the grave.xml');
		boyfriendHand.animation.addByPrefix('reach', 'zombie raise', 24, false);
		boyfriendHand.animation.addByPrefix('grab', 'zombie grab', 24, false);
		boyfriendHand.animation.play('reach');
		boyfriendHand.visible = false;
		add(boyfriendHand);

		mic = new FlxSprite(500, -300);
		mic.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/Back from the grave.png', 'assets/images/pauseAlt/Back from the grave.xml');
		mic.animation.addByPrefix('idle', 'falling mic', 24, false);
		mic.animation.play('idle');
		add(mic);

		Conductor.songPosition = 0;
		FlxG.sound.playMusic('assets/music/sadOrgans' + TitleState.soundExt, 1.5);
		Conductor.changeBPM(100);

		super.create();
	}

	override function beatHit()
	{
		super.beatHit();

		curBeat += 1;

		if (curBeat == 32 && !forceEnd && !hesDead)
			theEND = true;
	}

	var fading = false;
	var forceEnd = false;
	var hesDead = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.playing) {
			Conductor.songPosition = FlxG.sound.music.time;
		}
		
		if (theEND && !fading) {
			fading = true;
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
				FlxG.sound.music.stop();
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
		if (controls.ACCEPT && !forceEnd && !hesDead) {
			forceEnd = true;
			FlxG.sound.music.stop();
			boyfriendHand.animation.play('reach', true);
			boyfriendHand.visible = true;
			new FlxTimer().start(1.2, function(tmr:FlxTimer) {
				FlxTween.tween(mic, {y: 200}, 0.3, {
					onComplete: function(tween:FlxTween) {
						boyfriendHand.animation.play('grab');
						mic.visible = false;
						FlxG.sound.play('assets/music/gameOverEnd' + TitleState.soundExt, 0.6);
						new FlxTimer().start(0.7, function(tmr:FlxTimer) {
							theEND = true;
						});
					}
				});
			});
		}
		if (controls.BACK && !forceEnd && !hesDead)
		{
			hesDead = true;
			FlxG.sound.music.stop();

			new FlxTimer().start(1.2, function(tmr:FlxTimer) {
				FlxTween.tween(mic, {y: 350}, 0.2, {
						onComplete: function(tween:FlxTween) {
							mic.x += 40;
							mic.angle = 40;
							FlxG.sound.play('assets/sounds/micDrop' + TitleState.soundExt, 0.8);
							new FlxTimer().start(5, function(tmr:FlxTimer) {
								FlxG.camera.fade(FlxColor.BLACK, 1, false, function() {
									if (PlayState.isStoryMode)
										LoadingState.loadAndSwitchState(new StoryMenuState());
									else
										LoadingState.loadAndSwitchState(new FreeplayState());
								});
							});
						}
				});
			});
		}

		super.update(elapsed);
	}
}
