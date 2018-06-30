# 787-8 systems
#
#

aircraft.livery.init("Aircraft/787/Models/Liveries");

baro =0.0;
inhg = 0;
kpa= 0;
rev1 = nil;
r1 = nil;
r2 = nil;
v1 = nil;
cl = 0.0;
c2 = 0.0;
hpsi = 0.0;
pph1=0.0;
pph2=0.0;
pph3=0.0;
fuel_density=0.0;
n_offset=0;
nm_calc=0.0;
spdbrake=0.0;
et_base=0.0;
et_hr=0.0;
et_min=0.0;
et_min_start=0.0;
force = 0.0;
test = 0.0;
tgt_offset=0.0;
test_dist=0.0;
test1_dist=0.0;
norm_dist=0.0;
true_heading=0.0;
ai_craft="";
mp_craft="";
lengine_running=1;
rengine_running=1;
apu_running=0;
setprop("/systems/electrical/outputs/eec-Lbus",14);
setprop("/systems/electrical/outputs/eec-Rbus",14);

strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new("sim/model/Boeing-787-8/lighting/strobe-blink", [0.05, 1.25], strobe_switch);
beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("sim/model/Boeing-787-8/lighting/beacon", [0.05, 1.25], beacon_switch);

strobe_on = func {
setprop("sim/multiplay/generic/int[8]",1);
}

strobe_off = func {
setprop("sim/multiplay/generic/int[8]",0);
}

init_controls = func {
setprop("/instrumentation/efis/baro",0.0);
setprop("/instrumentation/efis/inhg",0);
setprop("/instrumentation/efis/kpa",0);
setprop("/instrumentation/efis/stab",0);
setprop("//instrumentation/mk-viii/serviceable","true");
setprop("//instrumentation/mk-viii/configuration-module/category-1","254");
setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
setprop("/instrumentation/gps/serviceable","true");
setprop("/engines/engine[0]/fuel-flow_pph",0.0);
setprop("/engines/engine[1]/fuel-flow_pph",0.0);
setprop("/engines/engine[2]/fuel-flow_pph",0.0);
setprop("/instrumentation/efis/baro-mode",0.0);
setprop("/instrumentation/efis/fixed-temp",0.0);
setprop("/instrumentation/efis/fixed-stab",0.0);
setprop("/instrumentation/efis/fixed-pitch",0.0);
setprop("/instrumentation/efis/fixed-vs",0.0);
setprop("/instrumentation/efis/alt-mode",0.0);
setprop("/controls/engines/reverser-position",0.0);
setprop("/environment/turbulence/use-cloud-turbulence","true");
setprop("/sim/current-view/field-of-view",60.0);
setprop("/controls/gear/brake-parking",1.0);
setprop("/instrumentation/annunciator/master-caution",0.0);
setprop("/systems/hydraulic/pump-psi[0]",0.0);
setprop("/systems/hydraulic/pump-psi[1]",0.0);
fuel_density=getprop("consumables/fuel/tank[0]/density-ppg");
setprop("/surface-positions/speedbrake-pos-norm",0.0);
setprop("/instrumentation/clock/ET-min",0);
setprop("/instrumentation/clock/ET-hr",0);
setprop("/instrumentation/mk-viii/speaker/volume",.4);
setprop("/instrumentation/wxradar/display-mode",2);#was 'arc'
reset_et();
if(getprop("/sim/model/start-idling")) {
 setprop("/systems/electrical/outputs/eec-Lbus", 30);
 setprop("/systems/electrical/outputs/eec-Rbus", 30);
 setprop("sim/model/Boeing-787-8/start-engines", 1);
 lengine_running = 1;
 rengine_running = 1;
 setprop("/controls/engines/engine[0]/cutoff",0);
 setprop("/controls/engines/engine[1]/cutoff",0);
}
else {
 setprop("sim/multiplay/generic/float[13]",0);
 setprop("sim/multiplay/generic/float[14]",0);
 setprop("/sim/model/Boeing-787-8/n2[0]",0);
 setprop("/sim/model/Boeing-787-8/n2[1]",0);
 setprop("/sim/model/Boeing-787-8/egt[0]",0);
 setprop("/sim/model/Boeing-787-8/egt[1]",0);
};
setprop("/sim/model/Boeing-787-8/start-cycle[0]",0);
setprop("/sim/model/Boeing-787-8/start-cycle[1]",0);
setprop("/sim/model/Boeing-787-8/apu-start",0);
setprop("/systems/electrical/apu-test",0);
print("Aircraft systems initialized");
}
settimer(init_controls, 0);

reset_et = func{
et_base = getprop("/sim/time/elapsed-sec");
et_min_start = et_base;
et_hr=0.0;
et_min=0.0;
}

# ESTIMATED TIME CALCULATIONS 

update_radar = func{
true_heading = getprop("/orientation/heading-deg");
ai_craft = props.globals.getNode("/ai/models").getChildren("aircraft");
for(i=0; i<size(ai_craft);i=i+1){
tgt_offset=getprop("/ai/models/aircraft[" ~ i ~ "]/radar/bearing-deg");
if(tgt_offset == nil){tgt_offset = 0.0;}
tgt_offset -= true_heading;
if (tgt_offset < -180){tgt_offset +=360;}
if (tgt_offset > 180){tgt_offset -=360;}
setprop("/instrumentation/radar/ai[" ~ i ~ "]/brg-offset",tgt_offset);
test_dist=getprop("/instrumentation/radar/range");
test1_dist = getprop("/ai/models/aircraft[" ~ i ~ "]/radar/range-nm");
if(test1_dist == nil){test1_dist=0.0;}
norm_dist= (1 / test_dist) * test1_dist;
setprop("/instrumentation/radar/ai[" ~ i ~ "]/norm-dist", norm_dist);
}

mp_craft = props.globals.getNode("/ai/models").getChildren("multiplayer");
for(i=0; i<size(mp_craft);i=i+1){
tgt_offset=getprop("/ai/models/multiplayer[" ~ i ~ "]/radar/bearing-deg");
if(tgt_offset == nil){tgt_offset = 0.0;}
tgt_offset -= true_heading;
if (tgt_offset < -180){tgt_offset +=360;}
if (tgt_offset > 180){tgt_offset -=360;}
setprop("/instrumentation/radar/mp[" ~ i ~ "]/brg-offset",tgt_offset);
test_dist=getprop("/instrumentation/radar/range");
test1_dist = getprop("/ai/models/multiplayer[" ~ i ~ "]/radar/range-nm");
if(test1_dist == nil){test1_dist=0.0;}
norm_dist= (1 / test_dist) * test1_dist;
setprop("/instrumentation/radar/mp[" ~ i ~ "]/norm-dist", norm_dist);
	}
} 


update_clock = func{
sec = getprop("/sim/time/elapsed-sec") - et_min_start;
if(sec >= 60.0){et_min += 1;
et_min_start = getprop("/sim/time/elapsed-sec");
}
if(et_min ==60){et_min = 0; et_hr += 1;}

etmin = props.globals.getNode("/instrumentation/clock/ET-min");
etmin.setIntValue(et_min);
ethr = props.globals.getNode("/instrumentation/clock/ET-hr");
ethr.setIntValue(et_hr);
}

update_systems = func {
update_clock();
update_radar();
baro = getprop("/instrumentation/altimeter/setting-inhg");
setprop("/instrumentation/efis/inhg",baro * 100);
setprop("/instrumentation/efis/kpa",baro * 33.8637526);
setprop("/instrumentation/efis/stab",getprop("/controls/flight/elevator-trim") * 15);

alfa = getprop("/orientation/alpha-deg");
abs_alfa = math.sqrt(alfa*alfa);
setprop("/instrumentation/efis/abs-alpha-deg",abs_alfa);

if(getprop("/instrumentation/efis/baro-mode")== 0){
setprop("/instrumentation/efis/baro", baro * 100);
}else{
setprop("/instrumentation/efis/baro",baro * 33.8637526);
}

test = getprop("/environment/temperature-degc");
if(test < 0.00){test = -1 * test;}
setprop("/instrumentation/efis/fixed-temp",test);

test = getprop("/controls/flight/elevator-trim");
if(test < 0.00){test = -1 * test;}
setprop("/instrumentation/efis/fixed-stab",test);

test = getprop("/orientation/pitch-deg");
if(test < 0.00){test = -1 * test;}
setprop("/instrumentation/efis/fixed-pitch",test);

test = getprop("/autopilot/settings/vertical-speed-fpm");
if(test == nil ){test=0.0;}
if(test < 0.00){test = -1 * test;}
setprop("/instrumentation/efis/fixed-vs",test);


force = getprop("/accelerations/pilot-g");
if(force == nil) {force = 1.0;}
eyepoint = (getprop("sim/view/config/y-offset-m") - (force * 0.01));
if(getprop("/sim/current-view/view-number") < 1){
setprop("/sim/current-view/y-offset-m",eyepoint);
}

hpsi = getprop("/engines/engine[0]/n2");
if(hpsi == nil){hpsi =0.0;}
if(hpsi > 30.0){setprop("/systems/hydraulic/pump-psi[0]",60.0);}
else{setprop("/systems/hydraulic/pump-psi[0]",hpsi * 2);}

hpsi = getprop("/engines/engine[1]/n2");
if(hpsi == nil){hpsi =0.0;}
if(hpsi > 30.0){setprop("/systems/hydraulic/pump-psi[1]",60.0);}
else{setprop("/systems/hydraulic/pump-psi[1]",hpsi * 2);}

pph1=getprop("/engines/engine[0]/fuel-flow-gph");
if(pph1 == nil){pph1 = 0.0};

pph2=getprop("/engines/engine[1]/fuel-flow-gph");
if(pph2 == nil){pph2 = 0.0};

pph3=getprop("/engines/engine[2]/fuel-flow-gph");
if(pph3 == nil){pph3 = 0.0};

setprop("engines/engine[0]/fuel-flow_pph",pph1* fuel_density);
setprop("engines/engine[1]/fuel-flow_pph",pph2* fuel_density);
setprop("engines/engine[2]/fuel-flow_pph",pph3* fuel_density);

if(getprop("sim/model/Boeing-787-8/lighting/strobe-blink/state") == 1) {
 settimer(strobe_on,0.1);
}

if(getprop("sim/model/Boeing-787-8/lighting/strobe-blink/state") == 0) {
 settimer(strobe_off,0.1);
}

if(getprop("/controls/flight/spoiler") == 0){

 setprop("/controls/flight/ground-speedbrake", 0);
 setprop("/controls/flight/speedbrake", 0);
 setprop("/controls/flight/ob-speedbrake", 0);
}

if(getprop("/controls/flight/spoiler") == 1){

 if(getprop("/gear/gear[1]/wow") == 1 or getprop("/gear/gear[2]/wow") == 1) {
  setprop("/controls/flight/ground-speedbrake", 1.0);
  setprop("/controls/flight/speedbrake", 1.0);
  setprop("/controls/flight/ob-speedbrake", 1.0);
 }

 if(getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0) {
  setprop("/controls/flight/ground-speedbrake", 0);
  setprop("/controls/flight/speedbrake", 0);
  setprop("/controls/flight/ob-speedbrake", 0);
 }
}

if(getprop("/controls/flight/spoiler") == 2){

 if(getprop("/gear/gear[1]/wow") == 1 or getprop("/gear/gear[2]/wow") == 1) {
  setprop("/controls/flight/speedbrake", 1.0);
  setprop("/controls/flight/ground-speedbrake", 1.0);
  setprop("/controls/flight/ob-speedbrake", 1.0);
 }

 if(getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0) {
  setprop("/controls/flight/ob-speedbrake", 0.67);
  setprop("/controls/flight/speedbrake", 0);
  setprop("/controls/flight/ground-speedbrake", 0);
 }
}

if(getprop("/controls/flight/spoiler") == 3){

  setprop("/controls/flight/speedbrake", 1);
  setprop("/controls/flight/ob-speedbrake", 1.0);
}

#slats

if(getprop("/controls/flight/flaps") < 0.22){
 setprop("/controls/flight/slats", 0);
}

if(getprop("/controls/flight/flaps") > 0.21){
 setprop("/controls/flight/slats", 1);
}

#inboard aileron controls

ailerons = getprop("controls/flight/aileron");

if(getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") < 160) {
 setprop("/controls/flight/mini-aileron",ailerons);
}

if(getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 160) {
 setprop("/controls/flight/mini-aileron",0);
}

cur_ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
flaps_pos = getprop("controls/flight/flaps");
gear_dwn = getprop("controls/gear/gear-down");
aoa = getprop("/orientation/alpha-deg");
abs_aoa = getprop("/instrumentation/efis/abs-alpha-deg");
cur_n1_l = getprop("sim/multiplay/generic/float[13]");
cur_n1_r = getprop("sim/multiplay/generic/float[14]");
#print("gear_dwn=", gear_dwn);
#angle of attack limit
if(aoa > 0 and abs_aoa > 8) {setprop("/instrumentation/annunciator/master-caution",1);}
#gear speed limits
elsif(cur_ias < 190 and gear_dwn == 0) {setprop("/instrumentation/annunciator/master-caution",1);}
elsif(cur_ias > 270 and gear_dwn == 1)  {setprop("/instrumentation/annunciator/master-caution",1);}
#flaps speed limits
elsif(cur_ias > 170 and flaps_pos == 1) {setprop("/instrumentation/annunciator/master-caution",1);}
elsif(cur_ias > 180 and flaps_pos >= 0.833)  {setprop("/instrumentation/annunciator/master-caution",1);}
elsif(cur_ias > 190 and flaps_pos >= 0.666)  {setprop("/instrumentation/annunciator/master-caution",1);}
elsif(cur_ias > 200 and flaps_pos >= 0.5)  {setprop("/instrumentation/annunciator/master-caution",1);}
elsif(cur_ias > 220 and flaps_pos >= 0.22)  {setprop("/instrumentation/annunciator/master-caution",1);}
elsif(cur_ias > 240 and flaps_pos >= 0.033)  {setprop("/instrumentation/annunciator/master-caution",1);}
#engines 
elsif(cur_n1_l < 54.5 or cur_n1_r < 54.5)  {setprop("/instrumentation/annunciator/master-caution",1);}
else {setprop("/instrumentation/annunciator/master-caution",0);};

if(!getprop("/sim/model/Boeing-787-8/start-engines") and lengine_running) {
 setprop("/controls/engines/engine/cutoff",1);
}

if(!getprop("/sim/model/Boeing-787-8/start-engines") and rengine_running) {
 setprop("/controls/engines/engine[1]/cutoff",1);
}

if(!getprop("/controls/engines/engine/cutoff") and lengine_running){
    setprop("sim/multiplay/generic/float[13]",getprop("/engines/engine/n1"));
    setprop("/sim/model/Boeing-787-8/n2[0]",getprop("/engines/engine/n2"));
    setprop("/sim/model/Boeing-787-8/egt[0]",getprop("/engines/engine[0]/egt-degf"));
}else{
    setprop("controls/engines/engine/throttle",0);
    interpolate("sim/multiplay/generic/float[13]",0,10);
    interpolate("/sim/model/Boeing-787-8/n2[0]",0,10);
    interpolate("/sim/model/Boeing-787-8/egt[0]",0,10);
    if(getprop("sim/multiplay/generic/float[13]") < 5.0){
        lengine_running  = 0;
    }
}

if(!getprop("/controls/engines/engine[1]/cutoff") and rengine_running){
    setprop("sim/multiplay/generic/float[14]",getprop("/engines/engine[1]/n1"));
    setprop("/sim/model/Boeing-787-8/n2[1]",getprop("/engines/engine[1]/n2"));
    setprop("/sim/model/Boeing-787-8/egt[1]",getprop("/engines/engine[1]/egt-degf"));
}else{
    setprop("/controls/engines/engine[1]/throttle",0);
    interpolate("sim/multiplay/generic/float[14]",0,10);
    interpolate("/sim/model/Boeing-787-8/n2[1]",0,10);
    interpolate("/sim/model/Boeing-787-8/egt[1]",0,10);
    if(getprop("sim/multiplay/generic/float[14]") < 5.0){
        rengine_running  = 0;
    }
}

if(getprop("/sim/model/Boeing-787-8/start-cycle[0]") and (rengine_running or apu_running or (getprop("sim/multiplay/generic/float[13]") > 35.0))){
    interpolate("sim/multiplay/generic/float[13]",56.0,10);
    interpolate("/sim/model/Boeing-787-8/n2[0]",70.0,10);
    interpolate("/sim/model/Boeing-787-8/egt[0]",60.0,10);
    if(getprop("sim/multiplay/generic/float[13]") > 55.0) {
        setprop("/sim/model/Boeing-787-8/start-cycle[0]",0);
        if(getprop("/systems/electrical/outputs/eec-Lbus") > 12.0) {
         setprop("/controls/engines/engine[0]/cutoff",0);
         lengine_running  = 1;
        };
    }
}

if(getprop("/sim/model/Boeing-787-8/start-cycle[1]") and (lengine_running or apu_running or (getprop("sim/multiplay/generic/float[14]") > 35.0))) {
    interpolate("sim/multiplay/generic/float[14]",56.0,10);
    interpolate("/sim/model/Boeing-787-8/n2[1]",70.0,10);
    interpolate("/sim/model/Boeing-787-8/egt[1]",60.0,10);
    if(getprop("sim/multiplay/generic/float[14]") > 55.0) {
        setprop("/sim/model/Boeing-787-8/start-cycle[1]",0);
        if(getprop("/systems/electrical/outputs/eec-Rbus") > 12.0) {
         setprop("/controls/engines/engine[1]/cutoff",0);
         rengine_running  = 1;
        };
    }
}

#if(getprop("/sim/model/Boeing-787-8/start-cycle[0]") and !apu_running) {setprop("/sim/model/Boeing-787-8/start-cycle[0]",0);};
#if(getprop("/sim/model/Boeing-787-8/start-cycle[1]") and !apu_running) {setprop("/sim/model/Boeing-787-8/start-cycle[1]",0);};

eecL = getprop("/systems/electrical/outputs/eec-Lbus");
if(eecL==nil) {eecL=0;};
eecR = getprop("/systems/electrical/outputs/eec-Rbus");
if(eecR==nil) {eecR=0;};
if(eecL < 12.0) {setprop("/controls/engines/engine[0]/cutoff",1);};
if(eecR < 12.0) {setprop("/controls/engines/engine[1]/cutoff",1);};

#APU control
if(!getprop("/controls/APU/off-start-run") and apu_running) {
 setprop("/controls/engines/engine[2]/cutoff",1);
};
if(!getprop("/controls/engines/engine[2]/cutoff")){
    setprop("/sim/model/Boeing-787-8/apu-n1",getprop("/engines/engine[2]/n1"));
    setprop("/sim/model/Boeing-787-8/apu-n2",getprop("/engines/engine[2]/n2"));
    setprop("/sim/model/Boeing-787-8/apu-egt",getprop("/engines/engine[2]/egt-degf"));
}else{
    setprop("controls/engines/engine[2]/throttle",0);
    interpolate("/sim/model/Boeing-787-8/apu-n1",0,10);
    interpolate("/sim/model/Boeing-787-8/apu-n2",0,10);
    interpolate("/sim/model/Boeing-787-8/apu-egt",0,10);
    if(getprop("/sim/model/Boeing-787-8/apu-n1") < 50.0){
        apu_running  = 0;
    }
}
if(getprop("/sim/model/Boeing-787-8/apu-start")) {
    interpolate("/sim/model/Boeing-787-8/apu-n1",80.0,4);
    interpolate("/sim/model/Boeing-787-8/apu-n2",85.0,4);
    interpolate("/sim/model/Boeing-787-8/apu-egt",350.0,4);
    if(getprop("/sim/model/Boeing-787-8/apu-n1") > 79.8){
        setprop("/sim/model/Boeing-787-8/apu-start",0);
        if(getprop("/systems/electrical/outputs/apu-bus") > 12.0) {
         setprop("/controls/engines/engine[2]/cutoff",0);
         setprop("/controls/APU/off-start-run",2);
         apu_running  = 1;
        }
        else {setprop("/controls/APU/off-start-run",0);};
    }
}
if(getprop("/controls/APU/off-start-run")==1 and getprop("/systems/electrical/outputs/starter")>20) {
  if(!getprop("/sim/model/Boeing-787-8/apu-start")) {
    if(!getprop("/systems/electrical/apu-test")) {setprop("/systems/electrical/apu-test",1);}
    interpolate("/systems/electrical/apu-test",0,0.2);
    if(getprop("/systems/electrical/apu-test")<0.1) {setprop("/sim/model/Boeing-787-8/apu-start",1);};
  }
}
if(getprop("/controls/APU/off-start-run")==1 and getprop("/systems/electrical/outputs/starter")<20) {
 setprop("/controls/APU/off-start-run",0);
};
if(apu_running) {setprop("/controls/engines/engine[2]/throttle",1);}
else {setprop("/controls/engines/engine[2]/throttle",0);};

#gpws only audible in cockpit
if(getprop("/sim/current-view/cockpit") == 1) {
 setprop("/instrumentation/mk-viii/speaker/volume",.4);
}
if(getprop("/sim/current-view/cockpit") == 0) {
 setprop("/instrumentation/mk-viii/speaker/volume",0);
}

setprop("sim/multiplay/generic/float[0]",getprop("gear/gear[0]/compression-m"));
setprop("sim/multiplay/generic/float[1]",getprop("gear/gear[1]/compression-m"));
setprop("sim/multiplay/generic/float[2]",getprop("gear/gear[2]/compression-m"));
setprop("sim/multiplay/generic/int[0]",getprop("sim/model/Boeing-787-8/lighting/beacon/state"));
setprop("sim/multiplay/generic/float[15]",getprop("accelerations/pilot-g"));

if(getprop("/gear/gear[4]/wow") == 1) {
 rrcomp=getprop("/gear/gear[4]/compression-m");
 rfcomp=getprop("/gear/gear[2]/compression-m");
 rcomp=((rrcomp - rfcomp) * 80);
 if(rcomp > 20) {
  aoa=getprop("orientation/pitch-deg");
  rcomp=(aoa + 20);
 }
 setprop("sim/multiplay/generic/float[4]",rcomp);
}

if(getprop("/gear/gear[3]/wow") == 1) {
 lrcomp=getprop("/gear/gear[3]/compression-m");
 lfcomp=getprop("/gear/gear[1]/compression-m");
 lcomp=((lrcomp - lfcomp) * 80);
 if(lcomp > 20) {
  aoa=getprop("orientation/pitch-deg");
  lcomp=(aoa + 20);
 }
 setprop("sim/multiplay/generic/float[3]",lcomp);
}


settimer(update_systems,0);
}
settimer(update_systems,0);

setlistener("/sim/signals/fdm-initialized", func {
 setprop("/sim/sound/Ovolume", 0.5);
 setprop("/sim/sound/Ivolume", 0.25);
 pph1=getprop("/engines/engine[0]/fuel-flow-gph");
 if(pph1 == nil){pph1 = 0.0};
 pph2=getprop("/engines/engine[1]/fuel-flow-gph");
 if(pph2 == nil){pph2 = 0.0};
 pph3=getprop("/engines/engine[2]/fuel-flow-gph");
 if(pph3 == nil){pph3 = 0.0};
 setprop("engines/engine[0]/fuel-flow_pph",pph1* fuel_density);
 setprop("engines/engine[1]/fuel-flow_pph",pph2* fuel_density);
 setprop("engines/engine[2]/fuel-flow_pph",pph3* fuel_density);
 setprop("/instrumentation/efis/pfd-left-switch",0);
 setprop("/instrumentation/efis/pfd-right-switch",0);
});

setlistener("/instrumentation/efis/pfd-left-switch", func {
 pos = getprop("/instrumentation/efis/pfd-left-switch");
 right = getprop("/instrumentation/efis/pfd-right-switch");
 if(pos==-1) {#VOR-L
  setprop("/instrumentation/adf/ident-audible",0);
  setprop("/instrumentation/adf/volume-norm",0);
  setprop("/instrumentation/nav/volume",0.25);
  setprop("/instrumentation/nav/audio-btn",1);
  setprop("/instrumentation/nav[1]/volume",0);
  setprop("/instrumentation/nav[1]/audio-btn",0);
 }
 elsif(pos==0) {#OFF-L
  setprop("/instrumentation/adf/ident-audible",0);
  setprop("/instrumentation/adf/volume-norm",0);
  setprop("/instrumentation/nav/volume",0);
  setprop("/instrumentation/nav/audio-btn",0);
  if(right==-1){#VOR-R
   setprop("/instrumentation/nav[1]/volume",0.25);
   setprop("/instrumentation/nav[1]/audio-btn",1);
  }
  if(right==1){#ADF-R
   setprop("/instrumentation/adf/ident-audible",1);
   setprop("/instrumentation/adf/volume-norm",0.25);
  };
 }
 elsif(pos==1) {#ADF-L
  setprop("/instrumentation/adf/ident-audible",1);
  setprop("/instrumentation/adf/volume-norm",0.25);
  setprop("/instrumentation/nav/volume",0);
  setprop("/instrumentation/nav/audio-btn",0);
  setprop("/instrumentation/nav[1]/volume",0);
  setprop("/instrumentation/nav[1]/audio-btn",0);
 };
});

setlistener("/instrumentation/efis/pfd-right-switch", func {
 pos = getprop("/instrumentation/efis/pfd-right-switch");
 left = getprop("/instrumentation/efis/pfd-left-switch");
 if(left==0) {
  if(pos==-1) {#VOR-R
   setprop("/instrumentation/nav[1]/volume",0.25);
   setprop("/instrumentation/nav[1]/audio-btn",1);
   setprop("/instrumentation/adf/ident-audible",0);
   setprop("/instrumentation/adf/volume-norm",0);
  }
  elsif(pos==0) {#OFF
   setprop("/instrumentation/adf/ident-audible",0);
   setprop("/instrumentation/adf/volume-norm",0);
   setprop("/instrumentation/nav[1]/volume",0);
   setprop("/instrumentation/nav[1]/audio-btn",0);
  }
  elsif(pos==1) {#ADF-R
   setprop("/instrumentation/adf/ident-audible",1);
   setprop("/instrumentation/adf/volume-norm",0.25);
   setprop("/instrumentation/nav[1]/volume",0);
   setprop("/instrumentation/nav[1]/audio-btn",0);
  };
 };
});

setlistener("instrumentation/nav/radials/target-radial-deg[0]", func {
 hdg = getprop("instrumentation/nav/radials/target-radial-deg[0]");
 mvd = getprop("/environment/magnetic-variation-deg");
 if(mvd == nil) mvd = 0;
 hdg -= mvd;
 setprop("instrumentation/nav/radials/mag-target-radial-deg[0]",hdg)
});

setlistener("instrumentation/nav[1]/radials/target-radial-deg[0]", func {
 hdg = getprop("instrumentation/nav[1]/radials/target-radial-deg[0]");
 mvd = getprop("/environment/magnetic-variation-deg");
 if(mvd == nil) mvd = 0;
 hdg -= mvd;
 setprop("instrumentation/nav[1]/radials/mag-target-radial-deg[0]",hdg)
});

setlistener("instrumentation/nav/heading-deg", func {
 nav_hdg = getprop("instrumentation/nav/heading-deg");
 hdg = getprop("/orientation/heading-deg");
 hdg -= nav_hdg;
 if(hdg < 0) {hdg += 360;};
 setprop("instrumentation/nav/bearing-deg",hdg);
});

setlistener("instrumentation/nav[1]/heading-deg", func {
 nav_hdg = getprop("instrumentation/nav[1]/heading-deg");
 hdg = getprop("/orientation/heading-deg");
 if(hdg == nil) hdg=0;
 nav_hdg -= hdg;
 if(nav_hdg < 0) {nav_hdg += 360;};
 setprop("instrumentation/nav[1]/bearing-deg",nav_hdg);
});

setlistener("/instrumentation/adf/ident", func {
 wpid = getprop("/instrumentation/adf/ident");
 if(wpid == nil or wpid == 0) {return;}
 if(size(wpid)==0) {return;};
 for(i=1;i<6;i=i+1) {
   setprop("/instrumentation/adf/ident-asc"~i~"", 0);
 }
 for(i=0;i<size(wpid);i=i+1) {
   setprop("/instrumentation/adf/ident-asc"~(i+1)~"", wpid[i]);
 }
});