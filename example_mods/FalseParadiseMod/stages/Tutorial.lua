local shaderName = "crt"

function onCreate()

	makeLuaSprite('bg1', 'black', -1600, -900);
	setLuaSpriteScrollFactor('bg1', 0, 0);
	setProperty('bg1.alpha', 1)
	scaleObject('bg1', 999, 999);

	makeLuaSprite('bg2', 'black', -1600, -900);
	setLuaSpriteScrollFactor('bg2', 0, 0);
	setProperty('bg2.alpha', 1)
	scaleObject('bg2', 999, 999);

	makeLuaSprite('bg3', 'black', -1600, -900);
	setLuaSpriteScrollFactor('bg3', 0, 0);
	setProperty('bg3.alpha', 1)
	scaleObject('bg3', 999, 999);

	-- background shit
	makeLuaSprite('stageback', 'Tutorial/stageback', -500, -300);
	setLuaSpriteScrollFactor('stageback', 0.9, 0.9);
	
	makeLuaSprite('stagefront', 'Tutorial/stagefront', -650, 600);
	setLuaSpriteScrollFactor('stagefront', 0.9, 0.9);
	scaleObject('stagefront', 1.1, 1.1);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		makeLuaSprite('stagelight_left', 'Tutorial/stage_light', -125, -100);
		setLuaSpriteScrollFactor('stagelight_left', 0.9, 0.9);
		scaleObject('stagelight_left', 1.1, 1.1);
		
		makeLuaSprite('stagelight_right', 'Tutorial/stage_light', 1225, -100);
		setLuaSpriteScrollFactor('stagelight_right', 0.9, 0.9);
		scaleObject('stagelight_right', 1.1, 1.1);
		setPropertyLuaSprite('stagelight_right', 'flipX', true); --mirror sprite horizontally

		makeLuaSprite('stagecurtains', 'Tutorial/stagecurtains', -500, -300);
		setLuaSpriteScrollFactor('stagecurtains', 1.3, 1.3);
		scaleObject('stagecurtains', 0.9, 0.9);
	end

	addLuaSprite('stageback', false);
	addLuaSprite('stagefront', false);
	addLuaSprite('stagelight_left', false);
	addLuaSprite('stagelight_right', false);
	addLuaSprite('stagecurtains', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end

function onStepHit()
	if curStep == 16 then
	removeLuaSprite('stageback', true);
	removeLuaSprite('stagefront', true);
	removeLuaSprite('stagelight_left', true);
	removeLuaSprite('stagelight_right', true);
	removeLuaSprite('stagecurtains', true);

    initLuaShader("cloud")
	addLuaSprite('bg1', false)

	setSpriteShader("bg1", "cloud")
	end
	if curStep == 143 then
    initLuaShader("bg")
	setSpriteShader("bg2", "bg")
    end
	if curStep == 784 then
    makeGraphic("bg3", screenWidth, screenHeight)
	addLuaSprite('bg3', false);
    setSpriteShader("bg3", "crt")

    runHaxeCode([[
        var shaderName = "]] .. shaderName .. [[";
        
        game.initLuaShader(shaderName);
        
        var shader0 = game.createRuntimeShader(shaderName);
        game.camGame.setFilters([new ShaderFilter(shader0)]);
        game.getLuaObject("shader3").shader = shader0; // setting it into temporary sprite so luas can set its shader uniforms/properties
        game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("shader3").shader)]);
        return;
    ]])
	end
end

function onUpdate(elapsed)
	setShaderFloat('bg1', 'iTime', getSongPosition()/500)
	setShaderFloat('bg2', 'iTime', getSongPosition()/500)
	setShaderFloat('bg3', 'iTime', getSongPosition()/300)
    setShaderFloat("shader3", "iTime", os.clock())
 end

function shaderCoordFix()
    runHaxeCode([[
        resetCamCache = function(?spr) {
            if (spr == null || spr.filters == null) return;
            spr.__cacheBitmap = null;
            spr.__cacheBitmapData = null;
        }
        
        fixShaderCoordFix = function(?_) {
            resetCamCache(game.camGame.flashSprite);
            resetCamCache(game.camHUD.flashSprite);
            resetCamCache(game.camOther.flashSprite);
        }
    
        FlxG.signals.gameResized.add(fixShaderCoordFix);
        fixShaderCoordFix();
        return;
    ]])
    
    local temp = onDestroy
    function onDestroy()
        runHaxeCode([[
            FlxG.signals.gameResized.remove(fixShaderCoordFix);
            return;
        ]])
        if (temp) then temp() end
    end
end