package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	public static var bfneedstofade:Bool = false;

	public function new(x:Float, y:Float)
	{
		FlxG.timeScale = 1;
		bfneedstofade = false;
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (PlayState.SONG.stage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'warzone-stress':
			    daBf = 'bf-holding-gf-DEAD';
			default:
				daBf = 'bf';
		}


		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
			bfneedstofade = true;
			PlayState.blueballed += 1;
		}

		if (bfneedstofade)
			{
           	//bf.alpha -= 0.004;
				//trace(bf.alpha);
				FlxTween.tween(bf, {alpha: 0}, 1.3, {
					onComplete: function(tween:FlxTween)
					{
				
					},	
			});
			}


		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (StoryMenuState.isStoryMode)
				{
					FlxG.switchState(new StoryMenuState());
					FlxG.timeScale = 1;
					PlayState.blueballed = 0;
					ChartingState.startfrompos = false;
				}
			else
				#if web
			FlxG.switchState(new FreeplayStateHTML5());
			FlxG.timeScale = 1;
			PlayState.blueballed = 0;
			ChartingState.startfrompos = false;
			#else
			FlxG.switchState(new FreeplayState());
			FlxG.timeScale = 1;
			PlayState.blueballed = 0;
			ChartingState.startfrompos = false;
			#end	
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			if (PlayState.SONG.stage == 'warzone-stress' || PlayState.SONG.stage == 'warzone')
				{
					FlxG.sound.play(Paths.soundRandom('jeffGameover/jeffGameover-', 1, 25), FlxG.random.float(1, 1));
					trace('hi jeff');
				}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				new FlxTimer().start(2.0, function(tmr:FlxTimer)
					{
						FlxG.timeScale = FreeplayState.gamespeed;
						if (FlxG.save.data.usedeprecatedloading)
							LoadingState.loadAndSwitchState(new PlayState());
							else
								PlayState.instance.restart();	
					});
					
					
			});
		}

		/*FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				if (FlxG.save.data.usedeprecatedloading)
				LoadingState.loadAndSwitchState(new PlayState());
				else
					PlayState.instance.restart();
			});*/
	}
}
