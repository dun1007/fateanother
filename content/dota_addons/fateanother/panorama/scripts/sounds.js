"use strict";

var hornIndex = 0;

function EmitHornSound(msg)
{
    if (msg.sound){
        hornIndex = Game.EmitSound(msg.sound); 
    }
}

function StopHornSound(msg)
{
	Game.StopSound(hornIndex);
}

(function(){
    GameEvents.Subscribe("emit_horn_sound", EmitHornSound);
    GameEvents.Subscribe("stop_horn_sound", StopHornSound);
})()