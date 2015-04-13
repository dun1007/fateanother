// Created by Crowbar 0.24.0.0

$modelname "heroes/tidehunter/tidehuntertentacle.mdl"

$bodygroup "default"
{
	studio "tidehuntertentacle_reference.smd"
}


$cdmaterials ""

$surfaceprop "default"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "root" "" 0 0 0 0 -1.570796 -1.570796 0 0 0 0 0 0
// $definebone "tentacle0_0" "root" 3.188409 0 17.677872 3.141593 -1.223739 0 0 0 0 0 0 0
// $definebone "tentacle0_1" "tentacle0_0" 18.664785 -0.000001 0.000001 0 -0.328804 0 0 0 0 0 0 0
// $definebone "tentacle0_2" "tentacle0_1" 18.667629 -0.000001 -0.000001 0 -0.14605 0 0 0 0 0 0 0
// $definebone "tentacle0_3" "tentacle0_2" 18.672371 -0.000002 -0.000002 0 0.449356 0 0 0 0 0 0 0
// $definebone "tentacle0_4" "tentacle0_3" 18.678993 -0.000001 0.000002 0 0.709858 0 0 0 0 0 0 0
// $definebone "tentacle0_5" "tentacle0_4" 18.687519 -0.000001 0 0 0.31197 0 0 0 0 0 0 0
// $definebone "tentacle0_6" "tentacle0_5" 18.697906 -0.000001 0 0 0.133846 0 0 0 0 0 0 0
// $definebone "tentacle0_7" "tentacle0_6" 18.710178 -0.000001 0.000008 0 -0.294166 0 0 0 0 0 0 0
// $definebone "tentacle0_8" "tentacle0_7" 19.313622 -0.000001 -0.000008 0 -0.568185 0 0 0 0 0 0 0
// $definebone "tentacle0_9" "tentacle0_8" 16.810654 -0.000001 -0.000003 0 -0.455681 0 0 0 0 0 0 0
// $definebone "tentacle0_10" "tentacle0_9" 17.330048 -0.000001 0 0 -0.850722 0 0 0 0 0 0 0
// $definebone "tentacle0_11" "tentacle0_10" 19.541779 -0.000001 0.000015 0 -1.135595 0 0 0 0 0 0 0




$sequence "BindPose" "tidehuntertentacle_anims\BindPose.smd" {
	fps 30
}

$sequence "spike_9frame" "tidehuntertentacle_anims\spike_9frame.smd" {
	fps 30
}

$sequence "spike_15frame" "tidehuntertentacle_anims\spike_15frame.smd" {
	fps 30
}


$keyvalues
{
}
