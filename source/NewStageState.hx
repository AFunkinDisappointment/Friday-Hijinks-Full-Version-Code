package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import DifficultyIcons;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIButton;
import flixel.ui.FlxSpriteButton;
import flixel.addons.ui.FlxUITabMenu;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;

#end
import lime.ui.FileDialog;
import lime.app.Event;
import haxe.Json;
import tjson.TJSON;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.ui.FileDialogType;
import haxe.io.Path;
using StringTools;

class NewStageState extends MusicBeatState
{
	var addCharUi:FlxUI;
	var mainPngButton:FlxButton;
	var nameText:FlxUIInputText;
	var likeText:FlxUIInputText;
	var infoButton:FlxUIButton;
	var importText:FlxUIInputText;
	var importButton:FlxUIButton;
	var exportText:FlxUIInputText;
	var exportButton:FlxUIButton;
	var finishButton:FlxButton;
	var coolFile:FileReference;
	var coolData:ByteArray;
	var epicFiles:Array<String>;
	var stageFileButton:FlxButton;
	var stageFilePath:String;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	override function create()
	{
		addCharUi = new FlxUI();
		FlxG.mouse.visible = true;
		epicFiles = [];
		var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuBGBlue.png');
		add(bg);
		mainPngButton = new FlxButton(10,10,"Stage Files",function ():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN_MULTIPLE);
			coolDialog.onSelectMultiple.add(function (paths:Array<String>):Void {
				epicFiles = paths;
			});
		});
		nameText = new FlxUIInputText(100,10,70,"template");
		likeText = new FlxUIInputText(100,50,70,"stage");
		stageFileButton = new FlxButton(10, 60, "Stage Hscript", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				stageFilePath = path;
			});
		});

		infoButton = new FlxUIButton(100, 90, "Stage Info", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				getInfo(path);
			});
		});

		importText = new FlxUIInputText(400,10,70,"stage");
		importButton = new FlxUIButton(400,50, "Import Stage", function():Void {
			var basePath:String = "assets/module/import/stages/" + importText.text;
			if (FileSystem.exists(basePath)) {
				if (FileSystem.exists(basePath + '/stageFile.hscript'))
					stageFilePath = basePath + '/stageFile.hscript';

				var daInfo:String = basePath + '/info.txt';
				getInfo(daInfo, true);
			}
		});

		exportText = new FlxUIInputText(490,10,70,"philly");
		exportButton = new FlxUIButton(490,50, "Export Song", function():Void {
			var exportPath:String = "assets/module/export/stages/" + exportText.text;
			var stagePath:String = "assets/images/custom_stages/" + exportText.text;

			if (!FileSystem.exists(exportPath))
				FileSystem.createDirectory(exportPath);

			var daInfo:Array<String> = [];
			var coolStage = CoolUtil.parseJson(FNFAssets.getText("assets/images/custom_stages/custom_stages.json"));
			daInfo.push("This stage info was made using Disappointing Plus");
			daInfo.push("I would recommend changing the nulls to your desired values before importing!");
			daInfo.push("");
			daInfo.push("stagename:" + exportText.text);
			daInfo.push("like:" + Reflect.field(coolStage, exportText.text));
			var sussyInfo = StringTools.replace(daInfo.toString(), ',', '\n');
			sussyInfo = StringTools.replace(sussyInfo, '[', '');
			sussyInfo = StringTools.replace(sussyInfo, ']', '');
			trace(sussyInfo);
			File.saveContent(exportPath + '/info.txt', sussyInfo);

			/*if (FileSystem.exists())

			for (file in ) {
				var coolPath:Path = new Path(file);
				File.copy(file, exportPath + '/' + coolPath.file + '.' + coolPath.ext);
			}*/
		});

		finishButton = new FlxButton(FlxG.width - 170, FlxG.height - 50, "Finish", function():Void {
			writeCharacters();
			LoadingState.loadAndSwitchState(new SaveDataState());
		});
		var cancelButton = new FlxButton(FlxG.width - 300, FlxG.height - 50, "Cancel", function():Void
		{
			// go back
			LoadingState.loadAndSwitchState(new SaveDataState());
		});
		add(cancelButton);
		add(finishButton);
		add(nameText);
		add(likeText);
		add(mainPngButton);
		add(infoButton);
		add(importText);
		add(importButton);
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

	}
	function getInfo(infoPath:String, importing:Bool = false) {
	var infoText:Array<String> = CoolUtil.coolTextFile(infoPath);
		for (i in 0...infoText.length) {
			var data:Array<String> = infoText[i].split(':');
			switch(data[0]) {
				case 'stagename':
					nameText.text = data[1];
				case 'like':
					likeText.text = data[1];
				case 'assets':
					if (importing) {
						epicFiles = [];
						var basePath:String = "assets/module/import/stages/" + importText.text;
						for (i in 1...data.length) {
							if (FileSystem.exists(basePath + data[i]))
								epicFiles.push(basePath + data[i]);
						}
					}
			}
		}
	}
	function writeCharacters() {
		// check to see if directory exists
		#if sys
		if (!FileSystem.exists('assets/images/custom_stages/' + nameText.text))
			FileSystem.createDirectory('assets/images/custom_stages/' + nameText.text);

		for (epicFile in epicFiles) {
			var coolPath:Path = new Path(epicFile);
			coolPath.dir = 'assets/custom_stages/' + nameText.text;
			var pathString:String = coolPath.dir + '/' + coolPath.file + '.' + coolPath.ext;
			File.copy(epicFile, pathString);
		}

		if (stageFilePath != null)
		    File.copy(stageFilePath, 'assets/custom_stages/' + likeText.text);

		var epicStageFile:Dynamic = CoolUtil.parseJson(Assets.getText('assets/images/custom_stages/custom_stages.json'));
		trace("parsed");
		Reflect.setField(epicStageFile, nameText.text, likeText.text);

		File.saveContent('assets/images/custom_stages/custom_stages.json', CoolUtil.stringifyJson(epicStageFile));
		trace("cool stuff");
		#end
	}
}
