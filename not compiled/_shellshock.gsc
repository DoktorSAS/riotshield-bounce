#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;
#include maps/mp/_scoreevents;
#include maps/mp/killstreaks/_killstreak_weapons;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/_riotshield;

/*
	Developer: DoktorSAS
	Discord: Discord.io/Sorex
	Mod: Ritoshield Bounces
	Website: sorexproject.webflow.io
	Discord:  https://discord.io/Sorex or https://discord.com/invite/nCP2y4J
	Description: This script is to enable riotshiled bounce
	
	If you like my servers and scripts I invite you to donate something to support my work 
	Donate: https://www.paypal.com/paypalme/SorexProject
	
	Copyright: The script was created by DoktorSAS and no one else can 
			   say they created it. The script is free and accessible to 
			   everyone, it is not possible to sell the script.
*/

init()
{
	precacheshellshock( "frag_grenade_mp" );
	precacheshellshock( "damage_mp" );
	precacherumble( "artillery_rumble" );
	precacherumble( "grenade_rumble" );
	/*This var is to manage silder when there Depatched Bounce on or OFF*/
	/*--------- Don't Tuch IT ------------*/
	level.isDepatcedBounceON = getDvar("sv_enablebounces");
	/*------------------------------------*/
	level thread onPlayerConnect();
}

shellshockondamage( cause, damage ){
	if ( self maps/mp/_utility::isflashbanged() ){
		return;
	}
	if ( cause != "MOD_EXPLOSIVE" && cause != "MOD_GRENADE" && cause != "MOD_GRENADE_SPLASH" || cause == "MOD_PROJECTILE" && cause == "MOD_PROJECTILE_SPLASH" ){
		time = 0;
		if ( damage >= 90 ){
			time = 4;
		}else if ( damage >= 50 ){
			time = 3;
		}else if ( damage >= 25 ){
			time = 2;
		}else{
			if ( damage > 10 ){
				time = 2;
			}
		}
		if ( time ){
			if ( self mayapplyscreeneffect() ){
				self shellshock( "frag_grenade_mp", 0.5 );
			}
		}
	}
}
endondeath(){
	self waittill( "death" );
	waittillframeend;
	self notify( "end_explode" );
}
endontimer( timer ){
	self endon( "disconnect" );
	wait timer;
	self notify( "end_on_timer" );
}
rcbomb_earthquake( position ){
	playrumbleonposition( "grenade_rumble", position );
	earthquake( 0.5, 0.5, self.origin, 512 );
}
onPlayerConnect(){
    for(;;){
        level waittill("connected", player);
        player thread onPlayerDisconnect();
        player thread onRiotShield();
    }
}
/*--------- Don't Tuch IT ------------*/
onRiotShield(){ //This function is to manage Riotshield Bounces
	self endon("disconnect");
	level endon("game_ended");
	self.riotshield = [];
	self.riotshield["status"] = false;
	self.riotshield["type"] = level.isDepatcedBounceON;
    for(;;){
    	wait 0.05;
		if(isDefined( self.riotshieldretrievetrigger ) && isDefined( self.riotshieldentity ) && !self.riotshield["status"]){
			self.riotshield["status"] = true;
			self.canBounce = true;
			if(level.isDepatcedBounceON)
				level thread DepeatchedBounce( self.origin + (0,0,50), 25, self getxuid());
			else
				level thread Bounce( self.origin + (0,0,50), 25, self getxuid()); // If something goes wrong change DepeatchedBounce with Bounce
				/* Both functions go, but in case something goes wrong I leave them both to you */
		}else if(!isDefined( self.riotshieldretrievetrigger ) && !isDefined( self.riotshieldentity ) && self.riotshield["status"]){
			self.riotshield["status"] = false;
			level notify( self getxuid() );
		}
    }
}
onPlayerDisconnect(){ // This function is to disable bounce when player disconnect (It should not be necessary)
	self waittill("disconnect");
	if(self.riotshield["status"])
		level notify( self getguid() );
}
/*------------------------------------*/
/*
	Developer: DoktorSAS
	Discord: Discord.io/Sorex
	Mod: Ritoshield Bounces
	Website: sorexproject.webflow.io
	Discord:  https://discord.io/Sorex or https://discord.com/invite/nCP2y4J
	Description: This script is to enable riotshiled bounce
	
	If you like my servers and scripts I invite you to donate something to support my work 
	Donate: https://www.paypal.com/paypalme/SorexProject
	
	Copyright: The script was created by DoktorSAS and no one else can 
			   say they created it. The script is free and accessible to 
			   everyone, it is not possible to sell the script.
*/


/*
	When there No Depatched Bounce the velocity is differnet, thats why there 2 bounces functions
	if something go wrong just change the number (INT) in the NegateBounceDepatched function 
*/
DepeatchedBounce( bounceOrigin, range, guid){
	level endon("game_ended");
	level endon( guid );
	for(;;){
		foreach(player in level.players){
			if (!player isOnGround()){
				player.vel = player GetVelocity();
				if( player isInPosition(bounceOrigin , range) && player.vel[2] < 0 && !player isOnGround()){
					//player thread playerDepatchedBounce(  );
					player.vel = player GetVelocity();
					player.newVel = (player.vel[0], player.vel[1], NegateBounce(player.vel[2]));
					player SetVelocity( player.newVel );
				}
			}
			
		}
	wait .01;
	}
}
playerDepatchedBounce(){
	level endon("game_ended");
	self.canBounce = false;
	wait 1;
	self.canBounce = true;
}
NegateBounceDepatched( vector ){
   negative = vector - (vector * 80.125); //Change the number there if something go wrong
   return( negative );
}
/*
	When there Depatched Bounce the velocity is differnet, thats why there 2 bounces functions
	if something go wrong just change the number (INT) in the NegateBounce function 
*/
Bounce( bounceOrigin, range, guid){
	level endon("game_ended");
	level endon( guid );
	for(;;){
		foreach(player in level.players){
			if (!player isOnGround()){
				player.vel = player GetVelocity();
				player.newVel = (player.vel[0], player.vel[1], NegateBounce(player.vel[2]));
				if( player isInPosition(bounceOrigin , range) && player.vel[2] < 0 && !player isOnGround()){
					//player thread playerBounce( );
					player.newVel = (player.vel[0], player.vel[1], NegateBounceDepatched(player.vel[2]));
					player SetVelocity( player.newVel * 2);
				}
			}
		}
	wait .01;
	}
}
playerBounce(){
	level endon("game_ended");
	self.canBounce = false;
	wait 1;
	self.canBounce = true;
}
// Credits go to CodJumper.
NegateBounce( vector ){
   negative = vector - (vector * 2); //Change the number there if something go wrong
   return( negative );
}
/*Common script*/
isInPosition( sP , range ){
	if(distance( self.origin, sP ) < range)
		return true;
	return false;
}