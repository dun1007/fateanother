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

function EmitPresenceSound(msg)
{
   	Game.EmitSound(msg.sound); 
}

(function(){
    GameEvents.Subscribe("emit_horn_sound", EmitHornSound);
    GameEvents.Subscribe("stop_horn_sound", StopHornSound);
    GameEvents.Subscribe("emit_presence_sound", EmitPresenceSound);
})()